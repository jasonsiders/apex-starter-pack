public abstract class LoginUtils {
    // UserId => List<AuthSession>
    static Map<Id, List<AuthSession>> activeSessions = LoginUtils.getAllActiveSessions();
    @TestVisible static String AUTH_SESSION_QUERY = 'AUTH_SESSION_QUERY';

    public static Map<Id, List<AuthSession>> getAllActiveSessions() {
        if (LoginUtils.activeSessions == null) {
            LoginUtils.activeSessions = new Map<Id, List<AuthSession>>(); 
            Soql query = DatabaseLayer.QueryEngine.newQuery(AuthSession.SObjectType)
                .setQueryKey(AUTH_SESSION_QUERY)
                .selectFields('LoginHistory.Application')
                .selectFields(new List<SObjectField>{
                    AuthSession.UsersId,
                    AuthSession.LastModifiedDate,
                    AuthSession.NumSecondsValid
                }).whereFilters(new Filter(
                    AuthSession.LastModifiedDate,
                    Filter.EQUALS,
                    'LAST_N_DAYS:1'
                )).whereFilters(new Filter(
                    AuthSession.ParentId,
                    Filter.Equals,
                    null
                )).orderBy(new SoqlSort(
                    AuthSession.CreatedDate,
                    SoqlSort.Order.ASCENDING
                ));
            for (AuthSession session : (List<AuthSession>) query.run()) {
                // Note: Can't easily filter active sessions in SOQL; must calculate manually
                Long currentVal = DateTime.now().getTime(); 
                Long expiresVal = session?.LastModifiedDate?.addSeconds(session?.NumSecondsValid)?.getTime();
                Long remainingSecs = (expiresVal - currentVal) / 1000; 
                Boolean isValid = remainingSecs > 0;
                if (isValid) {
                    // TODO: Replace this with CollectionUtils once built
                    Id userId = session?.UsersId; 
                    List<AuthSession> matching = (LoginUtils.activeSessions?.containsKey(userId)) ? 
                        LoginUtils.activeSessions.get(userId) : new List<AuthSession>();
                    matching.add(session); 
                    LoginUtils.activeSessions.put(userId, matching); 
                } 
            }
        }
        return LoginUtils.activeSessions;
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
