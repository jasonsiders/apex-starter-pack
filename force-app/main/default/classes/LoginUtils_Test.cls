@IsTest
private class LoginUtils_Test {
	@IsTest
	static void shouldRetrieveAllActiveAuthSessions() {
		// Excluding package context, there should at least be one auth session, for the current User Id
		Map<Id, List<AuthSession>> allSessions = LoginUtils.getAllActiveSessions();
		if (LoginUtils_Test.outsidePackageContext()) {
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
		User me = new User(Id = UserInfo.getUserId());
		List<AuthSession> mySessions = LoginUtils.getActiveSessions(me);
		if (LoginUtils_Test.outsidePackageContext()) {
			System.assertEquals(false, mySessions?.isEmpty(), 'No Active Sessions for current user');
		}
	}

	@IsTest
	static void shouldDetermineIfLoggedIn() {
		DB.setDmlEngine(new DmlMock());
		User me = (User) DB.Soql.newQuery(User.SObjectType)
			?.selectAll()
			?.whereCriteria(new Filter(User.Id, Filter.EQUALS, UserInfo.getUserId()))
			?.run()[0];
		// The current user should always be logged in
		System.assertEquals(true, LoginUtils.userIsLoggedIn(me), 'Current user is not logged in: ' + JSON.serialize(me));
		// A fake user should never be logged in
		User mockUser = new User();
		DB.Dml.doInsert(mockUser);
		System.assertEquals(false, LoginUtils.userIsLoggedIn(mockUser), 'A fake user was flagged as logged in');
	}

	static Boolean outsidePackageContext() {
		try {
			return (Packaging.getCurrentPackageId() == null);
		} catch (System.NoDataFoundException error) {
			return true;
		}
	}
}
