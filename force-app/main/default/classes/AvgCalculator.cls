public class AvgCalculator extends Rollup.Calculator {
    // Note: Many different flavors of "Average"; this class caters to most common business cases
    // Number (Decimal/Integer) values return the MEAN average (SUM / COUNT)
    // Date/DateTime values return the MIDRANGE average ((MAX-MIN) / 2)
    // If you wanted a class to give the MODE/MEDIAN/etc. of some field, 
    // this would be a good use case for creating your own new Rollup.Calculator instance
    final Rollup.Calculator MAX = new MaxCalculator();
    final Rollup.Calculator MIN = new MinCalculator();
    final Rollup.Calculator SUM = new SumCalculator(); 

    public override Rollup.Calculator setCalcField(SObjectField calcField) {
        super.setCalcField(calcField); 
        this.MAX.setCalcField(calcField); 
        this.MIN.setCalcField(calcField); 
        this.SUM.setCalcField(calcField); 
        return this;
    }

    public override Date calculateDate(List<SObject> records) {
        Date results; 
        Date maxDate = (Date) MAX.calculate(records); 
        Date minDate = (Date) MIN.calculate(records); 
        if (maxDate != null && minDate != null) {
            Integer daysBetween = minDate?.daysBetween(maxDate); 
            Integer daysToAdd = Integer.valueOf(daysBetween / 2);
            results = minDate.addDays(daysToAdd); 
        }
        return (results != null) ? results : maxDate;
    }

    public override DateTime calculateDateTime(List<SObject> records) {
        DateTime results; 
        DateTime maxDate = (DateTime) MAX.calculate(records);
        DateTime minDate = (DateTime) MIN.calculate(records);
        if (maxDate != null && minDate != null) {
            Integer secsBetween = Integer.valueOf(((maxDate?.getTime() - minDate?.getTime()) / 1000));
            Integer secsToAdd = Integer.valueOf(secsBetween / 2);
            results = minDate.addSeconds(secsToAdd); 
        }
        return (results != null) ? results : maxDate;
    }

    public override Decimal calculateNumber(List<SObject> records) {
        Decimal sum = (Decimal) SUM.calculate(records); 
        Integer count = records?.size();
        return (sum != null && count != null && count != 0) ? (sum / count) : 0; 
    }
}
