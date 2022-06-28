@IsTest 
private class DatabaseLayer_Test {
    @IsTest 
    static void shouldUseRealDatabaseOperationsByDefault() {
        System.assertEquals(Dml.class, TypeUtils.getType(Databaselayer.Dml), 'Wrong Dml Engine');
        System.assertEquals(true, Databaselayer.Soql instanceOf Soql.Factory, 'Wrong Query Engine');
    }

    @IsTest 
    static void shouldAllowMockDmlOperations() {
        Dml mockDml = new DmlMock(); 
        DatabaseLayer.setDmlEngine(mockDml); 
        System.assertEquals(true, Databaselayer.Dml instanceOf DmlMock, 'Not a mock instance'); 
        System.assertEquals(mockDml, Databaselayer.Dml, 'Wrong DML Engine');
    }

    @IsTest 
    static void shouldAllowMockSoqlOperations() {
        DatabaseLayer.QueryFactory mockSoql = new SoqlMock.Factory(); 
        DatabaseLayer.setQueryEngine(mockSoql);
        System.assertEquals(true, Databaselayer.Soql instanceOf SoqlMock.Factory, 'Not a mock instance');
        System.assertEquals(mockSoql, Databaselayer.Soql, 'Wrong Query Engine');
    }
}
