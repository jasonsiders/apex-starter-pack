public virtual inherited sharing class AsyncDml implements System.Queueable {
    List<Request> requests = new List<Request>();
    static AsyncDml instance; 

    @TestVisible
    private AsyncDml() {
        // Note: Singleton employed here to bulkify async requests as much as possible
    }

    public static AsyncDml getInstance() {
        instance = (instance != null) ? instance : new AsyncDml(); 
        return instance;
    }

    public AsyncDml addRequest(Request request) {
        this.requests?.add(request); 
        return this; 
    }

    public Id runJob() {
        Id jobId;
        if (LimitUtils.isQueueableSafe()) {
            jobId = System.enqueueJob(this); 
            this.requests.clear(); 
        } else {
            // If the job can't be done via queueable, try to process the requests synchronously
            final String message = 'Queueable limits reached. Processing {0} DML operations synchronously.';
            Logger.logAndPublish(LoggingLevel.WARN, message);
            this.execute(null); 
        }
        return jobId; 
    }

    public void execute(System.QueueableContext context) {
        for (Request request : this.requests) {
            request.process(); 
        }
    }

    public virtual class Request {
        @TestVisible Dml.Operation operation;
        @TestVisible List<SObject> records;
        @TestVisible SObjectField externalIdField;
        @TestVisible Boolean allOrNone = true; 
        @TestVisible Boolean skipTriggers = false;

        public Request(Dml.Operation operation, List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
            this.operation = operation; 
            this.records = records;
            this.externalIdField = externalIdField;
            this.allOrNone = allOrNone; 
        }

        public Request(Dml.Operation operation, List<SObject> records, SObjectField externalIdField) {
            this(operation, records, externalIdField, true); 
        }

        public Request(Dml.Operation operation, List<SObject> records, Boolean allOrNone) {
            this(operation, records, null, allOrNone); 
        }

        public Request(Dml.Operation operation, List<SObject> records) {
            this(operation, records, null, true); 
        }

        public Request(Dml.Operation operation, SObject record, SObjectField externalIdField, Boolean allOrNone) {
            this(operation, new List<SObject>{record}, externalIdField, allOrNone);
        }

        public Request(Dml.Operation operation, SObject record, SObjectField externalIdField) {
            this(operation, new List<SObject>{record}, externalIdField); 
        }

        public Request(Dml.Operation operation, SObject record, Boolean allOrNone) {
            this(operation, new List<SObject>{record}, allOrNone); 
        }

        public Request(Dml.Operation operation, SObject record) {
            this(operation, new List<SObject>{record}); 
        }

        protected Request() {
            // Needed for inheritance
        }

        public Request skipTriggers() {
            this.skipTriggers = true; 
            return this; 
        }

        public List<DmlResult> process() {
            return (this.skipTriggers) ? this.doDmlWithoutTriggers() : this.doDml();
        }

        private List<DmlResult> doDmlWithoutTriggers() {
            TriggerHandler.disable(); 
            List<DmlResult> results = this.doDml(); 
            TriggerHandler.enable(); 
            return results;
        }

        protected virtual List<DmlResult> doDml() {
            return Databaselayer.Dml.doDml(
                this.operation, 
                this.records, 
                this.externalIdField, 
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
            this(new List<Database.LeadConvert>{leadConvert});
        }

        public override List<DmlResult> doDml() {
            List<Database.LeadConvert> leadConverts = SerializableLeadConvert.unwrap(this.wrappers); 
            return Databaselayer.Dml.doConvert(leadConverts); 
        }
    }
}
