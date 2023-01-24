@IsTest
private class LoginUtils_Test {
	@IsTest
	static void shouldRetrieveAllActiveAuthSessions() {
		// There should at least be one auth session, for the current User Id
		Map<Id, List<AuthSession>> allSessions = LoginUtils.getAllActiveSessions();
		User me = LoginUtils_Test.getCurrentUser();
		if (LoginUtils_Test.notPackagingUser(me)) {
			System.assertEquals(false, allSessions?.isEmpty(), 'No active sessions');
		}
	}

	@IsTest
	static void shouldHandleMultipleSessionsForUser() {
		List<AuthSession> existingSessions = new List<AuthSession>();
		for (Integer i = 0; i < 2; i++) {
			AuthSession session = (AuthSession) SObjectUtils.setReadOnlyFields(
				new AuthSession(),
				new Map<SObjectField, Object>{
					AuthSession.UsersId => UserInfo.getUserId(),
					AuthSession.NumSecondsValid => 99999,
					AuthSession.LastModifiedDate => DateTime.now().addSeconds(-10)
				}
			);
			existingSessions.add(session);
		}
		DB.setQueryEngine(new SoqlMock.Factory());
		LoginUtils.ActiveSessionQuery.toMock()?.setMockResults(existingSessions);

		Test.startTest();
		Map<Id, List<AuthSession>> allSessions = LoginUtils.getAllActiveSessions();
		Test.stopTest();

		System.assertEquals(
			existingSessions?.size(),
			allSessions?.get(UserInfo.getUserId())?.size(),
			'Wrong # of Sessions'
		);
	}

	@IsTest
	static void shouldRetrieveActiveAuthSessionsForAUser() {
		// There should be at least one auth session for the current user
		User me = LoginUtils_Test.getCurrentUser();
		List<AuthSession> mySessions = LoginUtils.getActiveSessions(me);
		if (LoginUtils_Test.notPackagingUser(me)) {
			System.assertEquals(false, mySessions?.isEmpty(), 'No Active Sessions for current user');
		}
	}

	@IsTest
	static void shouldDetermineIfLoggedIn() {
		DB.setDmlEngine(new DmlMock());
		User me = LoginUtils_Test.getCurrentUser();
		// Excluding packaging, the current user should always be logged in
		Boolean isLoggedIn = LoginUtils.userIsLoggedIn(me);
		if (LoginUtils_Test.notPackagingUser(me)) {
			System.assertEquals(true, isLoggedIn, me?.Alias + ' user is not logged in');
		}
		// A fake user should never be logged in
		User mockUser = new User();
		DB.Dml.doInsert(mockUser);
		System.assertEquals(false, LoginUtils.userIsLoggedIn(mockUser), 'A fake user was flagged as logged in');
	}

	// **** HELPER **** //
	// Note: When building new package versions, Salesforce uses an automated user that does not generate a "normal" session/authsession
	// Exclude this user from these checks
	static final String PACKAGING_USER_ALIAS = 'PBuil';

	static Boolean notPackagingUser(User user) {
		return user?.Alias != PACKAGING_USER_ALIAS;
	}

	static User getCurrentUser() {
		Filter filter = new Filter(User.Id, Filter.EQUALS, UserInfo.getUserId());
		List<User> users = (List<User>) DB.Soql?.newQuery(User.SObjectType)?.selectAll()?.whereCriteria(filter)?.run();
		return (User) CollectionUtils.getIndexOf(users, 0);
	}
}
