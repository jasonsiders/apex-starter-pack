@IsTest
private class Logger_Test {
	@IsTest
	static void shouldSetCorrectValues() {
		Logger.Settings = getActiveSettings(LoggingLevel.DEBUG);

		Logger.debug(Logger_Test.class, 'This is a test!');

		System.assertEquals(1, Logger.PendingLogs?.size(), 'Wrong # of Pending Logs');
		Log_Event__e logEvent = Logger.PendingLogs[0];
		System.assertEquals(String.valueOf(Logger_Test.class), logEvent?.Apex_Class__c, 'Wrong Apex Class');
		System.assertEquals(System.Request.getCurrent().getQuiddity().name(), logEvent?.Context__c, 'Wrong Context');
		System.assertEquals(LoggingLevel.DEBUG.name(), logEvent?.Level__c, 'Wrong Level');
		System.assertNotEquals(null, logEvent?.Logged_At__c, 'Wrong Logged At');
		System.assertEquals(UserInfo.getUserId(), logEvent?.Running_User__c, 'Wrong Running_User__c');
		System.assertequals(1, logEvent?.Sequence__c, 'Wrong Sequence__c');
		System.assertNotEquals(null, logEvent?.Stack_Trace__c, 'Wrong Stack_Trace__c');
		System.assertEquals(
			System.Request.getCurrent().getRequestId(),
			logEvent?.Transaction_Id__c,
			'Wrong Transaction_Id__c'
		);
	}

	@IsTest
	static void shouldLogIfThresholdIsMet() {
		Logger.Settings = getActiveSettings(LoggingLevel.DEBUG);

		// All Logging Levels above the current threshold (or NONE) should not log
		for (
			LoggingLevel level : new List<LoggingLevel>{
				LoggingLevel.FINEST,
				LoggingLevel.FINER,
				LoggingLevel.FINE,
				LoggingLevel.NONE
			}
		) {
			Logger.log(level, 'This should not log');
			System.assertEquals(
				0,
				Logger.PendingLogs?.size(),
				level +
				' log posted outside of its defined threshold: ' +
				Logger.Threshold
			);
		}

		// All Logging Levels at or below the current threshold should log
		for (
			LoggingLevel level : new List<LoggingLevel>{
				LoggingLevel.DEBUG,
				LoggingLevel.INFO,
				LoggingLevel.WARN,
				LoggingLevel.ERROR
			}
		) {
			Logger.log(level, 'This should log');
		}
		System.assertEquals(
			4,
			Logger.PendingLogs?.size(),
			'Wrong # of pending logs: ' + JSON.serializePretty(Logger.PendingLogs)
		);
	}

	@IsTest
	static void shouldLogFromApi() {
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		Logger.LogInput input = new Logger.LogInput();
		input.logLevelName = LoggingLevel.FINEST.name();
		input.logMessage = 'Hello world!';
		List<Logger.LogInput> inputs = new List<Logger.LogInput>{ input };
		RestRequest request = new RestRequest();
		request.requestBody = Blob.valueOf(JSON.serialize(inputs));
		RestContext.request = request;

		Test.startTest();
		Logger.logFromApi();
		Test.stopTest();

		System.assertEquals(1, Logger.PublishedLogs?.size(), 'Wrong # of pending logs');
		System.assertEquals(input.logMessage, Logger.PublishedLogs[0].Message__c, 'Wrong message');
	}

	@IsTest
	static void shouldLogFromFlow() {
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		Logger.LogInput input = new Logger.LogInput();
		input.logLevelName = LoggingLevel.FINEST.name();
		input.logMessage = 'Hello world!';

		Test.startTest();
		Logger.logFromFlow(new List<Logger.LogInput>{ input });
		Test.stopTest();

		System.assertEquals(1, Logger.PublishedLogs?.size(), 'Wrong # of pending logs');
		System.assertEquals(input.logMessage, Logger.PublishedLogs[0].Message__c, 'Wrong message');
	}

	@IsTest
	static void shouldLogFromLightning() {
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		Logger.LogInput input = new Logger.LogInput();
		input.logLevelName = LoggingLevel.FINEST.name();
		input.logMessage = 'Hello world!';

		Test.startTest();
		Logger.logFromLightning(new List<Logger.LogInput>{ input });
		Test.stopTest();

		System.assertEquals(1, Logger.PublishedLogs?.size(), 'Wrong # of pending logs');
		System.assertEquals(input.logMessage, Logger.PublishedLogs[0].Message__c, 'Wrong message');
	}

	@IsTest
	static void shouldLogFromLevelSpecificMethod() {
		// Callers can use the level-specific overrides below for brevity
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		LoggingLevel currentLevel;
		Integer size = 0;

		Logger.error('Test Message');
		currentLevel = LoggingLevel.ERROR;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');

		Logger.warn('Test Message');
		currentLevel = LoggingLevel.WARN;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');

		Logger.info('Test Message');
		currentLevel = LoggingLevel.INFO;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');

		Logger.debug('Test Message');
		currentLevel = LoggingLevel.DEBUG;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');

		Logger.fine('Test Message');
		currentLevel = LoggingLevel.FINE;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');

		Logger.finer('Test Message');
		currentLevel = LoggingLevel.FINER;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');

		Logger.finest('Test Message');
		currentLevel = LoggingLevel.FINEST;
		size++;
		System.assertEquals(size, Logger.PendingLogs?.size(), currentLevel + ' not logged');
		System.assertEquals(String.valueOf(currentLevel), Logger.PendingLogs[size - 1].Level__c, 'Wrong Level');
	}

	@IsTest
	static void shouldIncludeApexClass() {
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		Type apexClass = Logger_Test.class;

		Test.startTest();
		Logger.error(apexClass, 'This is a test');
		Logger.warn(apexClass, 'This is a test');
		Logger.info(apexClass, 'This is a test');
		Logger.debug(apexClass, 'This is a test');
		Logger.fine(apexClass, 'This is a test');
		Logger.finer(apexClass, 'This is a test');
		Logger.finest(apexClass, 'This is a test');
		Test.stopTest();

		System.assertEquals(false, Logger.PendingLogs?.isEmpty(), 'No logs were generated');
		for (Log_Event__e log : Logger.PendingLogs) {
			System.assertEquals(String.valueOf(apexClass), log.Apex_Class__c, 'Wrong Apex Class value');
		}
	}

	@IsTest
	static void shouldNotLogInNewOrg() {
		// In a new org, without an org default Log_Setting__c,
		// Logger.Settings will be an empty object (no Level__c specified)
		// Calls to Logger.log() should not fail, but they won't log either
		Logger.Settings = new Log_Setting__c();
		Test.startTest();
		try {
			Logger.info('Testing 1234');
		} catch (Exception caughtError) {
			System.assert(false, 'An error was thrown: ' + caughtError);
		}
		Test.stopTest();

		System.assertEquals(0, Logger.PendingLogs?.size(), 'Log was generated with empty settings');
	}

	@IsTest
	static void shouldNotLogIfDisabled() {
		Logger.Settings = new Log_Setting__c(Enabled__c = false, Level__c = LoggingLevel.INFO.name());

		Test.startTest();
		for (LoggingLevel level : LoggingLevel.values()) {
			Logger.log(level, 'Logging for ' + level.name());
		}
		Test.stopTest();

		System.assertEquals(
			0,
			Logger.PendingLogs?.size(),
			'Log(s) were generated when Enabled set to false: ' + JSON.serializePretty(Logger.PendingLogs)
		);
	}

	@IsTest
	static void shouldLogAllIfThresholdIsFinest() {
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);

		Test.startTest();
		for (LoggingLevel level : LoggingLevel.values()) {
			Logger.log(level, 'Logging for ' + level.name());
		}
		Test.stopTest();

		// All except NONE and INTERNAL should generate a Log
		System.assertEquals(
			getValidLevels()?.size(),
			Logger.PendingLogs?.size(),
			'Wrong # of PendingLogs for FINEST: ' + JSON.serializePretty(Logger.PendingLogs)
		);
	}

	@IsTest
	static void shouldNotLogIfThresholdIsNone() {
		Logger.Settings = getActiveSettings(LoggingLevel.NONE);

		Test.startTest();
		for (LoggingLevel level : LoggingLevel.values()) {
			Logger.log(level, 'Logging for ' + level.name());
		}
		Test.stopTest();

		System.assertEquals(
			0,
			Logger.PendingLogs?.size(),
			'Log(s) were generated with a null LoggingLevel: ' + JSON.serializePretty(Logger.PendingLogs)
		);
	}

	@IsTest
	static void shouldNotLogIfNullLoggingLevel() {
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);

		Test.startTest();
		Logger.log(null, 'Hello world');
		Test.stopTest();

		System.assertEquals(0, Logger.PendingLogs?.size(), 'Log(s) were generated with a null LoggingLevel');
	}

	@IsTest
	static void shouldIncrementSequence() {
		// The Sequence__c field helps us to piece together a timeline;
		// It shows the order that log statements were generated in its Transaction_Id__c
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		for (Integer i = 0; i < 100; i++) {
			Integer logNumber = (i + 1);
			Logger.info('Test Message #' + logNumber);
			System.assertEquals(logNumber, Logger.PendingLogs?.size(), 'Wrong # of pending logs');
			System.assertEquals(logNumber, Logger.PendingLogs[i]?.Sequence__c, 'Wrong Sequence');
		}
	}

	@IsTest
	static void shouldExcludeSelfFromStackTrace() {
		// The Log Event's stack trace field should start from
		// where the Logger class is called from - not the Logger class itself
		Logger.Settings = getActiveSettings(LoggingLevel.FINEST);
		DmlMock dmlMock = (DmlMock) DatabaseLayer.setDmlEngine(new DmlMock());
		// Try logging from directly in the test class
		Logger.finest('Test Message');
		System.assertEquals(1, Logger.PendingLogs?.size(), 'Did not log');
		Log_Event__e event = Logger.PendingLogs[0];
		System.assert(
			event.Stack_Trace__c?.startsWithIgnoreCase('Class.Logger_Test.'),
			'Expected Stack Trace to start with "Class.Logger_Test." - Actual: "' +
			event.Stack_Trace__c +
			'"'
		);
		System.assert(
			event.Stack_Trace__c?.contains('Class.Logger.') == false,
			'Contains a stack trace line from the logger class: ' + event.Stack_Trace__c
		);
		// Try logging from another class
		new MyClass().logSomething();
		System.assertEquals(2, Logger.PendingLogs?.size(), 'Did not log from child class');
		event = Logger.PendingLogs[1];
		System.assert(
			event.Stack_Trace__c?.startsWithIgnoreCase('Class.Logger_Test.MyClass.'),
			'Expected Stack Trace to start with "Class.Logger_Test.MyClass." - Actual: "' +
			event.Stack_Trace__c +
			'"'
		);
		System.assert(
			event.Stack_Trace__c?.contains('Class.Logger.') == false,
			'Contains a stack trace line from the logger class: ' + event.Stack_Trace__c
		);
	}

	@IsTest
	static void shouldGenerateOrgDefaultSettingsIfNone() {
		// In a new org, no Custom Settings records exist by default. The Logger should still be able to operate
		// In this scenario, will create an inactive Settings record and set as Org Default
		delete [SELECT Id FROM Log_Setting__c]; // Just in case
		System.assertEquals(null, Log_Setting__c.getOrgDefaults()?.Id, 'Org Default settings still exists');
		Logger.info('Something'); // Any reference to the Logger class should do the trick
		Log_Setting__c defaults = Log_Setting__c.getOrgDefaults();
		System.assertNotEquals(null, defaults?.Id, 'Org Default settings still do not exist');
		System.assertEquals(LoggingLevel.NONE.name(), defaults?.Level__c, 'Wrong default level');
		System.assertEquals(false, defaults?.Enabled__c, 'Not inactive by default');
	}

	@IsTest
	static void shouldUpdateOrgDefaultSettingsIfInvalidLevel() {
		Log_Setting__c defaults = new Log_Setting__c(
			Level__c = 'lajsdflkjasdfljkasdfkljasdf',
			SetupOwnerId = UserInfo.getOrganizationId()
		);
		insert defaults;
		Logger.info('Something');
		defaults = Log_Setting__c.getOrgDefaults();
		System.assertEquals(LoggingLevel.NONE.name(), defaults?.Level__c, 'Wrong default level');
	}

	// **** HELPER **** //
	static Log_Setting__c getActiveSettings(LoggingLevel level) {
		return new Log_Setting__c(Enabled__c = true, Level__c = level?.name());
	}

	static Set<LoggingLevel> getValidLevels() {
		// INTERNAL and NONE logs are never published
		Set<LoggingLevel> validLevels = new Set<LoggingLevel>(LoggingLevel.values());
		validLevels.remove(LoggingLevel.NONE);
		validLevels.remove(LoggingLevel.INTERNAL);
		return validLevels;
	}

	// **** INNER **** //
	private class MyClass {
		private void logSomething() {
			Logger.log(LoggingLevel.FINEST, 'Test Message');
		}
	}
}
