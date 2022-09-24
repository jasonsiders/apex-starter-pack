@IsTest 
private class Rollup_Test {
    @IsTest 
    static void shouldRunSynchronous() {
        List<Account> accounts = initMockAccounts(99); 
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        Rollup.RollupQuery?.toMock()?.setMockResults(accounts);

        Rollup.Target target = initTestTarget(); 
        Rollup rollup = new Rollup(target);
        rollup.addRecords(accounts); 

        Test.startTest();
        Id jobId = rollup.run(); 
        Test.stopTest();
        // Verify that the job ran in the correct context
        System.assertEquals(null, jobId, 'Job was processed async');
        // Verify that the records were updated
        List<Account> results = Dml.Updated?.getRecords(Account.SObjectType);
        System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of updated records'); 
        for (Account account : results) {
            System.assertEquals(account.Opportunities?.size(), account.NumberOfEmployees, 'Wrong COUNT of Account.Opportunities');
            System.assertEquals(1000, account.AnnualRevenue, 'Wrong SUM of Account.Opportunities.Amount');
        }
    }

    @IsTest 
    static void shouldRunQueueable() {
        List<Account> accounts = initMockAccounts(101); 
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        Rollup.RollupQuery?.toMock()?.setMockResults(accounts);
        
        Rollup.Target target = initTestTarget(); 
        Rollup rollup = new Rollup(target);
        rollup.addRecords(accounts);

        Test.startTest();
        Id jobId = rollup.run();
        Test.stopTest();

        // Verify that the job ran in the correct context 
        System.assertNotEquals(null, jobId, 'Was not run async');
        testJobType(jobId, Runtime.Context.QUEUEABLE); 
        // Verify that the records were updated
        List<Account> results = Dml.Updated?.getRecords(Account.SObjectType);
        System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of updated records'); 
        for (Account account : results) {
            System.assertEquals(account.Opportunities?.size(), account.NumberOfEmployees, 'Wrong COUNT of Account.Opportunities');
            System.assertEquals(1000, account.AnnualRevenue, 'Wrong SUM of Account.Opportunities.Amount');
        }
    }

    @IsTest 
    static void shouldRunBatch() {
        Integer batchSize = 250; 
        List<Account> accounts = initMockAccounts(batchSize); 
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        Rollup.RollupQuery?.toMock()?.setMockResults(accounts);

        Rollup.Target target = initTestTarget();
        // Note: Can't run a Batchable job with more than one batch in @IsTest context
        Rollup.RuntimeConfig config = new Rollup.RuntimeConfig().setBatchSize(batchSize);
        Rollup rollup = new Rollup(target).setRuntime(config).addRecords(accounts);

        Test.startTest();
        Id jobId = rollup.run(); 
        Test.stopTest();

        // Verify that the job ran in the correct context
        System.assertNotEquals(null, jobId, 'Was not run async');
        testJobType(jobId, RunTime.Context.BATCHAPEX); 
        // Verify that the records were updated
        List<Account> results = Dml.Updated?.getRecords(Account.SObjectType);
        System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of updated records'); 
        for (Account account : results) {
            System.assertEquals(account.Opportunities?.size(), account.NumberOfEmployees, 'Wrong COUNT of Account.Opportunities');
            System.assertEquals(1000, account.AnnualRevenue, 'Wrong SUM of Account.Opportunities.Amount');
        }
    }

    @IsTest 
    static void shouldCalculateRollupResults() {
        // If callers need more control over DML operations,
        // they can call the target class's doRollup() method directly
        // This will return a list of updated SObjects
        List<Account> accounts = initMockAccounts(200); 
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        Rollup.RollupQuery?.toMock()?.setMockResults(accounts);
        Rollup.Target target = initTestTarget(); 

        Test.startTest();
        List<Account> results = (List<Account>) target.doRollup(accounts); 
        Test.stopTest();

        System.assertEquals(results?.size(), accounts?.size(), 'Wrong # of results');
        for (Account account : results) {
            System.assertEquals(account.Opportunities?.size(), account.NumberOfEmployees, 'Wrong COUNT of Account.Opportunities');
            System.assertEquals(1000, account.AnnualRevenue, 'Wrong SUM of Account.Opportunities.Amount');
        }
    }

    @IsTest 
    static void shouldRunWithCriteria() {
        // Callers can optionally add criteria to their rollups
        // This will exclude non-matching child records from the calculation
        List<Account> accounts = initMockAccounts(100); 
        // Each account should have 1/10 Opps as 'Closed Won'
        for (Account account : accounts) {
            Opportunity opp = (Opportunity) CollectionUtils.getIndexOf(account.Opportunities, 1);
            opp.StageName = 'Closed Won'; 
        }
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        Rollup.RollupQuery?.toMock()?.setMockResults(accounts);

        // Create a rollup that only looks at Closed Won opps
        Rollup.Operation operation = new Rollup.Operation(
            Account.NumberOfEmployees, 
            new CountCalculator(),
            new Filter(Opportunity.StageName, Filter.EQUALS, 'Closed Won')
        );
        Rollup rollup = new Rollup(new Rollup.Target(Account.SObjectType))
            .addOperation(Opportunity.AccountId, operation);
        
        Test.startTest();
        rollup.run();
        Test.stopTest();

        // Verify that the records were updated
        List<Account> results = Dml.Updated?.getRecords(Account.SObjectType);
        System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of updated records'); 
        for (Account account : results) {
            System.assertEquals(1, account.NumberOfEmployees, 'Wrong COUNT of "Closed Won" Opportunities');
        }
    }

    @IsTest 
    static void shouldRunFromChild() {
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Account> accounts = initMockAccounts(100); 
        for (Account account : accounts) {
            opportunities.addAll(account.Opportunities); 
        }
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        Rollup.TargetRecordQuery?.toMock()?.setMockResults(accounts);
        Rollup.RollupQuery?.toMock()?.setMockResults(accounts);

        Rollup.Target target = initTestTarget(); 
        Rollup rollup = new Rollup(target).addRecords(opportunities, Opportunity.AccountId);
        
        Test.startTest();
        rollup.run(); 
        Test.stopTest(); 

        // Verify that the records were updated
        List<Account> results = Dml.Updated?.getRecords(Account.SObjectType);
        System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of updated records'); 
        for (Account account : results) {
            System.assertEquals(account.Opportunities?.size(), account.NumberOfEmployees, 'Wrong COUNT of Account.Opportunities');
            System.assertEquals(1000, account.AnnualRevenue, 'Wrong SUM of Account.Opportunities.Amount');
        } 
    }
    
    @IsTest
	static void shouldProvideDefaultCalculatorValues() {
		List<Opportunity> opportunities = new List<Opportunity>();
		Rollup.Calculator calc = new MockCalculator();
		calc.setCalcField(Opportunity.IsClosed);
		System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for Boolean');
		calc.setCalcField(Opportunity.CloseDate);
		System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for Date');
		calc.setCalcField(Opportunity.CreatedDate);
		System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for DateTime');
		calc.setCalcField(Opportunity.Amount);
		System.assertEquals(0, calc.calculate(opportunities), 'Wrong default value for Number');
		calc.setCalcField(Opportunity.Name);
		System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for Text');
		// Since setCalcField() accepts both an SObjectField and FieldRef (for parent-field calculations), can't pass "null"
		SObjectField nullField; 
		calc.setCalcField(nullField);
		System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for null calcField');
	}

    // **** HELPER **** //
    static List<Account> initMockAccounts(Integer numAccs) {
        DatabaseLayer.setDmlEngine(new DmlMock());
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numAccs; i++) {
            List<Opportunity> opportunities = new List<Opportunity>();
            for (Integer n = 0; n < 10; n++) {
                Opportunity opp = new Opportunity(
                    Id = DmlMock.generateFakeId(Opportunity.SObjectType), 
                    Amount = 100
                );
                opportunities.add(opp);
            }
            Account account = (Account) SObjectUtils.setRelatedList(
                new Account(Name = 'Test Account #' + i),
                SchemaUtils.getChildRelationship(Opportunity.AccountId),
                opportunities
            );
            accounts.add(account);
        }
        DatabaseLayer.Dml.doInsert(accounts);
        return accounts;
    }

    static Rollup.Target initTestTarget() {
        return new Rollup.Target(Account.SObjectType)
            .addOperation(Opportunity.AccountId, new Rollup.Operation(
                Account.NumberOfEmployees, 
                new CountCalculator()
            ))
            .addOperation(Opportunity.AccountId, new Rollup.Operation(
                Account.AnnualRevenue,
                new SumCalculator().setCalcField(Opportunity.Amount)
            ));
    }

    static void testJobType(Id jobId, Runtime.Context jobType) {
        DatabaseLayer.setQueryEngine(new Soql.Factory()); 
        Soql query = DatabaseLayer.Soql.newQuery(AsyncApexJob.SObjectType).selectFields(AsyncApexJob.JobType);
        AsyncApexJob job = (AsyncApexJob) CollectionUtils.getIndexOf(query.run(), 0); 
        System.assertEquals(jobType.name()?.toUpperCase(), job?.JobType?.toUpperCase(), 'Not a ' + jobType.name());
    }

    public class MockCalculator extends Rollup.Calculator {}
}
