public inherited sharing abstract class DatabaseLayer {
    public static IDml DmlEngine { get; private set; }
    public static IQueryFactory QueryEngine { get; private set; }

    static {
        DatabaseLayer.DmlEngine = new Dml();
        DatabaseLayer.QueryEngine = new SoqlQuery.Factory();
    }

    @TestVisible
    static IDml setDmlEngine(IDml dmlEngine) {
        DatabaseLayer.DmlEngine = dmlEngine;
        return dmlEngine; 
    }

    @TestVisible
    static IQueryFactory setQueryEngine(IQueryFactory queryEngine) {
        DatabaseLayer.QueryEngine = queryEngine; 
        return queryEngine;
    }
}
