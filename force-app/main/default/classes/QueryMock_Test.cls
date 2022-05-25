@IsTest
private class QueryMock_Test {
    @IsTest 
    static void shouldQueryMock() {
        // Generate a stupid amount of records, insert them via mock Dml, then retrieve them via mock query
        QueryMock.Factory queryFactory = (QueryMock.Factory) DatabaseLayer.setQueryEngine(new QueryMock.Factory()); 
        DatabaseLayer.setDmlEngine(new DmlMock());
        List<Account> accounts = new List<Account>(); 
        for (Integer i = 0; i < 10000; i++) {
            accounts.add(new Account(
                Name = 'Test Account #' + (i + 1),
                AnnualRevenue = (i * i)
            )); 
        } 
        DatabaseLayer.DmlEngine.doInsert(accounts); 
        queryFactory.setMockResults(accounts); 
        
        Test.startTest();
        IQuery query = DatabaseLayer.QueryEngine.newQuery(Account.SObjectType)
            .addFields(new List<SObjectField>{Account.Name, Account.AnnualRevenue})
            .addFilters(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'));
        List<Account> results = (List<Account>) query.run(); 
        Test.stopTest();
        System.assertEquals(results?.size(), accounts?.size(), 'Wrong # of results'); 
        for (Account account : results) {
            System.assertNotEquals(null, account.Id); 
            System.assertNotEquals(null, account.AnnualRevenue); 
            System.assert(account?.Name?.startsWithIgnoreCase('Test Account'), 'Expected to start with "Test Account", Actual: "' + account?.Name + '"');
        }
    }

    @IsTest
    static void shouldGenerateNewQuery() {
        IQueryFactory factory = new QueryMock.Factory();
        IQuery query = factory.newQuery(null); 
        System.assertEquals(true, query instanceOf QueryMock, 'Wrong type of IQuery generated');
    }
}