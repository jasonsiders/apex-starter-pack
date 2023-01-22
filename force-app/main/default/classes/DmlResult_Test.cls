@IsTest
private class DmlResult_Test {
	@IsTest
	static void shouldConvertDeleteResults() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		Databaselayer.Dml.doInsert(records);
		List<Database.DeleteResult> deleteResults = Database.delete(records, false);

		Test.startTest();
		List<DmlResult> dmlResults = DmlResult.wrap(deleteResults);
		Test.stopTest();

		System.assertEquals(deleteResults?.size(), dmlResults?.size(), 'Wrong # of results');
		for (Integer i = 0; i < dmlResults?.size(); i++) {
			DmlResult dmlResult = dmlResults[i];
			Database.DeleteResult deleteResult = deleteResults[i];
			System.assertEquals(deleteResult.getErrors()?.size(), dmlResult.errors?.size(), 'Wrong # of errors');
			System.assertEquals(deleteResult.getId(), dmlResult?.recordId, 'Wrong recordId');
			System.assertEquals(deleteResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
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
			System.assertEquals(saveResult.getErrors()?.size(), dmlResult.errors?.size(), 'Wrong # of errors');
			System.assertEquals(saveResult.getId(), dmlResult?.recordId, 'Wrong recordId');
			System.assertEquals(saveResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
		}
	}

	@IsTest
	static void shouldConvertUndeleteResults() {
		// This type can't be mocked without performing dml - hence the reason for the wrapper class
		List<Account> records = new List<Account>{ new Account(Name = 'Test') };
		Databaselayer.Dml.doInsert(records);
		Databaselayer.Dml.doDelete(records);
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
			System.assertEquals(numDbErrors, dmlResult.errors?.size(), 'Wrong # of errors');
			System.assertEquals(undeleteResult.getId(), dmlResult?.recordId, 'Wrong recordId');
			System.assertEquals(undeleteResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
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
			System.assertEquals(upsertResult.getErrors()?.size(), dmlResult.errors?.size(), 'Wrong # of errors');
			System.assertEquals(upsertResult.getId(), dmlResult?.recordId, 'Wrong recordId');
			System.assertEquals(upsertResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
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
			System.assertEquals(error.getFields(), dmlError.fields, 'Wrong fields');
			System.assertEquals(error.getMessage(), dmlError.message, 'Wrong message');
			System.assertEquals(error.getStatusCode(), dmlError.statusCode, 'Wrong status code');
		}
	}

	@IsTest
	static void shouldBeExtendable() {
		// For some reason, the default constructor must be visible for extending types to exist
		// ...even if those types don't use the default constructor?
		Object obj = new Example();
		System.assertEquals(true, obj instanceof DmlResult, 'Did not inherit properly');
	}

	// **** INNER **** //
	private class Example extends DmlResult {
	}
}
