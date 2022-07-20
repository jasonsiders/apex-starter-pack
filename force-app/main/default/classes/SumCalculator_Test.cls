@IsTest 
private class SumCalculator_Test {
    @IsTest 
    static void shouldNotCalculateBooleanValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.IsClosed, 
                true
            ));
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.IsClosed));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Boolean values'); 
    }
    
    @IsTest 
    static void shouldNotCalculateSumOfDateValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(
                CloseDate = Date.today().addDays(i)
            ));
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Date values');
    }

    @IsTest 
    static void shouldNotCalculateSumOfDateTimeValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.CreatedDate, 
                DateTime.now()
            ));
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for DateTime values'); 
    }

    @IsTest 
    static void shouldCalculateSumOfNumberValues() {
        Decimal totalAmount = 0; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Decimal increment = 100; 
            totalAmount += increment; 
            opportunities.add(new Opportunity(
                Amount = increment
            ));
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(totalAmount, calc.calculate(opportunities), 'Wrong SUM of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateTextValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(Name = 'Test Opp'));
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.Name));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Text values'); 
    }

    @IsTest 
    static void shouldCalculateSomeValuesOnNumberFields() {
        Decimal totalAmount = 0; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Decimal increment = (i != null) ? 100 : null;
            if (increment != null) {
                totalAmount += increment; 
            }
            opportunities.add(new Opportunity(
                Amount = increment
            ));
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(totalAmount, calc.calculate(opportunities), 'Wrong SUM of Opportunity.Amount');
    }

    @IsTest 
    static void shouldCalculateAllNullValuesOnNumberFields() {
        // Note: Sum of null numbers is 0
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(0, calc.calculate(opportunities), 'All Opportunity.Amount values are null, but did not return 0');
    }

    @IsTest 
    static void shouldCalculateNullRecordsOnNumberFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new SumCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(0, calc.calculate(opportunities), 'All Opportunity.Amount values are null, but did not return 0');
    }

    @IsTest 
    static void shouldNotCalculateNullCalcField() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(
                Amount = 1000
            ));
        }

        Rollup.Calculator calc = new SumCalculator(); // No calc field!
        System.assertEquals(null, calc.calculate(opportunities), 'Returned a non-null value, despite missing calc field');
    }
}
