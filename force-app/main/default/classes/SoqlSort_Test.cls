@IsTest 
private class SoqlSort_Test {
    @IsTest 
    static void shouldReturnValidOrderByStatement() {
        SoqlSort sorter = new SoqlSort(Account.CreatedDate, SoqlSort.Order.ASCENDING);
        System.assertEquals('CreatedDate ASC', sorter.toString(), 'Unexpected output'); 
        sorter =  new SoqlSort(Account.CreatedDate, SoqlSort.Order.DESCENDING); 
        System.assertEquals('CreatedDate DESC', sorter.toString(), 'Unexpected output'); 
    }   

    @IsTest 
    static void shouldHandleMultipleFields() {
        SoqlSort sorter = new SoqlSort(
            new List<SObjectField>{Account.CreatedDate, Account.AnnualRevenue}, 
            SoqlSort.Order.DESCENDING
        ); 
        System.assertEquals('CreatedDate, AnnualRevenue DESC', sorter.toString(), 'Unexpected output'); 
    }

    @IsTest 
    static void shouldHandleParentFields() {
        final String reallyLongParentReference = 'Account.Owner.Profile.CreatedDate';
        SoqlSort sorter = new SoqlSort(reallyLongParentReference, SoqlSort.Order.ASCENDING); 
        System.assertEquals(reallyLongParentReference + ' ASC', sorter.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldHandleMultipleParentFields() {
        List<String> fieldNames = new List<String>{
            'Owner.Name', 
            'Owner.ProfileId',
            'Owner.Manager.Name'
        };
        SoqlSort sorter = new SoqlSort(fieldNames, SoqlSort.Order.ASCENDING);
        System.assertEquals('Owner.Name, Owner.ProfileId, Owner.Manager.Name ASC', sorter.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldDefineNullSort() {
        SoqlSort sorter = new SoqlSort(Account.CreatedDate, SoqlSort.Order.Ascending, SoqlSort.NullOrder.FIRST);
        System.assertEquals('CreatedDate ASC NULLS FIRST', sorter.toString(), 'Unexpected output');
    }
}