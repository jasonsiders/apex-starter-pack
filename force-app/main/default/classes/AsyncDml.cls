global abstract inherited sharing class AsyncDml {
	static Container container = new Container();

	global static void addRequest(Request request) {
		container?.addRequest(request);
	}

	global static Id runJob() {
		Id jobId;
		Boolean hasQueueableCapacity = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
		if (hasQueueableCapacity) {
			jobId = System.enqueueJob(container);
		} else {
			// If the job can't be done via queueable, try to process the requests synchronously
			final String message = 'Queueable limits reached. Processing {0} DML operations synchronously.';
			System.debug(LoggingLevel.WARN, AsyncDml.class + ': ' + message);
			container?.execute(null);
		}
		container?.reset();
		return jobId;
	}

	// **** INNER **** //
	global virtual class Request {
		public Dml.Operation operation { get; private set; }
		public List<SObject> records { get; private set; }
		public FieldRef externalIdField { get; private set; }
		public Boolean allOrNone { get; private set; }
		public Boolean skipTriggers { get; private set; }

		global Request(Dml.Operation operation, List<SObject> records) {
			this.operation = operation;
			this.records = records;
			this.externalIdField(null);
			this.allOrNone(true);
			this.skipTriggers(false);
		}

		global Request(Dml.Operation operation, SObject record) {
			this(operation, new List<SObject>{ record });
		}

		global Request externalIdField(SObjectField externalIdField) {
			if (externalIdField != null) {
				this.externalIdField = new FieldRef(externalIdField);
			}
			return this;
		}

		global Request allOrNone(Boolean allOrNone) {
			this.allOrNone = allOrNone;
			return this;
		}

		global Request skipTriggers(Boolean skipTriggers) {
			this.skipTriggers = skipTriggers;
			return this;
		}

		global virtual List<DmlResult> doDml() {
			return DB.Dml.doDml(this.operation, this.records, this.externalIdField?.toSchemaType(), this.allOrNone);
		}

		protected Request() {
			// Needed for inheritance
		}

		public List<DmlResult> process() {
			try {
				return (this.skipTriggers == true) ? this.doDmlWithoutTriggers() : this.doDml();
			} catch (Exception error) {
				System.debug(
					LoggingLevel.ERROR,
					AsyncDml.class +
					': Async operation failed: ' +
					error +
					'\n' +
					error?.getStackTraceString()
				);
				return null;
			}
		}

		private List<DmlResult> doDmlWithoutTriggers() {
			TriggerHandler.disable();
			List<DmlResult> results = this.doDml();
			TriggerHandler.enable();
			return results;
		}
	}

	global class Conversion extends Request {
		// Necessary since Database.LeadConvert objects cannot be deserialized,
		// which prevents it from being used as a member of a Queueable instance
		List<SerializableLeadConvert> wrappers;

		global Conversion(List<Database.LeadConvert> leadConverts) {
			this.wrappers = SerializableLeadConvert.wrap(leadConverts);
		}

		global Conversion(Database.LeadConvert leadConvert) {
			this(new List<Database.LeadConvert>{ leadConvert });
		}

		public override List<DmlResult> doDml() {
			List<Database.LeadConvert> leadConverts = SerializableLeadConvert.unwrap(this.wrappers);
			return DB.Dml.doConvert(leadConverts);
		}
	}

	private class Container implements System.Queueable {
		List<Request> requests = new List<Request>();

		private void addRequest(Request request) {
			this.requests?.add(request);
		}

		public void execute(System.QueueableContext context) {
			for (Request request : this.requests) {
				request?.process();
			}
		}

		private void reset() {
			this.requests?.clear();
		}
	}
}
