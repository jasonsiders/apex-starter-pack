@IsTest
private class Rollup_Test {
	@IsTest
	static void shouldRunFromParent() {
		Soql accountQuery = Databaselayer.Soql.newQuery(Account.SObjectType)
			.selectSubQuery(new SubQuery(Opportunity.AccountId));
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
		Soql oppQuery = Databaselayer.Soql.newQuery(Opportunity.SObjectType).selectFields(Opportunity.AccountId);
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
		Soql oppQuery = Databaselayer.Soql.newQuery(Opportunity.SObjectType).selectFields(Opportunity.AccountId);
		List<Opportunity> opportunities = (List<Opportunity>) oppQuery.run();
		// Update one of the Opportunities amounts to 0
		Set<Id> accountIds = new Set<Id>();
		Opportunity invalidOpp = opportunities[0];
		accountIds.add(invalidOpp.AccountId);
		invalidOpp.Amount = 0;
		Databaselayer.Dml.doUpdate(invalidOpp);

		Test.startTest();
		Rollup rollup = new Rollup(Account.SObjectType)
			.addRelationship(
				new Rollup.Relationship(Opportunity.AccountId)
					.addRequest(
						new Rollup.Request(
								Account.AnnualRevenue,
								new SumCalculator()?.setCalcField(new FieldRef(Opportunity.Amount))
							)
							.addFilters(new Filter(Opportunity.Amount, Filter.GREATER_THAN, 0))
					)
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
		// Since setCalcField() accepts both an SObjectField and FieldRef (for parent-field calculations), can't pass "null"
		SObjectField nullField; 
		calc.setCalcField(nullField);
		System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for null calcField');
	}

	@IsTest
	static void shouldPreventDuplicateRelationships() {
		Rollup rollup = new Rollup(Account.SObjectType);
		// Create two relationship objects for the same ChildRelationship
		Rollup.Relationship rel1 = new Rollup.Relationship(Opportunity.AccountId)
			.addRequest(new Rollup.Request(Account.NumberOfEmployees, new MockCalculator()));
		Rollup.Relationship rel2 = new Rollup.Relationship(Opportunity.AccountId)
			.addRequest(new Rollup.Request(Account.AnnualRevenue, new MockCalculator()));

		Test.startTest();
		rollup.addRelationship(rel1).addRelationship(rel2);
		Test.stopTest();

		System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationsihps');
		Rollup.Relationship relationship = rollup.relationships.values()[0];
		System.assertEquals(2, relationship.requests?.size(), 'Wrong # of requests');
	}

	// **** HELPER **** //
	@TestSetup
	static void setup() {
		Account account = new Account(Name = 'Test Account');
		Databaselayer.Dml.doInsert(account);
		List<Opportunity> opportunities = new List<Opportunity>();
		for (Integer i = 0; i < 3; i++) {
			opportunities.add(
				new Opportunity(
					AccountId = account.Id,
					Amount = 1000,
					CloseDate = Date.today(),
					Name = 'Test Opportunity #' + (i + 1),
					StageName = 'New'
				)
			);
		}
		Databaselayer.Dml.doInsert(opportunities);
	}

	private static Rollup getSumCalculator() {
		return new Rollup(Account.SObjectType)
			.addRelationship(
				new Rollup.Relationship(Opportunity.AccountId)
					.addRequest(
						new Rollup.Request(
							Account.AnnualRevenue,
							new SumCalculator()?.setCalcField(new FieldRef(Opportunity.Amount))
						)
					)
			);
	}

	// **** INNER **** //
	public class MockCalculator extends Rollup.Calculator {
	}
}
