global class DmlResult {
    // Database.*Result classes do not share a common interface, and they cannot be manually constructed
    // This makes testing/mocking especially difficult
    // This class wraps all of those result types
    static IDml dmlEngine = new Dml(); 

    global List<Error> errors { get; private set; }
    global Boolean isSuccess { get; private set; }
    global Id recordId { get; private set; }

    @TestVisible
    private DmlResult(List<Error> errors, Boolean isSuccess, Id recordId) {
        this.errors = errors;
        this.isSuccess = isSuccess;
        this.recordId = recordId; 
    }

    @TestVisible
    private DmlResult(List<Database.Error> errors, Boolean isSuccess, Id recordId) {
        this(DmlResult.wrap(errors), isSuccess, recordId);
    }

    // Constructors wrap a single Result object
    global DmlResult(Database.DeleteResult result) {
        this(result.getErrors(), result.isSuccess(), result.getId());
    }

    global DmlResult(Database.SaveResult result) {
        this(result.getErrors(), result.isSuccess(), result.getId());
    }

    global DmlResult(Database.UndeleteResult result) {
        this(result.getErrors(), result.isSuccess(), result.getId());
    }

    global DmlResult(Database.UpsertResult result) {
        this(result.getErrors(), result.isSuccess(), result.getId());
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

    @TestVisible
    static List<DmlResult> getMockResults(List<SObject> records) {
        List<DmlResult> dmlResults = new List<DmlResult>();
        for (SObject record : records) {
            dmlResults.add(new DmlResult(
                new List<Error>(), 
                true, 
                record.Id
            ));
        }
        return dmlResults;
    }

    global class Error {
        // Wraps the Database.Error class, which also cannot be constructed
        global List<String> fields { get; private set; }
        global String message { get; private set; }
        global StatusCode statusCode { get; private set; }

        global Error(Database.Error error) {
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