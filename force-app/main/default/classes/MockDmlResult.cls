@IsTest
global class MockDmlResult extends DmlResult {
    // Gives visibility into the DmlResult class constructors outside the package
    global MockDmlResult(List<Error> errors, Boolean isSuccess, Id recordId, Type sourceType) {
		super(errors, isSuccess, recordId, sourceType);
	}

	global MockDmlResult(List<Database.Error> errors, Boolean isSuccess, Id recordId, Type sourceType) {
		this(DmlResult.wrap(errors), isSuccess, recordId, sourceType);
	}
}