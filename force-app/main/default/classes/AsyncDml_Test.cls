@IsTest 
private class AsyncDml_Test {
    @IsTest 
    static void shouldProcessDmlAsynchronously() { 
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            testAccounts.add(new Account(Name = 'Test Account')); 
        }

        Test.startTest(); 
        AsyncDml.getInstance().addRequest(new AsyncDml.Request(Dml.Operation.DO_INSERT, testAccounts)).runJob();
        Test.stopTest(); 

        List<Account> inserted = (List<Account>) Databaselayer.Soql.newQuery(Account.SObjectType).run();
        System.assertEquals(testAccounts?.size(), inserted?.size(), 'Wrong # of accounts inserted'); 
    } 

    @IsTest 
    static void shouldConvertLeadAsynchronously() {
        Lead testLead = new Lead(
            Company = 'Acme Inc.',
            Email = 'john.doe@test.com.invalid',
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '+15555555555'
        );
        Databaselayer.Dml.doInsert(testLead); 
        Soql statusQuery = Databaselayer.Soql.newQuery(LeadStatus.SObjectType)
            .selectFields(LeadStatus.MasterLabel)
            .whereFilters(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
            .setRowLimit(1);
        String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
        Database.LeadConvert leadConvertObj = new Database.LeadConvert();
        leadConvertObj.setLeadId(testLead.Id); 
        leadConvertObj.setConvertedStatus(status);

        Test.startTest();
        AsyncDml.getInstance().addRequest(new AsyncDml.Conversion(leadConvertObj)).runJob();
        Test.stopTest();

        Soql query = Databaselayer.Soql.newQuery(Lead.SObjectType)
            .whereFilters(new Filter(Lead.IsConverted, Filter.EQUALS, true));
        System.assertEquals(1, query.run().size(), 'Wrong # of converted leads');
    }

    @IsTest 
    static void shouldMakeRequestWithExternalId() {
        AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case(), new FieldReference(Case.CaseNumber));
        System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation'); 
        System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
        System.assertEquals(Case.CaseNumber, request?.externalIdField?.toSchemaType(), 'Wrong externalIdField');
        System.assertEquals(true, request?.allOrNone, 'Wrong allOrNone'); 
        System.assertEquals(false, request?.skipTriggers, 'Wrong skipTriggers'); 
    }

    @IsTest 
    static void shouldMakeRequestWithAllOrNone() {
        AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case(), false);
        System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation'); 
        System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
        System.assertEquals(null, request?.externalIdField, 'Wrong externalIdField');
        System.assertEquals(false, request?.allOrNone, 'Wrong allOrNone'); 
        System.assertEquals(false, request?.skipTriggers, 'Wrong skipTriggers'); 
    }

    @IsTest 
    static void shouldMakeRequestWithExternalIdAndAllOrNone() {
        AsyncDml.Request request = new AsyncDml.Request(
            Dml.Operation.DO_INSERT, 
            new Case(), 
            new FieldReference(Case.CaseNumber),
            false
        );
        System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation'); 
        System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
        System.assertEquals(Case.CaseNumber, request?.externalIdField?.toSchemaType(), 'Wrong externalIdField');
        System.assertEquals(false, request?.allOrNone, 'Wrong allOrNone'); 
        System.assertEquals(false, request?.skipTriggers, 'Wrong skipTriggers'); 
    }

    @IsTest 
    static void shouldMakeRequestWithSkippedTriggers() {
        AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case()).skipTriggers();
        System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation'); 
        System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
        System.assertEquals(null, request?.externalIdField, 'Wrong externalIdField');
        System.assertEquals(true, request?.allOrNone, 'Wrong allOrNone'); 
        System.assertEquals(true, request?.skipTriggers, 'Wrong skipTriggers'); 
    }

    @IsTest 
    static void shouldSkipTriggers() {
        AsyncDml.Request request = new AsyncDml.Request(
            Dml.Operation.DO_INSERT, 
            new Account(Name = 'Test Account')
        ).skipTriggers();

        Test.startTest();
        AsyncDml.getInstance().addRequest(request).runJob(); 
        Test.stopTest(); 

        // Note: We can't actually assert that the triggers were skipped, without having a trigger on a specific object
        System.assertEquals(1, Databaselayer.Soql.newQuery(Account.SObjectType)?.run().size(), 'DML was not performed');
    }

    @IsTest 
    static void shouldInsertSynchronouslyIfLimitsReached() {
        Account account = new Account(Name = 'Test Account');
        AsyncDml.getInstance().addRequest(new AsyncDml.Request(
            Dml.Operation.DO_INSERT,
            account
        ));
        LimitUtils.instance = new LimitsMock(); 

        Test.startTest();
        Id jobId = AsyncDml.getInstance().runJob(); 
        Test.stopTest();

        System.assertEquals(null, jobId, 'Job was processed asynchronously');
        System.assertNotEquals(null, account.Id, 'DML was not processed'); 
    }

    // **** HELPER **** // 
    public class LimitsMock extends LimitUtils {
        public override Boolean checkIfQueueableIsSafe() {
            // Simulate an instance where a new job cannot be enqueued safely
            return false; 
        }
    }
}