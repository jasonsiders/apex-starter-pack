public inherited sharing abstract class DatabaseLayer {
    public static Dml Dml { get; private set; }
    public static IQueryFactory Soql { get; private set; }

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
    static IQueryFactory setQueryEngine(IQueryFactory queryEngine) {
        Databaselayer.Soql = queryEngine; 
        return queryEngine;
    }
}
