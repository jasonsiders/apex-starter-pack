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
    static void shouldFilterListOfComplexTypes() {
        List<Account> testData = getTestData(); 
        Filter myFilter = new Filter(Account.AnnualRevenue, Filter.NOT_EQUALS, 1000); 

        Test.startTest(); 
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

    @IsTest 
    static void shouldFilterListOfPrimitiveTypes() {
        List<Integer> items = new List<Integer>{1, 2, 3, 4, 5};
        Filter myFilter = new Filter.PrimitiveFilter(Filter.GREATER_THAN, 1); 

        Test.startTest();
        List<Integer> filtered = (List<Integer>) CollectionUtils.filterCollection(
            items, 
            myFilter,
            List<Integer>.class
        );

        System.assertEquals(4, filtered?.size(), 'Wrong # of filtered items');
        for (Integer item : filtered) {
            System.assertEquals(true, item > 1, item + ' is not > 1');
        }
    }

    @IsTest 
    static void shouldReturnIndexOfList() {
        List<String> items = new List<String>{
            'foo',
            'bar',
            'hello world!'
        };
        // Get items with legal indeces
        for (Integer i = 0; i < items?.size(); i++) {
            String item = items[i];
            System.assertEquals(item, CollectionUtils.getIndexOf(items, i), 'Incorrect result');
        }
        // Get items with an illegal index
        System.assertEquals(null, CollectionUtils.getIndexOf(items, 3), 'items[3] is out of bounds, but returned a result anyways');
    }

    @IsTest 
    static void shouldReturnIndexSizeOfList() {
        List<String> items = new List<String>{'a', 'b', 'c'};
        System.assertEquals(2, CollectionUtils.getMaxIndex(items), 'Did not return the max index');
        System.assertEquals('c', items[CollectionUtils.getMaxIndex(items)], 'Max index did not return the correct value');
        items.clear();
        System.assertEquals(null, CollectionUtils.getMaxIndex(items), 'Empty list should have returned null');
        items = null; 
        System.assertEquals(null, CollectionUtils.getMaxIndex(items), 'Null list should have returned null');
    }

    @IsTest 
    static void shouldExtractValues() {
        List<Account> accounts = new List<Account>(); 
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(
                Name = 'Account #' + i
            ));
        }

        Test.startTest();
        List<String> accountNames = (List<String>) CollectionUtils.extractValues(accounts, Account.Name, List<String>.class);
        System.assertEquals(accounts.size(), accountNames?.size(), 'Wrong # of Account Names'); 
        for (Integer i = 0; i < 10; i++) {
            Account account = accounts[i];
            String name = accountNames[i];
            System.assertEquals(name, account.Name, 'Wrong name');
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
