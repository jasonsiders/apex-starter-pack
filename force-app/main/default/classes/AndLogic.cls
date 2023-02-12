global virtual class AndLogic extends FilterLogic {
	static final String AND_PREDICATE = 'AND';

	global AndLogic() {
		super(AND_PREDICATE); 
	}

	global override Boolean meetsCriteria(Object item) {
		for (ICriteria criteria : this.criterion) {
			if (criteria.meetsCriteria(item) == false) {
				return false;
			}
		}
		return true;
	}
}
