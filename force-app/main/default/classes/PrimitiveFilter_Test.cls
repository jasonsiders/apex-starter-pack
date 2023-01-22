@IsTest
private class PrimitiveFilter_Test {
	@IsTest
	static void shouldFilterBooleanValues() {
		Filter myFilter = new PrimitiveFilter(Filter.EQUALS, false);
		System.assertEquals(true, myFilter.meetsCriteria(false), 'false != false');
		System.assertEquals(false, myFilter.meetsCriteria(true), 'true == false');
	}

	@IsTest
	static void shouldFilterDateValues() {
		Date today = Date.today();
		Date tomorrow = today.addDays(1);
		Filter myFilter = new PrimitiveFilter(Filter.EQUALS, today);
		System.assertEquals(true, myFilter.meetsCriteria(today), today + ' != ' + today);
		System.assertEquals(false, myFilter.meetsCriteria(tomorrow), tomorrow + ' == ' + today);
	}

	@IsTest
	static void shouldFilterDateTimeValues() {
		DateTime now = DateTime.now();
		DateTime soon = DateTime.now().addHours(1);
		Filter myFilter = new PrimitiveFilter(Filter.EQUALS, now);
		System.assertEquals(true, myFilter.meetsCriteria(now), now + ' != ' + now);
		System.assertEquals(false, myFilter.meetsCriteria(soon), soon + ' == ' + now);
	}

	@IsTest
	static void shouldFilterNumberValues() {
		Filter myFilter = new PrimitiveFilter(Filter.EQUALS, 1);
		System.assertEquals(true, myFilter.meetsCriteria(1), 1 + ' != ' + 1);
		System.assertEquals(false, myFilter.meetsCriteria(99), 99 + ' == ' + 1);
	}

	@IsTest
	static void shouldFilterTextValues() {
		Filter myFilter = new PrimitiveFilter(Filter.EQUALS, 'foo');
		System.assertEquals(true, myFilter.meetsCriteria('foo'), '"foo" != "foo"');
		System.assertEquals(false, myFilter.meetsCriteria('bar'), '"bar" == "foo"');
	}
}
