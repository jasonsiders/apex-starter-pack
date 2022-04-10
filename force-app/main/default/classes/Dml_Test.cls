@IsTest
private class Dml_Test {
    static final Integer TEST_SIZE = 10; 

    @TestSetup 
    static void setup() {
        List<Account> accounts = new List<Account>(); 
        for (Integer i = 0; i < TEST_SIZE; i++) {
            accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
        }
        insert accounts;
    }

    @IsTest 
    static void shouldDoInsert() {
        Account account = new Account(Name = 'Test Account #0');
        Test.startTest();
        new Dml().doInsert(account);
        Test.stopTest();
        System.assertNotEquals(null, account?.Id, 'Account was not inserted');
    }

    @IsTest 
    static void shouldDoUpdate() {
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        final String newName = 'Some other name';
        account.Name = newName; 
        Test.startTest();
        new Dml().doUpdate(account); 
        Test.stopTest();
        System.assertEquals(newName, account.Name, 'Account was not updated'); 
    }

    @IsTest 
    static void shouldDoUpsert() {
        Account account = new Account(Name = 'Test Account #0'); 
        new Dml().doUpsert(account); 
        System.assertNotEquals(null, account.Id, 'Account was not inserted'); 
        final String newName = 'Some other name';
        account.Name = newName; 
        new Dml().doUpsert(account); 
        System.assertEquals(newName, account.Name, 'Account was not updated'); 
    }

    @IsTest 
    static void shouldDoUpsertOnExternalId() {
        // The upsert key is set to the *.Id by default, so we'd never actually run something like this
        // But there isn't a way to test this functioanlity without first defining a custom external Id field
        Account testAccount = new Account(Name = 'Test Account #0'); 
        new Dml().doUpsert(testAccount, Account.Id); 
        System.assertNotEquals(null, account.Id, 'Account was not inserted'); 
        final String newName = 'Some other name';
        testAccount.Name = newName; 
        new Dml().doUpsert(testAccount, Account.Id); 
        System.assertEquals(newName, testAccount.Name, 'Account was not updated'); 
    }

    @IsTest 
    static void shouldDoUndelete() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        delete account; 
        Test.startTest();
        new Dml().doUndelete(account); 
        Test.stopTest();
        System.assertEquals(false, [SELECT Id FROM Account WHERE Id = :account.Id]?.isEmpty(), 'Account was not undeleted'); 
    }

    @IsTest 
    static void shouldDoDelete() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        new Dml().doDelete(account); 
        Test.stopTest(); 
        System.assertEquals(true, [SELECT Id FROM Account WHERE Id = :account.Id]?.isEmpty(), 'Account was not deleted'); 
    }

    @IsTest 
    static void shouldDoHardDelete() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        new Dml().doHardDelete(account); 
        Test.stopTest(); 
        account = [SELECT Id, IsDeleted FROM Account WHERE Id = :account.Id ALL ROWS];
        System.assertEquals(true, account.IsDeleted, 'Account was not hard deleted'); 
    }
}