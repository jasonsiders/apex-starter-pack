@IsTest
private class DmlMock_Test {
	@IsTest
	static void shouldGenerateFakeId() {
		Set<Id> accountIds = new Set<Id>();
		for (Integer i = 0; i < 200; i++) {
			Id fakeId = DmlMock.generateFakeId(Account.SObjectType);
			accountIds.add(fakeId);
		}
		System.assertEquals(200, accountIds.size(), 'Wrong number of Ids generated. Was there a duplicate?');
	}

	@IsTest
	static void shouldAddFakeIdToRecord() {
		Account account = (Account) DmlMock.generateFakeId(new Account(Name = 'Test Account'));
		System.assertNotEquals(null, account.Id, 'Account ID was not set');
		System.assertEquals('001000000000000000', account.Id, 'Unexpected Id set');
	}

	@IsTest
	static void shouldMockInsert() {
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		Account account = new Account(Name = 'Test Account');

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doInsert(account);
		Test.stopTest();

		System.assertNotEquals(null, account.Id, 'Id was not added');
		System.assertEquals(true, Dml.Inserted?.containsRecord(account.Id), 'Not inserted');
		System.assertEquals(account.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUpdate() {
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUpdate(testAccount);
		Test.stopTest();

		System.assertEquals(newName, testAccount.Name, 'Wrong name value');
		System.assertEquals(true, Dml.Updated?.containsRecord(testAccount.Id), 'Not updated');
		System.assertEquals(
			newName,
			Dml.Updated?.getRecord(testAccount).get(Account.Name),
			'Name was not updated in the "updated" list'
		);
		System.assertEquals(testAccount.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUpsert() {
		Account testAccount = new Account(Name = 'Test Account');
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		DB.Dml.doUpsert(testAccount);
		System.assertNotEquals(null, testAccount.Id, 'Id was not added');
		System.assertEquals(true, Dml.Upserted?.containsRecord(testAccount.Id), 'Not upserted');
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUpsert(testAccount);
		Test.stopTest();

		System.assertEquals(newName, testAccount.Name, 'Wrong name value');
		System.assertEquals(
			newName,
			Dml.Upserted?.getRecord(testAccount)?.get(Account.Name),
			'Name was not updated in the "upserted" list'
		);
		System.assertEquals(testAccount.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUpsertByExternalId() {
		// Name isn't an actual external Id field, so this will only work with a Mock class
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doUpsert(testAccount, Account.Name);
		System.assertNotEquals(null, testAccount.Id, 'Id was not added');
		System.assertEquals(true, Dml.Upserted?.containsRecord(testAccount.Id), 'Not upserted');
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUpsert(testAccount, Account.Name);
		Test.stopTest();

		System.assertEquals(newName, testAccount.Name, 'Wrong name value');
		System.assertEquals(
			newName,
			Dml.Upserted?.getRecord(testAccount).get(Account.Name),
			'Name was not updated in the "upserted" list'
		);
		System.assertEquals(testAccount.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUndelete() {
		Account account = new Account(Name = 'Test');
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		DB.Dml.doInsert(account);
		DB.Dml.doDelete(account);

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUndelete(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Undeleted?.containsRecord(account.Id), 'Account was not undeleted');
		System.assertEquals(account.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockDelete() {
		Account account = new Account(Name = 'Test');
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		DB.Dml.doInsert(account);

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doDelete(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Deleted?.containsRecord(account.Id), 'Account was not deleted');
		System.assertEquals(account.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockHardDelete() {
		Account account = new Account(Name = 'Test');
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		DB.Dml.doInsert(account);

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doHardDelete(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Deleted?.containsRecord(account.Id), 'Account was not deleted');
		System.assertEquals(account.Id, dmlResult.getId(), 'Wrong result getId()');
		System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess() value');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # getErrors()');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockPublish() {
		PlatformStatusAlertEvent event = new PlatformStatusAlertEvent();
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doPublish(event);
		Test.stopTest();

		List<PlatformStatusAlertEvent> events = ((List<PlatformStatusAlertEvent>) Dml.Published
			?.getRecords(PlatformStatusAlertEvent.SObjectType));
		System.assertEquals(1, events?.size(), 'Wrong # of published events');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockNewLeadConversion() {
		DB.setDmlEngine(new DmlMock());
		Lead testLead = new Lead(
			Company = 'Acme Inc.',
			Email = 'john.doe@test.com.invalid',
			FirstName = 'John',
			LastName = 'Doe',
			Phone = '+15555555555'
		);
		DB.Dml.doInsert(testLead);
		Soql statusQuery = DB.Soql.newQuery(LeadStatus.SObjectType)
			.selectFields(LeadStatus.MasterLabel)
			.whereCriteria(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
			.setRowLimit(1);
		String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
		Database.LeadConvert leadConvertObj = new Database.LeadConvert();
		leadConvertObj.setLeadId(testLead.Id);
		leadConvertObj.setConvertedStatus(status);
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>{ leadConvertObj };

		Test.startTest();
		List<ConversionResult> results = (List<ConversionResult>) DB.Dml.doConvert(leadConverts);
		Test.stopTest();

		System.assertEquals(1, results?.size(), 'Wrong # of conversion results');
		ConversionResult result = results[0];
		System.assertEquals(true, result.isSuccess(), 'Wrong isSuccess()');
		System.assertEquals(testLead.Id, result.getLeadId(), 'Wrong leadId');
		System.assertNotEquals(null, result.getAccountId(), 'Wrong accountId');
		System.assertNotEquals(null, result.getContactId(), 'Wrong contactId');
		System.assertNotEquals(null, result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(0, result.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldMockLeadMergeConversion() {
		DB.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test');
		DB.Dml.doInsert(testAccount);
		Contact testContact = new Contact(AccountId = testAccount.Id);
		DB.Dml.doInsert(testContact);
		Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id, Name = 'Test Opportunity');
		DB.Dml.doInsert(testOpportunity);
		Lead testLead = new Lead(
			Company = 'Acme Inc.',
			Email = 'john.doe@test.com.invalid',
			FirstName = 'John',
			LastName = 'Doe',
			Phone = '+15555555555'
		);
		DB.Dml.doInsert(testLead);
		Soql statusQuery = DB.Soql.newQuery(LeadStatus.SObjectType)
			.selectFields(LeadStatus.MasterLabel)
			.whereCriteria(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
			.setRowLimit(1);
		String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
		Database.LeadConvert leadConvertObj = new Database.LeadConvert();
		leadConvertObj.setLeadId(testLead.Id);
		leadConvertObj.setConvertedStatus(status);
		leadConvertObj.setAccountId(testAccount.Id);
		leadConvertObj.setContactId(testContact.Id);
		leadConvertObj.setOpportunityId(testOpportunity.Id);
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>{ leadConvertObj };

		Test.startTest();
		List<ConversionResult> results = (List<ConversionResult>) DB.Dml.doConvert(leadConverts);
		Test.stopTest();

		System.assertEquals(1, results?.size(), 'Wrong # of conversion results');
		ConversionResult result = results[0];
		System.assertEquals(true, result.isSuccess(), 'Wrong isSuccess()');
		System.assertEquals(testLead.Id, result.getLeadId(), 'Wrong leadId');
		System.assertEquals(testAccount.Id, result.getAccountId(), 'Wrong accountId');
		System.assertEquals(testContact.Id, result.getContactId(), 'Wrong contactId');
		System.assertEquals(testOpportunity.Id, result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(0, result.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldReturnPublishedEvents() {
		PlatformStatusAlertEvent event = new PlatformStatusAlertEvent();
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		DB.Dml.doPublish(event);

		Test.startTest();
		List<PlatformStatusAlertEvent> events = (List<PlatformStatusAlertEvent>) Dml.Published?.getAll();
		Test.stopTest();

		System.assertEquals(1, events?.size(), 'Wrong # of publishedEvents');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockDynamicDml() {
		DB.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test Account');

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_INSERT, testAccount);
		Test.stopTest();

		System.assertNotEquals(null, testAccount.Id, 'Account was not mock inserted');
		System.assertEquals(true, Dml.Inserted?.containsRecord(testAccount), 'Account was not added to Inserted');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML Statements');
	}

	@IsTest
	static void shouldGenerateMockResultsFromSObjects() {
		DmlMock dmlMock = (DmlMock) DB.setDmlEngine(new DmlMock());
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
		}
		DB.Dml.doInsert(accounts);

		Test.startTest();
		List<DmlResult> dmlResults = dmlMock.mockDmlResults(accounts, Database.SaveResult.class);
		Test.stopTest();

		System.assertEquals(accounts?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Account account = accounts[i];
			System.assertEquals(true, dmlResult.isSuccess(), 'Wrong isSuccess()');
			System.assertEquals(account.Id, dmlResult.getId(), 'Wrong getId()');
			System.assertEquals(0, dmlResult?.getErrors()?.size(), 'Wrong # of getErrors()');
		}
	}

	@IsTest
	static void shouldClearAllHistoryObjects() {
		DB.setDmlEngine(new DmlMock());
		Lead testLead = new Lead(Company = 'Test Lead');
		// Add 1 record to each history object
		Map<Dml.Operation, Dml.History> operations = new Map<Dml.Operation, Dml.History>{
			Dml.Operation.DO_INSERT => Dml.Inserted,
			Dml.Operation.DO_UPDATE => Dml.Updated,
			Dml.Operation.DO_UPSERT => Dml.Upserted,
			Dml.Operation.DO_DELETE => Dml.Deleted,
			Dml.Operation.DO_UNDELETE => Dml.Undeleted
		};

		for (Dml.Operation operation : operations.keySet()) {
			DB.Dml.doDml(operation, testLead);
			Dml.History history = operations.get(operation);
			System.assertEquals(1, history.getAll()?.size(), 'Wrong # of records for ' + operation);
		}

		Test.startTest();
		// Remove all previously added history objects
		DmlMock.resetHistory();
		Test.stopTest();

		for (Dml.Operation operation : operations.keySet()) {
			Dml.History history = operations.get(operation);
			System.assertEquals(0, history.getAll()?.size(), 'Wrong # of records for ' + operation);
		}
	}
}
