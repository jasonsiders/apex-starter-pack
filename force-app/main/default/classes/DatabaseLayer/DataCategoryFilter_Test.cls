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
		FilterLogic logic = new DataCategoryFilter.AndLogic(filters);
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
		FilterLogic logic = new DataCategoryFilter.OrLogic(filters);
		System.assertEquals(
			'Category1 ABOVE Category2 OR Category3 BELOW Category4',
			logic.toString(),
			'Unexpected output'
		);
	}

	@IsTest
	static void shouldGenerateCustomLogic() {
		List<DataCategoryFilter> filters = new List<DataCategoryFilter>{
			new DataCategoryFilter('Category1', DataCategoryFilter.ABOVE, 'Category2'),
			new DataCategoryFilter('Category3', DataCategoryFilter.BELOW, 'Category4'),
			new DataCategoryFilter('Category5', DataCategoryFilter.AT, 'Category6')
		};
		FilterLogic logic = new CustomLogic(filters);
		System.assertEquals(
			'(Category1 ABOVE Category2 AND Category3 BELOW Category4) OR Category5 AT Category6',
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

	// **** HELPER **** //
	public class CustomLogic extends FilterLogic implements DataCategoryFilter.Logic {
		public CustomLogic(List<DataCategoryFilter> filters) {
			this.filters = filters;
		}

		public override Boolean meetsCriteria(Object obj) {
			return null; // We don't care about this method for now
		}

		public override String toString() {
			return String.format(
				'({0} AND {1}) OR {2}',
				new List<String>{ this.filters[0].toString(), this.filters[1].toString(), this.filters[2].toString() }
			);
		}
	}
}
