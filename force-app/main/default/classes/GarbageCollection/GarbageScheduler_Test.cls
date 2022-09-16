@IsTest
private class GarbageScheduler_Test {
	@IsTest
	static void shouldLaunchActiveJobs() {
		GarbageScheduler instance = new GarbageScheduler();
		instance.activeJobs = getTestJobs(3);
		Test.startTest();
		instance.execute(null);
		Test.stopTest();

		System.assertEquals(instance.activeJobs?.size(), instance.processedJobs?.size(), 'Wrong # of processed jobs');
		System.assertEquals(0, instance.skippedJobs?.size(), 'Wrong # of skipped jobs');
	}

	@IsTest
	static void shouldNotExceedLimit() {
		GarbageScheduler instance = new GarbageScheduler();
		instance.activeJobs = getTestJobs(3);
		instance.flexQueueSize = GarbageScheduler.FLEX_QUEUE_LIMIT;

		Test.startTest();
		instance.execute(null);
		Test.stopTest();

		System.assertEquals(0, instance.processedJobs?.size(), 'Wrong # of processed jobs');
		System.assertEquals(instance.activeJobs?.size(), instance.skippedJobs?.size(), 'Wrong # of skipped jobs');
	}

	@IsTest
	static void shouldExecuteScheduledJob() {
		final String CRON_EXP = '0 0 * * * ?'; // Once hourly
		Id jobId = System.schedule('Test Job', CRON_EXP, new GarbageScheduler());
		System.assertNotEquals(null, jobId, 'Job was not scheduled');
	}

	private static List<Garbage_Collection_Job__mdt> getTestJobs(Integer numJobs) {
		List<Garbage_Collection_Job__mdt> testJobs = new List<Garbage_Collection_Job__mdt>();
		for (Integer i = 0; i < numJobs; i++) {
			testJobs.add(
				new Garbage_Collection_Job__mdt(
					Batch_Size__c = 200,
					SObjectType__c = 'Account',
					SOQL_Filter__c = 'CreatedDate = null'
				)
			);
		}
		return testJobs;
	}
}
