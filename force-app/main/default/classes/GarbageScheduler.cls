public without sharing class GarbageScheduler implements System.Schedulable {    
    @TestVisible static IQueryFactory queryEngine = new SoqlQuery.Factory(); 
    @TestVisible static final Integer FLEX_QUEUE_LIMIT = 100; 
    
    @TestVisible List<Garbage_Collection_Job__mdt> activeJobs = this.getActiveJobs();
    @TestVisible List<Garbage_Collection_Job__mdt> processedJobs = new List<Garbage_Collection_Job__mdt>();
    @TestVisible List<Garbage_Collection_Job__mdt> skippedJobs = new List<Garbage_Collection_Job__mdt>();
    @TestVisible Integer flexQueueSize = this.getFlexQueueSize(); 
    
    public void execute(System.SchedulableContext context) {
        for (Garbage_Collection_Job__mdt jobMdt : this.activeJobs) {
            if (FLEX_QUEUE_LIMIT > flexQueueSize) {
                GarbageCollector batchJob = GarbageCollector.getInstance(jobMdt).runBatch();
                this.logNewBatch(jobMdt, batchJob.jobId);
                processedJobs.add(jobMdt);
                flexQueueSize++; 
            } else {
                this.skippedJobs.add(jobMdt); 
            }
        }
        this.logSkippedJobs();
        Logger.publish(); 
    }

    private void logNewBatch(Garbage_Collection_Job__mdt jobMdt, Id batchId) {
        final String message = 
            jobMdt.SObjectType__c + ' GarbageCollector job created\n' + 
            'Job Name: ' + jobMdt.DeveloperName + '/n' + 
            'Job Id: ' + batchId;
        Logger.log(LoggingLevel.INFO, message);
    }

    private void logSkippedJobs() {
        if (this.skippedJobs?.isEmpty() == false) {
            final String message = 
                'Could not execute ' + this.skippedJobs?.size() + ' GarbageCollection jobs, ' + 
                'because number of jobs in the Apex Flex Queue (' + FLEX_QUEUE_LIMIT + ').\n' + 
                'Please retry these jobs manually, or wait until the next scheduled run.\n' + 
                'Skipped Jobs: ' + JSON.serializePretty(this.skippedJobs); 
            Logger.log(LoggingLevel.ERROR, message); 
        }
    }

    private List<Garbage_Collection_Job__mdt> getActiveJobs() {
        IQuery query = GarbageScheduler.queryEngine
            .newQuery(Garbage_Collection_Job__mdt.SObjectType)
            .addFields(new List<SObjectField>{
                Garbage_Collection_Job__mdt.Apex_Class_Name__c,
                Garbage_Collection_Job__mdt.Batch_Size__c,
                Garbage_Collection_Job__mdt.DeveloperName,
                Garbage_Collection_Job__mdt.SOQL_Filter__c
            }).addFilters(new QueryFilter(
                Garbage_Collection_Job__mdt.Active__c,
                QueryFilter.Operator.EQUALS,
                true
            )).setOrderBy(new QuerySort(
                Garbage_Collection_Job__mdt.Priority__c,
                QuerySort.Order.ASCENDING
            ));
        return (List<Garbage_Collection_Job__mdt>) query.run();
    }

    private Integer getFlexQueueSize() {
        IQuery query = GarbageScheduler.queryEngine
            .newQuery(AsyncApexJob.SObjectType)
            .addFilters(new QueryFilter(
                AsyncApexJob.Status,
                QueryFilter.Operator.IN_COLLECTION,
                new List<String>{'Holding', 'Pending', 'Processing'}
            ));
        return query.run()?.size(); 
    }
}