@IsTest
public class SoqlMock extends Soql {
    public static Map<String, List<SObject>> mockResults = new Map<String, List<SObject>>(); 

    public SoqlMock(SObjectType objectType) {
        super(objectType);
    }

    public override List<SObject> run() {
        String queryKey = super.queryKey;
        List<SObject> mockResults = SoqlMock.mockResults?.get(queryKey);  
        return (mockResults != null) ? mockResults : new List<SObject>(); 
    }

    public static void setMockResults(String queryKey, List<SObject> mockResults) {
        SoqlMock.mockResults.put(queryKey, mockResults);
    }

    public class Factory implements DatabaseLayer.QueryFactory {
        public Soql newQuery(SObjectType objectType) {
            return new SoqlMock(objectType); 
        }
    }
}
