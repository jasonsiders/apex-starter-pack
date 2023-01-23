public abstract class DB {
	// Represents the environment's database layer. 
	// Can be stubbed out in @IsTest context to support mocking.
	public static Dml Dml { get; private set; }
	public static QueryFactory Soql { get; private set; }

	static {
		DB.Dml = new Dml();
		DB.Soql = new Soql.Factory();
	}

	@TestVisible
	static Dml setDmlEngine(Dml dmlEngine) {
		DB.Dml = dmlEngine;
		return dmlEngine;
	}

	@TestVisible
	static QueryFactory setQueryEngine(QueryFactory queryEngine) {
		DB.Soql = queryEngine;
		return queryEngine;
	}

	public interface QueryFactory {
		Soql newQuery(SObjectType objectType);
	}
}
