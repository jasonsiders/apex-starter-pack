@IsTest
private class DmlResult_Test {
	@IsTest
	static void shouldConvertDeleteResults() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		insert records;
		List<Database.DeleteResult> deleteResults = Database.delete(records, false);

		Test.startTest();
		List<DmlResult> dmlResults = DmlResult.wrap(deleteResults);
		Test.stopTest();

		System.assertEquals(deleteResults?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Database.DeleteResult deleteResult = deleteResults[i];
			System.assertEquals(deleteResult.getErrors()?.size(), dmlResult.getErrors()?.size(), 'Wrong # of errors');
			System.assertEquals(deleteResult.getId(), dmlResult?.getId(), 'Wrong recordId');
			System.assertEquals(deleteResult.isSuccess(), dmlResult.isSuccess(), 'Wrong isSuccess value');
		}
	}

	@IsTest
	static void shouldConvertSaveResults() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		List<Database.SaveResult> saveResults = Database.insert(records, false);

		Test.startTest();
		List<DmlResult> dmlResults = DmlResult.wrap(saveResults);
		Test.stopTest();

		System.assertEquals(saveResults?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Database.SaveResult saveResult = saveResults[i];
			System.assertEquals(saveResult.getErrors()?.size(), dmlResult.getErrors()?.size(), 'Wrong # of errors');
			System.assertEquals(saveResult.getId(), dmlResult?.getId(), 'Wrong recordId');
			System.assertEquals(saveResult.isSuccess(), dmlResult.isSuccess(), 'Wrong isSuccess value');
		}
	}

	@IsTest
	static void shouldConvertUndeleteResults() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		insert records;
		delete records;
		List<Database.UndeleteResult> undeleteResults = Database.undelete(records, false);

		Test.startTest();
		List<DmlResult> dmlResults = DmlResult.wrap(undeleteResults);
		Test.stopTest();

		System.assertEquals(undeleteResults?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Database.UndeleteResult undeleteResult = undeleteResults[i];
			List<Database.Error> dbErrors = undeleteResult.getErrors();
			Integer numDbErrors = (dbErrors != null) ? dbErrors.size() : 0;
			System.assertEquals(numDbErrors, dmlResult.getErrors()?.size(), 'Wrong # of errors');
			System.assertEquals(undeleteResult.getId(), dmlResult?.getId(), 'Wrong recordId');
			System.assertEquals(undeleteResult.isSuccess(), dmlResult.isSuccess(), 'Wrong isSuccess value');
		}
	}

	@IsTest
	static void shouldConvertUpsertResults() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		List<Database.UpsertResult> upsertResults = Database.upsert(records, false);

		Test.startTest();
		List<DmlResult> dmlResults = DmlResult.wrap(upsertResults);
		Test.stopTest();

		System.assertEquals(upsertResults?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Database.UpsertResult upsertResult = upsertResults[i];
			System.assertEquals(upsertResult.getErrors()?.size(), dmlResult.getErrors()?.size(), 'Wrong # of errors');
			System.assertEquals(upsertResult.getId(), dmlResult?.getId(), 'Wrong recordId');
			System.assertEquals(upsertResult.isSuccess(), dmlResult.isSuccess(), 'Wrong isSuccess value');
		}
	}

	@IsTest
	static void shouldConvertErrors() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		List<Database.Error> errors = new List<Database.Error>();
		for (Database.SaveResult saveResult : Database.update(records, false)) {
			// Can't update SObjects if they don't already exist! This will produce errors
			errors.addAll(saveResult.getErrors());
		}

		Test.startTest();
		List<DmlResult.Error> dmlErrors = DmlResult.wrap(errors);
		Test.stopTest();

		System.assertEquals(errors?.size(), dmlErrors?.size(), 'Wrong # of errors');
		for (Integer i = 0; i < dmlErrors?.size(); i++) {
			DmlResult.Error dmlError = dmlErrors[i];
			Database.Error error = errors[i];
			System.assertEquals(error.getFields(), dmlError.getFields(), 'Wrong fields');
			System.assertEquals(error.getMessage(), dmlError.getMessage(), 'Wrong message');
			System.assertEquals(error.getStatusCode(), dmlError.getStatusCode(), 'Wrong status code');
		}
	}

	@IsTest
	static void shouldBeTypeAware() {
		// If it's ever needed, callers should be able to get to
		// the original Database.*Result object that spawned this object
		DmlResult result;
		Account account = new Account(Name = 'Test');

		Test.startTest();
		result = new DmlResult(Database.insert(account, false));
		System.assertEquals(Database.SaveResult.class, result?.getType(), 'Wrong Type');
		result = new DmlResult(Database.upsert(account, false));
		System.assertEquals(Database.UpsertResult.class, result?.getType(), 'Wrong Type');
		result = new DmlResult(Database.delete(account, false));
		System.assertEquals(Database.DeleteResult.class, result?.getType(), 'Wrong Type');
		result = new DmlResult(Database.undelete(account, false));
		System.assertEquals(Database.UndeleteResult.class, result?.getType(), 'Wrong Type');
		Test.stopTest();
	}

	@IsTest
	static void shouldBeExtendable() {
		// For some reason, the default constructor must be visible for extending types to exist
		// ...even if those types don't use the default constructor?
		Object obj = new Example();
		System.assertEquals(true, obj instanceof DmlResult, 'Did not inherit properly');
	}

	@IsTest
	static void shouldOutputError() {
		DmlResult result = new DmlResult(Database.update(new Account(), false));
		List<DmlResult.Error> errors = result?.getErrors();
		DmlResult.Error error = (errors?.isEmpty() == false) ? errors[0] : null;

		Test.startTest();
		String errorMsg = String.valueOf(error);
		Test.stopTest();

		String expected = String.format(
			'{0}: {1}: {2}',
			new List<String>{
				String.valueOf(error?.getStatusCode()),
				error?.getMessage(),
				JSON.serialize(error?.getFields())
			}
		);
		System.assertEquals(expected, errorMsg, 'Wrong Error Message');
	}

	// **** INNER **** //
	private class Example extends DmlResult {
	}
}
