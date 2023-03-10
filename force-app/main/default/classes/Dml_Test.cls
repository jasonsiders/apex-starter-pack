@IsTest
private class Dml_Test {
	static final Integer TEST_SIZE = 10;

	@TestSetup
	static void setup() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < TEST_SIZE; i++) {
			accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
		}
		DB.Dml.doInsert(accounts);
	}

	@IsTest
	static void shouldDoInsert() {
		Account account = new Account(Name = 'Test Account #0');
		Test.startTest();
		DmlResult dmlResult = DB.Dml.doInsert(account);
		Test.stopTest();
		System.assertEquals(true, Dml.Inserted?.containsRecord(account), 'Account was not added to History list');
		System.assertNotEquals(null, account?.Id, 'Account was not inserted');
		System.assertEquals(account?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoUpdate() {
		Account account = (Account) DB.Soql.newQuery(Account.SObjectType).setRowLimit(1).run()[0];
		final String newName = 'Some other name';
		account.Name = newName;
		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUpdate(account);
		Test.stopTest();
		System.assertEquals(true, Dml.Updated?.containsRecord(account), 'Account was not added to History list');
		System.assertEquals(newName, account.Name, 'Account was not updated');
		System.assertEquals(account?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoUpsert() {
		Account account = new Account(Name = 'Test Account #0');
		DB.Dml.doUpsert(account);
		System.assertNotEquals(null, account.Id, 'Account was not inserted');
		final String newName = 'Some other name';
		account.Name = newName;
		DmlResult dmlResult = DB.Dml.doUpsert(account);
		System.assertEquals(true, Dml.Upserted?.containsRecord(account), 'Account was not added to History list');
		System.assertEquals(newName, account.Name, 'Account was not updated');
		System.assertEquals(account?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoUpsertOnExternalId() {
		Lead testLead = new Lead(Company = 'Test', Email = 'test@test.com.invalid', LastName = 'Test');
		DB.Dml.doUpsert(new List<Lead>{ testLead }, Lead.Id);
		System.assertNotEquals(null, lead.Id, 'Lead was not inserted');
		final String newName = 'Some other name';
		testLead.LastName = newName;
		System.assertEquals(true, Dml.Upserted?.containsRecord(testLead), 'Lead was not added to History list');
		DmlResult dmlResult = DB.Dml.doUpsert(testLead, Lead.Id);
		System.assertEquals(newName, testLead.LastName, 'Lead was not updated');
		System.assertEquals(testLead?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoUndelete() {
		Account testAccount = (Account) DB.Soql.newQuery(Account.SObjectType).setRowLimit(1).run()[0];
		DB.Dml.doDelete(testAccount);
		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUndelete(testAccount);
		Test.stopTest();
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		List<Account> accounts = (List<Account>) query.run();
		System.assertEquals(false, accounts?.isEmpty(), 'Account was not undeleted');
		System.assertEquals(true, Dml.Undeleted?.containsRecord(testAccount), 'Account was not added to History list');
		System.assertEquals(testAccount?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoDelete() {
		Account testAccount = (Account) DB.Soql.newQuery(Account.SObjectType).setRowLimit(1).run()[0];
		Test.startTest();
		DmlResult dmlResult = DB.Dml.doDelete(testAccount);
		Test.stopTest();
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		List<Account> accounts = (List<Account>) query.run();
		System.assertEquals(true, accounts?.isEmpty(), 'Account was not deleted');
		System.assertEquals(true, Dml.Deleted?.containsRecord(testAccount), 'Account was not added to History list');
		System.assertEquals(testAccount?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoHardDelete() {
		Account testAccount = (Account) DB.Soql.newQuery(Account.SObjectType).setRowLimit(1).run()[0];
		Test.startTest();
		DmlResult dmlResult = DB.Dml.doHardDelete(testAccount);
		Test.stopTest();
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.selectFields(Account.IsDeleted)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id))
			.forUsage(Soql.Usage.ALL_ROWS);
		testAccount = (Account) query.run()[0];
		System.assertEquals(true, testAccount.IsDeleted, 'Account was not hard Deleted');
		System.assertEquals(true, Dml.Deleted?.containsRecord(testAccount), 'Account was not added to History list');
		System.assertEquals(testAccount?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoPublish() {
		// PlatformStatusAlertEvent is a standard platform event
		PlatformStatusAlertEvent event = new PlatformStatusAlertEvent();
		Test.startTest();
		DmlResult result = DB.Dml.doPublish(event);
		Test.stopTest();
		Test.getEventBus().deliver();
		// Unlike "normal" DML, platform events are not given an ID after insert/publish
		System.assertEquals(null, event.ReplayId, 'Event was not inserted');
		System.assertEquals(true, Dml.Published?.containsRecord(event), 'Event was not added to History list');
		System.assertEquals(true, result.isSuccess(), 'Event did not publish. getErrors(): ' + result.getErrors());
	}

	@IsTest
	static void shouldDoLeadConvert() {
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

		Test.startTest();
		ConversionResult result = (ConversionResult) DB.Dml.doConvert(leadConvertObj);
		Test.stopTest();

		System.assertEquals(
			true,
			result.isSuccess(),
			'LeadConvert was not a success: ' + JSON.serialize(result.getErrors())
		);
		System.assertEquals(testLead.Id, result.getLeadId(), 'Wrong leadId');
		System.assertNotEquals(null, result.getAccountId(), 'Null accountId');
		System.assertNotEquals(null, result.getContactId(), 'Null contactId');
		System.assertNotEquals(null, result.getOpportunityId(), 'Null opportunityId');
		System.assertEquals(0, result.getErrors()?.size(), 'Wrong # of getErrors()');
	}

	@IsTest
	static void shouldDoInsertImmediate() {
		// NOTE: The Database.insert/update/deleteImmediate() methods are designed to be used with big objects;
		// but these can't be manipulated in @IsTest context, so normal SObjects used instead
		Account testAccount = new Account(Name = 'Test Account #0');

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doInsertImmediate(testAccount);
		Test.stopTest();

		System.assertEquals(1, Dml.Inserted?.getRecords(Account.SObjectType)?.size(), 'Wrong # of accounts inserted');
		System.assertNotEquals(null, testAccount?.Id, 'Account was not inserted');
		System.assertEquals(testAccount?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
		// Because Big Objects can NEVER be DML'd in @IsTest context, dml is always mocked here
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount?.Id));
		System.assertEquals(true, query?.run()?.isEmpty(), 'Account was actually inserted');
	}

	@IsTest
	static void shouldDoUpdateImmediate() {
		// NOTE: The Database.insert/update/deleteImmediate() methods are designed to be used with big objects;
		// but these can't be manipulated in @IsTest context, so normal SObjects used instead
		Account testAccount = (Account) DB.Soql.newQuery(Account.SObjectType).setRowLimit(1).run()[0];
		final String newName = 'Some other name';
		testAccount.Name = newName;

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doUpdateImmediate(testAccount);
		Test.stopTest();

		System.assertEquals(1, Dml.Updated?.getRecords(Account.SObjectType)?.size(), 'Wrong # of updated accounts');
		System.assertEquals(newName, testAccount?.Name, 'Account was not updated');
		System.assertEquals(testAccount?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
		// Because Big Objects can NEVER be DML'd in @IsTest context, dml is always mocked here
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount?.Id))
			.whereCriteria(new Filter(Account.Name, Filter.EQUALS, newName));
		System.assertEquals(true, query?.run()?.isEmpty(), 'Account was actually updated');
	}

	@IsTest
	static void shouldDoDeleteImmediate() {
		// NOTE: The Database.insert/update/deleteImmediate() methods are designed to be used with big objects;
		// but these can't be manipulated in @IsTest context, so normal SObjects used instead
		Account testAccount = (Account) DB.Soql.newQuery(Account.SObjectType).setRowLimit(1).run()[0];

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doDeleteImmediate(testAccount);
		Test.stopTest();

		System.assertEquals(1, Dml.Deleted?.getRecords(Account.SObjectType)?.size(), 'Wrong # of deleted accounts');
		System.assertEquals(testAccount?.Id, dmlResult.getId(), 'Invalid DML Result');
		System.assertEquals(true, dmlResult.isSuccess(), 'DML marked as unsuccessful');
		System.assertEquals(0, dmlResult.getErrors()?.size(), 'Wrong # of getErrors()');
		// Because Big Objects can NEVER be DML'd in @IsTest context, dml is always mocked here
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount?.Id))
			.whereCriteria(new Filter(Account.IsDeleted, Filter.EQUALS, true));
		System.assertEquals(true, query?.run()?.isEmpty(), 'Account was actually deleted');
	}

	@IsTest
	static void shouldThrowErrorOnInsert() {
		Account account = new Account(); // Missing a required field

		Test.startTest();
		Exception caughtError;
		try {
			DB.Dml.doInsert(new List<Account>{ account });
		} catch (Exception thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
	}

	@IsTest
	static void shouldThrowErrorOnUpdate() {
		Account account = new Account(); // Missing an Id field

		Test.startTest();
		Exception caughtError;
		try {
			DB.Dml.doUpdate(new List<Account>{ account });
		} catch (Exception thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
	}

	@IsTest
	static void shouldThrowErrorOnUpsertForIllegalUpsertKey() {
		// Only certain types of fields can be used safely in an upsert call;
		Account testAccount = new Account(Name = 'Test');
		Exception caughtError;

		Test.startTest();
		try {
			// Account.Name is not a valid field for upsert!
			DB.Dml.doUpsert(testAccount, Account.Name);
		} catch (System.SObjectException thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An System.SObjectException was not thrown');
	}

	@IsTest
	static void shouldThrowErrorOnUpsertForIllegalUpsertValue() {
		Account account = new Account(Id = DmlMock.generateFakeId(Account.SObjectType)); // illegal account Id value

		Test.startTest();
		Exception caughtError;
		try {
			DB.Dml.doUpsert(new List<Account>{ account });
		} catch (Exception thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
	}

	@IsTest
	static void shouldThrowErrorOnDelete() {
		Account account = new Account(Id = DmlMock.generateFakeId(Account.SObjectType)); // illegal account Id value

		Test.startTest();
		Exception caughtError;
		try {
			DB.Dml.doDelete(new List<Account>{ account });
		} catch (Exception thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
	}

	@IsTest
	static void shouldThrowErrorOnHardDelete() {
		Account account = new Account(Id = DmlMock.generateFakeId(Account.SObjectType)); // illegal account Id value

		Test.startTest();
		Exception caughtError;
		try {
			DB.Dml.doHardDelete(new List<Account>{ account });
		} catch (Exception thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
	}

	@IsTest
	static void shouldThrowErrorOnUndelete() {
		Account account = new Account(Id = DmlMock.generateFakeId(Account.SObjectType)); // illegal account Id value

		Test.startTest();
		Exception caughtError;
		try {
			DB.Dml.doUndelete(new List<Account>{ account });
		} catch (Exception thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
	}

	@IsTest
	static void shouldBypassErrorOnInsert() {
		Account account = new Account(); // Missing a required field

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doInsert(account, false);
		} catch (Exception thrownError) {
			System.assert(false, 'An error was thrown: ' + thrownError);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult?.isSuccess(), 'Illegal operation succeeded');
		System.assertEquals(false, dmlResult?.getErrors()?.isEmpty(), 'No getErrors() posted');
	}

	@IsTest
	static void shouldBypassErrorOnUpdate() {
		Account account = new Account(); // Missing a required field

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doUpdate(account, false);
		} catch (Exception thrownError) {
			System.assert(false, 'An error was thrown: ' + thrownError);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult?.isSuccess(), 'Illegal operation succeeded');
		System.assertEquals(false, dmlResult?.getErrors()?.isEmpty(), 'No getErrors() posted');
	}

	@IsTest
	static void shouldBypassErrorOnUpsert() {
		Account account = new Account(); // Missing a required field

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doUpsert(account, false);
		} catch (Exception thrownError) {
			System.assert(false, 'An error was thrown: ' + thrownError);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult?.isSuccess(), 'Illegal operation succeeded');
		System.assertEquals(false, dmlResult?.getErrors()?.isEmpty(), 'No getErrors() posted');
	}

	@IsTest
	static void shouldBypassErrorOnDelete() {
		// SFDC never lets you delete Contacts w/Cases!
		Contact contact = new Contact(LastName = 'Test');
		DB.Dml.doInsert(contact);
		Case theCase = new Case(ContactId = contact.Id);
		DB.Dml.doInsert(theCase);

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doDelete(contact, false);
		} catch (Exception thrownError) {
			System.assert(false, 'An error was thrown: ' + thrownError);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult?.isSuccess(), 'Illegal operation succeeded');
		System.assertEquals(false, dmlResult?.getErrors()?.isEmpty(), 'No getErrors() posted');
	}

	@IsTest
	static void shouldBypassErrorOnHardDelete() {
		// SFDC never lets you delete Contacts w/Cases!
		Contact contact = new Contact(LastName = 'Test');
		DB.Dml.doInsert(contact);
		Case theCase = new Case(ContactId = contact.Id);
		DB.Dml.doInsert(theCase);

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doHardDelete(contact, false);
		} catch (Exception thrownError) {
			System.assert(false, 'An error was thrown: ' + thrownError);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult?.isSuccess(), 'Illegal operation succeeded');
		System.assertEquals(false, dmlResult?.getErrors()?.isEmpty(), 'No getErrors() posted');
	}

	@IsTest
	static void shouldBypassErrorOnUndelete() {
		// You can't undelete something once if it's no longer in the recycle bin
		Account account = new Account(Name = 'Test');
		DB.Dml.doInsert(account);
		DB.Dml.doHardDelete(account);

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doUndelete(account, false);
		} catch (Exception thrownError) {
			System.assert(false, 'An error was thrown: ' + thrownError);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult?.isSuccess(), 'Illegal operation succeeded');
		System.assertEquals(false, dmlResult?.getErrors()?.isEmpty(), 'No getErrors() posted');
	}

	@IsTest
	static void shouldThrowErrorIfPublishingNormalSObject() {
		// There's nothing that prevents us from publishing a "normal" SObject; ex.
		// EventBus.publish(myAccount);
		// However, this is not proper behavior; doing so from the Dml class will throw an SObject Exception
		Account notAnEvent = new Account(Name = 'Test');
		Exception caughtError;
		try {
			DB.Dml.doPublish(notAnEvent);
		} catch (System.SObjectException thrownError) {
			caughtError = thrownError;
		}
		System.assertNotEquals(null, caughtError, 'An error was not thrown');
	}

	@IsTest
	static void shouldReturnPublishedEvents() {
		PlatformStatusAlertEvent event = new PlatformStatusAlertEvent();
		DmlResult dmlResult = DB.Dml.doPublish(event);

		Test.startTest();
		List<PlatformStatusAlertEvent> events = (List<PlatformStatusAlertEvent>) Dml.Published?.getAll();
		Test.stopTest();

		System.assertEquals(1, events?.size(), 'Wrong # of published events');
	}

	@IsTest
	static void shouldPublishDynamically() {
		PlatformStatusAlertEvent event = new PlatformStatusAlertEvent();

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_PUBLISH, event);
		Test.stopTest();

		System.assertEquals(1, Dml.Published?.getAll()?.size(), 'Event was not Published');
	}

	@IsTest
	static void shouldInsertDynamically() {
		Account testAccount = new Account(Name = 'Test Account');

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_INSERT, testAccount);
		Test.stopTest();

		System.assertNotEquals(null, testAccount.Id, 'Account was not inserted');
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(false, query.run().isEmpty(), 'No Accounts exist');
	}

	@IsTest
	static void shouldInsertImmediateDynamically() {
		Account testAccount = new Account(Name = 'Test Account');

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_INSERT_IMMEDIATE, testAccount);
		Test.stopTest();

		System.assertNotEquals(null, testAccount.Id, 'Account was not inserted');
		// NOTE: Database.*Immediate() is reserved for Big Objects, and always mocked in @IsTest context
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(true, query.run().isEmpty(), 'Account was actually inserted');
	}

	@IsTest
	static void shouldUpdateDynamically() {
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);
		String newAccName = 'Something else';
		testAccount.Name = newAccName;

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_UPDATE, testAccount);
		Test.stopTest();

		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.selectFields(Account.Name)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		testAccount = (Account) query.run()[0];
		System.assertEquals(newAccName, testAccount?.Name, 'Account was not updated');
	}

	@IsTest
	static void shouldUpdateImmediateDynamically() {
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);
		String newAccName = 'Something else';
		testAccount.Name = newAccName;

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_UPDATE_IMMEDIATE, testAccount);
		Test.stopTest();

		// NOTE: Database.*Immediate() is reserved for Big Objects, and always mocked in @IsTest context
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.selectFields(Account.Name)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		testAccount = (Account) query.run()[0];
		System.assertNotEquals(newAccName, testAccount?.Name, 'Account was actually updated');
	}

	@IsTest
	static void shouldUpsertDynamically() {
		Account testAccount = new Account(Name = 'Test Account');

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_UPSERT, testAccount);
		Test.stopTest();

		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(false, query.run().isEmpty(), 'Account was not upserted');
	}

	@IsTest
	static void shouldDeleteDynamically() {
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_DELETE, testAccount);
		Test.stopTest();

		System.assertEquals(true, Dml.Deleted?.containsRecord(testAccount.Id), 'Account was not added to Dml.Deleted');
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(true, query.run().isEmpty(), 'Record still exists');
	}

	@IsTest
	static void shouldDeleteImmediateDynamically() {
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_DELETE_IMMEDIATE, testAccount);
		Test.stopTest();

		System.assertEquals(true, Dml.Deleted?.containsRecord(testAccount.Id), 'Account was not added to Dml.Deleted');
		// NOTE: Database.*Immediate() is reserved for Big Objects, and always mocked in @IsTest context
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(false, query.run().isEmpty(), 'Record was actually deleted');
	}

	@IsTest
	static void shouldUndeleteDynamically() {
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);
		DB.Dml.doDelete(testAccount);

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_UNDELETE, testAccount);
		Test.stopTest();

		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(false, query.run().isEmpty(), 'Account was not undeleted');
		System.assertEquals(
			true,
			Dml.Undeleted?.containsRecord(testAccount.Id),
			'Account was not added to Dml.Undeleted'
		);
	}

	@IsTest
	static void shouldHardDeleteDynamically() {
		Account testAccount = new Account(Name = 'Test Account');
		DB.Dml.doInsert(testAccount);

		Test.startTest();
		DmlResult dmlResult = DB.Dml.doDml(Dml.Operation.DO_HARD_DELETE, testAccount);
		Test.stopTest();

		System.assertEquals(testAccount.Id, dmlResult.getId(), 'Wrong result getId()');
		Soql query = DB.Soql.newQuery(Account.SObjectType)
			.whereCriteria(new Filter(Account.Id, Filter.EQUALS, testAccount.Id));
		System.assertEquals(true, query.run().isEmpty(), 'Account was not deleted');
		System.assertEquals(true, Dml.Deleted?.containsRecord(testAccount.Id), 'Account was not added to Dml.Deleted');
	}

	@IsTest
	static void shouldDoDmlDynamicallyWithExternalIdField() {
		Lead testLead = new Lead(Company = 'Test', Email = 'test@test.com.invalid', LastName = 'Test');

		Test.startTest();
		// Note: Any externalIdField must have an "idLookup" property
		// https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/access_for_fields.htm#access_lookup
		// Lead.Email is one of the only "standard" fields that have this
		DB.Dml.doDml(Dml.Operation.DO_UPSERT, testLead, Lead.Email);
		Test.stopTest();

		Soql query = DB.Soql.newQuery(Lead.SObjectType).whereCriteria(new Filter(Lead.Id, Filter.EQUALS, testLead.Id));
		System.assertEquals(false, query.run().isEmpty(), 'Lead was not upserted');
	}

	@IsTest
	static void shouldDoDmlDynamicallyWithAllOrNone() {
		Account testAccount = new Account(); // No name - should throw a DML Error

		Test.startTest();
		DmlResult dmlResult;
		try {
			dmlResult = DB.Dml.doDml(Dml.Operation.DO_UPSERT, testAccount, false);
		} catch (Exception error) {
			String message = error?.getTypeName() + ': ' + error.getMessage() + '\n' + error.getStackTraceString();
			System.assert(false, 'An error was thrown during DML: ' + message);
		}
		Test.stopTest();

		System.assertEquals(false, dmlResult.isSuccess(), 'Dml did not fail');
	}

	@IsTest
	static void shouldDoDmlDynamicallyWithExternalIdFieldAndAllOrNone() {
		Lead testLead = new Lead(Company = 'Test', Email = 'test@test.com.invalid', LastName = 'Test Account');

		Test.startTest();
		DB.Dml.doDml(Dml.Operation.DO_UPSERT, testLead, Lead.Email, false);
		Test.stopTest();

		Soql query = DB.Soql.newQuery(Lead.SObjectType).whereCriteria(new Filter(Lead.Id, Filter.EQUALS, testLead.Id));
		System.assertEquals(false, query.run().isEmpty(), 'Lead was not upserted');
	}

	@IsTest
	static void shouldDetermineIfRecordWasProcessed() {
		Account account = new Account(Name = 'Test Account');

		Test.startTest();
		DB.Dml.doInsert(account);
		Test.stopTest();

		System.assertEquals(true, Dml.Inserted?.containsRecord(account), 'Account was not inserted');
		System.assertEquals(false, Dml.Updated?.containsRecord(account), 'Account was updated');
		System.assertEquals(false, Dml.Upserted?.containsRecord(account), 'Account was upserted');
		System.assertEquals(false, Dml.Deleted?.containsRecord(account), 'Account was deleted');
		System.assertEquals(false, Dml.Undeleted?.containsRecord(account), 'Account was undeleted');
	}

	@IsTest
	static void shouldReturnRecordIfProcessed() {
		Account account = new Account(Name = 'Test Account');

		Test.startTest();
		DB.Dml.doInsert(account);
		Test.stopTest();

		System.assertEquals(account, Dml.Inserted?.getRecord(account), 'Account was not Inserted');
		System.assertEquals(null, Dml.Updated?.getRecord(account), 'Account was Updated');
		System.assertEquals(null, Dml.Upserted?.getRecord(account), 'Account was Upserted');
		System.assertEquals(null, Dml.Deleted?.getRecord(account), 'Account was Deleted');
		System.assertEquals(null, Dml.Undeleted?.getRecord(account), 'Account was Undeleted');
	}

	@IsTest
	static void shouldReturnAllProcessedRecordsOfAnSObjectType() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
		}

		Test.startTest();
		DB.Dml.doInsert(accounts);
		Test.stopTest();

		System.assertEquals(accounts, Dml.Inserted?.getRecords(Account.SObjectType), 'Accounts were not Inserted');
		System.assertEquals(true, Dml.Updated?.getRecords(Account.SObjectType)?.isEmpty(), 'Accounts were Updated');
		System.assertEquals(true, Dml.Upserted?.getRecords(Account.SObjectType)?.isEmpty(), 'Accounts were Upserted');
		System.assertEquals(true, Dml.Deleted?.getRecords(Account.SObjectType)?.isEmpty(), 'Accounts were Deleted');
		System.assertEquals(true, Dml.Undeleted?.getRecords(Account.SObjectType)?.isEmpty(), 'Accounts were Undeleted');
		System.assertEquals(true, Dml.Published?.getRecords(Account.SObjectType)?.isEmpty(), 'Accounts were Published');
	}

	@IsTest
	static void shouldReturnAllProcessedRecords() {
		Account account = new Account(Name = 'Test Account');
		DB.Dml.doInsert(account);
		Contact contact = new Contact(AccountId = account.Id, LastName = 'Test');
		DB.Dml.doInsert(contact);

		Test.startTest();
		List<SObject> insertedRecords = Dml.Inserted?.getAll();
		Test.stopTest();

		System.assertEquals(2, insertedRecords?.size(), 'Wrong # of Inserted records');
		System.assert(
			insertedRecords.contains(account),
			'Does not contain the account: ' + JSON.serialize(insertedRecords)
		);
		System.assert(
			insertedRecords.contains(contact),
			'Does not contain the contact: ' + JSON.serialize(insertedRecords)
		);
	}

	@IsTest
	static void shouldResetDmlHistory() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			accounts.add(new Account(Name = 'Test Account'));
		}
		DB.Dml.doInsert(accounts);
		System.assertEquals(200, Dml.Inserted?.getAll()?.size(), 'Wrong # of records Inserted');

		Test.startTest();
		Dml.Inserted?.clear();
		Test.stopTest();

		System.assertEquals(0, Dml.Inserted?.getAll()?.size(), 'Records were not cleared');
	}
}
