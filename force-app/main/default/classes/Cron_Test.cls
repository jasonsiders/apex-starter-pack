@IsTest
private class Cron_Test {
	@IsTest
	static void shouldCreateCronObject() {
		Test.startTest();
		Cron cron = new Cron(TEST_EXP);
		Test.stopTest();

		System.assertEquals('0', cron.seconds, 'Wrong seconds');
		System.assertEquals('5', cron.minutes, 'Wrong minutes');
		System.assertEquals('10', cron.hours, 'Wrong hours');
		System.assertEquals('15', cron.dayOfMonth, 'Wrong dayOfMonth');
		System.assertEquals('*', cron.month, 'Wrong month');
		System.assertEquals('?', cron.dayOfWeek, 'Wrong dayOfWeek');
		System.assertEquals(TEST_EXP, cron.expression(), 'Wrong expression');
	}

	@IsTest
	static void shouldRescheduleToFutureMinutesValue() {
		Integer numMins = 15;
		String expected = String.valueOf(DateTime.now().addMinutes(numMins).minute());

		Test.startTest();
		Cron cron = new Cron(TEST_EXP).minutesFromNow(numMins);
		Test.stopTest();

		System.assertEquals(expected, cron.minutes, 'Wrong minutes');
	}

	@IsTest
	static void shouldGenerateHourlyJob() {
		final String hourlyExp = '0 0 * * * ?'; // hourly

		Test.startTest();
		Cron cron = Cron.hourly();
		Test.stopTest();

		System.assertEquals(hourlyExp, cron.expression(), 'Wrong hourly value');
	}

	static final String TEST_EXP = '0 5 10 15 * ?';
}
