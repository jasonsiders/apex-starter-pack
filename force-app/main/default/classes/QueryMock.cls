@IsTest 
global class QueryMock extends SoqlQuery {
    List<SObject> mockResults; 

    global QueryMock(SObjectType objectType, List<SObject> mockResults) {
        super(objectType);
        this.setMockResults(mockResults); 
    }

    global QueryMock(SObjectType objectType) {
        this(objectType, null); 
    }

    global QueryMock setMockResults(List<SObject> mockResults) {
        this.mockResults = mockResults; 
        return this; 
    }

    global override List<SObject> run() {
        return this.mockResults; 
    }

    public class Factory implements IQueryFactory {
        public IQuery newQuery(SObjectType objectType) {
            return new QueryMock(objectType); 
        }
    }   
}