public virtual class LimitUtils {
    @TestVisible static System.Quiddity context = System.Request.getCurrent().getQuiddity();
    @TestVisible static Integer numDailyAsyncMethods; 
    @TestVisible static LimitUtils instance = new LimitUtils(); 
    @TestVisible static Integer LIMIT_DAILY_ASYNC_METHODS = 250000;

    protected LimitUtils() {}

    // **** PUBLIC **** // 
    public static Boolean isQueueableSafe() {
        return instance.checkIfQueueableIsSafe(); 
    }

    public static Integer getNumDailyAsyncMethods() {
        // Salesforce imposes a limit on the # of async Apex method executions per a 24-hour period (250k),
        // but the System.Limits class doesn't have a method to check for this
        if (LimitUtils.numDailyAsyncMethods == null) {
            // Note: Lazy-loading prevents unnecessary SOQL
            // Again, if SFDC simply added this to their Limits class, we wouldn't need to worry about this!
            LimitUtils.numDailyAsyncMethods = 0;
            Soql query = DatabaseLayer.QueryEngine.newQuery(AsyncApexJob.SObjectType)
                .selectFields(AsyncApexJob.JobType)
                .groupBy(AsyncApexJob.JobType)
                .selectAggregation(new SoqlAggregation(
                    SoqlAggregation.Function.COUNT, 
                    AsyncApexJob.Id, 
                    'NumJobs'
                )).selectAggregation(new SoqlAggregation(
                    SoqlAggregation.Function.SUM, 
                    AsyncApexJob.JobItemsProcessed, 
                    'NumBatches'
                )).whereFilters(new Filter(
                    AsyncApexJob.CreatedDate, 
                    Filter.GREATER_THAN, 
                    DateTime.now().addDays(-1)
                )).whereFilters(new Filter(
                    AsyncApexJob.JobType, 
                    Filter.IN_COLLECTION, 
                    new List<String>{
                        'Batch Apex',
                        'Future',
                        'Queueable',
                        'Scheduled Apex'
                    }
                ));
            List<AggregateAsyncJobs> results = (List<AggregateAsyncJobs>) query.run(List<AggregateAsyncJobs>.class); 
            for (AggregateAsyncJobs result : results) {
                LimitUtils.numDailyAsyncMethods += result.getNumAsyncMethods();
            }
        }
        return LimitUtils.numDailyAsyncMethods;
    }

    // **** PRIVATE **** //
    @TestVisible
    protected virtual Integer getQueueableJobs() {
        return Limits.getQueueableJobs(); 
    }

    protected virtual Boolean checkIfQueueableIsSafe() {
        Integer numQueueables = this.getQueueableJobs(); 
        // Note: In synchronous context, max 50; but in many other contexts, the limit is much lower (1)
        // Prevent this error: ! "Too many queueable jobs added to the queue: 2"
        List<System.Quiddity> restrictedContexts = new List<System.Quiddity>{
            System.Quiddity.BATCH_APEX, 
            System.Quiddity.BATCH_CHUNK_PARALLEL, 
            System.Quiddity.BATCH_CHUNK_SERIAL, 
            System.Quiddity.FUTURE, 
            System.Quiddity.QUEUEABLE
        };
        Integer maxQueueables = restrictedContexts.contains(LimitUtils.context) ? 1 : Limits.getLimitQueueableJobs();
        return (
            numQueueables < maxQueueables && 
            LimitUtils.getNumDailyAsyncMethods() < LimitUtils.LIMIT_DAILY_ASYNC_METHODS
        );
    }

    // **** INNER **** // 
    private class AggregateAsyncJobs  {
        Decimal numJobs; 
        Decimal numBatches;
        String jobType;

        public Integer getNumAsyncMethods() {
            // Batch Apex use a minimum of 3 method calls towards the limit (
            // (1 start() + 1 finish() + N execute() method calls)
            // All others consume a single method call towards the limit
            Decimal results = (this.jobType == 'Batch Apex') ? (this.numJobs * 2) + this.numBatches: this.numJobs;
            return Integer.valueOf(results);
        }
    }
}
