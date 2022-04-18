@IsTest 
private class DmlMock_Test {
    @IsTest
    static void shouldMockInsert() {
        Account account = new Account(Name = 'Test Account'); 
        Test.startTest();
        DmlMock dmlMock = new DmlMock(); 
        dmlMock.doInsert(account); 
        Test.stopTest();
        System.assertNotEquals(null, account.Id, 'Id was not added'); 
        System.assertEquals(true, dmlMock.inserted.containsRecord(account.Id), 'Not inserted');
    }

    @IsTest 
    static void shouldMockUpdate() {
        Account testAccount = new Account(Name = 'Test Account'); 
        new DmlMock().doInsert(testAccount); 
        final String newName = 'Some other name';
        testAccount.Name = newName; 
        Test.startTest();
        DmlMock dmlMock = new DmlMock();
        dmlMock.doUpdate(testAccount); 
        Test.stopTest();
        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(true, dmlMock.updated.containsRecord(testAccount.Id), 'Not updated');
        System.assertEquals(newName, dmlMock.updated.getRecord(testAccount).get(Account.Name), 'Name was not updated in the "updated" list');
    }

    @IsTest 
    static void shouldMockUpsert() {
        Account testAccount = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = new DmlMock(); 
        dmlMock.doUpsert(testAccount); 
        System.assertNotEquals(null, testAccount.Id, 'Id was not added'); 
        System.assertEquals(true, dmlMock.upserted.containsRecord(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 
        dmlMock.doUpsert(testAccount); 
        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, dmlMock.upserted.getRecord(testAccount)?.get(Account.Name), 'Name was not updated in the "upserted" list');
    }

    @IsTest 
    static void shouldMockUpsertByExternalId() {
        // Name isn't an actual external Id field, so this will only work with a Mock class
        Account testAccount = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = new DmlMock(); 
        dmlMock.doUpsert(testAccount, Account.Name); 
        System.assertNotEquals(null, testAccount.Id, 'Id was not added'); 
        System.assertEquals(true, dmlMock.upserted.containsRecord(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 
        dmlMock.doUpsert(testAccount, Account.Name); 
        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, dmlMock.upserted.getRecord(testAccount).get(Account.Name), 'Name was not updated in the "upserted" list');
    }

    @IsTest 
    static void shouldMockUndelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = new DmlMock(); 
        dmlMock.doInsert(account);
        dmlMock.doDelete(account);
        Test.startTest();
        dmlMock.doUndelete(account); 
        Test.stopTest();
        System.assertEquals(true, dmlMock.undeleted.containsRecord(account.Id)); 
    }

    @IsTest 
    static void shouldMockDelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = new DmlMock();
        dmlMock.doInsert(account);
        Test.startTest();
        dmlMock.doDelete(account); 
        Test.stopTest(); 
        System.assertEquals(true, dmlMock.deleted.containsRecord(account.Id)); 
    }

    @IsTest 
    static void shouldMockHardDelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = new DmlMock();
        dmlMock.doInsert(account);
        Test.startTest();
        dmlMock.doHardDelete(account); 
        Test.stopTest(); 
        System.assertEquals(true, dmlMock.deleted.containsRecord(account.Id)); 
    }

    @IsTest 
    static void shouldDetermineIfRecordWasProcessed() {
        Account account = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = new DmlMock(); 

        Test.startTest();
        dmlMock.doInsert(account); 
        System.assertEquals(true, dmlMock.inserted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.updated?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.upserted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.deleted?.containsRecord(account)); 
        System.assertEquals(false, dmlMock.undeleted?.containsRecord(account)); 
        Test.stopTest();
    }

    @IsTest 
    static void shouldReturnRecordIfProcessed() {
        Account account = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = new DmlMock(); 

        Test.startTest();
        dmlMock.doInsert(account); 
        System.assertEquals(account, dmlMock.inserted?.getRecord(account)); 
        System.assertEquals(null, dmlMock.updated?.getRecord(account)); 
        System.assertEquals(null, dmlMock.upserted?.getRecord(account)); 
        System.assertEquals(null, dmlMock.deleted?.getRecord(account)); 
        System.assertEquals(null, dmlMock.undeleted?.getRecord(account)); 
        Test.stopTest();
    }

    @IsTest 
    static void shouldReturnAllProcessedRecordsOfAnSObjectType() {
        List<Account> accounts = new List<Account>(); 
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
        }
        DmlMock dmlMock = new DmlMock(); 

        Test.startTest();
        dmlMock.doInsert(accounts); 
        System.assertEquals(accounts, dmlMock.inserted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.updated.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.upserted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.deleted.getRecords(Account.SObjectType));
        System.assertEquals(null, dmlMock.undeleted.getRecords(Account.SObjectType));
        Test.stopTest();
    }

    @IsTest 
    static void shouldReturnAllProcessedRecords() {
        DmlMock dmlMock = new DmlMock(); 
        Account account = new Account(Name = 'Test Account');
        dmlMock.doInsert(account); 
        Contact contact = new Contact(AccountId = account.Id, LastName = 'Test'); 
        dmlMock.doInsert(contact); 
        
        Test.startTest();
        List<SObject> insertedRecords = dmlMock.inserted.getAll();
        System.assertEquals(2, insertedRecords?.size(), 'Wrong # of inserted records');
        System.assert(insertedRecords.contains(account), 'Does not contain the account: ' + JSON.serialize(insertedRecords));
        System.assert(insertedRecords.contains(contact), 'Does not contain the contact: ' + JSON.serialize(insertedRecords)); 
        Test.stopTest(); 
    }

    @IsTest 
    static void shouldResetDml() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account'));
        }
        DmlMock dmlMock = new DmlMock();
        dmlMock.doInsert(accounts); 
        System.assertEquals(200, dmlMock.inserted?.getAll()?.size(), 'Wrong # of records inserted'); 
        
        Test.startTest();
        dmlMock.inserted?.clear(); 
        Test.stopTest(); 

        System.assertEquals(0, dmlMock.inserted?.getAll()?.size(), 'Records were not cleared');
    }
}