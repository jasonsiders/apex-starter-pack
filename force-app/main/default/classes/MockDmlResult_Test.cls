@IsTest
private class MockDmlResult_Test {
    @IsTest 
    static void shouldMockADmlRequest() {
        Account account = (Account) DmlMock.generateFakeId(new Account());
        Database.SaveResult saveResult = Database.insert(account, false);
        List<Database.Error> errors = saveResult?.getErrors();

        Test.startTest();
        DmlResult result = new MockDmlResult(errors, false, account?.Id, Database.SaveResult.class);
        Test.stopTest();

        System.assertEquals(errors?.size(), result?.getErrors()?.size(), 'Wrong # of errors');
        System.assertEquals(account?.Id, result?.getId(), 'Wrong Id');
        System.assertEquals(saveResult?.isSuccess(), result?.isSuccess(), 'Wrong isSuccess() value');
    }
}