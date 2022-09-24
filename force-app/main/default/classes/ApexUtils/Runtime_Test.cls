@IsTest 
private class Runtime_Test {
    @IsTest 
    static void shouldReturnExplicitRuntime() {
        Runtime rt = new TestRuntime();
        for (Runtime.Context context : Runtime.Context.values()) {
            rt.setExplicitContext(context); 
            System.assertEquals(context, rt.getRuntimeContext(1000), 'Wrong context returned');
        }   
    }

    @IsTest 
    static void shouldCalculateContext() {
        Runtime rt = new TestRuntime(); 
        Integer numRecords = ASYNC_THRESHOLD - 1;
        Runtime.Context results = rt.getRuntimeContext(numRecords); 
        System.assertEquals(Runtime.Context.REAL_TIME, results, 'Wrong context for ' + numRecords + ' records');
        numRecords = ASYNC_THRESHOLD; 
        results = rt.getRuntimeContext(numRecords); 
        System.assertEquals(Runtime.Context.QUEUEABLE, results, 'Wrong context for ' + numRecords + ' records');
        numRecords = BATCH_THRESHOLD;
        results = rt.getRuntimeContext(numRecords);
        System.assertEquals(Runtime.Context.BATCHAPEX, results, 'Wrong context for ' + numRecords + ' records');
    }
    // **** HELPER **** // 
    static final Integer ASYNC_THRESHOLD = 100; 
    static final Integer BATCH_THRESHOLD = 200; 

    public class TestRuntime extends Runtime {
        public TestRuntime() {
            this.setAsyncThreshold(ASYNC_THRESHOLD);
            this.setBatchThreshold(BATCH_THRESHOLD); 
        }
    }
}
