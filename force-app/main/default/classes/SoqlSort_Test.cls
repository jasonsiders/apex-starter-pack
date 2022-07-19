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
        FieldReference fieldReference = new FieldReference(new List<SObjectField>{
            Contact.AccountId, 
            Account.OwnerId,
            User.ProfileId,
            Profile.CreatedDate
        });
        SoqlSort sorter = new SoqlSort(fieldReference, SoqlSort.Order.ASCENDING); 
        System.assertEquals('Account.Owner.Profile.CreatedDate' + ' ASC', sorter.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldHandleMultipleParentFields() {
        List<FieldReference> fieldReferences = new List<FieldReference>{
            new FieldReference(new List<SObjectField>{Account.OwnerId, User.Name}),
            new FieldReference(new List<SObjectField>{Account.OwnerId, User.ProfileId}),
            new FieldReference(new List<SObjectField>{Account.OwnerId, User.ManagerId, User.Name})
        };
        SoqlSort sorter = new SoqlSort(fieldReferences, SoqlSort.Order.ASCENDING);
        System.assertEquals('Owner.Name, Owner.ProfileId, Owner.Manager.Name ASC', sorter.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldHandleStringConstructors() {
        SoqlSort sorter = new SoqlSort('Id', SoqlSort.Order.ASCENDING);
        System.assertEquals('Id ASC', sorter.toString(), 'Unexpected output');
        // Should work with null sorts too
        sorter = new SoqlSort('Id', SoqlSort.Order.ASCENDING, SoqlSort.NullOrder.FIRST);
        System.assertEquals('Id ASC NULLS FIRST', sorter.toString(), 'Unexpected output'); 
        // Would also work with multiple
        sorter = new SoqlSort(new List<String>{'Id', 'CreatedDate'}, SoqlSort.Order.ASCENDING);
        System.assertEquals('Id, CreatedDate ASC', sorter.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldDefineNullSort() {
        SoqlSort sorter = new SoqlSort(Account.CreatedDate, SoqlSort.Order.Ascending, SoqlSort.NullOrder.FIRST);
        System.assertEquals('CreatedDate ASC NULLS FIRST', sorter.toString(), 'Unexpected output');
    }
}