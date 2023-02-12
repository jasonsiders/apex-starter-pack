global abstract class DB {
	// Represents the environment's database layer.
	// Can be stubbed out in @IsTest context to support mocking.
	global static Dml Dml { get; private set; }
	global static QueryFactory Soql { get; private set; }
	@TestVisible static Boolean IsTest = Test.isRunningTest();

	static {
		DB.Dml = new Dml();
		DB.Soql = new Soql.Factory();
	}

	global static Dml setDmlEngine(Dml dmlEngine) {
		DB.contextCheck(); 
		DB.Dml = dmlEngine;
		return dmlEngine;
	}

	global static QueryFactory setQueryEngine(QueryFactory queryEngine) {
		DB.contextCheck(); 
		DB.Soql = queryEngine;
		return queryEngine;
	}

	static void contextCheck() {
		// setDmlEngine()/setQueryEngine() should only ever be called in @IsTest context
		// Normally, we'd make these methods @TestVisible, but this prevents subscribers
		// from accessing these mocks from outside the package - which is entirely the point of this repo.
		// Don't love this, but it's our best solution for now.
		if (DB.IsTest == false) {
			final String msg = 'You cannot mock the database outside of @IsTest context.';
			throw new ContextException(msg); 
		}
	}

	// **** INNER **** //
	global interface QueryFactory {
		Soql newQuery(SObjectType objectType);
	}

	@TestVisible
	private class ContextException extends Exception {}
}
