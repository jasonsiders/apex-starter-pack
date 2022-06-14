@IsTest
private class CollectionUtils_Test {
    @IsTest 
    static void shouldMapByUniqueKey() {
        List<Account> testData = getTestData(); 

        Test.startTest();
        Map<Decimal, Account> accountsByRevenue = (Map<Decimal, Account>) CollectionUtils.mapByUniqueKey(
            testData, 
            Account.AnnualRevenue, 
            Map<Decimal, Account>.class
        );
        Test.stopTest();    

        System.assertEquals(10, accountsByRevenue?.keySet().size(), 'Wrong # of keys');
        for (Decimal revenue : accountsByRevenue.keySet()) {
            Account account = accountsByRevenue.get(revenue); 
            System.assertEquals(revenue, account.AnnualRevenue, 'Wrong key value');
        }
    }

    @IsTest 
    static void shouldMapByCommonKey() {
        List<Account> testData = getTestData(); 

        Test.startTest();
        Map<Id, List<Account>> accountsByOwner = (Map<Id, List<Account>>) CollectionUtils.mapByCommonKey(
            testData, 
            Account.OwnerId,
            Map<Id, List<Account>>.class
        );
        Test.stopTest();    

        System.assertEquals(1, accountsByOwner?.keySet().size(), 'Wrong # of keys');
        System.assertEquals(10, accountsByOwner?.values()[0]?.size(), 'Wrong # of values for ' + UserInfo.getUserId());
    }

    @IsTest 
    static void shouldFilterList() {
        List<Account> testData = getTestData(); 

        Test.startTest(); 
        Filter myFilter = new Filter(Account.AnnualRevenue, Filter.NOT_EQUALS, 1000); 
        List<Account> filtered = (List<Account>) CollectionUtils.filterCollection(
            testData, 
            myFilter, 
            List<Account>.class
        ); 
        Test.stopTest();

        System.assertEquals(9, filtered?.size(), 'Wrong # of filtered accounts');
        for (Account account : filtered) {
            System.assertEquals(true, account.AnnualRevenue != 1000, 'Filter was not applied correctly: ' + myFilter.toString() + ': ' + JSON.serialize(account)); 
        }
    }

    // **** HELPER **** //
    static List<Account> getTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(
                AnnualRevenue = 1000 * i,
                OwnerId = UserInfo.getUserId()
            ));
        }
        return accounts;
    }
}
