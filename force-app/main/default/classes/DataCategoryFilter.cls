global class DataCategoryFilter extends Filter {
	global static final Type ABOVE = AboveOperator.class;
	global static final Type AT = AtOperator.class;
	global static final Type BELOW = BelowOperator.class;
	global static final Type ABOVE_OR_BELOW = AboveOrBelowOperator.class;

	global DataCategoryFilter(String category, Type operatorType, List<String> compareCategories) {
		super(category, operatorType, compareCategories);
	}

	global DataCategoryFilter(String category, Type operatorType, String compareCategory) {
		super(category, operatorType, compareCategory);
	}

	// **** INNER **** //
	global abstract class Operator extends Filter.Operator {
		global override String processStringValue(String value) {
			return value;
		}

		global override Boolean meetsCriteria(Object value, Object comparison) {
			// Note: All Operator types' meetsCriteria() method returns FALSE
			// We don't have a way of checking the hierarchy in apex, without SOQL (which gets a bit meta)
			// Since this class is primarily designed for use in SOQL itself, this is not really necessary
			return false;
		}
	}

	global class AboveOperator extends Operator {
		global override String getToken() {
			return 'ABOVE';
		}
	}

	global class AtOperator extends Operator {
		global override String getToken() {
			return 'AT';
		}
	}

	global class BelowOperator extends Operator {
		global override String getToken() {
			return 'BELOW';
		}
	}

	global class AboveOrBelowOperator extends Operator {
		global override String getToken() {
			return 'ABOVE_OR_BELOW';
		}
	}
}
