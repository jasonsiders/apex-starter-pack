public virtual class DmlResult {
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

	@TestVisible 
	protected DmlResult(Id recordId, Type sourceType) {
		this(new List<DmlResult.Error>(), true, recordId, sourceType);
	}

	protected DmlResult() {
		// Required for inheritance purposes
	}

	// Constructors wrap a single Result object
	public DmlResult(Database.DeleteResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.DeleteResult.class);
	}

	public DmlResult(Database.SaveResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.SaveResult.class);
	}

	public DmlResult(Database.UndeleteResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.UndeleteResult.class);
	}

	public DmlResult(Database.UpsertResult result) {
		this(result.getErrors(), result.isSuccess(), result.getId(), Database.UpsertResult.class);
	}

	public List<Error> getErrors() {
		return this.errors;
	}

	public Boolean isSuccess() {
		return this.isSuccess;
	}

	public Id getId() {
		return this.recordId;
	}

	public Type getType() {
		return this.sourceType;
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
		List<String> fields;
		String message;
		StatusCode statusCode;

		@TestVisible
		private Error(List<String> fields, String message, StatusCode statusCode) {
			this.fields = fields;
			this.message = message;
			this.statusCode = statusCode;
		}

		public Error(Database.Error error) {
			this(error.getFields(), error.getMessage(), error.getStatusCode());
		}

		public List<String> getFields() {
			return this.fields;
		}

		public String getMessage() {
			return this.message;
		}

		public StatusCode getStatusCode() {
			return this.statusCode;
		}

		public override String toString() {
			List<String> messageParts = new List<String>{
				String.valueOf(this?.getStatusCode()),
				this?.getMessage(),
				JSON.serialize(this?.getFields())
			};
			return String.join(messageParts, ': ');
		}
	}
}