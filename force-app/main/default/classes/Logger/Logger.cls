@RestResource(urlMapping='/log')
global without sharing abstract class Logger {
	static final Integer MAX_LENGTH = Log__c.Message__c.getDescribe()?.getLength();
	static Integer Sequence = 1;

	@TestVisible
	static List<Log_Event__e> PendingLogs = new List<Log_Event__e>();

	@TestVisible
	static List<Log_Event__e> PublishedLogs = new List<Log_Event__e>();

	@TestVisible
	static Log_Setting__c Settings = Logger.getLogSettings();

	@TestVisible
	static LoggingLevel Threshold {
		get {
			Boolean matchesSettings = Logger.Threshold?.name()?.equalsIgnoreCase(Logger.Settings?.Level__c);
			if (matchesSettings != true) {
				LoggingLevel newLevel = (LoggingLevel) EnumUtils.valueOf(Settings?.Level__c, LoggingLevel.class);
				Logger.Threshold = (newLevel != null) ? newLevel : LoggingLevel.NONE;
			}
			return Logger.Threshold;
		}
		private set;
	}

	// **** GLOBAL **** //
	@HttpPost
	global static void logFromApi() {
		// Exposes the logger to external solutions
		try {
			String requestBody = RestContext.request?.requestBody?.toString();
			List<LogInput> logInputs = (List<LogInput>) JSON.deserialize(requestBody, List<LogInput>.class);
			Logger.logFromExternalSource(logInputs);
			RestContext.response.statusCode = 200;
		} catch (Exception error) {
			RestContext.response.statusCode = 500;
			RestContext.response.responseBody = Blob.valueOf(
				JSON.serialize(new Map<String, String>{
					 'message' => String.valueOf(error) 
				})
			);
		}
	}

	@InvocableMethod(category='Logging' configurationEditor='c-cpe-logger' label='Post to Log')
	global static void logFromFlow(List<LogInput> logInputs) {
		// Exposes the logger to Flows
		Logger.logFromExternalSource(logInputs);
	}

	@AuraEnabled
	global static void logFromLightning(List<LogInput> logInputs) {
		// Exposes the logger to Aura Components & LWCs
		Logger.logFromExternalSource(logInputs);
	}

	// **** PUBLIC **** //
	public static void publish() {
		Logger.PublishedLogs.addAll(Logger.PendingLogs);
		DatabaseLayer.Dml.doPublish(Logger.PendingLogs);
		Logger.PendingLogs.clear();
	}

	public static void log(LoggingLevel level, Type apexClass, Object messageObj) {
		// Note: Since Exception.getStackTraceString() returns null in managed packages,
		// callers can use the optional `apexClass` param for rudimentary stack tracing
		if (Logger.isEnabled(level)) {
			System.debug(level, messageObj);
			Logger.PendingLogs.add(
				new Log_Event__e(
					Apex_Class__c = String.valueOf(apexClass),
					Context__c = System.Request.getCurrent().getQuiddity()?.name(),
					Level__c = level?.name(),
					Logged_At__c = DateTime.now(),
					Message__c = String.valueOf(messageObj)?.abbreviate(MAX_LENGTH),
					Running_User__c = UserInfo.getUserId(),
					Sequence__c = Logger.Sequence++,
					Stack_Trace__c = Logger.getStackTrace()?.abbreviate(MAX_LENGTH),
					Transaction_Id__c = System.Request.getCurrent()?.getRequestId()
				)
			);
		}
	}

	public static void log(LoggingLevel level, Object message) {
		Logger.log(level, null, message);
	}

	public static void log(Object message) {
		// Defaults to FINEST
		Logger.finest(message);
	}

	public static void error(Type apexClass, Object message) {
		Logger.log(LoggingLevel.ERROR, apexClass, message);
	}

	public static void error(Object message) {
		Logger.error(null, message);
	}

	public static void warn(Type apexClass, Object message) {
		Logger.log(LoggingLevel.WARN, apexClass, message);
	}

	public static void info(Type apexClass, Object message) {
		Logger.log(LoggingLevel.INFO, apexClass, message);
	}

	public static void info(Object message) {
		Logger.info(null, message);
	}

	public static void warn(Object message) {
		Logger.warn(null, message);
	}

	public static void debug(Type apexClass, Object message) {
		Logger.log(LoggingLevel.DEBUG, apexClass, message);
	}

	public static void debug(Object message) {
		Logger.debug(null, message);
	}

	public static void fine(Type apexClass, Object message) {
		Logger.log(LoggingLevel.FINE, apexClass, message);
	}

	public static void fine(Object message) {
		Logger.fine(null, message);
	}

	public static void finer(Type apexClass, Object message) {
		Logger.log(LoggingLevel.FINER, apexClass, message);
	}

	public static void finer(Object message) {
		Logger.finer(null, message);
	}

	public static void finest(Type apexClass, Object message) {
		Logger.log(LoggingLevel.FINEST, apexClass, message);
	}

	public static void finest(Object message) {
		Logger.finest(null, message);
	}

	// **** PRIVATE **** //
	@TestVisible
	static Log_Setting__c getLogSettings() {
		// Returns a Custom Setting record that corresponds to the running user/their profile/their organization
		Log_Setting__c logSettings = Log_Setting__c.getInstance();
		LoggingLevel level = (LoggingLevel) EnumUtils.valueOf(logSettings?.Level__c, LoggingLevel.class);
		if (level == null) {
			// Either no org defaults exist, or it has a missing/invalid Level__c
			// If this happens, upsert a valid settings record and set as org default
			Log_Setting__c defaultSettings = Log_Setting__c.getOrgDefaults();
			defaultSettings.Enabled__c = (defaultSettings.Enabled__c) ? defaultSettings.Enabled__c : false;
			defaultSettings.Level__c = LoggingLevel.NONE?.name();
			defaultSettings.SetupOwnerId = UserInfo.getOrganizationId();
			upsert defaultSettings;
			logSettings = defaultSettings;
		}
		return logSettings;
	}

	static void logFromExternalSource(List<LogInput> logInputs) {
		for (LogInput logInput : logInputs) {
			logInput.log();
		}
		Logger.publish();
	}

	static Boolean isEnabled(LoggingLevel currentLevel) {
		// Returns TRUE if logging is enabled, and the current level is
		// as/more severe than the minimum threshold specified in Custom Settings.
		// This is done to mimick the way traditional debug logs are set up in Salesforce.
		// Severity is indicated by the LoggingLevel enum's ordinal(), in order:
		// NONE(0), INTERNAL(1), FINEST(2), FINER(3), FINE(4), DEBUG(5), INFO(6), WARN(7), ERROR(8)
		Integer thresholdSeverity = (Logger.Threshold != null) ? Logger.Threshold?.ordinal() : 0;
		Integer currentSeverity = (currentLevel != null) ? currentLevel?.ordinal() : 0;
		Boolean results =
			Logger.Settings?.Enabled__c == true &&
			thresholdSeverity > 0 && // Prevent logging when Logger.Threshold == NONE
			currentSeverity >= thresholdSeverity;
		return results;
	}

	static String getStackTrace() {
		return new LogException().sourceStackTrace();
	}

	// **** INNER **** //
	global class LogInput {
		@InvocableVariable
		global String logLevelName;

		@InvocableVariable
		global String logMessage;

		public void log() {
			LoggingLevel level = (LoggingLevel) EnumUtils.valueOf(logLevelName, LoggingLevel.class);
			if (level != null) {
				Logger.log(level, logMessage);
			}
		}
	}

	private class LogException extends Exception {
		private String sourceStackTrace() {
			List<String> stackTraceLines = new List<String>();
			for (String stackTraceLine : this.getStackTraceString().split('\n')) {
				// Do not include this class in the stack trace info
				final String loggerPrefix = 'Class.' + String.valueOf(Logger.class) + '.';
				if (!stackTraceLine?.startsWith(loggerPrefix)) {
					stackTraceLines.add(stackTraceLine);
				}
			}
			return String.join(stackTraceLines, '\n');
		}
	}
}
