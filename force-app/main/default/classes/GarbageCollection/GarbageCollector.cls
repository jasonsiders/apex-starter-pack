public abstract inherited sharing class GarbageCollector implements Database.Batchable<SObject> {
	public Id jobId { get; private set; }
	public Integer batchSize { get; private set; }

	// **** INTERFACE **** //
	public GarbageCollector runBatch() {
		this.jobId = Database.executeBatch(this, this.batchSize);
		return this;
	}

	public GarbageCollector setBatchSize(Decimal batchSize) {
		this.batchSize = Integer.valueOf(batchSize);
		return this;
	}

	// **** BATCHABLE **** //
	public virtual void execute(Database.BatchableContext context, List<SObject> scope) {
		try {
			List<DmlResult> results = DatabaseLayer.Dml.doDelete(scope, false);
			DmlResult.logErrors(results);
		} catch (Exception caughtError) {
			final String template = 'Unexpected error (Job: {0})\n{1}';
			final String message = String.format(template, new List<String>{
				context?.getJobId(), 
				String.valueOf(caughtError)
			});
			Logger.error(GarbageCollector.class, message);
			Logger.publish();
			throw caughtError;
		}
	}

	public virtual void finish(Database.BatchableContext context) {
		Soql query = Databaselayer.Soql.newQuery(AsyncApexJob.SObjectType)
			.selectFields(AsyncApexJob.JobItemsProcessed)
			.selectFields(AsyncApexJob.TotalJobItems)
			.whereCriteria(new Filter(
				AsyncApexJob.Id, 
				Filter.EQUALS, 
				context.getJobId()
			));
		List<AsyncApexJob> jobDetails = (List<AsyncApexJob>) query.run();
		AsyncApexJob currentJob = (AsyncApexJob) CollectionUtils.getIndexOf(jobDetails, 0);
		Integer numCompletedBatches = currentJob?.JobItemsProcessed;
		Integer numTotalBatches = currentJob?.TotalJobItems;
		final String template = 'GarbageCollector job {0} completed. {1}/{2} successful batches';
		final String message = String.format(
			template,
			new List<String>{ context.getJobId(), String.valueOf(numCompletedBatches), String.valueOf(numTotalBatches) }
		);
		Logger.info(GarbageCollector.class, message);
		Logger.publish();
	}

	// **** STATIC **** //
	public static GarbageCollector createFromMetadata(Garbage_Collection_Job__mdt job) {
		GarbageCollector instance = GarbageCollector.parseMetadata(job); 
		if (instance == null) {
			throw new MetadataException('A valid GarbageCollector class or SOQL Query must be provided.');
		}
		return instance?.setBatchSize(job.Batch_Size__c);
	}

	private static GarbageCollector parseMetadata(Garbage_Collection_Job__mdt job) {
		GarbageCollector instance;
		if (String.isNotBlank(job?.Apex_Class_Name__c)) {
			instance = (GarbageCollector) Type.forName(job?.Apex_Class_Name__c)?.newInstance();
		} else if (String.isNotBlank(job?.SOQL_Filter__c)) {
			instance = new GarbageCollectorSoql(job);
		} 
		return instance; 
	}

	// **** INNER **** //
	public class MetadataException extends Exception {}
}
