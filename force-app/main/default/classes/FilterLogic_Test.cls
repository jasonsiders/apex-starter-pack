@IsTest 
private class FilterLogic_Test {
    @IsTest 
    static void shouldDetermineAllMeetCriteria() {
        FilterLogic.AndLogic logic = new FilterLogic.AndLogic(testFilters);
        // If all are true, will return true
        Account testAccount = new Account(
            AnnualRevenue = 9999,
            BillingCountry = 'USA',
            OwnerId = UserInfo.getUserId()
        );
        System.assertEquals(true, logic.meetsCriteria(testAccount), 'Unexpected FilterLogic.meetsCriteria() result. Logic: ' + logic + '. Item: ' + JSON.serialize(testAccount));
        // If one fails, all will fail
        testAccount.AnnualRevenue = 1; 
        System.assertEquals(false, logic.meetsCriteria(testAccount), 'Unexpected FilterLogic.meetsCriteria() result. Logic: ' + logic + '. Item: ' + JSON.serialize(testAccount));
        // Should output as a block of AND statements
        String expected = testFilters[0] + ' AND ' + testFilters[1] + ' AND ' + testFilters[2];
        System.assertEquals(expected, logic.toString(), 'Wrong logic output');
    }  

    @IsTest 
    static void shouldDetermineAnyMeetCriteria() {
        FilterLogic.OrLogic logic = new FilterLogic.OrLogic(testFilters);
        // If all fails, will return false
        Account testAccount = new Account(
            AnnualRevenue = 1,
            BillingCountry = 'UK',
            OwnerId = DmlMock.generateFakeId(User.SObjectType)
        );
        System.assertEquals(false, logic.meetsCriteria(testAccount), 'Unexpected FilterLogic.meetsCriteria() result. Logic: ' + logic + '. Item: ' + JSON.serialize(testAccount));
        // If just one is true, will return true
        testAccount.AnnualRevenue = 9999; 
        System.assertEquals(true, logic.meetsCriteria(testAccount), 'Unexpected FilterLogic.meetsCriteria() result. Logic: ' + logic + '. Item: ' + JSON.serialize(testAccount));
        // Should output as a block of OR statements
        String expected = testFilters[0] + ' OR ' + testFilters[1] + ' OR ' + testFilters[2];
        System.assertEquals(expected, logic.toString(), 'Wrong logic output');
    }

    @IsTest 
    static void shouldDetermineCustomCriteriaMet() {
        FilterLogic logic = new CustomLogic(); 
        // If 2/3 meets criteria, will return true
        Account testAccount = new Account(
            AnnualRevenue = 9999,
            BillingCountry = 'USA',
            OwnerId = DmlMock.generateFakeId(User.SObjectType)
        ); 
        System.assertEquals(true, logic.meetsCriteria(testAccount), 'Unexpected FilterLogic.meetsCriteria() result. Logic: ' + logic + '. Item: ' + JSON.serialize(testAccount));
        // If 1/3 (or less) meets criteria, will return false
        testAccount.BillingCountry = 'UK';
        System.assertEquals(false, logic.meetsCriteria(testAccount), 'Unexpected FilterLogic.meetsCriteria() result. Logic: ' + logic + '. Item: ' + JSON.serialize(testAccount));
        // Should output some complex logic
        String expected = '(' +
            '(' + testFilters[0] + ' AND ' + testFilters[1] + ') OR ' +
            '(' + testFilters[0] + ' AND ' + testFilters[2] + ') OR ' + 
            '(' + testFilters[1] + ' AND ' + testFilters[2] + ')' +
        ')';
        System.assertEquals(expected, logic.toString(), 'Wrong logic output');
    }

    @IsTest 
    static void shouldGetSetFilters() {
        FilterLogic logic = new FilterLogic.AndLogic(); 
        Filter myFilter = new Filter(Account.Name, Filter.EQUALS, 'Test');
        System.assertEquals(0, logic.getFilters()?.size(), 'Wrong # of filters'); 
        // addFilters() adds a new filter(s) to the list
        logic.addFilters(myFilter); 
        System.assertEquals(1, logic.getFilters()?.size(), 'Wrong # of filters');
        logic.addFilters(myFilter); 
        System.assertEquals(2, logic.getFilters()?.size(), 'Wrong # of filters'); 
        // setFilters() relaces the exising list
        logic.setFilters(myFilter); 
        System.assertEquals(1, logic.getFilters()?.size(), 'Wrong # of filters'); 
    }

    @IsTest 
    static void shouldConstructWithoutFilters() {
        // Optionally, callers can generate a new instance of AndLogic/OrLogic without filters defined at the start
        // This allows them to add them later on
        FilterLogic logic = new FilterLogic.AndLogic(); 
        System.assertEquals(0, logic.getFilters()?.size(), 'Wrong # of filters'); 
        logic = new FilterLogic.OrLogic(); 
        System.assertEquals(0, logic.getFilters()?.size(), 'Wrong # of filters');
    }

    @IsTest 
    static void shouldOutputValidSoqlForInCollectionFilters() {
        // Note: IN_COLLECTION / NOT_IN_COLLECTION Filter Operators have proven to be especially difficult to output
        // Verify that they will produce a valid queries
        List<String> accountIds = new List<String>{
            DmlMock.generateFakeId(Account.SObjectType),
            DmlMock.generateFakeId(Account.SObjectType)
        };
        List<String> testNames = new List<String>{'Test1', 'Test2'};
        List<Filter> filters = new List<Filter>{
            new Filter(Account.Id, Filter.IN_COLLECTION, accountIds),
            new Filter(Account.Name, Filter.NOT_IN_COLLECTION, testNames)
        };

        FilterLogic logic = new FilterLogic.AndLogic(filters); 
        String template = 'Id IN ({1}, {2}) {0} Name NOT IN ({3}, {4})';
        List<String> args = new List<String>{
            'AND', 
            '\'' + accountIds[0] + '\'', 
            '\'' + accountIds[1] + '\'', 
            '\'' + testNames[0] + '\'', 
            '\'' + testNames[1] + '\''
        };
        System.assertEquals(String.format(template, args), logic.toString(), 'Unexpected AND logic output');
        logic = new FilterLogic.OrLogic(filters); 
        args[0] = 'OR'; 
        System.assertEquals(String.format(template, args), logic.toString(), 'Unexpected OR logic output');
    }

    // **** HELPER **** //
    static List<Filter> testFilters = new List<Filter>{
        new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()),
        new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000),
        new Filter(Account.BillingCountry, Filter.EQUALS, 'USA')
    };

    public class CustomLogic extends FilterLogic {
        Filter ownedByMe = testFilters[0];
        Filter highValue = testFilters[1];
        Filter inUSA = testFilters[2];

        public override Boolean meetsCriteria(Object item) {
            // If 2/3 meets criteria, will return true
            Integer numValid = 0; 
            for (Filter filter : new List<Filter>{ownedByMe, highValue, inUSA}) {
                numValid += (filter.meetsCriteria(item)) ? 1: 0; 
            }
            return numValid >= 2;
        }

        public override String toString() {
            // Basically have to list out every combination...
            return String.format(
                '(({0} AND {1}) OR ({0} AND {2}) OR ({1} AND {2}))', new List<String>{
                    ownedByMe.toString(), 
                    highValue.toString(), 
                    inUSA.toString()
                }); 
        }
    }
}
