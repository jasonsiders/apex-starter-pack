@IsTest 
public class QueryMock extends SoqlQuery {
    public static Map<String, List<SObject>> mockResults = new Map<String, List<SObject>>(); 

    public QueryMock(SObjectType objectType) {
        super(objectType);
    }

    public override List<SObject> run() {
        String queryKey = super.queryKey;
        List<SObject> mockResults = QueryMock.mockResults?.get(queryKey);  
        return (mockResults != null) ? mockResults : new List<SObject>(); 
    }

    public static void setMockResults(String queryKey, List<SObject> mockResults) {
        QueryMock.mockResults.put(queryKey, mockResults);
    }

    public class Factory implements IQueryFactory {
        public IQuery newQuery(SObjectType objectType) {
            return new QueryMock(objectType); 
        }
    }
}