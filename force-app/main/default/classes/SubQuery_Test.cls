@IsTest
private class SubQuery_Test {
    @IsTest 
    static void shouldGenerateSubQuery() {
        Schema.ChildRelationship contactsRelationship = Describes.getChildRelationship(Account.SObjectType, 'Contacts');

        Test.startTest();
        SubQuery subQuery = new SubQuery(contactsRelationship);
        Test.stopTest();

        System.assertEquals(contactsRelationship, subQuery.relationship, 'Wrong relationship');
        System.assertEquals('(SELECT Id FROM Contacts)', subQuery.getQueryString(), 'Unexpected Query String');
    }
}
