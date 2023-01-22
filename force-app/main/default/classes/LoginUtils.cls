public abstract class LoginUtils {
	@TestVisible
	static Soql ActiveSessionQuery = Databaselayer.Soql.newQuery(AuthSession.SObjectType)
		.selectFields(new FieldRef(new List<SObjectField>{ AuthSession.LoginHistoryId, LoginHistory.Application }))
		.selectFields(
			new List<SObjectField>{ AuthSession.UsersId, AuthSession.LastModifiedDate, AuthSession.NumSecondsValid }
		)
		.whereCriteria(new Filter(AuthSession.LastModifiedDate, Filter.EQUALS, 'LAST_N_DAYS:1'))
		.whereCriteria(new Filter(AuthSession.ParentId, Filter.Equals, null))
		.orderBy(new SoqlSort(AuthSession.CreatedDate, SoqlSort.Order.ASCENDING));

	static Map<Id, List<AuthSession>> ActiveSessions {
		// Map of UserId => List<AuthSession>
		get {
			ActiveSessions = (ActiveSessions != null) ? ActiveSessions : LoginUtils.getAllActiveSessions();
			return ActiveSessions;
		}
		private set;
	}

	public static Map<Id, List<AuthSession>> getAllActiveSessions() {
		Map<Id, List<AuthSession>> activeSessions = new Map<Id, List<AuthSession>>();
		for (AuthSession session : (List<AuthSession>) LoginUtils.ActiveSessionQuery?.run()) {
			// Note: Can't easily filter active sessions in SOQL; must calculate manually
			Long currentVal = DateTime.now().getTime();
			Long expiresVal = session?.LastModifiedDate?.addSeconds(session?.NumSecondsValid)?.getTime();
			Long remainingSecs = (expiresVal != null && currentVal != null) ? (expiresVal - currentVal) / 1000 : 0;
			if (remainingSecs > 0) {
				Id userId = session?.UsersId;
				List<AuthSession> matching = (activeSessions?.containsKey(userId))
					? activeSessions.get(userId)
					: new List<AuthSession>();
				matching.add(session);
				activeSessions.put(userId, matching);
			}
		}
		return activeSessions;
	}

	public static List<AuthSession> getActiveSessions(Id userId) {
		return LoginUtils.activeSessions?.get(userId);
	}

	public static List<AuthSession> getActiveSessions(User user) {
		return LoginUtils.getActiveSessions(user?.Id);
	}

	public static Boolean userIsLoggedIn(Id userId) {
		return LoginUtils.activeSessions?.containsKey(userId) == true;
	}

	public static Boolean userIsLoggedIn(User user) {
		return LoginUtils.userIsLoggedIn(user?.Id);
	}
}
