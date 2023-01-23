@IsTest
private class AsyncDml_Test {
	@IsTest
	static void shouldProcessDmlAsynchronously() {
		List<Account> testAccounts = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			testAccounts.add(new Account(Name = 'Test Account'));
		}

		Test.startTest();
		AsyncDml.addRequest(new AsyncDml.Request(Dml.Operation.DO_INSERT, testAccounts));
		AsyncDml.runJob();
		Test.stopTest();

		List<Account> inserted = (List<Account>) DB.Soql.newQuery(Account.SObjectType).run();
		System.assertEquals(testAccounts?.size(), inserted?.size(), 'Wrong # of accounts inserted');
	}

	@IsTest
	static void shouldConvertLeadAsynchronously() {
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
		AsyncDml.addRequest(new AsyncDml.Conversion(leadConvertObj));
		AsyncDml.runJob();
		Test.stopTest();

		Soql query = DB.Soql.newQuery(Lead.SObjectType)
			.whereCriteria(new Filter(Lead.IsConverted, Filter.EQUALS, true));
		System.assertEquals(1, query?.run()?.size(), 'Wrong # of converted leads');
	}

	@IsTest
	static void shouldMakeRequestWithExternalId() {
		AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case())
			?.externalIdField(Case.CaseNumber);
		System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation');
		System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
		System.assertEquals(Case.CaseNumber, request?.externalIdField?.toSchemaType(), 'Wrong externalIdField');
		System.assertEquals(true, request?.allOrNone, 'Wrong allOrNone');
		System.assertEquals(false, request?.skipTriggers, 'Wrong skipTriggers');
	}

	@IsTest
	static void shouldMakeRequestWithAllOrNone() {
		AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case())?.allOrNone(false);
		System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation');
		System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
		System.assertEquals(null, request?.externalIdField, 'Wrong externalIdField');
		System.assertEquals(false, request?.allOrNone, 'Wrong allOrNone');
		System.assertEquals(false, request?.skipTriggers, 'Wrong skipTriggers');
	}

	@IsTest
	static void shouldMakeRequestWithExternalIdAndAllOrNone() {
		AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case())
			?.allOrNone(false)
			?.externalIdField(Case.CaseNumber);
		System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation');
		System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
		System.assertEquals(Case.CaseNumber, request?.externalIdField?.toSchemaType(), 'Wrong externalIdField');
		System.assertEquals(false, request?.allOrNone, 'Wrong allOrNone');
		System.assertEquals(false, request?.skipTriggers, 'Wrong skipTriggers');
	}

	@IsTest
	static void shouldMakeRequestWithSkippedTriggers() {
		AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, new Case()).skipTriggers(true);
		System.assertEquals(Dml.Operation.DO_INSERT, request?.operation, 'Wrong DML operation');
		System.assertEquals(1, request?.records?.size(), 'Wrong # of records');
		System.assertEquals(null, request?.externalIdField, 'Wrong externalIdField');
		System.assertEquals(true, request?.allOrNone, 'Wrong allOrNone');
		System.assertEquals(true, request?.skipTriggers, 'Wrong skipTriggers');
	}

	@IsTest
	static void shouldskipTriggers() {
		Account acc = new Account(Name = 'Test Account');
		AsyncDml.Request request = new AsyncDml.Request(Dml.Operation.DO_INSERT, acc).skipTriggers(true);

		Test.startTest();
		AsyncDml.addRequest(request);
		AsyncDml.runJob();
		Test.stopTest();

		// Note: We can't actually assert that the triggers were skipped, without having a trigger on a specific object
		System.assertEquals(1, DB.Soql.newQuery(Account.SObjectType)?.run().size(), 'DML was not performed');
	}

	@IsTest
	static void shouldInsertSynchronouslyIfLimitsReached() {
		Account account = new Account(Name = 'Test Account');
		AsyncDml.addRequest(new AsyncDml.Request(Dml.Operation.DO_INSERT, account));

		Test.startTest();
		// Prevent the job from running - must be in the same Test.start/stopTest context
		for (Integer i = 0; i < Limits.getLimitQueueableJobs(); i++) {
			System.enqueueJob(new ExampleQueueable());
		}
		Id jobId = AsyncDml.runJob();
		Test.stopTest();

		System.assertEquals(null, jobId, 'Job was processed asynchronously');
		System.assertNotEquals(null, account.Id, 'DML was not processed');
	}

	@IsTest
	static void shouldHandleErrors() {
		Account account = new Account(Name = 'Test Account');
		AsyncDml.Request req = new AsyncDml.Request(Dml.Operation.DO_UPDATE, account)?.allOrNone(true);
		// Can't update an Account with no Id - this will return a System.DmlException
		AsyncDml.addRequest(req);

		Test.startTest();
		Id jobId = AsyncDml.runJob();
		Test.stopTest();

		System.assertNotEquals(null, jobId, 'Job did not run');
		System.assertEquals(null, account.Id, 'Invalid Account was inserted');
	}

	private class ExampleQueueable implements System.Queueable {
		public void execute(System.QueueableContext context) {
			System.debug('Queueable ran');
		}
	}
}
