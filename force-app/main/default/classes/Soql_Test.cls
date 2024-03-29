@IsTest
private class Soql_Test {
	@IsTest
	static void shouldGenerateSimpleQuery() {
		Soql query = new Soql(Account.SObjectType).selectFields(Account.OwnerId);
		Soql_Test.checkQueryString('SELECT Id, OwnerId FROM Account', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWihAllFields() {
		Soql query = new Soql(Account.SObjectType).selectAll();
		for (SObjectField field : Account.SObjectType?.getDescribe()?.fields?.getMap()?.values()) {
			String fieldName = String.valueOf(field);
			System.assert(
				query.selectClauses?.contains(fieldName),
				'Missing field (' +
				fieldName +
				'): ' +
				query?.toString()
			);
		}
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithParentFields() {
		Soql query = new Soql(Account.SObjectType)
			.selectFields(new FieldRef(new List<SObjectField>{ Account.OwnerId, User.Name }));
		Soql_Test.checkQueryString('SELECT Id, Owner.Name FROM Account', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithSubqueries() {
		SubQuery contactsSubQuery = new SubQuery(Contact.AccountId);
		Soql query = new Soql(Account.SObjectType).selectSubQuery(contactsSubQuery);
		Soql_Test.checkQueryString('SELECT Id, (SELECT Id FROM Contacts) FROM Account', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldDeselectIdField() {
		Soql query = new Soql(Account.SObjectType).selectFields(Account.OwnerId).deselectId();
		Soql_Test.checkQueryString('SELECT OwnerId FROM Account', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateAggregateQuery() {
		SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.SUM, Account.AnnualRevenue);
		Soql query = new Soql(Account.SObjectType)
			.selectFields(Account.BillingCountry)
			.selectAggregation(aggregation)
			.groupBy(Account.BillingCountry);
		Soql_Test.checkQueryString(
			'SELECT BillingCountry, SUM(AnnualRevenue) FROM Account GROUP BY BillingCountry',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateAggregateQueryWithAlias() {
		SoqlAggregation aggregation = new SoqlAggregation(
			SoqlAggregation.Function.SUM,
			Account.AnnualRevenue,
			'accountValue'
		);
		Soql query = new Soql(Account.SObjectType)
			.selectFields(Account.BillingCountry)
			.selectAggregation(aggregation)
			.groupBy(Account.BillingCountry);
		Soql_Test.checkQueryString(
			'SELECT BillingCountry, SUM(AnnualRevenue) accountValue FROM Account GROUP BY BillingCountry',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateAggregateQueryGroupedByParentField() {
		FieldRef fieldRef = new FieldRef(new List<SObjectField>{ Lead.ConvertedAccountId, Account.Name });
		SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.MAX, Lead.CreatedDate);
		Soql query = new Soql(Lead.SObjectType).selectFields(fieldRef).selectAggregation(aggregation).groupBy(fieldRef);
		Soql_Test.checkQueryString(
			'SELECT ConvertedAccount.Name, MAX(CreatedDate) FROM Lead GROUP BY ConvertedAccount.Name',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateAggregateQueryWithHavingClause() {
		SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.COUNT, Lead.Name);
		Soql query = new Soql(Lead.SObjectType)
			.selectFields(Lead.LeadSource)
			.selectAggregation(aggregation)
			.groupBy(Lead.LeadSource)
			.havingCriteria(new SoqlAggregation.AggregateFilter(aggregation, Filter.GREATER_THAN, 100));
		Soql_Test.checkQueryString(
			'SELECT LeadSource, COUNT(Name) FROM Lead GROUP BY LeadSource HAVING COUNT(Name) > 100',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateAggregateQueryWithMultipleHavingClauses() {
		SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.COUNT, Lead.Name);
		Soql query = new Soql(Lead.SObjectType)
			.selectFields(Lead.LeadSource)
			.selectAggregation(aggregation)
			.groupBy(Lead.LeadSource)
			.havingCriteria(new SoqlAggregation.AggregateFilter(aggregation, Filter.GREATER_THAN, 100))
			.havingCriteria(new SoqlAggregation.AggregateFilter(aggregation, Filter.LESS_THAN, 1000));
		// By default, the HAVING filter logic is always AND
		Soql_Test.checkQueryString(
			'SELECT LeadSource, COUNT(Name) FROM Lead GROUP BY LeadSource HAVING COUNT(Name) > 100 AND COUNT(Name) < 1000',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateAggregateQueryWithHavingLogic() {
		SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.COUNT, Lead.Name);
		Soql query = new Soql(Lead.SObjectType)
			.selectFields(Lead.LeadSource)
			.selectAggregation(aggregation)
			.groupBy(Lead.LeadSource)
			.havingCriteria(new SoqlAggregation.AggregateFilter(aggregation, Filter.GREATER_THAN, 100))
			.havingCriteria(new SoqlAggregation.AggregateFilter(aggregation, Filter.LESS_THAN, 1000))
			.setHavingLogic(OrLogic.class);
		Soql_Test.checkQueryString(
			'SELECT LeadSource, COUNT(Name) FROM Lead GROUP BY LeadSource HAVING COUNT(Name) > 100 OR COUNT(Name) < 1000',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithRunningContext() {
		// Check for USER_MODE
		Soql query = new Soql(Account.SObjectType)
			.withExpression(new SoqlWithClause.ContextExpression(SoqlWithClause.Context.USER_MODE));
		Soql_Test.checkQueryString('SELECT Id FROM Account WITH USER_MODE', query);
		Soql_Test.runTestQuery(query);
		// Check again for SYSTEM_MODE
		query.withExpression(new SoqlWithClause.ContextExpression(SoqlWithClause.Context.SYSTEM_MODE));
		Soql_Test.checkQueryString('SELECT Id FROM Account WITH SYSTEM_MODE', query);
		Soql_Test.runTestQuery(query);
		// Chcek again for SECURITY_ENFORCED
		query.withExpression(new SoqlWithClause.ContextExpression(SoqlWithClause.Context.SECURITY_ENFORCED));
		Soql_Test.checkQueryString('SELECT Id FROM Account WITH SECURITY_ENFORCED', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryForDataCategories() {
		Soql query = new Soql(Account.SObjectType)
			// Note: Normally this would fail when querying a non-knowledge object,
			// But knowledge must be enabled in order to test this properly
			.withExpression(
				new SoqlWithClause.DataCategoryExpression(
					new OrLogic()
						.addCriteria(
							new List<DataCategoryFilter>{
								new DataCategoryFilter('CategoryA__c', DataCategoryFilter.ABOVE, 'CategoryB__c'),
								new DataCategoryFilter(
									'CategoryC__c',
									DataCategoryFilter.BELOW,
									new List<String>{ 'CategoryD__c', 'CategoryE__c', 'CategoryF__c' }
								)
							}
						)
				)
			);
		Soql_Test.checkQueryString(
			'SELECT Id FROM Account WITH CategoryA__c ABOVE CategoryB__c OR CategoryC__c BELOW (CategoryD__c, CategoryE__c, CategoryF__c)',
			query
		);
		// Cannot actually test running this query, since knowledge may/may not be enabled in your org
	}

	@IsTest
	static void shouldGenerateQueryWithOneWhereClause() {
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000));
		Soql_Test.checkQueryString('SELECT Id FROM Account WHERE AnnualRevenue > 1000', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithMultipleWhereClauses() {
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
			.whereCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()));
		Soql_Test.checkQueryString(
			'SELECT Id FROM Account WHERE AnnualRevenue > 1000 AND OwnerId = \'' +
			UserInfo.getUserId() +
			'\'',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithAndFilterLogic() {
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
			.whereCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
			.whereCriteria(new Filter(Account.CreatedDate, Filter.LESS_THAN, DateTime.newInstanceGmt(2022, 1, 1)));
		Soql_Test.checkQueryString(
			'SELECT Id FROM Account WHERE AnnualRevenue > 1000 AND OwnerId = \'' +
			UserInfo.getUserId() +
			'\' AND CreatedDate < 2022-01-01T00:00:00Z',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithOrFilterLogic() {
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
			.whereCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
			.whereCriteria(new Filter(Account.CreatedDate, Filter.LESS_THAN, DateTime.newInstanceGmt(2022, 1, 1)))
			.setWhereLogic(OrLogic.class);
		Soql_Test.checkQueryString(
			'SELECT Id FROM Account WHERE AnnualRevenue > 1000 OR OwnerId = \'' +
			UserInfo.getUserId() +
			'\' OR CreatedDate < 2022-01-01T00:00:00Z',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithNestedFilterLogic() {
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
			.whereCriteria(
				new AndLogic()
					.addCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
					.addCriteria(new Filter(Account.CreatedDate, Filter.LESS_THAN, DateTime.newInstanceGmt(2022, 1, 1)))
			)
			.setWhereLogic(OrLogic.class);
		Soql_Test.checkQueryString(
			'SELECT Id FROM Account WHERE AnnualRevenue > 1000 OR (OwnerId = \'' +
			UserInfo.getUserId() +
			'\' AND CreatedDate < 2022-01-01T00:00:00Z)',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithParentFieldFilters() {
		Soql query = new Soql(Opportunity.SObjectType)
			.whereCriteria(new Filter('Account.AnnualRevenue', Filter.GREATER_THAN, 1000));
		Soql_Test.checkQueryString('SELECT Id FROM Opportunity WHERE Account.AnnualRevenue > 1000', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithInnerQueries() {
		// The Filter class consumes SOQL objects as IN_COLLECTION / NOT_IN_COLLECTION values
		Soql innerQuery = new Soql(User.SObjectType)
			.deselectId()
			.selectFields(User.ProfileId)
			.whereCriteria(new Filter(User.Id, Filter.EQUALS, UserInfo.getUserId()));
		Soql query = new Soql(Profile.SObjectType)
			.whereCriteria(new Filter(Profile.Id, Filter.IN_COLLECTION, innerQuery));
		Soql_Test.checkQueryString(
			'SELECT Id FROM Profile WHERE Id IN (SELECT ProfileId FROM User WHERE Id = \'' +
			UserInfo.getUserId() +
			'\')',
			query
		);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryUsingScope() {
		Soql query = new Soql(Account.SObjectType).usingScope(Soql.Scope.MINE);
		Soql_Test.checkQueryString('SELECT Id FROM Account USING SCOPE mine', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithSingleOrderBy() {
		Soql query = new Soql(Account.SObjectType)
			.orderBy(new SoqlSort(Account.AnnualRevenue, SoqlSort.Order.ASCENDING));
		Soql_Test.checkQueryString('SELECT Id FROM Account ORDER BY AnnualRevenue ASC', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldGenerateQueryWithMultipleOrdersBy() {
		SoqlSort orderBy = new SoqlSort(
			new List<SObjectField>{ Account.AnnualRevenue, Account.CreatedDate },
			SoqlSort.Order.ASCENDING
		);
		Soql query = new Soql(Account.SObjectType).orderBy(orderBy);
		Soql_Test.checkQueryString('SELECT Id FROM Account ORDER BY AnnualRevenue, CreatedDate ASC', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldSetRowLimit() {
		Soql query = new Soql(Account.SObjectType).setRowLimit(200);
		Soql_Test.checkQueryString('SELECT Id FROM Account LIMIT 200', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldSetRowOffset() {
		Soql query = new Soql(Account.SObjectType).setRowOffset(200);
		Soql_Test.checkQueryString('SELECT Id FROM Account OFFSET 200', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldSetRowLimitAndOffset() {
		Soql query = new Soql(Account.SObjectType).setRowLimit(200).setRowOffset(100);
		Soql_Test.checkQueryString('SELECT Id FROM Account LIMIT 200 OFFSET 100', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldSetUsage() {
		Soql query = new Soql(Account.SObjectType).forUsage(Soql.Usage.FOR_REFERENCE);
		Soql_Test.checkQueryString('SELECT Id FROM Account FOR REFERENCE', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest 
	static void shouldHandleBindQuery() {
		Id userId = UserInfo.getUserId();
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.OwnerId, Filter.EQUALS, ':userId'))
			.bind('userId', userId);
		Soql_Test.checkQueryString('SELECT Id FROM Account WHERE OwnerId = :userId', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest 
	static void shouldHandleAccessLevel() {
		// AccessLevel defaults to USER_MODE, but can be overridden
		AccessLevel mode = AccessLevel.SYSTEM_MODE;
		Soql query = new Soql(Account.SObjectType).setAccessLevel(mode);
		// This does not appear in the actual query string; used as an arg in Database.query()
		System.assertEquals(mode, query.access, 'AccessLevel was not set');
		Soql_Test.checkQueryString('SELECT Id FROM Account', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldHandleRelativeDateQuery() {
		Soql query = new Soql(Account.SObjectType)
			.whereCriteria(new Filter(Account.CreatedDate, Filter.EQUALS, 'LAST_N_DAYS:10'));
		Soql_Test.checkQueryString('SELECT Id FROM Account WHERE CreatedDate = LAST_N_DAYS:10', query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldHandleComplexQuery() {
		Soql query = new Soql(Account.SObjectType)
			.selectFields(new List<SObjectField>{ Account.Id, Account.CreatedDate, Account.Name })
			.selectFields(new FieldRef(new List<SObjectField>{ Account.OwnerId, User.ProfileId }))
			.whereCriteria(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'))
			.whereCriteria(new Filter(Account.CreatedDate, Filter.GREATER_THAN, DateTime.newInstanceGmt(2022, 1, 1)))
			.whereCriteria(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
			.setWhereLogic(OrLogic.class)
			.orderBy(new SoqlSort(new List<String>{ 'CreatedDate', 'AnnualRevenue' }, SoqlSort.Order.DESCENDING))
			.setRowLimit(200)
			.withExpression(new SoqlWithClause.ContextExpression(SoqlWithClause.Context.SECURITY_ENFORCED))
			.forUsage(Soql.Usage.ALL_ROWS)
			.usingScope(Soql.Scope.EVERYTHING);
		final String expected =
			'SELECT Id, CreatedDate, Name, Owner.ProfileId FROM Account ' +
			'USING SCOPE everything ' +
			'WHERE Name LIKE \'Test Account%\' OR ' +
			'CreatedDate > 2022-01-01T00:00:00Z OR ' +
			'OwnerId = \'' +
			UserInfo.getUserId() +
			'\' ' +
			'WITH SECURITY_ENFORCED ' +
			'ORDER BY CreatedDate, AnnualRevenue DESC ' +
			'LIMIT 200 ALL ROWS';
		Soql_Test.checkQueryString(expected, query);
		Soql_Test.runTestQuery(query);
	}

	@IsTest
	static void shouldReturnSoqlResults() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 3; i++) {
			accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
		}
		DB.Dml.doInsert(accounts);
		Soql query = new Soql(Account.SObjectType)
			.selectFields(new List<SObjectField>{ Account.Id, Account.CreatedDate, Account.Name })
			.whereCriteria(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'))
			.orderBy(new SoqlSort(Account.CreatedDate, SoqlSort.Order.DESCENDING))
			.setRowLimit(200);
		Test.startTest();
		List<SObject> results = query.run();
		Test.stopTest();
		System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of results');
		for (Account account : (List<Account>) results) {
			System.assertNotEquals(null, account?.Id, 'Unexpected Account.Id');
			System.assertNotEquals(null, account?.CreatedDate, 'Unexpected Account.CreatedDate');
			System.assert(
				account?.Name?.startsWith('Test Account'),
				'Unexpected Account.Name. Expected "Test Account%". Actual: ' + account?.Name
			);
		}
	}

	@IsTest
	static void shouldReturnWrapperClass() {
		// Insert 3 accounts for US and CA
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 3; i++) {
			accounts.add(new Account(BillingCountry = 'CA', Name = 'CA Account #' + i));
			accounts.add(new Account(BillingCountry = 'US', Name = 'US Account #' + i));
		}
		DB.Dml.doInsert(accounts);

		Test.startTest();
		Soql query = new Soql(Account.SObjectType)
			.selectFields(Account.BillingCountry)
			.selectAggregation(new SoqlAggregation(SoqlAggregation.Function.COUNT, Account.Id, 'numAccs'))
			.groupBy(Account.BillingCountry);
		List<SampleWrapper> results = (List<SampleWrapper>) query.run(List<SampleWrapper>.class);
		Test.stopTest();

		System.assertEquals(2, results?.size(), 'Wrong # of results');
		for (SampleWrapper wrapper : results) {
			System.assertEquals(3, wrapper.numAccs, 'Wrong # of accs');
		}
	}

	@IsTest
	static void shouldThrowErrorIfInvalidQuery() {
		Soql query = new Soql(Account.SObjectType).selectFields('lajksdf');
		Test.startTest();
		Exception caughtError;
		try {
			query.run();
		} catch (System.QueryException thrownError) {
			caughtError = thrownError;
		}
		System.assertNotEquals(null, caughtError, 'An error was not thrown for an invalid query');
	}

	@IsTest
	static void shouldGenerateNewQuery() {
		DB.QueryFactory factory = new Soql.Factory();
		Object queryObj = factory.newQuery(null);
		System.assertEquals(true, queryObj instanceof Soql, 'Not an instance of Soql.class');
		System.assertEquals(false, queryObj instanceof SoqlMock, 'Factory created an instance of SoqlMock.class');
	}

	// **** HELPER **** //
	static void checkQueryString(String expected, Soql query) {
		System.assert(
			expected == query?.toString(),
			'Unexpected query.\nExpected: "' +
			expected +
			'".\nActual: "' +
			query?.toString() +
			'"'
		);
	}

	static void runTestQuery(Soql query) {
		try {
			query.run();
		} catch (System.QueryException queryError) {
			System.assert(false, queryError);
		}
	}

	public class SampleWrapper {
		Integer numAccs;
		String billingCountry;
	}
}
