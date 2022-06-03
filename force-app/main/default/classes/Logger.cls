@RestResource(urlMapping='/log/*')
global without sharing class Logger {
    @TestVisible static final Integer maxPublishCalls = Logger.getMaxPublishCalls();  
    @TestVisible static List<Log_Event__e> pendingEvents = new List<Log_Event__e>();  
    @TestVisible static Log_Setting__c settings = Log_Setting__c.getInstance(UserInfo.getUserId());
    @TestVisible static LoggingLevel threshold { get { 
        return (LoggingLevel) EnumUtils.valueOf(
            Logger.settings?.Level__c, 
            LoggingLevel.class
        );
    }}
    
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

    @HttpPost
    global static void logFromApi(List<Input> inputs) {
        // Only one method per type can be defined with: HttpPost, 
        // so callers must supply an array of Inputs
        Logger.logFromExternalSource(inputs);
    }
    
    @AuraEnabled
    public static void logFromLightning(List<Input> inputs) {
        Logger.logFromExternalSource(inputs); 
    }

    @AuraEnabled 
    public static void logFromLightning(Input input) {
        Logger.logFromLightning(new List<Input>{input});
    }

    @InvocableMethod(label='Post to Log')
    public static void logFromFlow(List<Input> inputs) {
        Logger.logFromExternalSource(inputs); 
    }

    public static void log(LoggingLevel level, String message) {
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

    public static void log(String message) {
        // This will default the logging level to the current threshold
        Logger.log(threshold, message); 
    }

    public static void logAndPublish(LoggingLevel level, String message) {
        Logger.log(level, message); 
        Logger.publish(); 
    }

    public static void logAndPublish(String message) {
        Logger.logAndPublish(threshold, message); 
    }

    public static void publish() {
        Integer currentPublishCalls = Limits.getPublishImmediateDml();
        if (currentPublishCalls < Logger.maxPublishCalls) {
            DatabaseLayer.DmlEngine.doPublish(Logger.pendingEvents); 
            Logger.pendingEvents.clear(); 
        }
    }

    public static void logException(Exception error) {
        String message = error?.getTypeName() + ': ' + error?.getMessage() + '\n' + error?.getStackTraceString();
        Logger.logAndPublish(LoggingLevel.ERROR, message);
    }

    public static void clear() {
        Logger.pendingEvents?.clear(); 
    }

    // **** PRIVATE **** //
    static void logFromExternalSource(List<Input> inputs) {
        // Private, because all apex code should call the log() method directly
        // External sources (API, Flow, LWC) should call their respective logFrom*() method
        for (Input input : inputs) {
            Logger.log(input.getLevel(), input.message);
        }
        Logger.publish();
    }

    static Integer getMaxPublishCalls() {
        Integer publishCalls = Integer.valueOf(Log_Setting__c.getOrgDefaults().Max_Publish_Calls__c);
        return (publishCalls != null) ? publishCalls : 100;
    }

    static Boolean clearsSeverityThreshold(LoggingLevel current) {
        // Returns true if the threshold != 'NONE',
        // and the current level has a lower severity number
        Integer thresholdSeverity = getSeverity(Logger.threshold); 
        Integer currentSeverity = getSeverity(current); 
        return 
            thresholdSeverity > 0 && 
            currentSeverity > 0 && 
            currentSeverity <= thresholdSeverity;
    }

    static Integer getSeverity(LoggingLevel logLevel) {
        Integer severity = Logger.SEVERITY_MATRIX.get(logLevel); 
        return (severity != null) ? severity : 0; 
    }

    static String getStackTrace() {
        // Generate an exception, grab its stack trace, and erase the elements that come from this class 
        return new LogException().sourceStackTrace(); 
    }

    // **** INNER **** //
    global class Input {
        @InvocableVariable 
        global String loggingLevel; 

        @InvocableVariable 
        global String message; 

        global LoggingLevel getLevel() {
            return (LoggingLevel) EnumUtils.valueOf(this.loggingLevel, LoggingLevel.class);
        }
    }
    
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