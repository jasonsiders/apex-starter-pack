public virtual inherited sharing class AsyncDml implements System.Queueable {
	static AsyncDml Instance = new AsyncDml();
	List<Request> requests = new List<Request>();

	@TestVisible
	private AsyncDml() {
		// Note: Singleton employed here to bulkify async requests as much as possible
	}

	public static void addRequest(Request request) {
		AsyncDml.Instance?.requests?.add(request);
	}

	public static Id runJob() {
		Id jobId;
		if (LimitUtils.isQueueableSafe()) {
			jobId = System.enqueueJob(AsyncDml.Instance);
			AsyncDml.Instance?.requests?.clear();
		} else {
			// If the job can't be done via queueable, try to process the requests synchronously
			final String message = 'Queueable limits reached. Processing {0} DML operations synchronously.';
			System.debug(LoggingLevel.WARN, AsyncDml.class + ': ' + message);
			AsyncDml.Instance?.execute(null);
		}
		return jobId;
	}

	// **** QUEUEABLE **** //
	public void execute(System.QueueableContext context) {
		for (Request request : this.requests) {
			request.process();
		}
	}

	// **** INNER **** //
	public virtual class Request {
		public Dml.Operation operation { get; private set; }
		public List<SObject> records { get; private set; }
		public FieldRef externalIdField { get; private set; }
		public Boolean allOrNone { get; private set; }
		public Boolean skipTriggers { get; private set; }

		public Request(
			Dml.Operation operation,
			List<SObject> records
		) {
			this.operation = operation;
			this.records = records;
			this.allOrNone(true); 
			this.skipTriggers(false); 
		}

		public Request(Dml.Operation operation, SObject record) {
			this(operation, new List<SObject>{ record });
		}

		public Request externalIdField(SObjectField externalIdField) {
			this.externalIdField = new FieldRef(externalIdField);
			return this; 
		}

		public Request allOrNone(Boolean allOrNone) {
			this.allOrNone = allOrNone;
			return this; 
		}

		public Request skipTriggers(Boolean skipTriggers) {
			this.skipTriggers = skipTriggers; 
			return this; 
		}

		protected Request() {
			// Needed for inheritance
		}

		public List<DmlResult> process() {
			try {
				return (this.skipTriggers == true) ? this.doDmlWithoutTriggers() : this.doDml();
			} catch (Exception error) {
				System.debug(LoggingLevel.ERROR, AsyncDml.class + ': Async operation failed: ' + error + '\n' + error?.getStackTraceString());
				return null;
			}
		}

		private List<DmlResult> doDmlWithoutTriggers() {
			TriggerHandler.disable();
			List<DmlResult> results = this.doDml();
			TriggerHandler.enable();
			return results;
		}

		protected virtual List<DmlResult> doDml() {
			return DB.Dml.doDml(
				this.operation,
				this.records,
				this.externalIdField?.toSchemaType(),
				this.allOrNone
			);
		}
	}

	public class Conversion extends Request {
		// Database.LeadConvert objects cannot be deserialized/used as a member of a Queueable instance
		List<SerializableLeadConvert> wrappers;

		public Conversion(List<Database.LeadConvert> leadConverts) {
			this.wrappers = SerializableLeadConvert.wrap(leadConverts);
		}

		public Conversion(Database.LeadConvert leadConvert) {
			this(new List<Database.LeadConvert>{ leadConvert });
		}

		public override List<DmlResult> doDml() {
			List<Database.LeadConvert> leadConverts = SerializableLeadConvert.unwrap(this.wrappers);
			return DB.Dml.doConvert(leadConverts);
		}
	}
}
