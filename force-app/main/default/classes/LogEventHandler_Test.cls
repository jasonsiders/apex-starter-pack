@IsTest 
private class LogEventHandler_Test extends TriggerHandler {
    @IsTest 
    static void shouldGenerateOneTransactionRecordPerTransactionId() {
        // There is only supposed to be one transaction per platform event trigger,
        // unless events are re-published, or something else goes wrong
        // Just in case, a single Log_Transaction__c will be created per Transaction_Id__c listed in the events
        Set<String> transactionIds = new Set<String>(); 
        List<Log_Event__e> logEvents = new List<Log_Event__e>(); 
        for (Integer i = 0; i < 200; i++) {
            String transactionId = 'Transaction #' + Crypto.getRandomInteger() + '_' + i;
            transactionIds.add(transactionId);
            logEvents.add(new Log_Event__e(
                Message__c = 'Testing 123',
                Running_User__c = UserInfo.getUserId(),
                Severity__c = 'FINEST',
                Transaction_Id__c = transactionId
            ));
        }
        TriggerHandler handler = new LogEventHandler();
        handler.operation = System.TriggerOperation.AFTER_INSERT;
        handler.triggerNew = logEvents; 

        Test.startTest(); 
        handler.run(); 
        Test.stopTest(); 

        List<Log_Transaction__c> logTransactions = getLogTransactions(); 
        System.assertEquals(logEvents?.size(), logTransactions?.size(), 'Wrong # of transactions created'); 
        for (Log_Transaction__c logTransaction : logTransactions) {
            System.assertEquals(1, logTransaction.Logs__r?.size(), 'Wrong # of logs per transaction created'); 
            System.assertEquals(UserInfo.getUserId(), logTransaction.OwnerId, 'Wrong running user'); 
            System.assert(transactionIds.contains(logTransaction.Transaction_Id__c), 'Wrong Transaction Id: ' + logTransaction.Transaction_Id__c);
        }
    }
    
    @IsTest 
    static void shouldGenerateOneLogRecordPerEventFromHandler() {
        Request context = Request.getCurrent(); 
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        for (Integer i = 0; i < 200; i++) {
            logEvents.add(new Log_Event__e(
                Message__c = 'Testing 123',
                Running_User__c = UserInfo.getUserId(),
                Severity__c = String.valueOf(LoggingLevel.FINEST),
                Source__c = String.valueOf(context.getQuiddity()),
                Stack_Trace__c = 'n/a',
                Transaction_Id__c = context.getRequestId()           
            ));
        }
        TriggerHandler handler = new LogEventHandler();
        handler.operation = System.TriggerOperation.AFTER_INSERT; 
        handler.triggerNew = logEvents; 
        
        Test.startTest();
        handler.run(); 
        Test.stopTest(); 

        List<Log_Transaction__c> logTransactions = getLogTransactions();
        System.assertEquals(1, logTransactions?.size(), 'Wrong number of transactions inserted');
        Log_Transaction__c logTransaction = logTransactions[0]; 
        System.assertEquals(UserInfo.getUserId(), logTransaction.OwnerId, 'Wrong running user'); 
        System.assertEquals(context.getRequestId(), logTransaction.Transaction_Id__c, 'Wrong Transaction Id');
        for (Log__c log : logTransactions[0].Logs__r) {
            System.assertEquals('Testing 123', log.Message__c, 'Wrong Message');
            System.assertEquals('FINEST', log.Severity__c, 'Wrong Severity');
            System.assertEquals(String.valueOf(context.getQuiddity()), log.Source__c, 'Wrong Source');
            System.assertEquals('n/a', log.Stack_Trace__c, 'Wrong Stack Trace');
        }
    }

    @IsTest 
    static void shouldGenerateOneLogRecordPerEventFromTrigger() {
        Request context = Request.getCurrent(); 
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        for (Integer i = 0; i < 200; i++) {
            logEvents.add(new Log_Event__e(
                Message__c = 'Testing 123',
                Running_User__c = UserInfo.getUserId(),
                Severity__c = String.valueOf(LoggingLevel.FINEST),
                Source__c = String.valueOf(context.getQuiddity()),
                Stack_Trace__c = 'n/a',
                Transaction_Id__c = context.getRequestId()           
            ));
        }

        Test.startTest();
        DatabaseLayer.DmlEngine.doPublish(logEvents); 
        Test.stopTest();

        List<Log_Transaction__c> logTransactions = getLogTransactions();
        System.assertEquals(1, logTransactions?.size(), 'Wrong number of transactions inserted');
        Log_Transaction__c logTransaction = logTransactions[0]; 
        System.assertEquals(UserInfo.getUserId(), logTransaction.OwnerId, 'Wrong running user'); 
        System.assertEquals(context.getRequestId(), logTransaction.Transaction_Id__c, 'Wrong Transaction Id');
        for (Log__c log : logTransactions[0].Logs__r) {
            System.assertEquals('Testing 123', log.Message__c, 'Wrong Message');
            System.assertEquals('FINEST', log.Severity__c, 'Wrong Severity');
            System.assertEquals(String.valueOf(context.getQuiddity()), log.Source__c, 'Wrong Source');
            System.assertEquals('n/a', log.Stack_Trace__c, 'Wrong Stack Trace');
        }
    }

    private static List<Log_Transaction__c> getLogTransactions() {
        Schema.ChildRelationship logsRelationship = Describes.getChildRelationship(Log_Transaction__c.SObjectType, 'Logs__r');
        IQuery query = DatabaseLayer.QueryEngine.newQuery(Log_Transaction__c.SObjectType)
            .addFields(new List<SObjectField>{
                Log_Transaction__c.OwnerId, 
                Log_Transaction__c.Transaction_Id__c
            }).addSubQueries((SubQuery) new SubQuery(logsRelationship)
                .addFields(new List<SObjectField>{
                    Log__c.Id, 
                    Log__c.Message__c, 
                    Log__c.Severity__c,
                    Log__c.Source__c, 
                    Log__c.Stack_Trace__c
                }
            ));
        return query.run();
    }
}