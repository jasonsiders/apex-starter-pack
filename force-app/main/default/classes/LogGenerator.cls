public without sharing class LogGenerator {
    final List<Log_Event__e> events; 

    public LogGenerator(List<Log_Event__e> events) {
        this.events = events;
    }

    public void generateLogs() {
        // Wrap LogEvents with the same TransactionId, and Map by their TransactionId
        Map<String, LogGroup> logGroups = this.groupLogsByTransactionId(); 
        // Generate & upsert a Log_Transaction__c record for each unique TransactionId
        List<Log_Transaction__c> logTransactions = this.generateLogTransactions(logGroups.values()); 
        DatabaseLayer.DmlEngine.doUpsert(logTransactions, Log_Transaction__c.Transaction_Id__c); 
        // Generate & Insert a Log__c record for each Log Event
        List<Log__c> logRecords = this.generateLogs(logGroups.values());
        DatabaseLayer.DmlEngine.doInsert(logRecords); 
    }

    private Map<String, LogGroup> groupLogsByTransactionId() {
        Map<String, LogGroup> logGroups = new Map<String, LogGroup>();
        for (Log_Event__e event : events) {
            String transactionId = event.Transaction_Id__c; 
            LogGroup logGroup = (logGroups.containsKey(transactionId)) 
                ? logGroups.get(transactionId) : new LogGroup(transactionId);
            logGroup.addEvent(event); 
            logGroups.put(transactionId, logGroup); 
        }
        return logGroups; 
    }

    private List<Log_Transaction__c> generateLogTransactions(List<LogGroup> logGroups) {
        List<Log_Transaction__c> logTransactions = new List<Log_Transaction__c>();
        for (LogGroup logGroup : logGroups) {
            logTransactions.add(logGroup.generateTransactionRecord());
        }
        return logTransactions; 
    }

    private List<Log__c> generateLogs(List<LogGroup> logGroups) {
        List<Log__c> logRecords = new List<Log__c>();
        for (LogGroup logGroup : logGroups) {
            logRecords.addAll(logGroup.generateLogRecords()); 
        }
        return logRecords;
    }

    private class LogGroup {
        final String transactionId; 
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        Log_Transaction__c logTransaction; 
        List<Log__c> logRecords = new List<Log__c>();

        private LogGroup(String transactionId) {
            this.transactionId = transactionId;
        }

        private void addEvent(Log_Event__e event) {
            this.logEvents.add(event); 
        }

        private Log_Transaction__c generateTransactionRecord() {
            this.logTransaction = new Log_Transaction__c(
                OwnerId = this.getRunningUserId(),
                Transaction_Id__c = this.transactionId
            );
            return this.logTransaction; 
        }

        private Id getRunningUserId() {
            return (this.logEvents?.isEmpty() == false) 
                ? this.logEvents[0]?.Running_User__c : UserInfo.getUserId();
        }

        private List<Log__c> generateLogRecords() {
            List<Log__c> logRecords = new List<Log__c>();
            for (Log_Event__e event : this.logEvents) {
                this.logRecords.add(new Log__c(
                    Log_Transaction__c = this.logTransaction.Id,
                    Message__c = event.Message__c,
                    Severity__c = event.Severity__c, 
                    Source__c = event.Source__c,
                    Stack_Trace__c = event.Stack_Trace__c
                ));
            }
            return this.logRecords;
        }
    }
}