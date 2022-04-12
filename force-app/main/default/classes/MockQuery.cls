@IsTest 
global class MockQuery extends SoqlQuery {
    List<SObject> mockResults; 

    global MockQuery(SObjectType objectType, List<SObject> mockResults) {
        super(objectType); 
        this.mockResults = mockResults; 
    }

    global override List<SObject> run() {
        return this.mockResults; 
    }
}