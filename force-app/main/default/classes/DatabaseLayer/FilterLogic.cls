public abstract class FilterLogic implements ICriteria {
	protected List<ICriteria> criterion = new List<ICriteria>();
	protected String token;

	// **** INTERFACE **** //
	public abstract Boolean meetsCriteria(Object item);

	public Boolean meetsCriteria(SObject record) {
		// For this method, the logic for both overrides is the same
		Object obj = record;
		return this.meetsCriteria(obj);
	}

	public Set<String> getFieldNames() {
		Set<String> fieldNames = new Set<String>();
		for (ICriteria criteria : this.criterion) {
			fieldNames.addAll(criteria.getFieldNames());
		}
		return fieldNames;
	}

	public override String toString() {
		String delimiter = ' ' + this.token + ' ';
		List<String> criteriaStrings = new List<String>(); 
		for (ICriteria criteria : this.criterion) {
			// Wrap inner FilterLogic objects in parentheses
			String criteriaString = (criteria instanceOf FilterLogic) 
				? '(' + criteria?.toString() + ')' 
				: criteria?.toString();
			criteriaStrings.add(criteriaString); 
		}
		return String.join(criteriaStrings, delimiter);
	}

	// **** PUBLIC **** // 
	public virtual FilterLogic addCriteria(List<ICriteria> criterion) {
		this.criterion.addAll(criterion); 
		return this;
	}
	
	public virtual FilterLogic addCriteria(ICriteria criteria) {
		return this.addCriteria(new List<ICriteria>{ criteria });
	}

	public virtual List<ICriteria> getCriteria() {
		return this.criterion;
	}

	public virtual FilterLogic setCriteria(List<ICriteria> criterion) {
		this.criterion = criterion;
		return this;
	}

	// **** IMPLEMENTATIONS **** //
	public virtual class AndLogic extends FilterLogic {
		public AndLogic() {
			this.token = 'AND';
		}

		public override Boolean meetsCriteria(Object item) {
			for (ICriteria criteria : this.criterion) {
				if (criteria.meetsCriteria(item) == false) {
					return false;
				}
			}
			return true;
		}
	}

	public virtual class OrLogic extends FilterLogic {
		public OrLogic() {
			this.token = 'OR';
		}

		public override Boolean meetsCriteria(Object item) {
			for (ICriteria criteria : this.criterion) {
				if (criteria.meetsCriteria(item) == true) {
					return true;
				}
			}
			return false;
		}
	}
}
