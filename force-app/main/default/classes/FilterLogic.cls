global abstract class FilterLogic implements ICriteria {
	protected List<ICriteria> criterion = new List<ICriteria>();
	protected String token;

	// **** INTERFACE **** //
	global abstract Boolean meetsCriteria(Object item);

	global Boolean meetsCriteria(SObject record) {
		// For this method, the logic for both overrides is the same
		Object obj = record;
		return this.meetsCriteria(obj);
	}

	global Set<String> getFieldNames() {
		Set<String> fieldNames = new Set<String>();
		for (ICriteria criteria : this.criterion) {
			fieldNames.addAll(criteria?.getFieldNames());
		}
		return fieldNames;
	}

	global override String toString() {
		String delimiter = ' ' + this.token + ' ';
		List<String> criteriaStrings = new List<String>();
		for (ICriteria criteria : this.criterion) {
			// Wrap inner FilterLogic objects in parentheses
			String criteriaString = (criteria instanceof FilterLogic)
				? '(' + criteria?.toString() + ')'
				: criteria?.toString();
			criteriaStrings.add(criteriaString);
		}
		return String.join(criteriaStrings, delimiter);
	}

	// **** global **** //
	global virtual FilterLogic addCriteria(List<ICriteria> criterion) {
		this.criterion.addAll(criterion);
		return this;
	}

	global virtual FilterLogic addCriteria(ICriteria criteria) {
		return this.addCriteria(new List<ICriteria>{ criteria });
	}

	global virtual List<ICriteria> getCriteria() {
		return this.criterion;
	}

	global virtual FilterLogic setCriteria(List<ICriteria> criterion) {
		this.criterion = criterion;
		return this;
	}
}
