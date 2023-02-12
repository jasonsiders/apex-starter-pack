@IsTest
private class DB_Test {
	@IsTest
	static void shouldUseRealDatabaseOperationsByDefault() {
		System.assertEquals(Dml.class, TypeUtils.getType(DB.Dml), 'Wrong Dml Engine');
		System.assertEquals(true, DB.Soql instanceOf Soql.Factory, 'Wrong Query Engine');
	}

	@IsTest
	static void shouldAllowMockDmlOperations() {
		Dml mockDml = new DmlMock();

		Test.startTest();
		DB.setDmlEngine(mockDml);
		Test.stopTest();

		System.assertEquals(true, DB.Dml instanceOf DmlMock, 'Not a mock instance');
		System.assertEquals(mockDml, DB.Dml, 'Wrong DML Engine');
	}

	@IsTest 
	static void shouldPreventDmlMocksOutsideOfTestContext() {
		Dml mockDml = new DmlMock(); 
		DB.IsTest = false; // Mock a non-@IsTest context

		Test.startTest();
		Exception caughtError; 
		try {
			DB.setDmlEngine(mockDml);
		} catch (DB.ContextException error) {
			caughtError = error; 
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown');
		System.assertEquals(false, DB.Dml instanceOf DmlMock, 'Mock instance was supplied anyways');
	}

	@IsTest
	static void shouldAllowMockSoqlOperations() {
		DB.QueryFactory mockSoql = new SoqlMock.Factory();

		Test.startTest();
		DB.setQueryEngine(mockSoql);
		Test.stopTest();

		System.assertEquals(true, DB.Soql instanceOf SoqlMock.Factory, 'Not a mock instance');
		System.assertEquals(mockSoql, DB.Soql, 'Wrong Query Engine');
	}

	@IsTest 
	static void shouldPreventSoqlMocksOutsideOfTestContext() {
		DB.QueryFactory mockSoql = new SoqlMock.Factory();
		DB.IsTest = false; // Mock a non-@IsTest context
		 
		Test.startTest();
		Exception caughtError;
		try {
			DB.setQueryEngine(mockSoql);
		} catch (DB.ContextException error) {
			caughtError = error; 
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown');
		System.assertEquals(false, DB.Soql instanceOf SoqlMock.Factory, 'Mock instance was supplied anyways');
	}
}
