@IsTest 
private class MaxCalculator_Test {
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

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.IsClosed));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Boolean values'); 
    }
    
    @IsTest 
    static void shouldCalculateMaxOfDateValues() {
        Date maxDate = Date.newInstance(2022, 01, 01); 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            maxDate = maxDate.addDays(10); 
            opportunities.add(new Opportunity(
                CloseDate = maxDate
            ));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CloseDate)); 
        System.assertEquals(maxDate, calc.calculate(opportunities), 'Wrong MAX of Opportunity.CloseDate');
    }

    @IsTest 
    static void shouldCalculateMaxOfDateTimeValues() {
        DateTime maxDt = DateTime.newInstanceGmt(2022, 01, 01);
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            maxDt = maxDt.addDays(10); 
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.CreatedDate, 
                maxDt
            ));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CreatedDate)); 
        System.assertEquals(maxDt, calc.calculate(opportunities), 'Wrong MAX of Opportunity.CreatedDate');
    }

    @IsTest 
    static void shouldCalculateMaxOfNumberValues() {
        Decimal maxAmount = 0; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            maxAmount += 100; 
            opportunities.add(new Opportunity(
                Amount = maxAmount
            ));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.Amount)); 
        System.assertEquals(maxAmount, calc.calculate(opportunities), 'Wrong MAX of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateTextValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(Name = 'Test Opp'));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.Name));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Text values'); 
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnDateFields() {
        Date maxDate = Date.newInstance(2022, 01, 01); 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Date newDate = (i != 0) ? maxDate.addDays(10) : null; 
            if (newDate != null) {
                maxDate = newDate;
            }
            opportunities.add(new Opportunity(
                CloseDate = newDate
            ));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CloseDate)); 
        System.assertEquals(maxDate, calc.calculate(opportunities), 'Wrong MAX of Opportunity.CloseDate');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnDateTimeFields() {
        DateTime maxDt = DateTime.newInstanceGmt(2022, 01, 01);
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            DateTime newDt = (i != 0) ? maxDt.addDays(10) : null;
            if (newDt != null) {
                maxDt = newDt; 
            }
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.CreatedDate, 
                newDt
            ));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CreatedDate)); 
        System.assertEquals(maxDt, calc.calculate(opportunities), 'Wrong MAX of Opportunity.CreatedDate');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnNumberFields() {
        Decimal maxAmount = 0; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Decimal newAmount = (i != 0) ? maxAmount + 100 : null; 
            if (newAmount != null) {
                maxAmount = newAmount; 
            }
            opportunities.add(new Opportunity(
                Amount = newAmount
            ));
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.Amount)); 
        System.assertEquals(maxAmount, calc.calculate(opportunities), 'Wrong MAX of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateAllNullValuesOnDateFields() {
        // Note: Max of null dates is null
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CloseDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldNotCalculateAllNullValuesOnDateTimeFields() {
        // Note: Max of null datetimes is null
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CreatedDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CreatedDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldCalculateAllNullValuesOnNumberFields() {
        // Note: Max of null numbers is 0
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.Amount)); 
        System.assertEquals(0, calc.calculate(opportunities), 'All Opportunity.Amount values are null, but did not return 0');
    }

    @IsTest 
    static void shouldNotCalculateNullRecordsOnDateFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CloseDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldNotCalculateNullRecordsOnDateTimeFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.CreatedDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CreatedDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldCalculateNullRecordsOnNumberFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new MaxCalculator().setCalcField(new FieldRef(Opportunity.Amount)); 
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

        Rollup.Calculator calc = new MaxCalculator(); // No calc field!
        System.assertEquals(null, calc.calculate(opportunities), 'Returned a non-null value, despite missing calc field');
    }
}
