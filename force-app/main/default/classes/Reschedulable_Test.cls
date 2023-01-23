@IsTest
private class Reschedulable_Test extends Reschedulable {
	@IsTest
	static void shouldRunAndReschedule() {
		Test.startTest();
		Id jobId = System.schedule('Test Job', Cron.hourly()?.expression(), new Reschedulable_Test());
		Test.stopTest();

		Integer numAccs = (Integer) [SELECT COUNT(Id) FROM Account][0]?.get('expr0');
		System.assertEquals(200, numAccs, 'Wrong # of Accounts');
		List<AsyncApexJob> pendingJobs = AsyncUtils.getPendingJobs(Reschedulable_Test.class, jobId);
		System.assertEquals(false, pendingJobs?.isEmpty(), 'Job not re-scheduled');
	}

	// **** IMPLEMENTATION **** //
	// Note: Normally would employ an inner class here, but inner classes do not seem to work with this...
	public override Type getType() {
		return Reschedulable_Test.class;
	}

	public override Integer getInterval() {
		return 10;
	}

	public override void doScheduledActions(System.SchedulableContext context) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 200; i++) {
			Account account = new Account(Name = 'Test Account #' + i);
			accounts.add(account);
		}
		DB.Dml.doInsert(accounts);
	}
}
