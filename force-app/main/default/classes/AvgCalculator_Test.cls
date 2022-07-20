@IsTest 
private class AvgCalculator_Test { 
    @IsTest 
    static void shouldNotCalculateBooleanValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(new Opportunity(), Opportunity.IsClosed, true)); 
        }
        
        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.IsClosed));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Boolean values');
    }
    
    @IsTest 
    static void shouldCalculateAvgOfDateValues() {
        Date minDate = Date.newInstance(2022, 01, 01); 
        Date maxDate = minDate; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Integer extraDays = i * 10; 
            maxDate = minDate.addDays(extraDays);
            opportunities.add(new Opportunity(
                CloseDate = maxDate
            ));
        }

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CloseDate));
        Date expected = minDate.addDays(Integer.valueOf((minDate.daysBetween(maxDate) / 2)));
        System.assertEquals(expected, calc.calculate(opportunities), 'Wrong AVG of Opportunity.CloseDate');
    }

    @IsTest 
    static void shouldCalculateAvgOfDateTimeValues() {
        DateTime minDt = DateTime.newInstanceGmt(2022, 01, 01); 
        DateTime maxDt = minDt; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Integer extraDays = i * 10; 
            maxDt = minDt.addDays(extraDays);
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(new Opportunity(), Opportunity.CreatedDate, maxDt));
        }

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate));
        DateTime expected = minDt.addSeconds(Integer.valueOf(((maxDt.getTime() - minDt.getTime()) / 1000) / 2));
        System.assertEquals(expected, calc.calculate(opportunities), 'Wrong AVG of Opportunity.CreatedDate');
    }

    @IsTest 
    static void shouldCalculateAvgOfNumberValues() {
        Decimal sum = 0; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Decimal amount = Math.random() * 1000;
            sum += amount; 
            opportunities.add(new Opportunity(
                Amount = amount
            ));
        }

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.Amount));
        Decimal expected = (sum / opportunities?.size()); 
        System.assertEquals(expected, calc.calculate(opportunities), 'Wrong AVG of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateTextValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opportunity #' + i
            ));
        }
        
        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.Name));
        System.assertEquals(null, calc.calculate(opportunities), 'Did not return null for Text values');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnDateFields() {
        Date minDate = Date.newInstance(2022, 01, 01); 
        Date maxDate = minDate;
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(CloseDate = minDate)); 
        for (Integer i = 0; i < 10; i++) {
            Date newDate = (i != null) ? maxDate.addDays(10) : null; 
            maxDate = (newDate != null) ? newDate : maxDate; 
            opportunities.add(new Opportunity(
                CloseDate = newDate
            ));
        } 

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        Date expected = minDate.addDays(Integer.valueOf((minDate.daysBetween(maxDate) / 2)));
        System.assertEquals(expected, calc.calculate(opportunities), 'Wrong AVG of Opportunity.CloseDate');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnDateTimeFields() {
        DateTime minDt = DateTime.newInstanceGmt(2022, 01, 01); 
        DateTime maxDt = minDt; 
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(new Opportunity(), Opportunity.CreatedDate, minDt)); 
        for (Integer i = 0; i < 10; i++) {
            Integer extraDays = i * 10; 
            DateTime newDt = (i != 0) ? minDt.addDays(extraDays) : null; 
            if (newDt != null) {
                maxDt = newDt;
            }
            opportunities.add((Opportunity) SObjectUtils.setReadOnlyField(new Opportunity(), Opportunity.CreatedDate, newDt));
        }

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate));
        DateTime expected = minDt.addSeconds(Integer.valueOf(((maxDt.getTime() - minDt.getTime()) / 1000) / 2));
        System.assertEquals(expected, calc.calculate(opportunities), 'Wrong AVG of Opportunity.CreatedDate');
    }

    @IsTest 
    static void shouldCalculateSomeNullValuesOnNumberFields() {
        Decimal sum = 0; 
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Decimal amount = (i != 0) ? Math.random() * 1000 : null; 
            if (amount != null) {
                sum += amount;
            }
            opportunities.add(new Opportunity(
                Amount = amount
            ));
        }

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        Decimal expected = (sum / opportunities?.size());
        System.assertEquals(expected, calc.calculate(opportunities), 'Wrong AVG of Opportunity.Amount');
    }

    @IsTest 
    static void shouldNotCalculateAllNullValuesOnDateFields() {
        // Note: Avg of null dates is null
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }   

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'Did not default AVG of null date values to null');
    }

    @IsTest 
    static void shouldNotCalculateAllNullValuesOnDateTimeFields() {
        // Note: Avg of null datetimes is null
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }   

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'Did not default AVG of null values to null');
    }

    @IsTest 
    static void shouldCalculateAllNullValuesOnNumberFields() {
        // Note: Avg of null numbers is 0
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity());
        }   

        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(0, calc.calculate(opportunities), 'Did not default AVG of null number values to 0');
    }

    @IsTest 
    static void shouldNotCalculateNullRecordsOnDateFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CloseDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'Did not default AVG of null records to 0');
    }

    @IsTest 
    static void shouldNotCalculateNullRecordsOnDateTimeFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.CreatedDate)); 
        System.assertEquals(null, calc.calculate(opportunities), 'Did not default AVG of null records to 0');
    }

    @IsTest 
    static void shouldCalculateNullRecordsOnNumberFields() {
        List<Opportunity> opportunities = null; 
        Rollup.Calculator calc = new AvgCalculator().setCalcField(new FieldReference(Opportunity.Amount)); 
        System.assertEquals(0, calc.calculate(opportunities), 'Did not default AVG of null records to 0');
    }

    @IsTest 
    static void shouldNotCalculateNullCalcField() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            opportunities.add(new Opportunity(
                Amount = 1000
            ));
        }

        Rollup.Calculator calc = new AvgCalculator(); // No calc field!
        System.assertEquals(null, calc.calculate(opportunities), 'Returned a non-null value, despite missing calc field');
    }
}
