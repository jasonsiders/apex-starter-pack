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
        DmlResult dmlResult = new Dml().doInsert(account);
        Test.stopTest();
        System.assertNotEquals(null, account?.Id, 'Account was not inserted');
        System.assertEquals(account?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors');
    }

    @IsTest 
    static void shouldDoUpdate() {
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        final String newName = 'Some other name';
        account.Name = newName; 
        Test.startTest();
        DmlResult dmlResult = new Dml().doUpdate(account); 
        Test.stopTest();
        System.assertEquals(newName, account.Name, 'Account was not updated');
        System.assertEquals(account?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors'); 
    }

    @IsTest 
    static void shouldDoUpsert() {
        Account account = new Account(Name = 'Test Account #0'); 
        new Dml().doUpsert(account); 
        System.assertNotEquals(null, account.Id, 'Account was not inserted'); 
        final String newName = 'Some other name';
        account.Name = newName; 
        DmlResult dmlResult = new Dml().doUpsert(account); 
        System.assertEquals(newName, account.Name, 'Account was not updated'); 
        System.assertEquals(account?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors');
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
        DmlResult dmlResult = new Dml().doUpsert(testAccount, Account.Id); 
        System.assertEquals(newName, testAccount.Name, 'Account was not updated');
        System.assertEquals(testAccount?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors'); 
    }

    @IsTest 
    static void shouldDoUndelete() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        delete account; 
        Test.startTest();
        DmlResult dmlResult = new Dml().doUndelete(account); 
        Test.stopTest();
        System.assertEquals(false, [SELECT Id FROM Account WHERE Id = :account.Id]?.isEmpty(), 'Account was not undeleted'); 
        System.assertEquals(account?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors');
    }

    @IsTest 
    static void shouldDoDelete() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        DmlResult dmlResult = new Dml().doDelete(account); 
        Test.stopTest(); 
        System.assertEquals(true, [SELECT Id FROM Account WHERE Id = :account.Id]?.isEmpty(), 'Account was not deleted'); 
        System.assertEquals(account?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors');
    }

    @IsTest 
    static void shouldDoHardDelete() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        DmlResult dmlResult = new Dml().doHardDelete(account); 
        Test.stopTest(); 
        account = [SELECT Id, IsDeleted FROM Account WHERE Id = :account.Id ALL ROWS];
        System.assertEquals(true, account.IsDeleted, 'Account was not hard deleted'); 
        System.assertEquals(account?.Id, dmlResult.recordId, 'Invalid DML Result');
        System.assertEquals(true, dmlResult.isSuccess, 'DML marked as unsuccessful');
        System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # of errors');
    }

    @IsTest 
    static void shouldDoPublish() {
        Log_Event__e event = new Log_Event__e(
            Message__c = 'Testing 123',
            Running_User__c = TestUtils.generateFakeId(Account.SObjectType),
            Severity__c = 'NONE',
            Transaction_Id__c = '1234'
        );
        Test.startTest();
        Dml dml = new Dml(); 
        DmlResult result = dml.doPublish(event);
        Test.stopTest();
        Test.getEventBus().deliver();
        // Unlike "normal" DML, platform events are not given an ID after insert/publish
        System.assertEquals(null, event.ReplayId);
        System.assertEquals(true, result.isSuccess, 'Event did not publish. Errors: ' + result.errors);
    }

    @IsTest 
    static void shouldThrowErrorOnInsert() {
        Account account = new Account(); // Missing a required field
        
        Test.startTest();
        Exception caughtError; 
        try { 
            new Dml().doInsert(new List<Account>{account});
        } catch (Exception thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
    }

    @IsTest 
    static void shouldThrowErrorOnUpdate() {
        Account account = new Account(); // Missing an Id field
        
        Test.startTest();
        Exception caughtError; 
        try { 
            new Dml().doUpdate(new List<Account>{account});
        } catch (Exception thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
    }

    @IsTest 
    static void shouldThrowErrorOnUpsert() {
        Account account = new Account(Id = TestUtils.generateFakeId(Account.SObjectType)); // illegal account Id value
        
        Test.startTest();
        Exception caughtError; 
        try { 
            new Dml().doUpsert(new List<Account>{account});
        } catch (Exception thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
    }

    @IsTest 
    static void shouldThrowErrorOnDelete() {
        Account account = new Account(Id = TestUtils.generateFakeId(Account.SObjectType)); // illegal account Id value
        
        Test.startTest();
        Exception caughtError; 
        try { 
            new Dml().doDelete(new List<Account>{account});
        } catch (Exception thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
    }

    @IsTest 
    static void shouldThrowErrorOnHardDelete() {
        Account account = new Account(Id = TestUtils.generateFakeId(Account.SObjectType)); // illegal account Id value
        
        Test.startTest();
        Exception caughtError; 
        try { 
            new Dml().doHardDelete(new List<Account>{account});
        } catch (Exception thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
    }

    @IsTest 
    static void shouldThrowErrorOnUndelete() {
        Account account = new Account(Id = TestUtils.generateFakeId(Account.SObjectType)); // illegal account Id value
        
        Test.startTest();
        Exception caughtError; 
        try { 
            new Dml().doUndelete(new List<Account>{account});
        } catch (Exception thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
    }

    @IsTest 
    static void shouldBypassErrorOnInsert() {
        Account account = new Account(); // Missing a required field
        
        Test.startTest();
        DmlResult dmlResult; 
        try { 
            dmlResult = new Dml().doInsert(account, false);
        } catch (Exception thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError);
        }
        Test.stopTest();

        System.assertEquals(false, dmlResult?.isSuccess, 'Illegal operation succeeded');
        System.assertEquals(false, dmlResult?.errors?.isEmpty(), 'No errors posted');
    }

    @IsTest 
    static void shouldBypassErrorOnUpdate() {
        Account account = new Account(); // Missing a required field
        
        Test.startTest();
        DmlResult dmlResult; 
        try { 
            dmlResult = new Dml().doUpdate(account, false);
        } catch (Exception thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError);
        }
        Test.stopTest();

        System.assertEquals(false, dmlResult?.isSuccess, 'Illegal operation succeeded');
        System.assertEquals(false, dmlResult?.errors?.isEmpty(), 'No errors posted');
    }

    @IsTest 
    static void shouldBypassErrorOnUpsert() {
        Account account = new Account(); // Missing a required field
        
        Test.startTest();
        DmlResult dmlResult; 
        try { 
            dmlResult = new Dml().doUpsert(account, false);
        } catch (Exception thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError);
        }
        Test.stopTest();

        System.assertEquals(false, dmlResult?.isSuccess, 'Illegal operation succeeded');
        System.assertEquals(false, dmlResult?.errors?.isEmpty(), 'No errors posted');
    }

    @IsTest 
    static void shouldBypassErrorOnDelete() {
        // SFDC never lets you delete Contacts w/Cases!
        Dml dmlEngine = new Dml();
        Contact contact = new Contact(LastName = 'Test');
        dmlEngine.doInsert(contact);
        Case theCase = new Case(ContactId = contact.Id);
        dmlEngine.doInsert(theCase);
        
        Test.startTest();
        DmlResult dmlResult; 
        try { 
            dmlResult = dmlEngine.doDelete(contact, false);
        } catch (Exception thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError);
        }
        Test.stopTest();

        System.assertEquals(false, dmlResult?.isSuccess, 'Illegal operation succeeded');
        System.assertEquals(false, dmlResult?.errors?.isEmpty(), 'No errors posted');
    }

    @IsTest 
    static void shouldBypassErrorOnHardDelete() {
        // SFDC never lets you delete Contacts w/Cases!
        Dml dmlEngine = new Dml();
        Contact contact = new Contact(LastName = 'Test');
        dmlEngine.doInsert(contact);
        Case theCase = new Case(ContactId = contact.Id);
        dmlEngine.doInsert(theCase);
        
        Test.startTest();
        DmlResult dmlResult; 
        try { 
            dmlResult = dmlEngine.doHardDelete(contact, false);
        } catch (Exception thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError);
        }
        Test.stopTest();

        System.assertEquals(false, dmlResult?.isSuccess, 'Illegal operation succeeded');
        System.assertEquals(false, dmlResult?.errors?.isEmpty(), 'No errors posted');
    }

    @IsTest 
    static void shouldBypassErrorOnUndelete() {
        // You can't undelete something once if it's no longer in the recycle bin
        Dml dmlEngine = new Dml();
        Account account = new Account(Name = 'Test');
        dmlEngine.doInsert(account);
        dmlEngine.doHardDelete(account);
        
        Test.startTest();
        DmlResult dmlResult; 
        try { 
            dmlResult = new Dml().doUndelete(account, false);
        } catch (Exception thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError);
        }
        Test.stopTest();

        System.assertEquals(false, dmlResult?.isSuccess, 'Illegal operation succeeded');
        System.assertEquals(false, dmlResult?.errors?.isEmpty(), 'No errors posted');
    }

    @IsTest 
    static void shouldInsertNormalSObjectFromPublish() {
        // Note: There isn't currently a `PlatformEventSObject` interface/type,
        // nor is there a way to identify/prevent "normal" SObjects from being passed here
        // EventBus.publish by default will insert "normal" SObjects instead of publish them
        // but by no means should we actually go try and do this in real life!
        Account notAnEvent = new Account(Name = 'Test'); 
        DmlResult result = new Dml().doPublish(notAnEvent);
        System.assertEquals(true, result.isSuccess, 'Account publish failed: ' + JSON.serialize(result));
        System.assertEquals(false, [SELECT Id FROM Account WHERE Id = :result.recordId]?.isEmpty(), 'Account was not inserted');
    }

    @IsTest 
    static void shouldReturnPublishedEvents() {
        Log_Event__e event = new Log_Event__e(Message__c = 'Testing 123'); 
        Dml dml = new Dml(); 
        DmlResult dmlResult = dml.doPublish(event); 

        Test.startTest();
        List<Log_Event__e> logEvents = (List<Log_Event__e>) dml.getPublishedEvents();
        Test.stopTest();
        
        System.assertEquals(1, logEvents?.size(), 'Wrong # of publishedEvents');
        System.assertEquals(event.Message__c, logEvents[0].Message__c, 'Wrong message');
    }
}