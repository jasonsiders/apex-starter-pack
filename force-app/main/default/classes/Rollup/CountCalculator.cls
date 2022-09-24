public class CountCalculator extends Rollup.Calculator {
	public CountCalculator() {
		this.label = 'COUNT';
	}
	
	// Note: COUNT is the only standard calculation type that does not use a calculation field
	public override Rollup.Calculator setCalcField(FieldRef calcField) {
		return this;
	}

	public override Object calculate(List<SObject> records) {
		return (records != null) ? records?.size() : 0;
	}
} 
