@IsTest 
private class DatabaseLayer_Test {
    @IsTest 
    static void shouldUseRealDatabaseOperationsByDefault() {
        System.assertEquals(true, DatabaseLayer.DmlEngine instanceOf Dml, 'Wrong Dml Engine');
        System.assertEquals(true, DatabaseLayer.QueryEngine instanceOf SoqlQuery.Factory, 'Wrong Query Engine');
    }

    @IsTest 
    static void shouldAllowMockDmlOperations() {
        IDml mockDml = new DmlMock(); 
        DatabaseLayer.setDmlEngine(mockDml); 
        System.assertEquals(true, DatabaseLayer.DmlEngine instanceOf DmlMock, 'Not a mock instance'); 
        System.assertEquals(mockDml, DatabaseLayer.DmlEngine, 'Wrong DML Engine');
    }

    @IsTest 
    static void shouldAllowMockSoqlOperations() {
        IQueryFactory mockSoql = new QueryMock.Factory(); 
        DatabaseLayer.setQueryEngine(mockSoql);
        System.assertEquals(true, DatabaseLayer.QueryEngine instanceOf QueryMock.Factory, 'Not a mock instance');
        System.assertEquals(mockSoql, DatabaseLayer.QueryEngine, 'Wrong Query Engine');
    }
}
