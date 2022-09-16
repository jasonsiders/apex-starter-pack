public virtual class DmlResult {
	// Database.*Result classes do not share a common interface, and they cannot be manually constructed
	// This makes testing/mocking especially difficult
	// This class wraps all of those result types
	public List<Error> errors { get; protected set; }
	public Boolean isSuccess { get; protected set; }
	public Id recordId { get; protected set; }

	@TestVisible
	protected DmlResult(List<Error> errors, Boolean isSuccess, Id recordId) {
		this.errors = errors;
		this.isSuccess = isSuccess;
		this.recordId = recordId;
	}

	@TestVisible
	protected DmlResult(List<Database.Error> errors, Boolean isSuccess, Id recordId) {
		this(DmlResult.wrap(errors), isSuccess, recordId);
	}

	protected DmlResult() {
		// Required for inheritance purposes
	}

	// Constructors wrap a single Result object
	public DmlResult(Database.DeleteResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId());
	}

	public DmlResult(Database.SaveResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId());
	}

	public DmlResult(Database.UndeleteResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId());
	}

	public DmlResult(Database.UpsertResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId());
	}

	// Specialized methods to process data
	public void logError() {
		if (this.isSuccess == false) {
			Logger.error(DmlResult.class, JSON.serializePretty(this.errors));
		}
	}

	public static void logErrors(List<DmlResult> results) {
		for (DmlResult result : results) {
			result.logError();
		}
		Logger.publish();
	}

	// Methods to "wrap" results in bulk
	public static List<DmlResult> wrap(List<Database.DeleteResult> deleteResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.DeleteResult deleteResult : deleteResults) {
			dmlResults.add(new DmlResult(deleteResult));
		}
		return dmlResults;
	}

	public static List<DmlResult> wrap(List<Database.SaveResult> saveResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.SaveResult saveResult : saveResults) {
			dmlResults.add(new DmlResult(saveResult));
		}
		return dmlResults;
	}

	public static List<DmlResult> wrap(List<Database.UndeleteResult> undeleteResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.UndeleteResult undeleteResult : undeleteResults) {
			dmlResults.add(new DmlResult(undeleteResult));
		}
		return dmlResults;
	}

	public static List<DmlResult> wrap(List<Database.UpsertResult> upsertResults) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (Database.UpsertResult upsertResult : upsertResults) {
			dmlResults.add(new DmlResult(upsertResult));
		}
		return dmlResults;
	}

	public static List<Error> wrap(List<Database.Error> errors) {
		List<Error> dmlErrors = new List<Error>();
		errors = (errors != null) ? errors : new List<Database.Error>();
		for (Database.Error error : errors) {
			dmlErrors.add(new Error(error));
		}
		return dmlErrors;
	}

	public class Error {
		// Wraps the Database.Error class, which also cannot be constructed
		public List<String> fields { get; private set; }
		public String message { get; private set; }
		public StatusCode statusCode { get; private set; }

		public Error(Database.Error error) {
			this(error.getFields(), error.getMessage(), error.getStatusCode());
		}

		@TestVisible
		private Error(List<String> fields, String message, StatusCode statusCode) {
			this.fields = fields;
			this.message = message;
			this.statusCode = statusCode;
		}
	}
}
