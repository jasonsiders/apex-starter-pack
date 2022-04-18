global without sharing class Logger {
    @TestVisible static Log_Setting__c settings;
    @TestVisible static LoggingLevel threshold;
    @TestVisible static Integer maxPublishCalls; 
    @TestVisible static List<Log_Event__e> pendingEvents = new List<Log_Event__e>();  
    @TestVisible static PlatformEventDml dmlEngine = new PlatformEventDml();
    
    // Indicates how severe something is. A log will only be published
    // if a log's logging level < the current user's "Level" threshold
    // LoggingLevel enum : https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_LoggingLevel.htm
    static final Map<LoggingLevel, Integer> SEVERITY_MATRIX = new Map<LoggingLevel, Integer>{
        LoggingLevel.NONE => 0,
        LoggingLevel.ERROR => 1, 
        LoggingLevel.WARN => 2,
        LoggingLevel.INFO => 3,
        LoggingLevel.DEBUG => 4,
        LoggingLevel.FINE => 5,
        LoggingLevel.FINER => 6,
        LoggingLevel.FINEST => 7
    };

    static {
        maxPublishCalls = Integer.valueOf(Log_Setting__c.getOrgDefaults().Max_Publish_Calls__c);
        maxPublishCalls = (maxPublishCalls != null) ? maxPublishCalls : 100; 
        settings = Log_Setting__c.getInstance(UserInfo.getUserId());
        threshold = loggingLevelValueOf(settings?.Level__c);
    }

    // **** PUBLIC **** //
    global static void log(LoggingLevel level, String message) {
        System.debug(level, message); 
        if (settings?.Enabled__c == true && clearsSeverityThreshold(level)) {
            Request context = Request.getCurrent(); 
            pendingEvents.add(new Log_Event__e(
                Message__c = message,
                Running_User__c = UserInfo.getUserId(),
                Severity__c = String.valueOf(level),
                Source__c = String.valueOf(context.getQuiddity()),
                Stack_Trace__c = getStackTrace(),
                Transaction_Id__c = context.getRequestId()           
            ));
        }
    }

    global static void log(String message) {
        // This will default the logging level to the current threshold
        log(threshold, message); 
    }

    global static void logAndPublish(LoggingLevel level, String message) {
        log(level, message); 
        publish(); 
    }

    global static void logAndPublish(String message) {
        logAndPublish(threshold, message); 
    }

    global static void publish() {
        Integer currentPublishCalls = Limits.getPublishImmediateDml();
        if (currentPublishCalls < maxPublishCalls) {
            dmlEngine.publish(pendingEvents); 
            pendingEvents.clear(); 
        }
    }

    global static void clear() {
        pendingEvents?.clear(); 
    }

    // **** PRIVATE **** //
    static Boolean clearsSeverityThreshold(LoggingLevel current) {
        // Returns true if the threshold != 'NONE',
        // and the current level has a lower severity number
        Integer thresholdSeverity = getSeverity(threshold); 
        Integer currentSeverity = getSeverity(current); 
        return 
            thresholdSeverity > 0 && 
            currentSeverity > 0 && 
            currentSeverity <= thresholdSeverity;
    }

    @TestVisible
    static LoggingLevel loggingLevelValueOf(String logLevel) {
        // Retrieve a LoggingLevel enum from a string value
        // Enum.valueOf() is supposed to do this,
        // but it will throw an exception if a null value 
        // or string that does not match an enum value is supplied
        LoggingLevel result; 
        try {
            result = LoggingLevel.valueOf(settings?.Level__c); 
        } catch (System.NoSuchElementException error) {
            result = LoggingLevel.NONE; 
        }
        return result; 
    }

    static Integer getSeverity(LoggingLevel logLevel) {
        Integer severity = SEVERITY_MATRIX.get(logLevel); 
        return (severity != null) ? severity : 0; 
    }

    static String getStackTrace() {
        // Generate an exception, grab its stack trace, and erase the elements that come from this class 
        return new LogException().sourceStackTrace(); 
    }

    // **** INNER **** //
    private class LogException extends Exception {
        private String sourceStackTrace() {
            List<String> stackTraceLines = new List<String>();
            for (String stackTraceLine : this.getStackTraceString().split('\n')) {
                // Do not include this class in the stack trace info
                if (!stackTraceLine?.startsWithIgnoreCase('Class.Logger.')) {
                    stackTraceLines.add(stackTraceLine); 
                }
            }
            return String.join(stackTraceLines, '\n');
        }
    }
}