@IsTest 
global class QueryMock extends SoqlQuery {
    List<SObject> mockResults; 

    global QueryMock(SObjectType objectType, List<SObject> mockResults) {
        super(objectType); 
        this.mockResults = mockResults; 
    }

    global override List<SObject> run() {
        return this.mockResults; 
    }
}