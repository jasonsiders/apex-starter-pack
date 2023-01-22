@IsTest
private class AsyncUtils_Test implements System.Queueable {
	@IsTest
	static void shouldReturnAllPendingJobs() {
		System.enqueueJob(new AsyncUtils_Test());
		List<AsyncApexJob> pending = AsyncUtils.getPendingJobs(AsyncUtils_Test.class, null);
		System.assertEquals(1, pending?.size(), 'Wrong # of pending jobs');
	}

	@IsTest
	static void shouldExcludeCurrentJobId() {
		Id currentJobId = System.enqueueJob(new AsyncUtils_Test());
		Id duplicateJobId = System.enqueueJob(new AsyncUtils_Test());
		List<AsyncApexJob> pending = AsyncUtils.getPendingJobs(AsyncUtils_Test.class, currentJobId);
		System.assertEquals(1, pending?.size(), 'Wrong # of pending jobs');
	}

	@IsTest
	static void shouldReturnNoneIfNoJobs() {
		List<AsyncApexJob> pending = AsyncUtils.getPendingJobs(AsyncUtils_Test.class, null);
		System.assertEquals(0, pending?.size(), 'Wrong # of pending jobs');
	}

	@IsTest
	static void shouldExcludeFinishedJobs() {
		Test.startTest();
		// This forces the job to execute
		Id currentJobId = System.enqueueJob(new AsyncUtils_Test());
		Test.stopTest();

		List<AsyncApexJob> pending = AsyncUtils.getPendingJobs(AsyncUtils_Test.class, null);
		System.assertEquals(0, pending?.size(), 'Wrong # of pending jobs');
	}

	// **** HELPER **** //
	public void execute(System.QueueableContext context) {
		// This test file is (obviously) not a real Queueable
		// Normally, we'd use an inner type for this,
		// but Apex's Type.getName() method does not return expected results for inner types.
	}
}
