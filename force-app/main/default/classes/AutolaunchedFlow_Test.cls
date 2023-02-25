@IsTest 
private class AutolaunchedFlow_Test {
    @IsTest 
    static void shouldRunFlow() {
        Flow.Interview expected = null;
        AutolaunchedFlow flow;

        Test.startTest();
        try {
            flow = new Implementation().run();
        } catch (Exception error) {
            System.assert(false, 'An error was thrown: ' + error);
        }
        Test.stopTest();

        // The base implementation will always return null; 
        // A real implementation would return an instance of the corresponding Flow.Interview
        System.assertEquals(expected, flow?.interview, 'Wrong interview');
    }

    @IsTest 
    static void shouldSetInputs() {
        AutolaunchedFlow flow = new Implementation();

        Test.startTest();
        flow.setInput('foo', 'bar');
        Test.stopTest();

        System.assertEquals('bar', flow?.inputs?.get('foo'), 'Input was not set');
    }

    @IsTest 
    static void shouldHandleErrors() {
        // Because there are no flows in the package, we cannot test a "real" flow error
        // Approximate this by returning a mock error; this should be re-cast as a System.FlowException
        String msg = 'This is a mock error';
        ImplementationWithCustomErrorHandling flow = new ImplementationWithCustomErrorHandling(); 
        flow.setError(msg);

        Test.startTest();
        Exception caughtError; 
        try {
            flow.run();
        } catch (System.FlowException error) {
            caughtError = error; 
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
        System.assertEquals(msg, caughtError?.getMessage(), 'Wrong error message');
    }

    // **** INNER **** //
    public virtual class Implementation extends AutolaunchedFlow {
        public override Flow.Interview initInterview() {
            // Note: This package does not contain any flows, and no "standard" flows are reliably included OOTB
            // Returns a new Flow.Interview - in this case, the flow should fail silently
            return null;
        }
    }

    public virtual class ImplementationWithCustomErrorHandling extends Implementation {
        String error; 

        public void setError(String error) {
            // Needed to mock a Flow error
            this.error = error; 
        }  

        public override String getError() {
            return this.error; 
        }
    }
}