@IsTest 
private class Logger_Test {
    @IsTest 
    static void shouldUseStaticConstructor() {
        System.assertEquals(Log_Setting__c.getInstance(UserInfo.getUserId()), Logger.settings, 'Wrong settings'); 
        System.assertEquals(EnumUtils.valueOf(Logger.settings?.Level__c, LoggingLevel.class), Logger.threshold, 'Logging Level not set');
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Not an empty list');
    }

    @IsTest 
    static void shouldGenerateLogEvent() {
        setUpTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        final String logMessage = 'Testing 123';

        Test.startTest();
        Logger.log(LoggingLevel.FINEST, logMessage);
        Test.stopTest();

        System.assertEquals(1, Logger.pendingEvents?.size(), 'Event not generated'); 
        Log_Event__e event = Logger.pendingEvents[0];
        System.assertEquals(logMessage, event.Message__c, 'Wrong message');
        System.assertEquals(UserInfo.getUserId(), event.Running_User__c, 'Wrong running user');
        System.assertEquals('FINEST', event.Severity__c, 'Wrong severity');
        System.assertEquals(String.valueOf(Request.getCurrent().getQuiddity()), event.Source__c, 'Wrong source'); 
        System.assertNotEquals(null, event.Stack_Trace__c, 'No stack trace');
        System.assertNotEquals(null, event.Transaction_Id__c, 'No Transaction Id');
    } 

    @IsTest 
    static void shouldGenerateAndPublishLogEvent() {
        setUpTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 

        Test.startTest();
        // Setting publishImmediately flag to 'true' will publish the log
        Logger.logAndPublish(LoggingLevel.FINEST, 'Testing 123');
        Test.stopTest();

        System.assertEquals(1, Dml.Published?.getAll()?.size(), 'Event not published');
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Event still pending');
    }

    @IsTest 
    static void shouldPublishUntilMaxPublishCallsMet() {
        setUpTestLogger(LoggingLevel.FINEST, true);

        Test.startTest();
        for (Integer i = 0; i < Logger.MAX_PUBLISH_CALLS; i++) {
            Logger.logAndPublish(LoggingLevel.FINEST, 'Testing 123');
        }
        System.assertEquals(Logger.MAX_PUBLISH_CALLS, Dml.Published.getAll()?.size(), 'Wrong number of events published');
        System.assertEquals(Logger.MAX_PUBLISH_CALLS, Limits.getPublishImmediateDml(), 'Wrong number of publish calls');
        // Now that we've hit our limit, subsequent calls to publish() will not do anything
        Logger.log(LoggingLevel.FINEST, 'Testing 123');
        Logger.publish(); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Wrong # of pending events');
        System.assertEquals(Logger.MAX_PUBLISH_CALLS, Dml.Published.getAll()?.size(), 'Wrong # of published events');
        Test.stopTest();
    }

    @IsTest 
    static void shouldNotLogIfDisabled() {
        // If disabled, will not log
        setUpTestLogger(LoggingLevel.ERROR, false);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Logger.log(LoggingLevel.ERROR, 'Test Message'); 
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged when disabled');
        // If null, should default to false, and will not throw an error
        Logger.settings = null; 
        Logger.log(LoggingLevel.ERROR, 'Test Message'); 
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged when null');
        // If enabled, will log
        setUpTestLogger(LoggingLevel.ERROR, true);
        Logger.log(LoggingLevel.ERROR, 'Test Message');
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not logged when enabled');
    }

    @IsTest 
    static void shouldOnlyLogForAppropriateLogLevel() {
        setUpTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        LoggingLevel logLevel = LoggingLevel.FINEST;
        String logMessage = 'Testing 123';
        // FINEST <= FINEST, so this will log
        logLevel = LoggingLevel.FINEST; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // FINER <= FINEST, so this will log
        logLevel = LoggingLevel.FINER; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // FINE <= FINEST, so this will log
        logLevel = LoggingLevel.FINE; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // DEBUG <= FINEST, so this will log
        logLevel = LoggingLevel.DEBUG; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // INFO <= FINEST, so this will log
        logLevel = LoggingLevel.INFO; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // WARN <= FINEST, so this will log
        logLevel = LoggingLevel.WARN; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // ERROR <= FINEST, so this will log
        logLevel = LoggingLevel.ERROR; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Not Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // NONE is not <= FINEST, so this will NOT log
        logLevel = LoggingLevel.NONE; 
        Logger.log(logLevel, logMessage); 
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
        // NONE <= NONE, but will never log for NONE
        Logger.settings.Level__c = String.valueOf(LoggingLevel.NONE);
        Logger.log(logLevel, logMessage); 
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
    }
    
    @IsTest 
    static void shouldNotLogIfNullLoggingLevel() {
        // If one or both are null, will not log
        setUpTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        LoggingLevel logLevel;
        String logMessage = 'Testing 123';
        Exception error; 
        // Both are null;
        logLevel = null; 
        Logger.settings.Level__c = null;
        try { 
            Logger.log(logLevel, logMessage); 
        } catch (Exception caughtError) {
            error = caughtError;
        }
        System.assertNotEquals(null, error, 'An error was not thrown for a null LoggingLevel');
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        error = null; 
        Logger.clear();
        // Only LoggingLevel is null
        Logger.settings.Level__c = String.valueOf(LoggingLevel.ERROR);
        try {
            Logger.log(logLevel, logMessage); 
        } catch (Exception caughtError) {
            error = caughtError;
        }
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        System.assertNotEquals(null, error, 'An error was not thrown for a null logging level');
        error = null; 
        Logger.clear();
        // Just threshold is null
        logLevel = LoggingLevel.ERROR;
        Logger.settings.Level__c = null; 
        try {
            Logger.log(logLevel, logMessage); 
        } catch (Exception caughtError) {
            System.assert(false, 'An error was thrown for a non-null LoggingLevel: ' + caughtError);
        }
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Logged: Threshold: ' + Logger.threshold + ', LogLevel: ' + logLevel);
        Logger.clear();
    }

    @IsTest 
    static void shouldLogAtThresholdLevel() {
        setupTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        String message = 'Testing 123';

        Test.startTest();
        Logger.log(message); 
        Test.stopTest();

        System.assertEquals(1, Logger.pendingEvents?.size(), 'Wrong # of pending events');
        System.assertEquals(message, Logger.pendingEvents[0].Message__c, 'Wrong message');
    }
    
    @IsTest 
    static void shouldLogAndPublishAtThresholdLevel() {
        setupTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 

        Test.startTest();
        Logger.logAndPublish('Testing 123'); 
        Test.stopTest(); 

        System.assertEquals(1, Dml.Published?.getAll()?.size(), 'Event not published');
        System.assertEquals(0, Logger.pendingEvents?.size(), 'Event still pending');
    }

    @IsTest 
    static void shouldNotGenerateStackTraceFromSelf() {
        // The Log Event's stack trace field should start 
        // from where the Logger class is called from;
        // not the Logger class itself
        setUpTestLogger(LoggingLevel.FINEST, true); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        // Try logging from directly in the test class
        Logger.log(LoggingLevel.FINEST, 'Test Message');
        System.assertEquals(1, Logger.pendingEvents?.size(), 'Did not log');
        Log_Event__e event = Logger.pendingEvents[0]; 
        System.assert(event.Stack_Trace__c?.startsWithIgnoreCase('Class.Logger_Test.'), 'Expected Stack Trace to start with "Class.Logger_Test." - Actual: "' + event.Stack_Trace__c + '"');
        System.assert(event.Stack_Trace__c?.contains('Class.Logger.') == false, 'Contains a stack trace line from the logger class: ' + event.Stack_Trace__c);
        // Try logging from another class
        new MyClass().logSomething(); 
        System.assertEquals(2, Logger.pendingEvents?.size(), 'Did not log from child class');
        event = Logger.pendingEvents[1]; 
        System.assert(event.Stack_Trace__c?.startsWithIgnoreCase('Class.Logger_Test.MyClass.'), 'Expected Stack Trace to start with "Class.Logger_Test.MyClass." - Actual: "' + event.Stack_Trace__c + '"');
        System.assert(event.Stack_Trace__c?.contains('Class.Logger.') == false, 'Contains a stack trace line from the logger class: ' + event.Stack_Trace__c);
    }

    @IsTest 
    static void shouldLogManyEventsFromLightning() {
        // This method is designed to be used by lightning components.
        setUpTestLogger(LoggingLevel.FINEST, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        List<Logger.Input> inputs = generateTestInputs();
        
        Test.startTest();
        Logger.logFromLightning(inputs);
        Test.stopTest();

        System.assertEquals(inputs?.size(), Dml.Published?.getAll()?.size(), 'Wrong # of published events');
    }

    @IsTest 
    static void shouldLogSingleEventFromLightning() {
        // This method is designed to be used by lightning components.
        setUpTestLogger(LoggingLevel.FINEST, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Logger.Input input = generateTestInputs()[0];
        
        Test.startTest();
        Logger.logFromLightning(input);
        Test.stopTest();

        System.assertEquals(1, Dml.Published?.getAll()?.size(), 'Wrong # of published events');
    }

    @IsTest 
    static void shouldLogManyEventsFromApi() {
        // This method is designed to be used by external API resources
        setUpTestLogger(LoggingLevel.FINEST, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        List<Logger.Input> inputs = generateTestInputs();
        
        Test.startTest();
        Logger.logFromApi(inputs);
        Test.stopTest();

        System.assertEquals(inputs?.size(), Dml.Published?.getAll()?.size(), 'Wrong # of published events');
    }

    @IsTest 
    static void shouldLogSingleEventsromApi() {
        // This method is designed to be used by external API resources
        // Unlike logFromLightning(), can't overload to allow single/multiple inputs,
        // since there can only be one @Http* method of each type per class
        setUpTestLogger(LoggingLevel.FINEST, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Logger.Input input = generateTestInputs()[0];
        
        Test.startTest();
        Logger.logFromApi(new List<Logger.Input>{input});
        Test.stopTest();

        System.assertEquals(1, Dml.Published?.getAll()?.size(), 'Wrong # of published events');
    }

    @IsTest 
    static void shouldLogManyEventsFromFlow() {
        // This method is designed to be used by Flows
        // Because of how Flow is bulkified, callers will use this action one log at a time,
        // but they are always processed in bulk
        setUpTestLogger(LoggingLevel.FINEST, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        List<Logger.Input> inputs = generateTestInputs();
        
        Test.startTest();
        Logger.logFromFlow(inputs);
        Test.stopTest();

        System.assertEquals(inputs?.size(), Dml.Published?.getAll()?.size(), 'Wrong # of published events');
    }

    @IsTest 
    static void shouldLogSingleEventFromFlow() {
        // This method is designed to be used by Flows
        // Because of how Flow is bulkified, callers will use this action one log at a time,
        // but they are always processed in bulk
        setUpTestLogger(LoggingLevel.FINEST, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Logger.Input input = generateTestInputs()[0];
        
        Test.startTest();
        Logger.logFromFlow(new List<Logger.Input>{input});
        Test.stopTest();

        System.assertEquals(1, Dml.Published?.getAll()?.size(), 'Wrong # of published events');
    }

    @IsTest 
    static void shouldLogExceptions() {
        setUpTestLogger(LoggingLevel.ERROR, true);
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
        
        Test.startTest();
        Exception error = new CustomException();
        Logger.logException(error); 
        Test.stopTest();

        List<Log_Event__e> logEvents = (List<Log_Event__e>) Dml.Published.getAll(); 
        System.assertEquals(1, logEvents.size(), 'Wrong # of published events'); 
        Log_Event__e event = logEvents[0];
        String expected = error?.getTypeName() + ': ' + error.getMessage() + '\n' + error.getStackTraceString();
        System.assertEquals(expected, event.Message__c, 'Wrong log message');
    }

    // **** HELPER **** // 
    private static void setUpTestLogger(LoggingLevel level, Boolean enabled) {
        Logger.settings = new Log_Setting__c(
            Enabled__c = enabled,
            Level__c = String.valueOf(level)
        );
    }

    private static List<Logger.Input> generateTestInputs() {
        List<Logger.Input> inputs = new List<Logger.Input>();
        for (Integer i = 0; i < 200; i++) {
            Logger.Input input = new Logger.Input(); 
            input.loggingLevel = String.valueOf(LoggingLevel.ERROR);
            input.message = 'Test Message #' + Crypto.getRandomInteger();
            inputs.add(input);
        }
        return inputs;
    }

    private class MyClass {
        private void logSomething() {
            Logger.log(LoggingLevel.FINEST, 'Test Message');
        }
    }

    private class CustomException extends Exception {}
}