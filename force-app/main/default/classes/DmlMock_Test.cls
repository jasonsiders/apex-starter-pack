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
        System.assertEquals(true, dmlMock.inserted.containsKey(account.Id), 'Not inserted');
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
        System.assertEquals(true, dmlMock.updated.containsKey(testAccount.Id), 'Not updated');
        System.assertEquals(newName, dmlMock.updated.get(testAccount.Id).get(Account.Name), 'Name was not updated in the "updated" list');
    }

    @IsTest 
    static void shouldMockUpsert() {
        Account testAccount = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = new DmlMock(); 
        dmlMock.doUpsert(testAccount); 
        System.assertNotEquals(null, testAccount.Id, 'Id was not added'); 
        System.assertEquals(true, dmlMock.upserted.containsKey(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 
        dmlMock.doUpsert(testAccount); 
        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, dmlMock.upserted.get(testAccount?.Id)?.get(Account.Name), 'Name was not updated in the "upserted" list');
    }

    @IsTest 
    static void shouldMockUpsertByExternalId() {
        // Name isn't an actual external Id field, so this will only work with a Mock class
        Account testAccount = new Account(Name = 'Test Account'); 
        DmlMock dmlMock = new DmlMock(); 
        dmlMock.doUpsert(testAccount, Account.Name); 
        System.assertNotEquals(null, testAccount.Id, 'Id was not added'); 
        System.assertEquals(true, dmlMock.upserted.containsKey(testAccount.Id), 'Not upserted');
        final String newName = 'Some other name';
        testAccount.Name = newName; 
        dmlMock.doUpsert(testAccount, Account.Name); 
        System.assertEquals(newName, testAccount.Name, 'Wrong name value');
        System.assertEquals(newName, dmlMock.upserted.get(testAccount.Id).get(Account.Name), 'Name was not updated in the "upserted" list');
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
        System.assertEquals(true, dmlMock.undeleted.containsKey(account.Id)); 
    }

    @IsTest 
    static void shouldMockDelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = new DmlMock();
        dmlMock.doInsert(account);
        Test.startTest();
        dmlMock.doDelete(account); 
        Test.stopTest(); 
        System.assertEquals(true, dmlMock.deleted.containsKey(account.Id)); 
    }

    @IsTest 
    static void shouldMockHardDelete() {
        Account account = new Account(Name = 'Test');
        DmlMock dmlMock = new DmlMock();
        dmlMock.doInsert(account);
        Test.startTest();
        dmlMock.doHardDelete(account); 
        Test.stopTest(); 
        System.assertEquals(true, dmlMock.deleted.containsKey(account.Id)); 
    }
}