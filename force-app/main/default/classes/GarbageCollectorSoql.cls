public without sharing class GarbageCollectorSoql extends GarbageCollector {
    // Note: Because this is the "default" implementation, 
    // I'd normally keep this class in the same file as its parent 
    // However, Salesforce does not allow Database.Batchable to be applied to inner types
    @TestVisible String soql = 'SELECT Id FROM {0} WHERE ({1})';

    public GarbageCollectorSoql(Garbage_Collection_Job__mdt job) {
        this.soql = String.format(soql, new List<String>{
            job.SObjectType__c, 
            job.SOQL_Filter__c
        });
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        try {
            Logger.logAndPublish(LoggingLevel.INFO, 'Executing query: ' + this.soql); 
            return Database.getQueryLocator(soql); 
        } catch (System.QueryException caughtError) {
            Logger.logAndPublish(LoggingLevel.ERROR, caughtError.getMessage()); 
            throw caughtError; 
        }
    }
}