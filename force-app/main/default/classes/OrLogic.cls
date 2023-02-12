global virtual class OrLogic extends FilterLogic {
	static final String OR_PREDICATE = 'OR';

	global OrLogic() {
		super(OR_PREDICATE);
	}

	global override Boolean meetsCriteria(Object item) {
		for (ICriteria criteria : this.criterion) {
			if (criteria.meetsCriteria(item) == true) {
				return true;
			}
		}
		return false;
	}
}
