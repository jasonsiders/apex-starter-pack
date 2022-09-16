public without sharing class GarbageCollectorSoql extends GarbageCollector {
	// Note: Because this is the "default" implementation,
	// I'd normally keep this class in the same file as its parent
	// However, Salesforce does not allow Database.Batchable to be applied to inner types
	@TestVisible
	String soql = 'SELECT Id FROM {0} WHERE ({1})';

	public GarbageCollectorSoql(Garbage_Collection_Job__mdt job) {
		String query = String.format(this.soql, new List<String>{ job?.SObjectType__c, job?.SOQL_Filter__c });
		this.soql = String.escapeSingleQuotes(query); 
	}

	public Database.QueryLocator start(Database.BatchableContext context) {
		try {
			return Database.getQueryLocator(soql);
		} catch (System.QueryException queryError) {
			String message = queryError + '\nQuery:\n' + this.soql; 
			Logger.error(message); 
			Logger.publish();
			throw queryError;
		}
	}
}
