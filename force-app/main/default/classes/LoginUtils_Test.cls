@IsTest 
private class LoginUtils_Test {
    @IsTest 
    static void shouldRetrieveAllActiveAuthSessions() {
        // There should at least be one auth session, for the current User Id
        Map<Id, List<AuthSession>> allSessions = LoginUtils.getAllActiveSessions(); 
        System.assertEquals(false, allSessions?.isEmpty(), 'No active sessions');
    }

    @IsTest 
    static void shouldRetrieveActiveAuthSessionsForAUser() {
        User me = new User(Id = UserInfo.getUserId()); 
        List<AuthSession> mySessions = LoginUtils.getActiveSessions(me);
        System.assertEquals(false, mySessions?.isEmpty(), 'No Active Sessions for current user');
    }

    @IsTest 
    static void shouldDetermineIfLoggedIn() {
        DatabaseLayer.setDmlEngine(new DmlMock()); 
        // The current user will always be logged in
        User me = new User(Id = UserInfo.getUserId()); 
        System.assertEquals(true, LoginUtils.userIsLoggedIn(me), 'Current user is not logged in');
        // A fake user should never be logged in
        User mockUser = new User();
        Databaselayer.Dml.doInsert(mockUser); 
        System.assertEquals(false, LoginUtils.userIsLoggedIn(mockUser), 'A fake user was flagged as logged in');
    }
}
