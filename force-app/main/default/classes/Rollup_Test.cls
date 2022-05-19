@IsTest
private class Rollup_Test {
    @IsTest 
    static void shouldRunFromParent() {
        IQuery accountQuery = DatabaseLayer.QueryEngine.newQuery(Account.SObjectType)
            .addSubQueries(new SubQuery(
                Describes.getChildRelationship(Account.SObjectType, 'Opportunities')
            ));
        List<Account> accounts = (List<Account>) accountQuery.run();

        Test.startTest(); 
        Rollup rollup = getTestSumRollup(); 
        List<Account> results = (List<Account>) rollup.run(accounts); 
        Test.stopTest();

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(3000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount'); 
    }

    @IsTest 
    static void shouldRunFromChild() {
        IQuery oppQuery = DatabaseLayer.QueryEngine.newQuery(Opportunity.SObjectType).addFields(Opportunity.AccountId);
        List<Opportunity> opportunities = (List<Opportunity>) oppQuery.run(); 

        Test.startTest();
        Rollup rollup = getTestSumRollup(); 
        List<Account> results = (List<Account>) rollup.runFromChild(opportunities, Opportunity.AccountId); 
        Test.stopTest();

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(3000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount'); 
    }

    @IsTest 
    static void shouldFilterRecords() {
        IQuery oppQuery = DatabaseLayer.QueryEngine.newQuery(Opportunity.SObjectType).addFields(Opportunity.AccountId);
        List<Opportunity> opportunities = (List<Opportunity>) oppQuery.run(); 
        // Update one of the Opportunities amounts to 0
        Set<Id> accountIds = new Set<Id>();
        Opportunity invalidOpp = opportunities[0];
        accountIds.add(invalidOpp.AccountId); 
        invalidOpp.Amount = 0; 
        DatabaseLayer.DmlEngine.doUpdate(invalidOpp); 

        Test.startTest(); 
        Rollup rollup = new Rollup(Account.SObjectType).addRelationship(
            new Rollup.Relationship(
                'Account',
                'Opportunities'
            ).addRequest(new Rollup.Request(
                Account.AnnualRevenue,
                new TestSumRollup(Opportunity.Amount)
            ).addFilters(new Filter(
                Opportunity.Amount, 
                Filter.GREATER_THAN,
                0
            )))
        );
        List<Account> results = (List<Account>) rollup.run(accountIds);
        Test.stopTest(); 

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(2000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount (where Amount > 0)');
    }

    // **** HELPER **** // 
    @TestSetup 
    static void setup() {
        Account account = new Account(Name = 'Test Account');
        DatabaseLayer.DmlEngine.doInsert(account); 
        List<Opportunity> opportunities = new List<Opportunity>(); 
        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(
                AccountId = account.Id,
                Amount = 1000,
                CloseDate = Date.today(),
                Name = 'Test Opportunity #' + (i + 1),
                StageName = 'New'
            ));
        }
        DatabaseLayer.DmlEngine.doInsert(opportunities); 
    }

    private static Rollup getTestSumRollup() {
        return new Rollup(Account.SObjectType).addRelationship(
            new Rollup.Relationship(
                'Account',
                'Opportunities'
            ).addRequest(new Rollup.Request(
                Account.AnnualRevenue,
                new TestSumRollup(Opportunity.Amount)
            ))
        );
    }

    private class TestSumRollup implements Rollup.ICalculator {
        SObjectField calcField; 

        public TestSumRollup(SObjectField calcField) {
            this.calcField = calcField; 
        }

        public Object calculate(List<SObject> records) {
            // Note: A real, fully-fleshed out SumRollup would handle multiple potential data types
            // For our purposes, this will only work with one
            Decimal sum = 0; 
            for (SObject record : records) {
                Decimal value = (Decimal) record.get(this.calcField);
                sum += value;
            }
            return sum;
        }

        public SObjectField getCalcField() {
            return this.calcField;
        }
    }
}
