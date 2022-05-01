global abstract inherited sharing class GarbageCollector implements Database.Batchable<SObject>, GarbageCollector.IGarbageCollector {
    public Id jobId { get; private set; }
    public Integer batchSize { get; private set; }

    static final String INTERFACE_NAME = String.valueOf(GarbageCollector.IGarbageCollector.class);
    static final Set<String> VALID_APEX_CLASSES = GarbageCollector.getExtendingTypes();
    
    // **** INTERFACE **** //
    public GarbageCollector runBatch() {
        this.jobId = Database.executeBatch(this, this.batchSize);
        return this;
    }

    public GarbageCollector setBatchSize(Decimal batchSize) {
        this.batchSize = Integer.valueOf(batchSize);
        return this;
    }

    public GarbageCollector toConcreteType() {
        return this; 
    }

    // **** BATCHABLE **** //
    public virtual void execute(Database.BatchableContext context, List<SObject> scope) {
        try {
            List<DmlResult> results = DatabaseLayer.DmlEngine.doDelete(scope, false); 
            DmlResult.logErrors(results);
        } catch (Exception caughtError) {
            final String message = 
                'Unexpected error (Job: ' + context?.getJobId() + ')\n' + 
                '"' + caughtError.getMessage() + '"';
            Logger.logAndPublish(LoggingLevel.ERROR, message);
            throw caughtError;
        }
    }

    public virtual void finish(Database.BatchableContext context) {
        IQuery query = DatabaseLayer.QueryEngine.newQuery(AsyncApexJob.SObjectType)
            .addFields(AsyncApexJob.JobItemsProcessed)
            .addFields(AsyncApexJob.TotalJobItems)
            .addFilters(new QueryFilter(
                AsyncApexJob.Id, 
                QueryFilter.Operator.EQUALS, 
                context.getJobId()
            ));
        List<AsyncApexJob> jobDetails = (List<AsyncApexJob>) query.run(); 
        AsyncApexJob currentJob = (jobDetails?.isEmpty() == false) ? jobDetails[0] : null; 
        Integer numCompletedBatches = currentJob?.JobItemsProcessed; 
        Integer numTotalBatches = currentJob?.TotalJobItems; 
        final String template = 'GarbageCollector job {0} completed. {1}/{2} successful batches';
        final String message = String.format(template, new List<String>{
            context.getJobId(),
            String.valueOf(numCompletedBatches),
            String.valueOf(numTotalBatches)
        });
        Logger.logAndPublish(LoggingLevel.INFO, message);
    }

    // **** STATIC **** // 
    public static GarbageCollector getInstance(Garbage_Collection_Job__mdt job) {
        IGarbageCollector instance = GarbageCollector.parseJobMetadata(job); 
        return instance?.toConcreteType().setBatchSize(job.Batch_Size__c);
    }

    private static IGarbageCollector parseJobMetadata(Garbage_Collection_Job__mdt job) {
        if (!String.isBlank(job.SOQL_Filter__c)) {
            return new GarbageCollectorSoql(job);
        } else if (VALID_APEX_CLASSES.contains(job?.Apex_Class_Name__c)) {
            // If the name is contained in the list of implementing types, it can be safely cast
            return (IGarbageCollector) Type.forName(job.Apex_Class_Name__c).newInstance();
        } else {
            throw new InvalidCriteriaException(job); 
        }
    }

    private static Set<String> getExtendingTypes() {
        Set<String> extendingTypeNames = new Set<String>();
        IQuery query = DatabaseLayer.QueryEngine.newQuery(ApexTypeImplementor.SObjectType) 
            .addFields(ApexTypeImplementor.ClassName)
            .addFilters(new QueryFilter(
                ApexTypeImplementor.InterfaceName, 
                QueryFilter.Operator.EQUALS, 
                INTERFACE_NAME
            )).addFilters(new QueryFilter(
                ApexTypeImplementor.IsConcrete, 
                QueryFilter.Operator.EQUALS, 
                true
            ));
        for (ApexTypeImplementor apexClass : (List<ApexTypeImplementor>) query.run()) {
            extendingTypeNames.add(apexClass.ClassName);
        }
        return extendingTypeNames;
    }

    // **** INNER **** //
    public class InvalidCriteriaException extends Exception {
        final String template = 
            'Invalid Garbage Collection Job criteria. ' + 
            'A SOQL Filter, or the name of an Apex Class ' +
            'that implements IGarbageCollectorScope must be provided.\n' + 
            'Garbage Collection Job: {0}';

        private InvalidCriteriaException(Garbage_Collection_Job__mdt job) {
            this.setMessage(String.format(this.template, new List<String>{JSON.serializePretty(job)}));
            Logger.logAndPublish(LoggingLevel.ERROR, this.getMessage()); 
        }
    }

    public interface IGarbageCollector {
        // Note: Apex provides the ApexTypeImplementor object to query types which implement an interface
        // This functionality doesn't currently exist for abstract or virtual types
        // GarbageCollector implements this inner interface to indirectly find types that extend it
        // Unfortunately, the interface must be public to be visible in ApexTypeImplementor queries
        // but you should never directly implement this interface elsewhere;
        // Instead, extend the GarbageCollector class
        GarbageCollector toConcreteType(); 
        GarbageCollector runBatch();
        GarbageCollector setBatchSize(Decimal batchSize);
    }
}