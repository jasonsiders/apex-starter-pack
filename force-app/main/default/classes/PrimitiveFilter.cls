global class PrimitiveFilter extends Filter {
	// Used to compare Primitive types (Integer, String, etc)
	// Since they do not have a property, will always compare the item itself
	global PrimitiveFilter(Type operatorType, Object value) {
		super('', operatorType, value);
	}

	global override Boolean meetsCriteria(Object item) {
		return this.operator?.meetsCriteria(item, this.value);
	}
}
