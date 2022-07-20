@IsTest 
private class MinCalculator_Test {
    @IsTest 
    static void shouldNotCalculateBooleanValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add((Opportunity) ObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.IsClosed, 
                true
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.IsClosed));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Boolean values'); 
    }
    
    @IsTest 
    static void shouldCalculateMinOfDateValues() {
        Date minDate = Date.newInstance(2022, 01, 01); 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            minDate = minDate.addDays(-10); 
            opportunities.add(new Opportunity(
                CloseDate = minDate
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(minDate, calc.calculate(opportunities), 'Wrong MIN of Opportunity.CloseDate');
    }

    @IsTest 
    static void shouldCalculateMinOfDateTimeValues() {
        DateTime minDt = DateTime.newInstanceGmt(2022, 01, 01);
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            minDt = minDt.addDays(-10); 
            opportunities.add((Opportunity) ObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.CreatedDate, 
                minDt
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate)); 
        System.assertEquals(minDt, calc.calculate(opportunities), 'Wrong MIN of Opportunity.CreatedDate');
    }

    @IsTest 
    static void shouldCalculateMinOfNumberValues() {
        Decimal minAmount = 1000000; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            minAmount -= 100; 
            opportunities.add(new Opportunity(
                Amount = minAmount
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(minAmount, calc.calculate(opportunities), 'Wrong MIN of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateTextValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(Name = 'Test Opp'));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.Name));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Text values'); 
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnDateFields() {
        Date minDate = Date.newInstance(2022, 01, 01); 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Date newDate = (i != 0) ? minDate.addDays(-10) : null; 
            if (newDate != null) {
                minDate = newDate;
            }
            opportunities.add(new Opportunity(
                CloseDate = newDate
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(minDate, calc.calculate(opportunities), 'Wrong MIN of Opportunity.CloseDate');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnDateTimeFields() {
        DateTime minDt = DateTime.newInstanceGmt(2022, 01, 01);
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            DateTime newDt = (i != 0) ? minDt.addDays(-10) : null;
            if (newDt != null) {
                minDt = newDt; 
            }
            opportunities.add((Opportunity) ObjectUtils.setReadOnlyField(
                new Opportunity(), 
                Opportunity.CreatedDate, 
                newDt
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate)); 
        System.assertEquals(minDt, calc.calculate(opportunities), 'Wrong MIN of Opportunity.CreatedDate');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnNumberFields() {
        Decimal minAmount = 1000000; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Decimal newAmount = (i != 0) ? minAmount - 100 : null; 
            if (newAmount != null) {
                minAmount = newAmount; 
            }
            opportunities.add(new Opportunity(
                Amount = newAmount
            ));
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(minAmount, calc.calculate(opportunities), 'Wrong MIN of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateAllNullValuesOnDateFields() {
        // Note: Min of null dates is null
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CloseDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldNotCalculateAllNullValuesOnDateTimeFields() {
        // Note: Min of null datetimes is null
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CreatedDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldCalculateAllNullValuesOnNumberFields() {
        // Note: Min of null numbers is 0
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }

        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(0, calc.calculate(opportunities), 'All Opportunity.Amount values are null, but did not return 0');
    }

    @IsTest 
    static void shouldNotCalculateNullRecordsOnDateFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CloseDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldNotCalculateNullRecordsOnDateTimeFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'All Opportunity.CreatedDate values are null, but did not return null');
    }

    @IsTest 
    static void shouldCalculateNullRecordsOnNumberFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new MinCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
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

        Rollup.Calculator calc = new MinCalculator(); // No calc field!
        System.assertEquals(null, calc.calculate(opportunities), 'Returned a non-null value, despite missing calc field');
    }
}
