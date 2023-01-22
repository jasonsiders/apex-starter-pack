@IsTest
private class Filter_Test {
	@IsTest
	static void shouldAllowStandardQuery() {
		Filter testFilter = new Filter(Opportunity.StageName, Filter.EQUALS, 'New');
		System.assertEquals('StageName = \'New\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldAllowParentQuery() {
		FieldRef fieldRef = new FieldRef(new List<SObjectField>{ Case.ContactId, Contact.AccountId, Account.Type });
		Filter testFilter = new Filter(fieldRef, Filter.EQUALS, 'Prospect');
		System.assertEquals('Contact.Account.Type = \'Prospect\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForEquals() {
		Filter testFilter = new Filter(Opportunity.Amount, Filter.EQUALS, 1000);
		System.assertEquals('Amount = 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForNotEquals() {
		Filter testFilter = new Filter(Opportunity.Amount, Filter.NOT_EQUALS, 1000);
		System.assertEquals('Amount != 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForInCollection() {
		Id accountId = DmlMock.generateFakeId(Account.SObjectType);
		Id caseId = DmlMock.generateFakeId(Case.SObjectType);
		Set<Id> recordIds = new Set<Id>{ accountId, caseId };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, recordIds);
		System.assertEquals(
			'My_Custom_Field__c IN (\'' +
			accountId +
			'\', \'' +
			caseId +
			'\')',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForNotInCollection() {
		Id accountId = DmlMock.generateFakeId(Account.SObjectType);
		Id caseId = DmlMock.generateFakeId(Case.SObjectType);
		Set<Id> recordIds = new Set<Id>{ accountId, caseId };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.NOT_IN_COLLECTION, recordIds);
		System.assertEquals(
			'My_Custom_Field__c NOT IN (\'' +
			accountId +
			'\', \'' +
			caseId +
			'\')',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForGreaterThan() {
		Filter testFilter = new Filter(Opportunity.Amount, Filter.GREATER_THAN, 1000);
		System.assertEquals('Amount > 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void houldHandleGreaterOrEqualThan() {
		Filter testFilter = new Filter(Opportunity.Amount, Filter.GREATER_OR_EQUAL, 1000);
		System.assertEquals('Amount >= 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForLessThan() {
		Filter testFilter = new Filter(Opportunity.Amount, Filter.LESS_THAN, 1000);
		System.assertEquals('Amount < 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForLessOrEqual() {
		Filter testFilter = new Filter(Opportunity.Amount, Filter.LESS_OR_EQUAL, 1000);
		System.assertEquals('Amount <= 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForStartsWith() {
		Filter testFilter = new Filter(Account.Website, Filter.STARTS_WITH, 'https://www.');
		System.assertEquals('Website LIKE \'https://www.%\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForEndsWith() {
		Filter testFilter = new Filter(Account.Website, Filter.ENDS_WITH, '.com');
		System.assertEquals('Website LIKE \'%.com\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForContains() {
		Filter testFilter = new Filter(Account.Website, Filter.CONTAINS, 'in-n-out');
		System.assertEquals('Website LIKE \'%in-n-out%\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForNotStartsWith() {
		Filter testFilter = new Filter(Account.Website, Filter.NOT_STARTS_WITH, 'https://www.');
		System.assertEquals('Website NOT LIKE \'https://www.%\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForNotEndsWith() {
		Filter testFilter = new Filter(Account.Website, Filter.NOT_ENDS_WITH, '.com');
		System.assertEquals('Website NOT LIKE \'%.com\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForNotContains() {
		Filter testFilter = new Filter(Account.Website, Filter.NOT_CONTAINS, 'in-n-out');
		System.assertEquals('Website NOT LIKE \'%in-n-out%\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForNull() {
		Filter testFilter = new Filter(Account.Name, Filter.EQUALS, null);
		System.assertEquals('Name = null', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForBoolean() {
		Filter testFilter = new Filter(Account.IsDeleted, Filter.EQUALS, true);
		System.assertEquals('IsDeleted = true', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListBoolean() {
		List<Boolean> myBools = new List<Boolean>{ false, true };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myBools);
		System.assertEquals('My_Custom_Field__c IN (false, true)', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetBoolean() {
		Set<Boolean> myBools = new Set<Boolean>{ false, true };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myBools);
		System.assertEquals('My_Custom_Field__c IN (false, true)', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForDate() {
		Date testDate = Date.newInstance(2022, 1, 1);
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.EQUALS, testDate);
		System.assertEquals('CloseDate = 2022-01-01', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForRelativeDate() {
		Filter testFilter = new Filter(Opportunity.CreatedDate, Filter.EQUALS, 'LAST_N_DAYS:10');
		System.assertEquals('CreatedDate = LAST_N_DAYS:10', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListDate() {
		List<Date> myDates = new List<Date>{ Date.newInstance(2022, 1, 1), Date.newInstance(2022, 2, 2) };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myDates);
		System.assertEquals(
			'My_Custom_Field__c IN (2022-01-01, 2022-02-02)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetDate() {
		Set<Date> myDates = new Set<Date>{ Date.newInstance(2022, 1, 1), Date.newInstance(2022, 2, 2) };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myDates);
		System.assertEquals(
			'My_Custom_Field__c IN (2022-01-01, 2022-02-02)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForDateTime() {
		DateTime testDateTime = DateTime.newInstanceGmt(2022, 1, 1);
		Filter testFilter = new Filter(Opportunity.CreatedDate, Filter.GREATER_THAN, testDateTime);
		System.assertEquals('CreatedDate > 2022-01-01T00:00:00Z', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListDateTime() {
		List<DateTime> myDts = new List<DateTime>{
			DateTime.newInstanceGmt(2022, 1, 1),
			DateTime.newInstanceGmt(2022, 2, 2)
		};
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myDts);
		System.assertEquals(
			'My_Custom_Field__c IN (2022-01-01T00:00:00Z, 2022-02-02T00:00:00Z)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetDateTime() {
		Set<DateTime> myDts = new Set<DateTime>{
			DateTime.newInstanceGmt(2022, 1, 1),
			DateTime.newInstanceGmt(2022, 2, 2)
		};
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myDts);
		System.assertEquals(
			'My_Custom_Field__c IN (2022-01-01T00:00:00Z, 2022-02-02T00:00:00Z)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForNumber() {
		// SOQL treats numbers all the same (whether Double/Integer/Decimal/etc)
		Filter testFilter = new Filter(Opportunity.Amount, Filter.GREATER_THAN, 1000);
		System.assertEquals('Amount > 1000', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListNumber() {
		List<Decimal> numbers = new List<Decimal>{ 1.0, 2.0, 3.0 };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, numbers);
		System.assertEquals('My_Custom_Field__c IN (1.0, 2.0, 3.0)', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetDecimal() {
		Set<Decimal> numbers = new Set<Decimal>{ 1.0, 2.0, 3.0 };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, numbers);
		System.assertEquals('My_Custom_Field__c IN (1.0, 2.0, 3.0)', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListId() {
		Id accountId = DmlMock.generateFakeId(Account.SObjectType);
		Id caseId = DmlMock.generateFakeId(Case.SObjectType);
		List<Id> myIds = new List<Id>{ accountId, caseId };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myIds);
		System.assertEquals(
			'My_Custom_Field__c IN (\'' +
			accountId +
			'\', \'' +
			caseId +
			'\')',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetId() {
		Id accountId = DmlMock.generateFakeId(Account.SObjectType);
		Id caseId = DmlMock.generateFakeId(Case.SObjectType);
		Set<Id> myIds = new Set<Id>{ accountId, caseId };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myIds);
		String expected = 'My_Custom_Field__c IN (\'' + accountId + '\', \'' + caseId + '\')';
		System.assertEquals(expected, testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListInteger() {
		List<Integer> myInts = new List<Integer>{ 1, 2, 3 };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myInts);
		System.assertEquals('My_Custom_Field__c IN (1, 2, 3)', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetInteger() {
		Set<Integer> myInts = new Set<Integer>{ 1, 2, 3 };
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myInts);
		System.assertEquals('My_Custom_Field__c IN (1, 2, 3)', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForString() {
		Filter testFilter = new Filter(Account.Website, Filter.EQUALS, 'https://www.in-n-out.com');
		System.assertEquals('Website = \'https://www.in-n-out.com\'', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListString() {
		List<String> statuses = new List<String>{ 'New', 'Closed Won' };
		Filter testFilter = new Filter(Opportunity.StageName, Filter.IN_COLLECTION, statuses);
		System.assertEquals('StageName IN (\'New\', \'Closed Won\')', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetString() {
		Set<String> statuses = new Set<String>{ 'New', 'Closed Won' };
		Filter testFilter = new Filter(Opportunity.StageName, Filter.IN_COLLECTION, statuses);
		System.assertEquals('StageName IN (\'New\', \'Closed Won\')', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForTime() {
		Time myTime = DateTime.newInstance(2022, 1, 1, 12, 0, 0).time();
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.EQUALS, myTime);
		System.assertEquals('My_Custom_Field__c = 12:00:00.000Z', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldProduceQuerySegmentForListTime() {
		List<Time> myTimes = new List<Time>{
			DateTime.newInstance(2022, 1, 1, 12, 0, 0).time(),
			DateTime.newInstance(2022, 1, 1, 13, 0, 0).time()
		};
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myTimes);
		System.assertEquals(
			'My_Custom_Field__c IN (12:00:00.000Z, 13:00:00.000Z)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldProduceQuerySegmentForSetTime() {
		Set<Time> myTimes = new Set<Time>{
			DateTime.newInstance(2022, 1, 1, 12, 0, 0).time(),
			DateTime.newInstance(2022, 1, 1, 13, 0, 0).time()
		};
		Filter testFilter = new Filter('My_Custom_Field__c', Filter.IN_COLLECTION, myTimes);
		System.assertEquals(
			'My_Custom_Field__c IN (12:00:00.000Z, 13:00:00.000Z)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldEvaluateForParentObjects() {
		String accountName = 'Test Account #' + Crypto.getRandomLong();
		Account testAccount = new Account(Name = accountName);
		Databaselayer.Dml.doInsert(testAccount);
		Opportunity testOpp = new Opportunity(
			AccountId = testAccount.Id,
			Amount = 1000,
			CloseDate = Date.today(),
			Name = 'Test Opp',
			StageName = 'New'
		);
		Databaselayer.Dml.doInsert(testOpp);
		testOpp = (Opportunity) Databaselayer.Soql.newQuery(Opportunity.SObjectType)
			.selectFields(new FieldRef(new List<SObjectField>{ Opportunity.AccountId, Account.Name }))
			.whereCriteria(new Filter(Opportunity.Id, Filter.EQUALS, testOpp.Id))
			.run()[0];

		Test.startTest();
		FieldRef fieldRef = new FieldRef(new List<SObjectField>{ Opportunity.AccountId, Account.Name });
		Filter testFilter = new Filter(fieldRef, Filter.EQUALS, accountName);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Account.Name + ' == ' + accountName);
		Test.stopTest();
	}

	@IsTest
	static void shouldEvaluateEquals() {
		String oppName = 'Test Opp #1';
		Opportunity testOpp = new Opportunity(Name = oppName);

		Test.startTest();
		Filter testFilter = new Filter(Opportunity.Name, Filter.EQUALS, oppName);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' == ' + oppName);
		testFilter = new Filter(Opportunity.Name, Filter.EQUALS, oppName + '234');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' == ' + oppName + '234');
		testFilter = new Filter(Opportunity.Name, Filter.EQUALS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' == null');
		Test.stopTest();
	}

	@IsTest
	static void shouldEvaluateNotEquals() {
		String oppName = 'Test Opp #1';
		String affix = '234';
		Opportunity testOpp = new Opportunity(Name = oppName);

		Test.startTest();
		Filter testFilter = new Filter(Opportunity.Name, Filter.NOT_EQUALS, oppName + affix);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' == ' + oppName + affix);
		testFilter = new Filter(Opportunity.Name, Filter.NOT_EQUALS, oppName);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' == ' + oppName);
		testFilter = new Filter(Opportunity.Name, Filter.NOT_EQUALS, null);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' == null');
		Test.stopTest();
	}

	@IsTest
	static void shouldEvaluateInCollection() {
		Opportunity testOpp = new Opportunity(Id = DmlMock.generateFakeId(Opportunity.SObjectType));
		List<Id> oppList = new List<Id>{ testOpp.Id };

		Test.startTest();
		Filter testFilter = new Filter(Opportunity.Id, Filter.IN_COLLECTION, oppList);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Id + ' is not in this collection');
		oppList.clear();
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Id + ' is in an empty collection');
		oppList = null;
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Id + ' is in a null collection');
		Test.stopTest();
	}

	@IsTest
	static void shouldNotEvaluateInCollectionIfInvalidType() {
		Opportunity testOpp = new Opportunity(Id = DmlMock.generateFakeId(Opportunity.SObjectType));
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>{ testOpp.Id => testOpp };
		Set<Id> oppSet = oppMap.keySet();

		Test.startTest();
		for (Object collection : new List<Object>{ oppMap, oppSet }) {
			Filter testFilter = new Filter(Opportunity.Id, Filter.IN_COLLECTION, collection);
			Exception caughtError;
			try {
				testFilter?.meetsCriteria(testOpp);
			} catch (Filter.FilterException thrownError) {
				caughtError = thrownError;
			}
			System.assertNotEquals(null, caughtError, 'No error was thrown');
		}
		Test.stopTest();
	}

	@IsTest
	static void shouldEvaluateNotInCollection() {
		Opportunity testOpp = new Opportunity(Id = DmlMock.generateFakeId(Opportunity.SObjectType));

		Id newId = DmlMock.generateFakeId(Opportunity.SObjectType);
		List<Id> oppList = new List<Id>{ newId };

		Test.startTest();
		Filter testFilter = new Filter(Opportunity.Id, Filter.NOT_IN_COLLECTION, oppList);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Id + ' is in this collection');
		testOpp.Id = newId;
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Id + ' is not in this collection');
		testOpp.Id = null;
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Id + ' is in a null collection');
		Test.stopTest();
	}

	@IsTest
	static void shouldEvaluateGreaterThanNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1000);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.GREATER_THAN, 999);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' > 999');
		testFilter = new Filter(Opportunity.Amount, Filter.GREATER_THAN, 1000);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' > 1000');
		testFilter = new Filter(Opportunity.Amount, Filter.GREATER_THAN, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' > null');
	}

	@IsTest
	static void shouldEvaluateGreaterThanDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_THAN, Date.newInstance(2021, 12, 31));
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' > 2021-12-31');
		testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_THAN, Date.newInstance(2022, 1, 1));
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' > 2022-01-01');
		testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_THAN, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' > null');
	}

	@IsTest
	static void shouldNotEvaluateGreaterThanIfInvalidType() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.GREATER_THAN, 'Some text');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' > "Some text"');
	}

	@IsTest
	static void shouldEvaluateLessThanNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1000);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.LESS_THAN, 1001);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' < 1001');
		testFilter = new Filter(Opportunity.Amount, Filter.LESS_THAN, 1000);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' < 1000');
		testFilter = new Filter(Opportunity.Amount, Filter.LESS_THAN, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' < null');
	}

	@IsTest
	static void shouldEvaluateLessThanDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_THAN, Date.newInstance(2022, 1, 2));
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' < 2022-01-02');
		testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_THAN, Date.newInstance(2022, 1, 1));
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' < 2022-01-01');
		testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_THAN, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' < null');
	}

	@IsTest
	static void shouldNotEvaluateLessThanIfInvalidType() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.LESS_THAN, 'Some text');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' < "Some text"');
	}

	@IsTest
	static void shouldEvaluateGreaterOrEqualThanNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1000);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.GREATER_OR_EQUAL, 999);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' >= 999');
		testFilter = new Filter(Opportunity.Amount, Filter.GREATER_OR_EQUAL, 1000);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' >= 1000');
		testFilter = new Filter(Opportunity.Amount, Filter.GREATER_OR_EQUAL, 1001);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' >= 1001');
		testFilter = new Filter(Opportunity.Amount, Filter.GREATER_OR_EQUAL, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' >= null');
	}

	@IsTest
	static void shouldEvaluateGreaterOrEqualThanDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_OR_EQUAL, Date.newInstance(2021, 12, 31));
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' >= 2021-12-31');
		testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_OR_EQUAL, Date.newInstance(2022, 1, 1));
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' >= 2022-01-01');
		testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_OR_EQUAL, Date.newInstance(2022, 1, 2));
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' >= 2022-01-02');
		testFilter = new Filter(Opportunity.CloseDate, Filter.GREATER_OR_EQUAL, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' >= null');
	}

	@IsTest
	static void shouldNotEvaluateGreaterOrEqualIfInvalidType() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.GREATER_OR_EQUAL, 'Some text');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' >= "Some text"');
	}

	@IsTest
	static void shouldEvaluateLessOrEqualThanNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1000);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.LESS_OR_EQUAL, 1001);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' <= 1001');
		testFilter = new Filter(Opportunity.Amount, Filter.LESS_OR_EQUAL, 1000);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' <= 1000');
		testFilter = new Filter(Opportunity.Amount, Filter.LESS_OR_EQUAL, 999);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' <= 999');
		testFilter = new Filter(Opportunity.Amount, Filter.LESS_OR_EQUAL, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' <= null');
	}

	@IsTest
	static void shouldEvaluateLessOrEqualThanDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_OR_EQUAL, Date.newInstance(2022, 1, 2));
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' <= 2022-01-02');
		testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_OR_EQUAL, Date.newInstance(2022, 1, 1));
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' <= 2022-01-01');
		testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_OR_EQUAL, Date.newInstance(2021, 12, 31));
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' <= 2021-12-31');
		testFilter = new Filter(Opportunity.CloseDate, Filter.LESS_OR_EQUAL, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' <= null');
	}

	@IsTest
	static void shouldNotEvaluateLessOrEqualIfInvalidType() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.LESS_OR_EQUAL, 'Some text');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' <= "Some text"');
	}

	@IsTest
	static void shouldEvaluateStartsWithDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.STARTS_WITH, 2022);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' startWith 202');
		testFilter = new Filter(Opportunity.CloseDate, Filter.STARTS_WITH, 2021);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' startWith 2021');
		testFilter = new Filter(Opportunity.CloseDate, Filter.STARTS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' startWith null');
	}

	@IsTest
	static void shouldEvaluateStartsWithNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1000);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.STARTS_WITH, 1);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' does not startsWith 1');
		testFilter = new Filter(Opportunity.Amount, Filter.STARTS_WITH, 2);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' startsWith 2');
		testFilter = new Filter(Opportunity.Amount, Filter.STARTS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' startsWith null');
	}

	@IsTest
	static void shouldEvaluateStartsWithText() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity #1');
		Filter testFilter = new Filter(Opportunity.Name, Filter.STARTS_WITH, 'Test');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' startsWith "Test"');
		testFilter = new Filter(Opportunity.Name, Filter.STARTS_WITH, 'Something Else');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' startsWith "Something Else"');
		testFilter = new Filter(Opportunity.Name, Filter.STARTS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' startsWith null');
	}

	@IsTest
	static void shouldEvaluateNotStartsWithDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_STARTS_WITH, '2022');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notStartsWith 2022');
		testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_STARTS_WITH, 2021);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notStartsWith 2021');
		testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_STARTS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notStartsWith null');
	}

	@IsTest
	static void shouldEvaluateNotStartsWithNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1000);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.NOT_STARTS_WITH, 1);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + 'notStartsWith 1');
		testFilter = new Filter(Opportunity.Amount, Filter.NOT_STARTS_WITH, 2);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notStartsWith 2');
		testFilter = new Filter(Opportunity.Amount, Filter.NOT_STARTS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notStartsWith null');
	}

	@IsTest
	static void shouldEvaluateNotStartsWithText() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.NOT_STARTS_WITH, 'Test');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + 'notStartsWith "Test"');
		testFilter = new Filter(Opportunity.Name, Filter.NOT_STARTS_WITH, 'Something else');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notStartsWith "Something else"');
		testFilter = new Filter(Opportunity.Name, Filter.NOT_STARTS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notStartsWith null');
	}

	@IsTest
	static void shouldEvaluateEndsWithDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.ENDS_WITH, 0);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' endWith 0');
		testFilter = new Filter(Opportunity.CloseDate, Filter.ENDS_WITH, 1);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' endWith 1');
		testFilter = new Filter(Opportunity.CloseDate, Filter.ENDS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' endWith null');
	}

	@IsTest
	static void shouldEvaluateEndsWithNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1234);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.ENDS_WITH, 4);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' endWith 4');
		testFilter = new Filter(Opportunity.Amount, Filter.ENDS_WITH, 5);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' endWith 5');
		testFilter = new Filter(Opportunity.Amount, Filter.ENDS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' endWith null');
	}

	@IsTest
	static void shouldEvaluateEndsWithText() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.ENDS_WITH, 'y');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' endWith "y"');
		testFilter = new Filter(Opportunity.Name, Filter.ENDS_WITH, 'z');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' endWith "z"');
		testFilter = new Filter(Opportunity.Name, Filter.ENDS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' endWith null');
	}

	@IsTest
	static void shouldEvaluateNotEndsWithDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_ENDS_WITH, 0);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notEndWith 0');
		testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_ENDS_WITH, 1);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notEndWith 1');
		testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_ENDS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notEndWith null');
	}

	@IsTest
	static void shouldEvaluateNotEndsWithNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1234);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.NOT_ENDS_WITH, 4);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notEndWith 4');
		testFilter = new Filter(Opportunity.Amount, Filter.NOT_ENDS_WITH, 5);
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notEndWith 5');
		testFilter = new Filter(Opportunity.Amount, Filter.NOT_ENDS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' endWith null');
	}

	@IsTest
	static void shouldEvaluateNotEndsWithText() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity');
		Filter testFilter = new Filter(Opportunity.Name, Filter.NOT_ENDS_WITH, 'y');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notEndWith "y"');
		testFilter = new Filter(Opportunity.Name, Filter.NOT_ENDS_WITH, 'z');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notEndWith "z"');
		testFilter = new Filter(Opportunity.Name, Filter.NOT_ENDS_WITH, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notEndWith null');
	}

	@IsTest
	static void shouldEvaluateContainsDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.CONTAINS, '01');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' contains "01"');
		testFilter = new Filter(Opportunity.CloseDate, Filter.CONTAINS, 'z');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' contains "z"');
		testFilter = new Filter(Opportunity.CloseDate, Filter.CONTAINS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' contains null');
	}

	@IsTest
	static void shouldEvaluateContainsNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1234);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.CONTAINS, '3');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' contains "3"');
		testFilter = new Filter(Opportunity.Amount, Filter.CONTAINS, 'z');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' conntains "z"');
		testFilter = new Filter(Opportunity.Amount, Filter.CONTAINS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' contains null');
	}

	@IsTest
	static void shouldEvaluateContainsText() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity #1');
		Filter testFilter = new Filter(Opportunity.Name, Filter.CONTAINS, '#');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' contains "#"');
		testFilter = new Filter(Opportunity.Name, Filter.CONTAINS, '!');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' contains "!"');
		testFilter = new Filter(Opportunity.Name, Filter.CONTAINS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' contains null');
	}

	@IsTest
	static void shouldEvaluateNotContainsDate() {
		Opportunity testOpp = new Opportunity(CloseDate = Date.newInstance(2022, 1, 1));
		Filter testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_CONTAINS, '01');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notContains "01"');
		testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_CONTAINS, 'z');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notContains "z"');
		testFilter = new Filter(Opportunity.CloseDate, Filter.NOT_CONTAINS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.CloseDate + ' notContains null');
	}

	@IsTest
	static void shouldEvaluateNotContainsNumber() {
		Opportunity testOpp = new Opportunity(Amount = 1234);
		Filter testFilter = new Filter(Opportunity.Amount, Filter.NOT_CONTAINS, '3');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notContains "3"');
		testFilter = new Filter(Opportunity.Amount, Filter.NOT_CONTAINS, 'z');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notContains "z"');
		testFilter = new Filter(Opportunity.Amount, Filter.NOT_CONTAINS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Amount + ' notContains null');
	}

	@IsTest
	static void shouldEvaluateNotContainsText() {
		Opportunity testOpp = new Opportunity(Name = 'Test Opportunity #1');
		Filter testFilter = new Filter(Opportunity.Name, Filter.NOT_CONTAINS, '#');
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notContains "#"');
		testFilter = new Filter(Opportunity.Name, Filter.NOT_CONTAINS, '!');
		System.assertEquals(true, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notContains "!"');
		testFilter = new Filter(Opportunity.Name, Filter.NOT_CONTAINS, null);
		System.assertEquals(false, testFilter?.meetsCriteria(testOpp), testOpp.Name + ' notContains null');
	}

	@IsTest
	static void shouldEvaluateIfGenericObjectMeetsCriteria() {
		ExampleObject obj = new ExampleObject();
		Filter myFilter = new Filter('myBool', Filter.EQUALS, true);
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myBool', Filter.EQUALS, false);
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myDate', Filter.STARTS_WITH, '2021');
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myDate', Filter.STARTS_WITH, '2022');
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myDt', Filter.STARTS_WITH, '2021');
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myDt', Filter.STARTS_WITH, '2022');
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myDec', Filter.NOT_EQUALS, 0);
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myDec', Filter.EQUALS, 0);
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myId', Filter.EQUALS, UserInfo.getUserId());
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myId', Filter.NOT_EQUALS, UserInfo.getUserId());
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myString', Filter.CONTAINS, 'Hello');
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('myString', Filter.EQUALS, 'Something else');
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		// if an unexpected param is supplied, its value will be read as null
		myFilter = new Filter('unexpectedParam', Filter.EQUALS, null);
		System.assertEquals(
			true,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
		myFilter = new Filter('unexpectedParam', Filter.EQUALS, true);
		System.assertEquals(
			false,
			myFilter.meetsCriteria(obj),
			myFilter.toString() +
			' returned unexpected value for obj: ' +
			JSON.serializePretty(obj)
		);
	}

	@IsTest
	static void shouldGenerateInnerQueryFilter() {
		// If a query is passed as the value, wrap it in parentheses to avoid syntax errors
		Soql innerQuery = Databaselayer.Soql.newQuery(User.SObjectType)
			.deselectId()
			.selectFields(User.ProfileId)
			.whereCriteria(new Filter(User.Id, Filter.EQUALS, UserInfo.getUserId()));

		Test.startTest();
		Filter myFilter = new Filter(Profile.Id, Filter.IN_COLLECTION, innerQuery);
		Test.stopTest();

		System.assertEquals(
			'Id IN (SELECT ProfileId FROM User WHERE Id = \'' +
			UserInfo.getUserId() +
			'\')',
			myFilter.toString(),
			'Unexpected output'
		);
	}

	private class ExampleObject {
		Boolean myBool = true;
		Date myDate = Date.newInstance(2021, 1, 1);
		DateTime myDt = DateTime.newInstanceGmt(2021, 1, 1);
		Decimal myDec = 1234.56;
		Id myId = UserInfo.getUserId();
		Integer myInt = 1234;
		String myString = 'Hello World!';
	}
}
