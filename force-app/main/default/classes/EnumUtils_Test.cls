@IsTest
private class EnumUtils_Test {
	@IsTest
	static void shouldReturnEnumForValidValue() {
		String valueString = 'Red'; // Enums aren't case sensitive!

		Test.startTest();
		TrafficLight value = (TrafficLight) EnumUtils.valueOf(valueString, TrafficLight.class);
		Test.stopTest();

		System.assertEquals(TrafficLight.RED, value, 'Wrong TrafficLight value');
	}

	@IsTest
	static void shouldReturnNullForIllegalValue() {
		String valueString = 'some nonsense';

		Test.startTest();
		TrafficLight value = (TrafficLight) EnumUtils.valueOf(valueString, TrafficLight.class);
		Test.stopTest();

		System.assertEquals(null, value, 'Wrong TrafficLight value');
	}

	@IsTest
	static void shouldReturnNullForIllegalEnum() {
		String valueString = 'RED';

		Test.startTest();
		TrafficLight value = (TrafficLight) EnumUtils.valueOf(valueString, Account.class); // not an enum type
		Test.stopTest();

		System.assertEquals(null, value, 'Wrong TrafficLight value');
	}

	// **** INNNER *** //
	public enum TrafficLight {
		RED,
		YELLOW,
		GREEN
	}
}
