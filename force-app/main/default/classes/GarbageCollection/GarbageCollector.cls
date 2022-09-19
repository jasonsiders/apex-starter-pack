public abstract inherited sharing class GarbageCollector implements Database.Batchable<SObject>, GarbageCollector.IGarbageCollector {
	public Id jobId { get; private set; }
	public Integer batchSize { get; private set; }

	@TestVisible
	static Soql InterfaceQuery = Databaselayer.Soql.newQuery(ApexTypeImplementor.SObjectType)
		.selectFields(ApexTypeImplementor.ClassName)
		.whereCriteria(
			new Filter(
				ApexTypeImplementor.InterfaceName,
				Filter.EQUALS,
				String.valueOf(GarbageCollector.IGarbageCollector.class)
			)
		)
		.whereCriteria(new Filter(ApexTypeImplementor.IsConcrete, Filter.EQUALS, true));

	static Set<String> ValidApexClasses {
		get {
			ValidApexClasses = (ValidApexClasses != null) ? ValidApexClasses : GarbageCollector.getExtendingTypes();
			return ValidApexClasses;
		}
		private set;
	}

	// **** INTERFACE **** //
	public GarbageCollector runBatch() {
		this.jobId = Database.executeBatch(this, this.batchSize);
		return this;
	}

	public GarbageCollector setBatchSize(Decimal batchSize) {
		this.batchSize = Integer.valueOf(batchSize);
		return this;
	}

	public GarbageCollector toConcreteType() {
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
	public static GarbageCollector getInstance(Garbage_Collection_Job__mdt job) {
		IGarbageCollector instance = GarbageCollector.parseJobMetadata(job);
		return instance?.toConcreteType().setBatchSize(job.Batch_Size__c);
	}

	private static IGarbageCollector parseJobMetadata(Garbage_Collection_Job__mdt job) {
		if (!String.isBlank(job.SOQL_Filter__c)) {
			return new GarbageCollectorSoql(job);
		} else if (ValidApexClasses.contains(job?.Apex_Class_Name__c)) {
			// If the name is contained in the list of implementing types, it can be safely cast
			return (IGarbageCollector) Type.forName(job?.Apex_Class_Name__c).newInstance();
		} else {
			throw new InvalidCriteriaException(job);
		}
	}

	private static Set<String> getExtendingTypes() {
		return (Set<String>) CollectionUtils.extractValues(
			GarbageCollector.InterfaceQuery?.run(),
			String.valueOf(ApexTypeImplementor.ClassName),
			Set<String>.class
		);
	}

	// **** INNER **** //
	public class InvalidCriteriaException extends Exception {
		final String template =
			'Invalid Garbage Collection Job criteria. ' +
			'Either a SOQL Filter, or the name of an Apex Class ' +
			'that implements IGarbageCollector must be provided.\n' +
			'Valid Apex Classes: {0}\n' +
			'Garbage Collection Job: {1}';

		private InvalidCriteriaException(Garbage_Collection_Job__mdt job) {
			this.setMessage(
				String.format(
					this.template,
					new List<String>{ JSON.serializePretty(ValidApexClasses), JSON.serializePretty(job) }
				)
			);
			Logger.error(GarbageCollector.class, this.getMessage());
			Logger.publish();
		}
	}

	public interface IGarbageCollector {
		// Note: Apex provides the ApexTypeImplementor object to query types which implement an interface
		// This functionality doesn't currently exist for abstract or virtual types
		// GarbageCollector implements this inner interface to indirectly find types that extend it
		// Unfortunately, the interface must be public to be visible in ApexTypeImplementor queries
		// but you should never directly implement this interface elsewhere;
		// Instead, extend the GarbageCollector class
		GarbageCollector toConcreteType();
		GarbageCollector runBatch();
		GarbageCollector setBatchSize(Decimal batchSize);
	}
}
