@IsTest
private class FilterLogic_Test {
	@IsTest
	static void shouldDetermineAllMeetCriteria() {
		FilterLogic logic = new AndLogic().addCriteria(testFilters);
		// If all are true, will return true
		Account testAccount = new Account(AnnualRevenue = 9999, BillingCountry = 'USA', OwnerId = UserInfo.getUserId());
		System.assertEquals(
			true,
			logic.meetsCriteria(testAccount),
			'Unexpected FilterLogic.meetsCriteria() result. Logic: ' +
			logic +
			'. Item: ' +
			JSON.serialize(testAccount)
		);
		// If one fails, all will fail
		testAccount.AnnualRevenue = 1;
		System.assertEquals(
			false,
			logic.meetsCriteria(testAccount),
			'Unexpected FilterLogic.meetsCriteria() result. Logic: ' +
			logic +
			'. Item: ' +
			JSON.serialize(testAccount)
		);
		// Should output as a block of AND statements
		String expected = testFilters[0] + ' AND ' + testFilters[1] + ' AND ' + testFilters[2];
		System.assertEquals(expected, logic.toString(), 'Wrong logic output');
	}

	@IsTest
	static void shouldDetermineAnyMeetCriteria() {
		FilterLogic logic = new OrLogic().addCriteria(testFilters);
		// If all fails, will return false
		Account testAccount = new Account(
			AnnualRevenue = 1,
			BillingCountry = 'UK',
			OwnerId = DmlMock.generateFakeId(User.SObjectType)
		);
		System.assertEquals(
			false,
			logic.meetsCriteria(testAccount),
			'Unexpected FilterLogic.meetsCriteria() result. Logic: ' +
			logic +
			'. Item: ' +
			JSON.serialize(testAccount)
		);
		// If just one is true, will return true
		testAccount.AnnualRevenue = 9999;
		System.assertEquals(
			true,
			logic.meetsCriteria(testAccount),
			'Unexpected FilterLogic.meetsCriteria() result. Logic: ' +
			logic +
			'. Item: ' +
			JSON.serialize(testAccount)
		);
		// Should output as a block of OR statements
		String expected = testFilters[0] + ' OR ' + testFilters[1] + ' OR ' + testFilters[2];
		System.assertEquals(expected, logic.toString(), 'Wrong logic output');
	}

	@IsTest
	static void shouldGetSetFilters() {
		FilterLogic logic = new AndLogic();
		Filter myFilter = new Filter(Account.Name, Filter.EQUALS, 'Test');
		System.assertEquals(0, logic.getCriteria()?.size(), 'Wrong # of filters');
		// addCriteria() adds a new filter(s) to the list
		logic.addCriteria(myFilter);
		System.assertEquals(1, logic.getCriteria()?.size(), 'Wrong # of filters');
		logic.addCriteria(myFilter);
		System.assertEquals(2, logic.getCriteria()?.size(), 'Wrong # of filters');
		// setCriteria() relaces the exising list
		logic.setCriteria(new List<Filter>{ myFilter });
		System.assertEquals(1, logic.getCriteria()?.size(), 'Wrong # of filters');
	}

	@IsTest
	static void shouldConstructWithoutFilters() {
		// Optionally, callers can generate a new instance of AndLogic/OrLogic without filters defined at the start
		// This allows them to add them later on
		FilterLogic logic = new AndLogic();
		System.assertEquals(0, logic.getCriteria()?.size(), 'Wrong # of filters');
		logic = new OrLogic();
		System.assertEquals(0, logic.getCriteria()?.size(), 'Wrong # of filters');
	}

	@IsTest
	static void shouldOutputValidSoqlForInCollectionFilters() {
		// Note: IN_COLLECTION / NOT_IN_COLLECTION Filter Operators have proven to be especially difficult to output
		// Verify that they will produce a valid queries
		List<String> accountIds = new List<String>{
			DmlMock.generateFakeId(Account.SObjectType),
			DmlMock.generateFakeId(Account.SObjectType)
		};
		List<String> testNames = new List<String>{ 'Test1', 'Test2' };
		List<Filter> filters = new List<Filter>{
			new Filter(Account.Id, Filter.IN_COLLECTION, accountIds),
			new Filter(Account.Name, Filter.NOT_IN_COLLECTION, testNames)
		};

		FilterLogic logic = new AndLogic().addCriteria(filters);
		String template = 'Id IN ({1}, {2}) {0} Name NOT IN ({3}, {4})';
		List<String> args = new List<String>{
			'AND',
			'\'' +
			accountIds[0] +
			'\'',
			'\'' +
			accountIds[1] +
			'\'',
			'\'' +
			testNames[0] +
			'\'',
			'\'' +
			testNames[1] +
			'\''
		};
		System.assertEquals(String.format(template, args), logic.toString(), 'Unexpected AND logic output');
		logic = new OrLogic().addCriteria(filters);
		args[0] = 'OR';
		System.assertEquals(String.format(template, args), logic.toString(), 'Unexpected OR logic output');
	}

	@IsTest
	static void shouldBeNestable() {
		// Callers can nest multiple FilterLogic instances to create the exact logical conditions they're looking for
		// 1 AND (2 OR (3 AND 4))
		FilterLogic innerAndLogic = new AndLogic()
			.addCriteria(new Filter(Account.BillingCountry, Filter.EQUALS, 'US'))
			.addCriteria(new Filter(Account.NumberOfEmployees, Filter.GREATER_THAN, 100));
		FilterLogic innerOrLogic = new OrLogic()
			.addCriteria(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
			.addCriteria(innerAndLogic);
		FilterLogic outerLogic = new AndLogic()
			.addCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
			.addCriteria(innerOrLogic);

		String expected =
			'OwnerId = \'' +
			UserInfo.getUserId() +
			'\' AND (AnnualRevenue > 1000 OR (BillingCountry = \'US\' AND NumberOfEmployees > 100))';
		System.assertEquals(expected, outerLogic.toString(), 'Unexpected nested logic output');

		Account testAcc = new Account(
			AnnualRevenue = 1001,
			BillingCountry = 'US',
			NumberOfEmployees = 101,
			OwnerId = UserInfo.getUserId()
		);
		System.assertEquals(true, outerLogic.meetsCriteria(testAcc), 'Valid account does not meet criteria');
		// Change one of the optional conditions to be false
		testAcc.AnnualRevenue = 999;
		System.assertEquals(true, outerLogic.meetsCriteria(testAcc), 'Valid account does not meet criteria');
		// Change one of the required conditions to be false
		testAcc.OwnerId = DmlMock.generateFakeId(User.SObjectType);
		System.assertEquals(false, outerLogic.meetsCriteria(testAcc), 'Invalid account meets criteria');
	}

	@IsTest
	static void shouldReturnFieldNames() {
		FilterLogic logic = new AndLogic()
			.addCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()));

		Test.startTest();
		Set<String> fieldNames = logic?.getFieldNames();
		Test.stopTest();

		System.assertEquals(1, fieldNames?.size(), 'Wrong # of field names');
		System.assertEquals(true, fieldNames?.contains('OwnerId'), 'Wrong field listed');
	}

	// **** HELPER **** //
	static List<Filter> testFilters = new List<Filter>{
		new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()),
		new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000),
		new Filter(Account.BillingCountry, Filter.EQUALS, 'USA')
	};
}
