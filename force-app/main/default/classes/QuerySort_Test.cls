@IsTest 
private class QuerySort_Test {
    @IsTest 
    static void shouldReturnValidOrderByStatement() {
        QuerySort sorter = new QuerySort(Account.CreatedDate, QuerySort.Order.ASCENDING);
        System.assertEquals('CreatedDate ASC', sorter.toString()); 
        sorter =  new QuerySort(Account.CreatedDate, QuerySort.Order.DESCENDING); 
        System.assertEquals('CreatedDate DESC', sorter.toString()); 
    }   

    @IsTest 
    static void shouldHandleMultipleFields() {
        QuerySort sorter = new QuerySort(
            new List<SObjectField>{Account.CreatedDate, Account.AnnualRevenue}, 
            QuerySort.Order.DESCENDING
        ); 
        System.assertEquals('CreatedDate, AnnualRevenue DESC', sorter.toString()); 
    }

    @IsTest 
    static void shouldHandleParentFields() {
        final String reallyLongParentReference = 'Account.Owner.Profile.CreatedDate';
        QuerySort sorter = new QuerySort(reallyLongParentReference, QuerySort.Order.ASCENDING); 
        System.assertEquals(reallyLongParentReference + ' ASC', sorter.toString());
    }
}