@IsTest 
private class OrgUtils_Test {
    @IsTest 
    static void shouldReturnCurrentApiVersion() {
        System.assertNotEquals(null, OrgUtils.getCurrentApiVersion(), 'Did not return the current API version');
    }
}
