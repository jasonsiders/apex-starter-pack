@IsTest
private class SoqlMock_Test {
	@IsTest
	static void shouldMockQuery() {
		// Generate a stupid amount of records, insert them via mock Dml, then retrieve them via mock query
		SoqlMock.Factory queryFactory = (SoqlMock.Factory) DB.setQueryEngine(new SoqlMock.Factory());
		DB.setDmlEngine(new DmlMock());
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 10000; i++) {
			accounts.add(new Account(Name = 'Test Account #' + (i + 1), AnnualRevenue = (i * i)));
		}
		DB.Dml.doInsert(accounts);
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.selectFields(new List<SObjectField>{ Account.Name, Account.AnnualRevenue })
			.whereCriteria(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'));
		query?.toMock()?.setMockResults(accounts);

		Test.startTest();
		List<Account> results = (List<Account>) query.run();
		Test.stopTest();

		System.assertEquals(results?.size(), accounts?.size(), 'Wrong # of results');
		for (Account account : results) {
			System.assertNotEquals(null, account.Id, 'Account does not have an Id');
			System.assertNotEquals(null, account.AnnualRevenue, 'Annual Revenue not populated');
			System.assert(
				account?.Name?.startsWithIgnoreCase('Test Account'),
				'Expected to start with "Test Account", Actual: "' +
				account?.Name +
				'"'
			);
		}
	}

	@IsTest
	static void shouldMockQueryResults() {
		DB.setQueryEngine(new SoqlMock.Factory());
		String key = 'My_Cool_Query';
		Soql query = DB.Soql.newQuery(Account.SObjectType);
		// In test environments, no Accounts exist
		// Without setting mock data, this will return an empty List<SObject>
		System.assertEquals(0, query?.run()?.size(), 'Wrong # of results');
		// Add some mock data to the query, indirectly. Now it should return those results
		List<Account> mockData = new List<Account>{ new Account(Name = 'Test Account') };
		query?.toMock()?.setMockResults(mockData);
		System.assertEquals(mockData, query?.run(), 'Did not return mockData');
	}

	@IsTest
	static void shouldGenerateNewQuery() {
		DB.setQueryEngine(new SoqlMock.Factory());
		Soql query = DB.Soql.newQuery(null);
		System.assertEquals(true, query instanceof SoqlMock, 'Wrong type of Soql generated');
	}
}
