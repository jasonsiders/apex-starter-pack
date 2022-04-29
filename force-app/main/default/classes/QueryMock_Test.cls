@IsTest
private class QueryMock_Test {
    @IsTest 
    static void shouldQueryMock() {
        // Generate a stupid amount of records, insert them via mock Dml, then retrieve them via mock query
        List<Account> accounts = new List<Account>(); 
        for (Integer i = 0; i < 10000; i++) {
            accounts.add(new Account(
                Name = 'Test Account #' + (i + 1),
                AnnualRevenue = (i * i)
            )); 
        }
        new DmlMock().doInsert(accounts); 
        Test.startTest();
        IQuery query = new QueryMock(Account.SObjectType, accounts)
            .addFields(new List<SObjectField>{Account.Name, Account.AnnualRevenue})
            .addFilters(new QueryFilter(Account.Name, QueryFilter.Operator.STARTS_WITH, 'Test Account'));
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