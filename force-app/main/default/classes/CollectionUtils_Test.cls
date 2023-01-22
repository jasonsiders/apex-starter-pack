@IsTest
private class CollectionUtils_Test {
	@IsTest
	static void shouldMapByUniqueKey() {
		List<Account> testData = CollectionUtils_Test.initAccounts(10);

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
		List<Account> testData = CollectionUtils_Test.initAccounts(10);

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
		List<Account> testData = CollectionUtils_Test.initAccounts(10);
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
			System.assertEquals(
				true,
				account.AnnualRevenue != 1000,
				'Filter was not applied correctly: ' + myFilter.toString()
			);
		}
	}

	@IsTest
	static void shouldFilterListOfPrimitiveTypes() {
		List<Integer> items = new List<Integer>{ 1, 2, 3, 4, 5 };
		Filter myFilter = new PrimitiveFilter(Filter.GREATER_THAN, 1);

		Test.startTest();
		List<Integer> filtered = (List<Integer>) CollectionUtils.filterCollection(items, myFilter, List<Integer>.class);

		System.assertEquals(4, filtered?.size(), 'Wrong # of filtered items');
		for (Integer item : filtered) {
			System.assertEquals(true, item > 1, item + ' is not > 1');
		}
	}

	@IsTest 
    static void shouldGetIndexOfCollection() {
		List<Account> accounts = new List<Account>(); 
		for (Integer i = 0; i < 10; i++) {
			Account account = new Account(
				BillingCountry = 'US', 
				Name = 'Test Account #' + i
			);
			accounts.add(account);  
		}
        
        // If index is in bounds, will return the value corresponding to that index
        for (Integer i = 0; i < accounts?.size(); i++) {
            Account account = (Account) CollectionUtils.getIndexOf(accounts, i);
            System.assertEquals(accounts[i], account, 'Wrong Account returned'); 
        }

        // If index is out of bounds, will return null
        for (Integer illegalIndex : new List<Integer>{-1, accounts?.size() + 1, null}) {
            System.assertEquals(null, CollectionUtils.getIndexOf(accounts, illegalIndex), 'Illegal index did not return null');
        }

        // If empty/null list, will return null
        System.assertEquals(null, CollectionUtils.getIndexOf(new List<Account>(), 0), 'Empty list did not return null');
        System.assertEquals(null, CollectionUtils.getIndexOf(null, 0), 'Null list did not return null');
    }

	@IsTest
	static void shouldReturnIndexSizeOfList() {
		List<String> items = new List<String>{ 'a', 'b', 'c' };
		System.assertEquals(2, CollectionUtils.getMaxIndex(items), 'Did not return the max index');
		System.assertEquals(
			'c',
			items[CollectionUtils.getMaxIndex(items)],
			'Max index did not return the correct value'
		);
		items.clear();
		System.assertEquals(null, CollectionUtils.getMaxIndex(items), 'Empty list should have returned null');
		items = null;
		System.assertEquals(null, CollectionUtils.getMaxIndex(items), 'Null list should have returned null');
	}

	@IsTest
	static void shouldExtractValues() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			accounts.add(new Account(Name = 'Account #' + i));
		}

		Test.startTest();
		List<String> accountNames = (List<String>) CollectionUtils.extractValues(
			accounts,
			Account.Name,
			List<String>.class
		);
		System.assertEquals(accounts.size(), accountNames?.size(), 'Wrong # of Account Names');
		for (Integer i = 0; i < 10; i++) {
			Account account = accounts[i];
			String name = accountNames[i];
			System.assertEquals(name, account.Name, 'Wrong name');
		}
	}

	@IsTest 
    static void shouldSplitListIntoChunks() {
        List<Account> accs = CollectionUtils_Test.initAccounts(1000); 
        Integer interval = 300; 
        // This should produce 3 lists w/300 Accounts + 1 list w/100 Accounts
        
        Test.startTest();
        List<List<Account>> results = (List<List<Account>>) CollectionUtils.split(
            accs, 
            interval, 
            List<List<Account>>.class
        );
        Test.stopTest();

        System.assertEquals(4, results?.size(), 'Wrong # of List<Account> returned');
        System.assertEquals(interval, results[0]?.size(), 'Wrong # of Accounts in first list');
        System.assertEquals(interval, results[1]?.size(), 'Wrong # of Accounts in second list');
        System.assertEquals(interval, results[2]?.size(), 'Wrong # of Accounts in third list');
        System.assertEquals(100, results[3]?.size(), 'Wrong # of Accounts in final list');
        System.assertEquals(1000, accs?.size(), 'Original list was transformed');
    }

	// **** HELPER **** //
	static List<Account> initAccounts(Integer numAccs) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numAccs; i++) {
			accounts.add(new Account(
				AnnualRevenue = 1000 * i, 
				BillingCountry = 'US',
				OwnerId = UserInfo.getUserId()
			));
		}
		return accounts;
	}
}
