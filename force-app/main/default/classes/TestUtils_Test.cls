@IsTest
private class TestUtils_Test {
    @IsTest 
    static void shouldGenerateFakeId() {
        Set<Id> accountIds = new Set<Id>(); 
        for (Integer i = 0; i < 200; i++) {
            Id fakeId = TestUtils.generateFakeId(Account.SObjectType); 
            accountIds.add(fakeId); 
        }
        System.assertEquals(200, accountIds.size(), 'Wrong number of Ids generated. Was there a duplicate?');
    }

    @IsTest 
    static void shouldAddFakeIdToRecord() {
        Account account = (Account) TestUtils.generateFakeId(new Account(Name = 'Test Account')); 
        System.assertNotEquals(null, account.Id, 'Account ID was not set'); 
        System.assertEquals('001000000000000000', account.Id, 'Unexpected Id set'); 
    }
}
