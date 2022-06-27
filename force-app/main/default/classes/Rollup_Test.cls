@IsTest
private class Rollup_Test {
    @IsTest 
    static void shouldRunFromParent() {
        Soql accountQuery = DatabaseLayer.QueryEngine.newQuery(Account.SObjectType)
            .selectSubQuery(new SubQuery(Account.SObjectType, 'Opportunities'));
        List<Account> accounts = (List<Account>) accountQuery.run(); 

        Test.startTest(); 
        Rollup rollup = getSumCalculator(); 
        List<Account> results = (List<Account>) rollup.run(accounts); 
        Test.stopTest();

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(3000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount'); 
    } 

    @IsTest 
    static void shouldRunFromChild() {
        Soql oppQuery = DatabaseLayer.QueryEngine.newQuery(Opportunity.SObjectType).selectFields(Opportunity.AccountId);
        List<Opportunity> opportunities = (List<Opportunity>) oppQuery.run(); 

        Test.startTest();
        Rollup rollup = getSumCalculator(); 
        List<Account> results = (List<Account>) rollup.runFromChild(opportunities, Opportunity.AccountId); 
        Test.stopTest();

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(3000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount'); 
    }

    @IsTest 
    static void shouldFilterRecords() {
        Soql oppQuery = DatabaseLayer.QueryEngine.newQuery(Opportunity.SObjectType).selectFields(Opportunity.AccountId);
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
                new SumCalculator()?.setCalcField(Opportunity.Amount)
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
        calc.setCalcField(null); 
        System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for null calcField');
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

    private static Rollup getSumCalculator() {
        return new Rollup(Account.SObjectType).addRelationship(
            new Rollup.Relationship(
                'Account',
                'Opportunities'
            ).addRequest(new Rollup.Request(
                Account.AnnualRevenue,
                new SumCalculator()?.setCalcField(Opportunity.Amount)
            ))
        );
    }

    // **** INNER **** // 
    public class MockCalculator extends Rollup.Calculator {}
}
