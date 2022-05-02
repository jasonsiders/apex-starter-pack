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
        System.assertEquals(true, dmlMock.inserted.containsRecord(account.Id), 'Not inserted');
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
        System.assertEquals(true, dmlMock.updated.containsRecord(testAccount.Id), 'Not updated');
        System.assertEquals(newName, dmlMock.updated.getRecord(testAccount).get(Account.Name), 'Name was not updated in the "updated" list');
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
        System.assertEquals(true, dmlMock.upserted.containsRecord(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 

        Test.startTest(); 
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doUpsert(testAccount); 
        Test.stopTest();

        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, dmlMock.upserted.getRecord(testAccount)?.get(Account.Name), 'Name was not updated in the "upserted" list');
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
        System.assertEquals(true, dmlMock.upserted.containsRecord(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 

        Test.startTest();
        DmlResult dmlResult = DatabaseLayer.DmlEngine.doUpsert(testAccount, Account.Name); 
        Test.stopTest();

        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, dmlMock.upserted.getRecord(testAccount).get(Account.Name), 'Name was not updated in the "upserted" list');
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

        System.assertEquals(true, dmlMock.undeleted.containsRecord(account.Id)); 
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

        System.assertEquals(true, dmlMock.deleted.containsRecord(account.Id)); 
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

        System.assertEquals(true, dmlMock.deleted.containsRecord(account.Id)); 
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

        List<Log_Event__e> logEvents = (List<Log_Event__e>) dmlMock.published.getRecords(Log_Event__e.SObjectType); 
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
    static void shouldDetermineIfRecordWasProcessed() {
        Account account = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());

        Test.startTest();
        DatabaseLayer.DmlEngine.doInsert(account); 
        Test.stopTest();

        System.assertEquals(true, dmlMock.inserted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.updated?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.upserted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.deleted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.undeleted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.published?.containsRecord(account)); 
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldReturnRecordIfProcessed() {
        Account account = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 

        Test.startTest();
        DatabaseLayer.DmlEngine.doInsert(account); 
        Test.stopTest();

        System.assertEquals(account, dmlMock.inserted?.getRecord(account)); 
        System.assertEquals(null, dmlMock.updated?.getRecord(account)); 
        System.assertEquals(null, dmlMock.upserted?.getRecord(account)); 
        System.assertEquals(null, dmlMock.deleted?.getRecord(account)); 
        System.assertEquals(null, dmlMock.undeleted?.getRecord(account));
        System.assertEquals(null, dmlMock.published?.getRecord(account)); 
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldReturnAllProcessedRecordsOfAnSObjectType() {
        List<Account> accounts = new List<Account>(); 
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
        }
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock()); 

        Test.startTest();
        DatabaseLayer.DmlEngine.doInsert(accounts); 
        Test.stopTest();

        System.assertEquals(accounts, dmlMock.inserted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.updated.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.upserted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.deleted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.undeleted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.published?.getRecords(Account.SObjectType)); 
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldReturnAllProcessedRecords() {
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
        Account account = new Account(Name = 'Test Account');
        DatabaseLayer.DmlEngine.doInsert(account); 
        Contact contact = new Contact(AccountId = account.Id, LastName = 'Test'); 
        DatabaseLayer.DmlEngine.doInsert(contact); 
        
        Test.startTest();
        List<SObject> insertedRecords = dmlMock.inserted.getAll();
        Test.stopTest(); 

        System.assertEquals(2, insertedRecords?.size(), 'Wrong # of inserted records');
        System.assert(insertedRecords.contains(account), 'Does not contain the account: ' + JSON.serialize(insertedRecords));
        System.assert(insertedRecords.contains(contact), 'Does not contain the contact: ' + JSON.serialize(insertedRecords)); 
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }

    @IsTest 
    static void shouldResetDml() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account'));
        }
        DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
        DatabaseLayer.DmlEngine.doInsert(accounts); 
        System.assertEquals(200, dmlMock.inserted?.getAll()?.size(), 'Wrong # of records inserted'); 
        
        Test.startTest();
        dmlMock.inserted?.clear(); 
        Test.stopTest(); 

        System.assertEquals(0, dmlMock.inserted?.getAll()?.size(), 'Records were not cleared');
        System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
    }
}