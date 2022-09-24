@IsTest
private class CountCalculator_Test {
	@IsTest
	static void shouldNotSetCalcField() {
		Rollup.Calculator calc = new CountCalculator().setCalcField(new FieldRef(Opportunity.Amount));
		System.assertEquals(null, calc.calcField, 'COUNT calculator set a calc field, though it is not used');
	}

	@IsTest
	static void shouldCountTheNumberOfRecords() {
		Integer numAccounts = Integer.valueOf(Math.random() * 200);
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numAccounts; i++) {
			accounts.add(new Account());
		}
		Rollup.Calculator calc = new CountCalculator();
		System.assertEquals(numAccounts, calc.calculate(accounts), 'Wrong COUNT of accounts');
	}

	@IsTest 
	static void shouldReturn0IfNullRecordList() {
		Rollup.Calculator calc = new CountCalculator();
		System.assertEquals(0, calc.calculate(null), 'Null records did not return a COUNT of 0');
	}
}
