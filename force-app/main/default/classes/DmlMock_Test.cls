@IsTest 
private class DmlMock_Test {
    @IsTest
    static void shouldMockInsert() {
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Account account = new Account(Name = 'Test Account'); 

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doInsert(account); 
        Test.stopTest();

        System.assertNotEquals(null, account.Id, 'Id was not added'); 
        System.assertEquals(true, Dml.Inserted.containsRecord(account.Id), 'Not inserted');
        System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockUpdate() {
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Account testAccount = new Account(Name = 'Test Account'); 
        DatabaseLayer.DmlEngine.doInsert(testAccount); 
        final String newName = 'Some other name';
        testAccount.Name = newName; 

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doUpdate(testAccount); 
        Test.stopTest();

        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(true, Dml.Updated.containsRecord(testAccount.Id), 'Not updated');
        System.assertEquals(newName, Dml.Updated.getRecord(testAccount).get(Account.Name), 'Name was not updated in the "updated" list');
        System.assertEquals(testAccount.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockUpsert() {
        Account testAccount = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
        DatabaseLayer.DmlEngine.doUpsert(testAccount); 
        System.assertNotEquals(null, testAccount.Id, 'Id was not added'); 
        System.assertEquals(true, Dml.Upserted.containsRecord(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 

        Test.startTest(); 
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doUpsert(testAccount); 
        Test.stopTest();

        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, Dml.Upserted.getRecord(testAccount)?.get(Account.Name), 'Name was not updated in the "upserted" list');
        System.assertEquals(testAccount.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockUpsertByExternalId() {
        // Name isn't an actual external Id field, so this will only work with a Mock class
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        Account testAccount = new Account(Name = 'Test Account'); 
        DatabaseLayer.DmlEngine.doUpsert(testAccount, Account.Name); 
        System.assertNotEquals(null, testAccount.Id, 'Id was not added'); 
        System.assertEquals(true, Dml.Upserted.containsRecord(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doUpsert(testAccount, Account.Name); 
        Test.stopTest();

        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, Dml.Upserted.getRecord(testAccount).get(Account.Name), 'Name was not updated in the "upserted" list');
        System.assertEquals(testAccount.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockUndelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
        DatabaseLayer.DmlEngine.doInsert(account);
        DatabaseLayer.DmlEngine.doDelete(account);

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doUndelete(account); 
        Test.stopTest();

        System.assertEquals(true, Dml.Undeleted.containsRecord(account.Id)); 
        System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockDelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        DatabaseLayer.DmlEngine.doInsert(account);

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doDelete(account); 
        Test.stopTest(); 

        System.assertEquals(true, Dml.Deleted.containsRecord(account.Id)); 
        System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockHardDelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        DatabaseLayer.DmlEngine.doInsert(account);

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doHardDelete(account); 
        Test.stopTest(); 

        System.assertEquals(true, Dml.Deleted.containsRecord(account.Id)); 
        System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
        System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockPublish() {
        Log_Event__e event = new Log_Event__e(Message__c = 'Testing 123'); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        
        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doPublish(event); 
        Test.stopTest();

        List<Log_Event__e> logEvents = (List<Log_Event__e>) Dml.Published.getRecords(Log_Event__e.SObjectType); 
        System.assertEquals(1, logEvents?.size(), 'Wrong # of published events');
        System.assertEquals(null, logEvents[0].Id, 'Platform Event was assigned an Id, but should not have');
        System.assertEquals(event.Message__c, logEvents[0].Message__c, 'Wrong message');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldReturnPublishedEvents() {
        Log_Event__e event = new Log_Event__e(Message__c = 'Testing 123'); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 
        DatabaseLayer.DmlEngine.doPublish(event); 

        Test.startTest();
        List<Log_Event__e> logEvents = (List<Log_Event__e>) DatabaseLayer.DmlEngine.getPublishedEvents();
        Test.stopTest();
        
        System.assertEquals(1, logEvents?.size(), 'Wrong # of publishedEvents');
        System.assertEquals(event.Message__c, logEvents[0].Message__c, 'Wrong message');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldMockDynamicDml() {
        DatabaseLayer.setDmlEngine(new DmlMock()); 
        Account testAccount = new Account(Name = 'Test Account'); 

        Test.startTest();
        DatabaseLayer.DmlEngine.doDml(Dml.Operation.DO_INSERT, testAccount); 
        Test.stopTest();

        System.assertNotEquals(null, testAccount.Id, 'Account was not mock inserted');
        System.assertEquals(true, Dml.Inserted.containsRecord(testAccount), 'Account was not added to Inserted');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML Statements');
    }
}