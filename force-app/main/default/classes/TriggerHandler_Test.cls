@IsTest
private class TriggerHandler_Test extends TriggerHandler {
    @IsTest 
    static void shouldDoNothingIfBaseClass() {
        // The base class's virtual trigger methods all do nothing. No changes will be made
        List<Account> accounts = initAccounts(); 
        TriggerHandler handler = new BlankTriggerHandler(); 
        handler.triggerNew = accounts;
        Test.startTest(); 
        // Before Insert
        handler.beforeInsert();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        // Before update
        handler.operation = System.TriggerOperation.BEFORE_UPDATE;
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        // Before delete
        handler.operation = System.TriggerOperation.BEFORE_DELETE;
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        // After insert
        handler.operation = System.TriggerOperation.AFTER_INSERT;
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        // After update
        handler.operation = System.TriggerOperation.AFTER_UPDATE;
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        // After delete
        handler.operation = System.TriggerOperation.AFTER_DELETE;
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        // After undelete
        handler.operation = System.TriggerOperation.AFTER_UNDELETE;
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWith('Test Account #'), 'Invalid Account Name. Expected: "Test Account #%". Actual: "' + account.Name + '".');
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldDoNothingIfDisabled() {
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.BEFORE_INSERT; 
        handler.triggerNew = initAccounts();
        // By default, the handler will be enabled
        handler.run(); 
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('beforeInsert'), 'Invalid Account Name. Expected: "beforeInsert%". Actual: "' + account.Name + '".');
        }
        // Reset the test, and Disable the handler
        handler.triggerNew = initAccounts(); 
        ExampleTriggerHandler.disable(); 
        handler.run(); 
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(false, account.Name.startsWithIgnoreCase('beforeInsert'), 'Invalid Account Name. Expected: "beforeInsert%". Actual: "' + account.Name + '".');
        }
        // Reset the test, and re-enable the handler
        handler.triggerNew = initAccounts(); 
        ExampleTriggerHandler.enable(); 
        handler.run();
        for (Account account : (List<Account>) handler.triggerNew) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('beforeInsert'), 'Invalid Account Name. Expected: "beforeInsert%". Actual: "' + account.Name + '".');
        }
    }
    
    @IsTest 
    static void shouldRunBeforeInsert() {
        List<Account> accounts = initAccounts(); 
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.BEFORE_INSERT;
        handler.triggerNew = accounts;
        Test.startTest(); 
        handler.operation = System.TriggerOperation.BEFORE_INSERT;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('beforeInsert'), 'Invalid Account Name. Expected: "beforeInsert%". Actual: "' + account.Name + '".');
        }
    }

    @IsTest 
    static void shouldRunBeforeUpdate() {
        List<Account> accounts = getAccounts();
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.BEFORE_UPDATE;
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts; 
        handler.triggerOldMap = new Map<Id, Account>(accounts); 
        Test.startTest(); 
        handler.operation = System.TriggerOperation.BEFORE_UPDATE;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('beforeUpdate'), 'Invalid Account Name. Expected: "beforeUpdate%". Actual: "' + account.Name + '".');
        }
    }

    @IsTest 
    static void shouldRunBeforeDelete() {
        List<Account> accounts = getAccounts();
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.BEFORE_DELETE;
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts;
        handler.triggerOldMap = new Map<Id, Account>(accounts); 
        Test.startTest(); 
        handler.operation = System.TriggerOperation.BEFORE_DELETE;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('beforeDelete'), 'Invalid Account Name. Expected: "beforeDelete%". Actual: "' + account.Name + '".');
        }
    }

    @IsTest 
    static void shouldRunAfterInsert() {
        List<Account> accounts = getAccounts();
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.AFTER_INSERT;
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        Test.startTest(); 
        handler.operation = System.TriggerOperation.AFTER_INSERT;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('afterInsert'), 'Invalid Account Name. Expected: "afterInsert%". Actual: "' + account.Name + '".');
        }
    }

    @IsTest 
    static void shouldRunAfterUpdate() {
        List<Account> accounts = getAccounts();
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.AFTER_UPDATE;
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts;
        handler.triggerOldMap = new Map<Id, Account>(accounts); 
        Test.startTest(); 
        handler.operation = System.TriggerOperation.AFTER_UPDATE;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('afterUpdate'), 'Invalid Account Name. Expected: "afterUpdate%". Actual: "' + account.Name + '".');
        }
    }

    @IsTest 
    static void shouldRunAfterDelete() {
        List<Account> accounts = getAccounts();
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.AFTER_DELETE;
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts;
        handler.triggerOldMap = new Map<Id, Account>(accounts); 
        Test.startTest(); 
        handler.operation = System.TriggerOperation.AFTER_DELETE;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('afterDelete'), 'Invalid Account Name. Expected: "afterDelete%". Actual: "' + account.Name + '".');
        }
    }

    @IsTest 
    static void shouldRunAfterUndelete() {
        List<Account> accounts = getAccounts();
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.operation = System.TriggerOperation.AFTER_UNDELETE;
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts;
        handler.triggerOldMap = new Map<Id, Account>(accounts); 
        Test.startTest(); 
        handler.operation = System.TriggerOperation.AFTER_UNDELETE;
        handler.run();
        Test.stopTest(); 
        for (Account account : accounts) {
            System.assertEquals(true, account.Name.startsWithIgnoreCase('afterUndelete'), 'Invalid Account Name. Expected: "afterUndelete%". Actual: "' + account.Name + '".');
        }
    }
    
    @IsTest 
    static void shouldDetermineIsNew() {
        // Returns true if the record in question is found in the handler's triggerOldMap
        List<Account> accounts = getAccounts();
        Account testAccount = accounts[0];
        Account otherAccount = accounts[1];
        TriggerHandler handler = new ExampleTriggerHandler(); 
        // Note: By default, triggerOldMap is empty, and won't contain the record in question
        System.assertEquals(true, handler.isNew(testAccount), 'Account is not new');
        // If triggerOldMap is not empty, it will return true if the record Id is contained
        handler.triggerOldMap.put(otherAccount.Id, otherAccount);
        System.assertEquals(true, handler.isNew(testAccount), 'Account is not new');
        handler.triggerOldMap.put(testAccount.Id, testAccount);
        System.assertEquals(false, handler.isNew(testAccount), 'Account is new');
    }

    @IsTest 
    static void shouldDetermineIsChanged() {
        List<Account> accounts = getAccounts();
        Account testAccount = accounts[0];
        TriggerHandler handler = new ExampleTriggerHandler(); 
        // Note: If the handler doesn't contain the account, this method will return true
        System.assertEquals(true, handler.isChanged(testAccount, Account.Name), 'Account is not changed');
        // If the handler contains the account, but it is unchanged, it will return false
        handler.triggerNew = accounts.deepClone(true);
        handler.triggerNewMap = new Map<Id, Account>(accounts.deepClone(true));
        handler.triggerOld = accounts.deepClone(true);
        handler.triggerOldMap = new Map<Id, Account>(accounts.deepClone(true)); 
        System.assertEquals(false, handler.isChanged(testAccount, Account.Name), 'Account is changed'); 
        // If the handler contains the account, and the specified field is changed, it will return true
        testAccount.Name = 'Some other account name';
        System.assertEquals(true, handler.isChanged(testAccount, Account.Name), 'Account is not changed');
    }

    @IsTest 
    static void shouldDetermineIfChangedFrom() {
        List<Account> accounts = getAccounts();
        Account testAccount = accounts[0];
        final String originalAccountName = testAccount.Name; 
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts.deepClone(); 
        handler.triggerOldMap = new Map<Id, Account>(accounts.deepClone(true)); 
        // If not changed, will return false
        System.assertEquals(false, handler.isChangedFrom(testAccount, Account.Name, originalAccountName), 'Account.Name was changed from value');
        // If changed from the value to another value, will return true
        testAccount.Name = 'Some other name';
        System.assertEquals(true, handler.isChangedFrom(testAccount, Account.Name, originalAccountName), 'Account.Name was not changed from value');
        // If changed, but the old value doesn't match, will return false
        System.assertEquals(false, handler.isChangedFrom(testAccount, Account.Name, 'A third value'), 'Account.Name was changed from value');
        // If not changed && the old value doesn't match, will still return false
        testAccount.Name = originalAccountName;
        System.assertEquals(false, handler.isChangedFrom(testAccount, Account.Name, 'Some other name'), 'Account.Name was changed from value');
    }

    @IsTest
    static void shouldDetermineIfChangedTo() {
        List<Account> accounts = getAccounts();
        Account testAccount = accounts[0];
        final String originalAccountName = testAccount.Name; 
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts.deepClone(); 
        handler.triggerOldMap = new Map<Id, Account>(accounts.deepClone(true)); 
        // If not changed, will return false
        System.assertEquals(false, handler.isChangedTo(testAccount, Account.Name, originalAccountName), 'Account.Name was changed to value');
        // If changed from one value to the expected value, will return true
        testAccount.Name = 'Test';
        System.assertEquals(true, handler.isChangedTo(testAccount, Account.Name, 'Test'), 'Account.Name was not changed to value'); 
        // If changed, but the new value doesn't match, will return false
        System.assertEquals(false, handler.isChangedTo(testAccount, Account.Name, 'Another Test'), 'Account.Name was changed to value');
        // If not changed, and the new value doesn't match, will still return false
        testAccount.Name = originalAccountName; 
        System.assertEquals(false, handler.isChangedTo(testAccount, Account.Name, 'Test'), 'Account.Name was changed to value');
    }

    @IsTest 
    static void shouldDetermineIfChangedFromTo() {
        List<Account> accounts = getAccounts();
        Account testAccount = accounts[0];
        final String originalAccountName = testAccount.Name; 
        final String newAccountName = 'My Test Account';
        TriggerHandler handler = new ExampleTriggerHandler(); 
        handler.triggerNew = accounts;
        handler.triggerNewMap = new Map<Id, Account>(accounts); 
        handler.triggerOld = accounts.deepClone(); 
        handler.triggerOldMap = new Map<Id, Account>(accounts.deepClone(true)); 
        // If not changed, will return false
        System.assertEquals(false, handler.isChangedFromTo(testAccount, Account.Name, originalAccountName, newAccountName), 'Account.Name was changed from/to value');
        // If changed, but the fromValue or toValue doesn't match, will return false
        testAccount.Name = newAccountName; 
        System.assertEquals(false, handler.isChangedFromTo(testAccount, Account.Name, 'Some Other Value', newAccountName), 'Account.Name was changed from/to value');
        System.assertEquals(false, handler.isChangedFromTo(testAccount, Account.Name, originalAccountName, 'Some other value'), 'Account.Name was changed from/to value');
        // If changed from the fromValue to the toValue, will return true
        System.assertEquals(true, handler.isChangedFromTo(testAccount, Account.Name, originalAccountName, newAccountName), 'Account.Name was not changed from/to value'); 
    }
    
    // **** HELPER **** // 
    @testSetup 
    static void setup() {
        DatabaseLayer.DmlEngine.doInsert(initAccounts());
    }

    static final Integer TEST_SIZE = 200;

    static List<Account> initAccounts() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < TEST_SIZE; i++) {
            accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
        }
        return accounts;
    }

    static List<Account> getAccounts() {
        Soql query = DatabaseLayer.QueryEngine.newQuery(Account.SObjectType)
            .selectFields(new List<SObjectField>{
                Account.AccountNumber,
                Account.Name  
            });
        return (List<Account>) query.run(); 
    }

    private class ExampleTriggerHandler extends TriggerHandler {
        public override void beforeInsert() {
            this.setAccountNameTo('beforeInsert');
        }

        public override void beforeUpdate() {
            this.setAccountNameTo('beforeUpdate');
        }

        public override void beforeDelete() {
            this.setAccountNameTo('beforeDelete');
        }

        public override void afterInsert() {
            this.setAccountNameTo('afterInsert');
        }

        public override void afterUpdate() {
            this.setAccountNameTo('afterUpdate');
        }

        public override void afterDelete() {
            this.setAccountNameTo('afterDelete');
        }

        public override void afterUndelete() {
            this.setAccountNameTo('afterUndelete');
        }

        private void setAccountNameTo(String newAccountName) {
            for (Account account : (List<Account>) this.triggerNew) {
                account.Name = (newAccountName + ': ' + account.Name); 
            }
        }
    }

    private class BlankTriggerHandler extends TriggerHandler {
        // Keeps the default implementation
    }
}