@IsTest 
public class QueryMock extends SoqlQuery {
    static List<SObject> mockResults; 

    public QueryMock(SObjectType objectType) {
        super(objectType);
    }

    public override List<SObject> run() {
        return QueryMock.mockResults; 
    }

    public class Factory implements IQueryFactory {
        public IQuery newQuery(SObjectType objectType) {
            return new QueryMock(objectType); 
        }

        public void setMockResults(List<SObject> mockResults) {
            QueryMock.mockResults = mockResults; 
        }
    }   
}