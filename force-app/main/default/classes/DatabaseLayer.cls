public inherited sharing abstract class DatabaseLayer {
    public static Dml DmlEngine { get; private set; }
    public static IQueryFactory QueryEngine { get; private set; }

    static {
        DatabaseLayer.DmlEngine = new Dml();
        DatabaseLayer.QueryEngine = new Soql.Factory();
    }

    @TestVisible
    static Dml setDmlEngine(Dml dmlEngine) {
        DatabaseLayer.DmlEngine = dmlEngine;
        return dmlEngine; 
    }

    @TestVisible
    static IQueryFactory setQueryEngine(IQueryFactory queryEngine) {
        DatabaseLayer.QueryEngine = queryEngine; 
        return queryEngine;
    }
}
