@IsTest 
private class LimitUtils_Test {
    @IsTest 
    static void shouldDetermineIfQueueableSafe() {
        MockLimits mockLimits = new MockLimits();
        LimitUtils.instance = mockLimits;
        List<System.Quiddity> restrictedContexts = new List<System.Quiddity>{
            System.Quiddity.BATCH_APEX, 
            System.Quiddity.BATCH_CHUNK_PARALLEL, 
            System.Quiddity.BATCH_CHUNK_SERIAL, 
            System.Quiddity.FUTURE, 
            System.Quiddity.QUEUEABLE
        };
        for (System.Quiddity context : restrictedContexts) {
            LimitUtils.context = context;
            // In these restricted contexts, only 1 queueable call can be made before an error is thrown 
            mockLimits.numQueueableJobs = 0; 
            System.assertEquals(true, LimitUtils.isQueueableSafe(), 'Queueable is not safe in ' + LimitUtils.context + ' with ' + mockLimits.numQueueableJobs + ' queueable calls made');
            mockLimits.numQueueableJobs = 1; 
            System.assertEquals(false, LimitUtils.isQueueableSafe(), 'Queueable is safe in ' + LimitUtils.context + ' with ' + mockLimits.numQueueableJobs + ' queueable calls made');
        }
        // In synchronous contexts, this is primarily governed by the Limits.getLimitQueueableJobs() method
        LimitUtils.context = System.Quiddity.SYNCHRONOUS; 
        mockLimits.numQueueableJobs = Limits.getLimitQueueableJobs() - 1;
        System.assertEquals(true, LimitUtils.isQueueableSafe(), 'Queueuable is not safe in ' + LimitUtils.context + ' with ' + mockLimits.numQueueableJobs + ' queueable calls made');
        mockLimits.numQueueableJobs++; 
        System.assertEquals(false, LimitUtils.isQueueableSafe(), 'Queueable is safe in ' + LimitUtils.context + ' with ' + mockLimits.numQueueableJobs + ' queueable calls made');
        // Else, if num daily async methods is met/exceeded, this will fail
        mockLimits.numQueueableJobs = 0;
        LimitUtils.limitDailyAsyncMethods = 0;
        System.assertEquals(false, LimitUtils.isQueueableSafe(), 'Queueable is safe, but the limit of daily async methods was exceeded');
    }

    @IsTest 
    static void shouldWrapTheLimitsClass() {
        System.assertEquals(Limits.getQueueableJobs(), LimitUtils.instance.getQueueableJobs(), 'Wrong default value');
    } 

    @IsTest 
    static void shouldReturnNumberOfAsyncMethodsToday() {
        Integer baseline = LimitUtils.getNumDailyAsyncMethods();
        // Reset the counter to force the query to run again
        LimitUtils.numDailyAsyncMethods = null;
        Test.startTest();
        // Running a queueable should increase the count by 1
        System.enqueueJob(new ExampleQueueable());
        Test.stopTest();
        System.assertEquals(baseline + 1, LimitUtils.getNumDailyAsyncMethods(), 'Wrong number of daily async methods');
    }   

    // **** HELPER **** // 
    public class ExampleQueueable implements System.Queueable {
        public void execute(System.QueueableContext context) {}
    }

    public class MockLimits extends LimitUtils {
        Integer numQueueableJobs = 0; 

        public override Integer getQueueableJobs() {
            return this.numQueueableJobs; 
        }
    }
}
