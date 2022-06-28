public inherited sharing abstract class DatabaseLayer {
    public static Dml Dml { get; private set; }
    public static QueryFactory Soql { get; private set; }

    static {
        Databaselayer.Dml = new Dml();
        Databaselayer.Soql = new Soql.Factory();
    }

    @TestVisible
    static Dml setDmlEngine(Dml dmlEngine) {
        Databaselayer.Dml = dmlEngine;
        return dmlEngine; 
    }

    @TestVisible
    static QueryFactory setQueryEngine(QueryFactory queryEngine) {
        Databaselayer.Soql = queryEngine; 
        return queryEngine;
    }

    public interface QueryFactory {
        Soql newQuery(SObjectType objectType); 
    }
}
