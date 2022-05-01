@IsTest
private class LogGenerator_Test {
    @IsTest 
    static void shouldGenerateOneTransactionRecordPerTransactionId() { 
        Set<String> transactionIds = new Set<String>(); 
        List<Log_Event__e> logEvents = new List<Log_Event__e>(); 
        // Generate 200 transaction Ids - should generate 200 Log Transaction records
        for (Integer i = 0; i < 200; i++) {
            String transactionId = 'Transaction #' + Crypto.getRandomInteger() + '_' + i;
            transactionIds.add(transactionId);
            // Add one event per transactionId
            logEvents.add(new Log_Event__e(
                Message__c = 'Testing 123',
                Running_User__c = UserInfo.getUserId(),
                Severity__c = 'FINEST',
                Transaction_Id__c = transactionId
            ));

        }

        Test.startTest();
        DmlMock dmlMock = new DmlMock(); 
        LogGenerator generator = new LogGenerator(logEvents); 
        DatabaseLayer.setDmlEngine(dmlMock); 
        generator.generateLogs(); 
        Test.stopTest(); 
        
        List<Log_Transaction__c> logTransactions = dmlMock.upserted.getRecords(Log_Transaction__c.SObjectType); 
        System.assertEquals(transactionIds?.size(), logTransactions?.size(), 'Wrong # of Log Transactions generated');
        List<Log__c> logRecords = dmlMock.inserted.getRecords(Log__c.SObjectType); 
        System.assertEquals(transactionIds?.size(), logRecords?.size(), 'Wrong # of Log Records generated. DmlMock: ' + JSON.serializePretty(dmlMock)); 
    }

    @IsTest 
    static void shouldGenerateOneLogRecordPerEvent() {
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
        DmlMock dmlMock = new DmlMock(); 
        LogGenerator generator = new LogGenerator(logEvents); 
        DatabaseLayer.setDmlEngine(dmlMock);
        generator.generateLogs(); 
        Test.stopTest(); 

        List<Log_Transaction__c> logTransactions = (List<Log_Transaction__c>) 
        dmlMock.upserted.getRecords(Log_Transaction__c.SObjectType);
        System.assertEquals(1, logTransactions?.size(), 'Wrong number of transactions inserted');
        Log_Transaction__c logTransaction = logTransactions[0]; 
        System.assertEquals(UserInfo.getUserId(), logTransaction.OwnerId, 'Wrong running user'); 
        System.assertEquals(context.getRequestId(), logTransaction.Transaction_Id__c, 'Wrong Transaction Id');

        List<Log__c> logs = (List<Log__c>) dmlMock.inserted.getRecords(Log__c.SObjectType);
        for (Log__c log : logs) {
            System.assertEquals('Testing 123', log.Message__c, 'Wrong Message');
            System.assertEquals('FINEST', log.Severity__c, 'Wrong Severity');
            System.assertEquals(String.valueOf(context.getQuiddity()), log.Source__c, 'Wrong Source');
            System.assertEquals('n/a', log.Stack_Trace__c, 'Wrong Stack Trace');
        }
    }
}
