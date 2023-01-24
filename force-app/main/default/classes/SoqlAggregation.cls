global class SoqlAggregation {
	Function function;
	String fieldName;
	String alias;

	global SoqlAggregation(Function function, String fieldName, String alias) {
		this.function = function;
		this.fieldName = fieldName;
		this.alias = alias;
	}

	global SoqlAggregation(Function function, String fieldName) {
		this(function, fieldName, '');
	}

	global SoqlAggregation(Function function, FieldRef fieldReference, String alias) {
		this(function, fieldReference?.toString(), alias);
	}

	global SoqlAggregation(Function function, FieldRef fieldReference) {
		this(function, fieldReference?.toString(), '');
	}

	global SoqlAggregation(Function function, SObjectField field, String alias) {
		this(function, new FieldRef(field), alias);
	}

	global SoqlAggregation(Function function, SObjectField field) {
		this(function, new FieldRef(field));
	}

	global override String toString() {
		return String.format(
				'{0}({1}) {2}',
				new List<String>{ String.valueOf(this.function), this.fieldName, this.alias }
			)
			.trim();
	}

	// **** INNER **** //
	global enum Function {
		AVG,
		COUNT,
		COUNT_DISTINCT,
		FORMAT,
		MIN,
		MAX,
		SUM
	}

	global class AggregateFilter extends Filter {
		global AggregateFilter(SoqlAggregation aggregation, Type operatorType, Object value) {
			super(aggregation?.toString(), operatorType, value);
		}
	}
}
