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
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Account account = new Account(Name = 'Test Account');

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doInsert(account);
		Test.stopTest();

		System.assertNotEquals(null, account.Id, 'Id was not added');
		System.assertEquals(true, Dml.Inserted?.containsRecord(account.Id), 'Not inserted');
		System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUpdate() {
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test Account');
		Databaselayer.Dml.doInsert(testAccount);
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doUpdate(testAccount);
		Test.stopTest();

		System.assertEquals(newName, testAccount.Name, 'Wrong name value');
		System.assertEquals(true, Dml.Updated?.containsRecord(testAccount.Id), 'Not updated');
		System.assertEquals(
			newName,
			Dml.Updated?.getRecord(testAccount).get(Account.Name),
			'Name was not updated in the "updated" list'
		);
		System.assertEquals(testAccount.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUpsert() {
		Account testAccount = new Account(Name = 'Test Account');
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Databaselayer.Dml.doUpsert(testAccount);
		System.assertNotEquals(null, testAccount.Id, 'Id was not added');
		System.assertEquals(true, Dml.Upserted?.containsRecord(testAccount.Id), 'Not upserted');
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doUpsert(testAccount);
		Test.stopTest();

		System.assertEquals(newName, testAccount.Name, 'Wrong name value');
		System.assertEquals(
			newName,
			Dml.Upserted?.getRecord(testAccount)?.get(Account.Name),
			'Name was not updated in the "upserted" list'
		);
		System.assertEquals(testAccount.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUpsertByExternalId() {
		// Name isn't an actual external Id field, so this will only work with a Mock class
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test Account');
		Databaselayer.Dml.doUpsert(testAccount, Account.Name);
		System.assertNotEquals(null, testAccount.Id, 'Id was not added');
		System.assertEquals(true, Dml.Upserted?.containsRecord(testAccount.Id), 'Not upserted');
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doUpsert(testAccount, Account.Name);
		Test.stopTest();

		System.assertEquals(newName, testAccount.Name, 'Wrong name value');
		System.assertEquals(
			newName,
			Dml.Upserted?.getRecord(testAccount).get(Account.Name),
			'Name was not updated in the "upserted" list'
		);
		System.assertEquals(testAccount.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockUndelete() {
		Account account = new Account(Name = 'Test');
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Databaselayer.Dml.doInsert(account);
		Databaselayer.Dml.doDelete(account);

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doUndelete(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Undeleted?.containsRecord(account.Id), 'Account was not undeleted');
		System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockDelete() {
		Account account = new Account(Name = 'Test');
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Databaselayer.Dml.doInsert(account);

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doDelete(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Deleted?.containsRecord(account.Id), 'Account was not deleted');
		System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockHardDelete() {
		Account account = new Account(Name = 'Test');
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Databaselayer.Dml.doInsert(account);

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doHardDelete(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Deleted?.containsRecord(account.Id), 'Account was not deleted');
		System.assertEquals(account.Id, dmlResult.recordId, 'Wrong result recordId');
		System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess value');
		System.assertEquals(0, dmlResult.errors?.size(), 'Wrong # errors');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockPublish() {
		Log_Event__e event = new Log_Event__e(Message__c = 'Testing 123');
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());

		Test.startTest();
		DmlResult dmlResult = Databaselayer.Dml.doPublish(event);
		Test.stopTest();

		List<Log_Event__e> logEvents = (List<Log_Event__e>) Dml.Published?.getRecords(Log_Event__e.SObjectType);
		System.assertEquals(1, logEvents?.size(), 'Wrong # of published events');
		System.assertEquals(null, logEvents[0].Id, 'Platform Event was assigned an Id, but should not have');
		System.assertEquals(event.Message__c, logEvents[0].Message__c, 'Wrong message');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockNewLeadConversion() {
		DatabaseLayer.setDmlEngine(new DmlMock());
		Lead testLead = new Lead(
			Company = 'Acme Inc.',
			Email = 'john.doe@test.com.invalid',
			FirstName = 'John',
			LastName = 'Doe',
			Phone = '+15555555555'
		);
		Databaselayer.Dml.doInsert(testLead);
		Soql statusQuery = Databaselayer.Soql.newQuery(LeadStatus.SObjectType)
			.selectFields(LeadStatus.MasterLabel)
			.whereCriteria(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
			.setRowLimit(1);
		String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
		Database.LeadConvert leadConvertObj = new Database.LeadConvert();
		leadConvertObj.setLeadId(testLead.Id);
		leadConvertObj.setConvertedStatus(status);
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>{ leadConvertObj };

		Test.startTest();
		List<ConversionResult> results = (List<ConversionResult>) Databaselayer.Dml.doConvert(leadConverts);
		Test.stopTest();

		System.assertEquals(1, results?.size(), 'Wrong # of conversion results');
		ConversionResult result = results[0];
		System.assertEquals(true, result.isSuccess, 'Wrong isSuccess');
		System.assertEquals(testLead.Id, result.getLeadId(), 'Wrong leadId');
		System.assertNotEquals(null, result.getAccountId(), 'Wrong accountId');
		System.assertNotEquals(null, result.getContactId(), 'Wrong contactId');
		System.assertNotEquals(null, result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(0, result.errors?.size(), 'Wrong # of errors');
	}

	@IsTest
	static void shouldMockLeadMergeConversion() {
		DatabaseLayer.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test');
		Databaselayer.Dml.doInsert(testAccount);
		Contact testContact = new Contact(AccountId = testAccount.Id);
		Databaselayer.Dml.doInsert(testContact);
		Opportunity testOpportunity = new Opportunity(AccountId = testAccount.Id, Name = 'Test Opportunity');
		Databaselayer.Dml.doInsert(testOpportunity);
		Lead testLead = new Lead(
			Company = 'Acme Inc.',
			Email = 'john.doe@test.com.invalid',
			FirstName = 'John',
			LastName = 'Doe',
			Phone = '+15555555555'
		);
		Databaselayer.Dml.doInsert(testLead);
		Soql statusQuery = Databaselayer.Soql.newQuery(LeadStatus.SObjectType)
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
		List<ConversionResult> results = (List<ConversionResult>) Databaselayer.Dml.doConvert(leadConverts);
		Test.stopTest();

		System.assertEquals(1, results?.size(), 'Wrong # of conversion results');
		ConversionResult result = results[0];
		System.assertEquals(true, result.isSuccess, 'Wrong isSuccess');
		System.assertEquals(testLead.Id, result.getLeadId(), 'Wrong leadId');
		System.assertEquals(testAccount.Id, result.getAccountId(), 'Wrong accountId');
		System.assertEquals(testContact.Id, result.getContactId(), 'Wrong contactId');
		System.assertEquals(testOpportunity.Id, result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(0, result.errors?.size(), 'Wrong # of errors');
	}

	@IsTest
	static void shouldReturnPublishedEvents() {
		Log_Event__e event = new Log_Event__e(Message__c = 'Testing 123');
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		Databaselayer.Dml.doPublish(event);

		Test.startTest();
		List<Log_Event__e> logEvents = (List<Log_Event__e>) Dml.Published?.getAll();
		Test.stopTest();

		System.assertEquals(1, logEvents?.size(), 'Wrong # of publishedEvents');
		System.assertEquals(event.Message__c, logEvents[0].Message__c, 'Wrong message');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML statements');
	}

	@IsTest
	static void shouldMockDynamicDml() {
		DatabaseLayer.setDmlEngine(new DmlMock());
		Account testAccount = new Account(Name = 'Test Account');

		Test.startTest();
		Databaselayer.Dml.doDml(Dml.Operation.DO_INSERT, testAccount);
		Test.stopTest();

		System.assertNotEquals(null, testAccount.Id, 'Account was not mock inserted');
		System.assertEquals(true, Dml.Inserted?.containsRecord(testAccount), 'Account was not added to Inserted');
		System.assertEquals(0, Limits.getDmlStatements(), 'Wrong # DML Statements');
	}

	@IsTest
	static void shouldGenerateMockResultsFromSObjects() {
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
		}
		Databaselayer.Dml.doInsert(accounts);

		Test.startTest();
		List<DmlResult> dmlResults = dmlMock.mockDmlResults(accounts);
		Test.stopTest();

		System.assertEquals(accounts?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Account account = accounts[i];
			System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess');
			System.assertEquals(account.Id, dmlResult.recordId, 'Wrong recordId');
			System.assertEquals(0, dmlResult?.errors?.size(), 'Wrong # of errors');
		}
	}

	@IsTest
	static void shouldClearAllHistoryObjects() {
		DatabaseLayer.setDmlEngine(new DmlMock());
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
			Databaselayer.Dml.doDml(operation, testLead);
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
