@IsTest
private class SubQuery_Test {
    @IsTest 
    static void shouldGenerateSubQuery() {
        SubQuery subQuery = new SubQuery(Contact.AccountId);
        System.assertEquals('Contacts', subQuery.relationship?.getRelationshipName(), 'Wrong relationship');
        System.assertEquals('(SELECT Id FROM Contacts)', subQuery.toString(), 'Unexpected Query String');
    }
}
