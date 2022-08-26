@IsTest
private class LogEventHandler_Test {
    @IsTest 
    static void shouldProcessLogEventsFromHandler() {
        LogEventHandler handler = new LogEventHandler(); 
        handler.triggerNew = generateTestEvents();
        handler.operation = System.TriggerOperation.AFTER_INSERT;

        Test.startTest();
        handler.run(); 
        Test.stopTest();

        System.assertEquals(handler.triggerNew?.size(), [SELECT Id FROM Log__c]?.size(), 'Wrong # of Logs');
    }
    
    @IsTest 
    static void shouldProcessLogEventsFromTrigger() {
        List<Log_Event__e> events = generateTestEvents();

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();

        System.assertEquals(events?.size(), [SELECT Id FROM Log__c]?.size(), 'Wrong # of Logs');
    }

    static List<Log_Event__e> generateTestEvents() {
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        Id userId = UserInfo.getUserId();
        System.Request req = System.Request.getCurrent();
        String stack = new System.DmlException()?.getStackTraceString();
        for (Integer i = 0; i < 200; i++) {
            logEvents?.add(new Log_Event__e(
                Apex_Class__c = String.valueOf(LogEventHandler_Test.class),
                Context__c = req.getQuiddity()?.name(),
                Level__c = 'FINEST',
                Logged_At__c = DateTime.now().addSeconds(-5),
                Message__c = 'Test Log #' + (i + 1),
                Running_User__c = userId,
                Sequence__c = (i + 1),
                Stack_Trace__c = stack,
                Transaction_Id__c = req.getRequestId()
            ));
        }
        return logEvents;
    }
}
