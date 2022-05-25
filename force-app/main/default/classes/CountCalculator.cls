public class CountCalculator extends Rollup.Calculator {
    // Note: COUNT is the only standard calculation type that does not use a calculation field
    public override Rollup.Calculator setCalcField(SObjectField calcField) {
        return this; 
    }

    public override Object calculate(List<SObject> records) {
        return (records != null) ? records?.size() : 0; 
    }
}
