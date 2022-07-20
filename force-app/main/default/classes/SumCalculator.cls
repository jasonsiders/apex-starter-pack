public class SumCalculator extends Rollup.Calculator {
    public override Decimal calculateNumber(List<SObject> records) {
        Decimal sum = 0; 
        for (SObject record : records) {
            Decimal recordValue = (Decimal) record?.get(this.calcField?.toSchemaType());
            // Default null values to 0
            Decimal sumValue = (recordValue != null) ? recordValue : 0; 
            sum += sumValue;
        }
        return sum;
    }
}
