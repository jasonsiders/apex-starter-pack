global virtual class OrLogic extends FilterLogic {
	global OrLogic() {
		this.token = 'OR';
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
