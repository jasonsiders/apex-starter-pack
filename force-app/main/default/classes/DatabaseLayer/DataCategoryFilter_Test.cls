@IsTest
private class DataCategoryFilter_Test {
	@IsTest
	static void shouldOutputAboveFilter() {
		Filter testFilter = new DataCategoryFilter('Category1', DataCategoryFilter.ABOVE, 'Category2');
		System.assertEquals('Category1 ABOVE Category2', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldOutputAtFilter() {
		Filter testFilter = new DataCategoryFilter('Category1', DataCategoryFilter.AT, 'Category2');
		System.assertEquals('Category1 AT Category2', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldOutputBelowFilter() {
		Filter testFilter = new DataCategoryFilter('Category1', DataCategoryFilter.BELOW, 'Category2');
		System.assertEquals('Category1 BELOW Category2', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldOutputAboveOrBelowFilter() {
		Filter testFilter = new DataCategoryFilter('Category1', DataCategoryFilter.ABOVE_OR_BELOW, 'Category2');
		System.assertEquals('Category1 ABOVE_OR_BELOW Category2', testFilter.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldCompareAgainstMultipleCategories() {
		Filter testFilter = new DataCategoryFilter(
			'Category1',
			DataCategoryFilter.ABOVE,
			new List<String>{ 'Category2', 'Category3', 'Category4' }
		);
		System.assertEquals(
			'Category1 ABOVE (Category2, Category3, Category4)',
			testFilter.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldGenerateAndLogic() {
		List<DataCategoryFilter> filters = new List<DataCategoryFilter>{
			new DataCategoryFilter('Category1', DataCategoryFilter.ABOVE, 'Category2'),
			new DataCategoryFilter('Category3', DataCategoryFilter.BELOW, 'Category4')
		};
		FilterLogic logic = new AndLogic().addCriteria(filters);
		System.assertEquals(
			'Category1 ABOVE Category2 AND Category3 BELOW Category4',
			logic.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldGenerateOrLogic() {
		List<DataCategoryFilter> filters = new List<DataCategoryFilter>{
			new DataCategoryFilter('Category1', DataCategoryFilter.ABOVE, 'Category2'),
			new DataCategoryFilter('Category3', DataCategoryFilter.BELOW, 'Category4')
		};
		FilterLogic logic = new OrLogic().addCriteria(filters);
		System.assertEquals(
			'Category1 ABOVE Category2 OR Category3 BELOW Category4',
			logic.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldTestOperatorMeetsCriteria() {
		// Note: All DataCategoryOperator types' meetsCriteria() method always returns FALSE
		DataCategoryFilter.Operator operator = new DataCategoryFilter.AboveOperator();
		System.assertEquals(false, operator.meetsCriteria(1, 1), 'Did not return false');
	}
}
