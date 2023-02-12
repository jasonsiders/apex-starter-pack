global abstract class FilterLogic implements ICriteria {
	global List<ICriteria> criterion = new List<ICriteria>();
	global final String predicate;

	global FilterLogic(String predicate) {
		this.predicate = predicate; 
	}

	global abstract Boolean meetsCriteria(Object item);

	global virtual Boolean meetsCriteria(SObject record) {
		// For this instance, the logic for both overrides is the same
		Object obj = record;
		return this.meetsCriteria(obj);
	}

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
	
	global Set<String> getFieldNames() {
		Set<String> fieldNames = new Set<String>();
		for (ICriteria criteria : this.criterion) {
			fieldNames.addAll(criteria?.getFieldNames());
		}
		return fieldNames;
	}

	global virtual FilterLogic setCriteria(List<ICriteria> criterion) {
		this.criterion = criterion;
		return this;
	}

	global override String toString() {
		String delimiter = ' ' + this.predicate + ' ';
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
}
