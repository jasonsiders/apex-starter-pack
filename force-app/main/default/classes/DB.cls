global abstract class DB {
	// Represents the environment's database layer.
	// Can be stubbed out in @IsTest context to support mocking.
	global static Dml Dml { get; private set; }
	global static QueryFactory Soql { get; private set; }

	static {
		DB.Dml = new Dml();
		DB.Soql = new Soql.Factory();
	}

	global static Dml setDmlEngine(Dml dmlEngine) {
		DB.Dml = dmlEngine;
		return dmlEngine;
	}

	global static QueryFactory setQueryEngine(QueryFactory queryEngine) {
		DB.Soql = queryEngine;
		return queryEngine;
	}

	global interface QueryFactory {
		Soql newQuery(SObjectType objectType);
	}
}
