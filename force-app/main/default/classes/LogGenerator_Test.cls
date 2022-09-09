@IsTest
private class LogGenerator_Test {
	@IsTest
	static void shouldLogFromTrigger() {
		List<Log_Event__e> events = generateTestEvents();

		Test.startTest();
		new LogGenerator(events).createLogRecords();
		Test.stopTest();

		List<Log__c> logs = getLogs();
		System.assertEquals(events?.size(), logs?.size(), 'Wrong # of logs');
		for (Integer i = 0; i < 200; i++) {
			Log__c log = logs[i];
			Log_Event__e event = events[i];
			System.assertEquals(event.Apex_Class__c, log.Apex_Class__c, 'Wrong Apex_Class__c');
			System.assertEquals(event.Context__c, log.Context__c, 'Wrong Context__c');
			System.assertEquals(event.Level__c, log.Level__c, 'Wrong Level__c');
			System.assertEquals(event.Logged_At__c, log.Logged_At__c, 'Wrong Logged_At__c');
			System.assert(log.Logged_At__c < log.CreatedDate, 'Logged At should be before CreatedDate');
			System.assertEquals(event.Message__c, log.Message__c, 'Wrong Message__c');
			System.assertEquals(event.Running_User__c, log.Running_User__c, 'Wrong Running_User__c');
			System.assertEquals(event.Sequence__c, log.Sequence__c, 'Wrong Sequence__c');
			System.assertEquals(event.Stack_Trace__c, log.Stack_Trace__c, 'Wrong Stack_Trace__c');
			System.assertEquals(event.Transaction_Id__c, log.Transaction_Id__c, 'Wrong Transaction_Id__c');
		}
	}

	// **** HELPER **** //
	static List<Log_Event__e> generateTestEvents() {
		List<Log_Event__e> logEvents = new List<Log_Event__e>();
		Id userId = UserInfo.getUserId();
		System.Request req = System.Request.getCurrent();
		String stack = new System.DmlException()?.getStackTraceString();
		for (Integer i = 0; i < 200; i++) {
			logEvents
				?.add(
					new Log_Event__e(
						Apex_Class__c = String.valueOf(LogGenerator_Test.class),
						Context__c = req.getQuiddity()?.name(),
						Level__c = 'FINEST',
						Logged_At__c = DateTime.now().addSeconds(-5),
						Message__c = 'Test Log #' + (i + 1),
						Running_User__c = userId,
						Sequence__c = (i + 1),
						Stack_Trace__c = stack,
						Transaction_Id__c = req.getRequestId()
					)
				);
		}
		return logEvents;
	}

	static List<Log__c> getLogs() {
		return [
			SELECT
				Id,
				Apex_Class__c,
				Context__c,
				CreatedDate,
				Level__c,
				Logged_At__c,
				Message__c,
				Running_User__c,
				Sequence__c,
				Stack_Trace__c,
				Transaction_Id__c
			FROM Log__c
			ORDER BY Sequence__c ASC
		];
	}
}
