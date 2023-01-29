global virtual class DmlResult {
	// Database.*Result classes do not share a common interface, and they cannot be manually constructed
	// This makes testing/mocking especially difficult
	// This class wraps all of those result types
	List<Error> errors;
	Boolean isSuccess;
	Id recordId;
	Type sourceType;

	@TestVisible
	protected DmlResult(List<Error> errors, Boolean isSuccess, Id recordId, Type sourceType) {
		this.errors = errors;
		this.isSuccess = isSuccess;
		this.recordId = recordId;
		this.sourceType = sourceType;
	}

	@TestVisible
	protected DmlResult(List<Database.Error> errors, Boolean isSuccess, Id recordId, Type sourceType) {
		this(DmlResult.wrap(errors), isSuccess, recordId, sourceType);
	}

	protected DmlResult() {
		// Required for inheritance purposes
	}

	// Constructors wrap a single Result object
	global DmlResult(Database.DeleteResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.DeleteResult.class);
	}

	global DmlResult(Database.SaveResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.SaveResult.class);
	}

	global DmlResult(Database.UndeleteResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.UndeleteResult.class);
	}

	global DmlResult(Database.UpsertResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.UpsertResult.class);
	}

	global List<Error> getErrors() {
		return this.errors;
	}

	global Boolean isSuccess() {
		return this.isSuccess;
	}

	global Id getId() {
		return this.recordId;
	}

	global Type getType() {
		return this.sourceType;
	}

	// Methods to "wrap" results in bulk
	global static List<DmlResult> wrap(List<Database.DeleteResult> deleteResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.DeleteResult deleteResult : deleteResults) {
			dmlResults.add(new DmlResult(deleteResult));
		}
		return dmlResults;
	}

	global static List<DmlResult> wrap(List<Database.SaveResult> saveResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.SaveResult saveResult : saveResults) {
			dmlResults.add(new DmlResult(saveResult));
		}
		return dmlResults;
	}

	global static List<DmlResult> wrap(List<Database.UndeleteResult> undeleteResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.UndeleteResult undeleteResult : undeleteResults) {
			dmlResults.add(new DmlResult(undeleteResult));
		}
		return dmlResults;
	}

	global static List<DmlResult> wrap(List<Database.UpsertResult> upsertResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.UpsertResult upsertResult : upsertResults) {
			dmlResults.add(new DmlResult(upsertResult));
		}
		return dmlResults;
	}

	global static List<Error> wrap(List<Database.Error> errors) {
		List<Error> dmlErrors = new List<Error>();
		errors = (errors != null) ? errors : new List<Database.Error>();
		for (Database.Error error : errors) {
			dmlErrors.add(new Error(error));
		}
		return dmlErrors;
	}

	global class Error {
		// Wraps the Database.Error class, which also cannot be constructed
		List<String> fields;
		String message;
		StatusCode statusCode;

		@TestVisible
		private Error(List<String> fields, String message, StatusCode statusCode) {
			this.fields = fields;
			this.message = message;
			this.statusCode = statusCode;
		}

		global Error(Database.Error error) {
			this(error.getFields(), error.getMessage(), error.getStatusCode());
		}

		global List<String> getFields() {
			return this.fields;
		}

		global String getMessage() {
			return this.message;
		}

		global StatusCode getStatusCode() {
			return this.statusCode;
		}

		global override String toString() {
			List<String> messageParts = new List<String>{
				String.valueOf(this?.getStatusCode()),
				this?.getMessage(),
				JSON.serialize(this?.getFields())
			};
			return String.join(messageParts, ': ');
		}
	}
}
