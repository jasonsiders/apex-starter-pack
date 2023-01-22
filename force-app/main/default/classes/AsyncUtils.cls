public without sharing abstract class AsyncUtils {
	static final Set<String> PENDING_STATUSES = new Set<String>{ 'Holding', 'Queued', 'Preparing', 'Processing' };

	public static List<AsyncApexJob> getPendingJobs(Type jobType, Id currentJobId) {
		// Note: ApexClass.Name will always display the **outer** Apex class in localized format
		// This means that inner types (like MyClass.Wrapper.class) will not be listed in this field.
		// Batchable/Queueable/Schedulable types probably should be kept in their own file anyways...
		return [
			SELECT Id, CronTriggerId, CronTrigger.CronExpression, CronTrigger.CronJobDetail.Name, Status
			FROM AsyncApexJob
			WHERE
				ApexClass.Name = :TypeUtils.getLocalName(jobType)
				AND Id != :currentJobId
				AND Status IN :PENDING_STATUSES
			ORDER BY CreatedDate ASC
		];
	}
}
