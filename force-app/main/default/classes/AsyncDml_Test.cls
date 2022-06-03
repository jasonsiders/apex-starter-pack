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

        List<Account> inserted = (List<Account>) DatabaseLayer.QueryEngine.newQuery(Account.SObjectType).run();
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
        DatabaseLayer.DmlEngine.doInsert(testLead); 
        IQuery statusQuery = DatabaseLayer.QueryEngine.newQuery(LeadStatus.SObjectType)
            .addFields(LeadStatus.MasterLabel)
            .addFilters(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
            .setLimit(1);
        String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
        Database.LeadConvert leadConvertObj = new Database.LeadConvert();
        leadConvertObj.setLeadId(testLead.Id); 
        leadConvertObj.setConvertedStatus(status);

        Test.startTest();
        AsyncDml.getInstance().addRequest(new AsyncDml.Conversion(leadConvertObj)).runJob();
        Test.stopTest();

        IQuery query = DatabaseLayer.QueryEngine.newQuery(Lead.SObjectType).addFilters(new Filter(
            Lead.IsConverted,
            Filter.EQUALS, 
            true
        ));
        System.assertEquals(1, query.run().size(), 'Wrong # of converted leads');
    }

    @IsTest 
    static void shouldMakeRequestWithExternalId() {
        AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case(), Case.CaseNumber);
        System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation'); 
        System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
        System.assertEquals(Case.CaseNumber, request?.externalIdField, 'Wrong externalIdField');
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
            Case.CaseNumber, 
            false
        );
        System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation'); 
        System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
        System.assertEquals(Case.CaseNumber, request?.externalIdField, 'Wrong externalIdField');
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
        System.assertEquals(1, DatabaseLayer.QueryEngine.newQuery(Account.SObjectType)?.run().size(), 'DML was not performed');
    }

    @IsTest 
    static void shouldInsertSynchronouslyIfLimitsReached() {
        Account account = new Account(Name = 'Test Account');
        AsyncDml instance = new PushedToLimitsExample().addRequest(new AsyncDml.Request(
            Dml.Operation.DO_INSERT,
            account
        ));

        Test.startTest();
        Id jobId = instance.runJob(); 
        Test.stopTest();

        System.assertEquals(null, jobId, 'Job was processed asynchronously');
        System.assertNotEquals(null, account.Id, 'DML was not processed'); 
    }

    // **** HELPER **** // 
    public class PushedToLimitsExample extends AsyncDml {
        public PushedToLimitsExample() {}

        public override Boolean queueableIsSafe() {
            // Simulate an instance where a new job cannot be enqueued safely
            return false; 
        }
    }
}