global abstract class SoqlWithClause {
	global abstract String output();

	global override String toString() {
		return String.format('WITH {0}', new List<String>{ this.output() });
	}

	// **** INNER **** //
	global enum Context {
		// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm
		USER_MODE,
		SYSTEM_MODE,
		// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_with_security_enforced.htm
		SECURITY_ENFORCED
	}

	global class ContextExpression extends SoqlWithClause {
		Context context;

		global ContextExpression(Context context) {
			this.context = context;
		}

		global override String output() {
			return String.valueOf(this.context);
		}
	}

	global class DataCategoryExpression extends SoqlWithClause {
		FilterLogic logic;

		global DataCategoryExpression(FilterLogic logic) {
			this.logic = logic;
		}

		global override String output() {
			return logic?.toString();
		}
	}
}
