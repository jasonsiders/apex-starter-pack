global class SoqlSort {
	List<String> fieldNames = new List<String>();
	Order order;
	NullOrder nullOrder;

	static final Map<Order, String> ORDER_BY_KEYS = new Map<Order, String>{
		Order.ASCENDING => 'ASC',
		Order.DESCENDING => 'DESC'
	};

	global SoqlSort(List<FieldRef> fieldReferences, Order order, NullOrder nullOrder) {
		for (FieldRef fieldReference : fieldReferences) {
			this.fieldNames.add(fieldReference?.toString());
		}
		this.order = order;
		this.nullOrder = nullOrder;
	}

	global SoqlSort(List<FieldRef> fieldReferences, Order order) {
		this(fieldReferences, order, null);
	}

	global SoqlSort(FieldRef fieldReference, Order order, NullOrder nullOrder) {
		this(new List<FieldRef>{ fieldReference }, order, nullOrder);
	}

	global SoqlSort(FieldRef fieldReference, Order order) {
		this(fieldReference, order, null);
	}

	global SoqlSort(List<SObjectField> fields, Order order, NullOrder nullOrder) {
		for (SObjectField field : fields) {
			this.fieldNames.add(String.valueOf(field));
		}
		this.order = order;
		this.nullOrder = nullOrder;
	}

	global SoqlSort(List<SObjectField> fields, Order order) {
		this(fields, order, null);
	}

	global SoqlSort(SObjectField field, Order order, NullOrder nullOrder) {
		this(new List<SObjectField>{ field }, order, nullOrder);
	}

	global SoqlSort(SObjectField field, Order order) {
		this(field, order, null);
	}

	global SoqlSort(List<String> fieldNames, Order order, NullOrder nullOrder) {
		this.fieldNames = fieldNames;
		this.order = order;
		this.nullOrder = nullOrder;
	}

	global SoqlSort(List<String> fieldNames, Order order) {
		this(fieldNames, order, null);
	}

	global SoqlSort(String fieldName, Order order, NullOrder nullOrder) {
		this(new List<String>{ fieldName }, order, nullOrder);
	}

	global SoqlSort(String fieldName, Order order) {
		this(fieldName, order, null);
	}

	global override String toString() {
		String nullOrder = (this.nullOrder != null) ? 'NULLS ' + String.valueOf(this.nullOrder) : '';
		return (String.join(fieldNames, ', ') + ' ' + ORDER_BY_KEYS.get(this.order) + ' ' + nullOrder).trim();
	}

	// **** INNER **** //
	global enum Order {
		ASCENDING,
		DESCENDING
	}

	global enum NullOrder {
		FIRST,
		LAST
	}
}
