@IsTest
private class DB_Test {
	@IsTest
	static void shouldUseRealDatabaseOperationsByDefault() {
		System.assertEquals(Dml.class, TypeUtils.getType(DB.Dml), 'Wrong Dml Engine');
		System.assertEquals(true, DB.Soql instanceof Soql.Factory, 'Wrong Query Engine');
	}

	@IsTest
	static void shouldAllowMockDmlOperations() {
		Dml mockDml = new DmlMock();
		DB.setDmlEngine(mockDml);
		System.assertEquals(true, DB.Dml instanceof DmlMock, 'Not a mock instance');
		System.assertEquals(mockDml, DB.Dml, 'Wrong DML Engine');
	}

	@IsTest
	static void shouldAllowMockSoqlOperations() {
		DB.QueryFactory mockSoql = new SoqlMock.Factory();
		DB.setQueryEngine(mockSoql);
		System.assertEquals(true, DB.Soql instanceof SoqlMock.Factory, 'Not a mock instance');
		System.assertEquals(mockSoql, DB.Soql, 'Wrong Query Engine');
	}
}
