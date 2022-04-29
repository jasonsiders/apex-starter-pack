@IsTest 
private class QueryFilter_Test {
    @IsTest 
    static void shouldAllowStandardQuery() {
        QueryFilter filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.EQUALS, 'New');
        System.assertEquals('StageName = \'New\'', filter.toString()); 
    }

    @IsTest 
    static void shouldAllowParentQuery() {
        QueryFilter filter = new QueryFilter('Opportunity.Account.Type', QueryFilter.Operator.EQUALS, 'Prospect');
        System.assertEquals('Opportunity.Account.Type = \'Prospect\'', filter.toString());
    }

    @IsTest 
    static void shouldHandleEquals() {
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.EQUALS, 1000);
        System.assertEquals('Amount = 1000', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleNotEquals() {
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.NOT_EQUALS, 1000); 
        System.assertEquals('Amount != 1000', filter.toString());
    }

    @IsTest 
    static void shouldHandleGreaterThan() {
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.GREATER_THAN, 1000);
        System.assertEquals('Amount > 1000', filter.toString());
    }

    @IsTest 
    static void houldHandleGreaterOrEqualThan() {
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.GREATER_OR_EQUAL, 1000);
        System.assertEquals('Amount >= 1000', filter.toString());
    }

    @IsTest
    static void shouldHandleLessThan() {
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.LESS_THAN, 1000);
        System.assertEquals('Amount < 1000', filter.toString());
    }

    @IsTest 
    static void shouldHandleLessOrEqual() {
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.LESS_OR_EQUAL, 1000);
        System.assertEquals('Amount <= 1000', filter.toString());
    }

    @IsTest 
    static void shouldHandleStartsWith() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.STARTS_WITH, 'https://www.');
        System.assertEquals('Website LIKE \'https://www.%\'', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleEndsWith() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.ENDS_WITH, '.com');
        System.assertEquals('Website LIKE \'%.com\'', filter.toString());
    }

    @IsTest 
    static void shouldHandleContains() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.CONTAINS, 'in-n-out');
        System.assertEquals('Website LIKE \'%in-n-out%\'', filter.toString());
    }

    @IsTest 
    static void shouldHandleNotStartsWith() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.NOT_STARTS_WITH, 'https://www.');
        System.assertEquals('Website NOT LIKE \'https://www.%\'', filter.toString());
    }

    @IsTest 
    static void shouldHandleNotEndsWith() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.NOT_ENDS_WITH, '.com');
        System.assertEquals('Website NOT LIKE \'%.com\'', filter.toString());
    }

    @IsTest
    static void shouldHandleNotContains() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.NOT_CONTAINS, 'in-n-out');
        System.assertEquals('Website NOT LIKE \'%in-n-out%\'', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleNull() {
        QueryFilter filter = new QueryFilter(Account.Name, QueryFilter.Operator.EQUALS, null); 
        System.assertEquals('Name = null', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleBoolean() {
        QueryFilter filter = new QueryFilter(Account.IsDeleted, QueryFilter.Operator.EQUALS, true); 
        System.assertEquals('IsDeleted = true', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleDate() {
        Date testDate = Date.newInstance(2022, 01, 01); 
        QueryFilter filter = new QueryFilter(Opportunity.CloseDate, QueryFilter.Operator.EQUALS, testDate);
        System.assertEquals('CloseDate = 2022-01-01', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleDateTime() {
        DateTime testDateTime = DateTime.newInstanceGmt(2022, 01, 01);
        QueryFilter filter = new QueryFilter(Opportunity.CreatedDate, QueryFilter.Operator.GREATER_THAN, testDateTime); 
        System.assertEquals('CreatedDate > 2022-01-01T00:00:00Z', filter.toString());
    }

    @IsTest 
    static void shouldHandleRelativeDate() {
        QueryFilter filter = new QueryFilter(Opportunity.CreatedDate, QueryFilter.Operator.EQUALS, 'LAST_N_DAYS:10');
        System.assertEquals('CreatedDate = LAST_N_DAYS:10', filter.toString()); 
    }

    @IsTest 
    static void shouldHandleNumber() {
        // SOQL treats numbers all the same (whether Double/Integer/Decimal/etc)
        QueryFilter filter = new QueryFilter(Opportunity.Amount, QueryFilter.Operator.GREATER_THAN, 1000);
        System.assertEquals('Amount > 1000', filter.toString());
    }

    @IsTest 
    static void shouldHandleString() {
        QueryFilter filter = new QueryFilter(Account.Website, QueryFilter.Operator.EQUALS, 'https://www.in-n-out.com');
        System.assertEquals('Website = \'https://www.in-n-out.com\'', filter.toString());
    }

    @IsTest 
    static void shouldHandleListBoolean() {
        List<Boolean> myBools = new List<Boolean>{true, false};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myBools); 
        System.assertEquals('My_Custom_Field__c IN (true, false)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myBools); 
        System.assertEquals('My_Custom_Field__c NOT IN (true, false)', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetBoolean() {
        Set<Boolean> myBools = new Set<Boolean>{true, false};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myBools); 
        System.assertEquals('My_Custom_Field__c IN (true, false)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myBools); 
        System.assertEquals('My_Custom_Field__c NOT IN (true, false)', filter.toString());
    }

    @IsTest 
    static void shouldHandleListDate() {
        List<Date> myDates = new List<Date>{Date.newInstance(2022, 01, 01), Date.newInstance(2022, 02, 02)};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDates);
        System.assertEquals('My_Custom_Field__c IN (2022-01-01, 2022-02-02)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDates);
        System.assertEquals('My_Custom_Field__c NOT IN (2022-01-01, 2022-02-02)', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetDate() {
        Set<Date> myDates = new Set<Date>{Date.newInstance(2022, 01, 01), Date.newInstance(2022, 02, 02)};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDates);
        System.assertEquals('My_Custom_Field__c IN (2022-01-01, 2022-02-02)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDates);
        System.assertEquals('My_Custom_Field__c NOT IN (2022-01-01, 2022-02-02)', filter.toString());
    }

    @IsTest 
    static void shouldHandleListDateTime() {
        List<DateTime> myDts = new List<DateTime>{
            DateTime.newInstanceGmt(2022, 01, 01), 
            DateTime.newInstanceGmt(2022, 02, 02)
        };
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDts);
        System.assertEquals('My_Custom_Field__c IN (2022-01-01T00:00:00Z, 2022-02-02T00:00:00Z)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDts);
        System.assertEquals('My_Custom_Field__c NOT IN (2022-01-01T00:00:00Z, 2022-02-02T00:00:00Z)', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetDateTime() {
        Set<DateTime> myDts = new Set<DateTime>{
            DateTime.newInstanceGmt(2022, 01, 01), 
            DateTime.newInstanceGmt(2022, 02, 02)
        };
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDts);
        System.assertEquals('My_Custom_Field__c IN (2022-01-01T00:00:00Z, 2022-02-02T00:00:00Z)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDts);
        System.assertEquals('My_Custom_Field__c NOT IN (2022-01-01T00:00:00Z, 2022-02-02T00:00:00Z)', filter.toString());
    }

    @IsTest 
    static void shouldHandleListDecimal() {
        List<Decimal> myDecs = new List<Decimal>{1.0, 2.0, 3.0};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDecs);
        System.assertEquals('My_Custom_Field__c IN (1.0, 2.0, 3.0)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDecs);
        System.assertEquals('My_Custom_Field__c NOT IN (1.0, 2.0, 3.0)', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetDecimal() {
        Set<Decimal> myDecs = new Set<Decimal>{1.0, 2.0, 3.0};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDecs);
        System.assertEquals('My_Custom_Field__c IN (1.0, 2.0, 3.0)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDecs);
        System.assertEquals('My_Custom_Field__c NOT IN (1.0, 2.0, 3.0)', filter.toString());
    }

    @IsTest 
    static void shouldHandleListDouble() {
        List<Double> myDubs = new List<Double>{1.0, 2.0, 3.0};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDubs);
        System.assertEquals('My_Custom_Field__c IN (1.0, 2.0, 3.0)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDubs);
        System.assertEquals('My_Custom_Field__c NOT IN (1.0, 2.0, 3.0)', filter.toString());
    }   

    @IsTest 
    static void shouldHandleSetDouble() {
        Set<Double> myDubs = new Set<Double>{1.0, 2.0, 3.0};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myDubs);
        System.assertEquals('My_Custom_Field__c IN (1.0, 2.0, 3.0)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myDubs);
        System.assertEquals('My_Custom_Field__c NOT IN (1.0, 2.0, 3.0)', filter.toString());
    }

    @IsTest 
    static void shouldHandleListId() {
        Id accountId = TestUtils.generateFakeId(Account.SObjectType); 
        Id caseId = TestUtils.generateFakeId(Case.SObjectType);
        List<Id> myIds = new List<Id>{accountId, caseId};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myIds); 
        System.assertEquals('My_Custom_Field__c IN (\'' + accountId + '\', \'' + caseId + '\')', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetId() {
        Id accountId = TestUtils.generateFakeId(Account.SObjectType); 
        Id caseId = TestUtils.generateFakeId(Case.SObjectType);
        Set<Id> myIds = new Set<Id>{accountId, caseId};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myIds); 
        System.assertEquals('My_Custom_Field__c IN (\'' + accountId + '\', \'' + caseId + '\')', filter.toString());
    }

    @IsTest 
    static void shouldHandleListInteger() {
        List<Integer> myInts = new List<Integer>{1, 2, 3};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myInts);
        System.assertEquals('My_Custom_Field__c IN (1, 2, 3)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myInts);
        System.assertEquals('My_Custom_Field__c NOT IN (1, 2, 3)', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetInteger() {
        Set<Integer> myInts = new Set<Integer>{1, 2, 3};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myInts);
        System.assertEquals('My_Custom_Field__c IN (1, 2, 3)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myInts);
        System.assertEquals('My_Custom_Field__c NOT IN (1, 2, 3)', filter.toString());
    }

    @IsTest 
    static void shouldHandleListSObject() {
        // Note: Normal SOQL will accept a list/set of SObjects,
        // but the IN/NOT IN methods can only be used off of Id fields
        // The functionality therefore, should mirror Id list/set methods
        Account account = new Account(
            Id = TestUtils.generateFakeId(Account.SObjectType)
        );
        Case testCase = new Case(
            Id = TestUtils.generateFakeId(Case.SObjectType)
        );
        List<SObject> myRecords = new List<SObject>{account, testCase};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myRecords); 
        System.assertEquals('My_Custom_Field__c IN (\'' + account.Id + '\', \'' + testCase.Id + '\')', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myRecords); 
        System.assertEquals('My_Custom_Field__c NOT IN (\'' + account.Id + '\', \'' + testCase.Id + '\')', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetSObject() {
        // Note: Normal SOQL will accept a list/set of SObjects,
        // but the IN/NOT IN methods can only be used off of Id fields
        // The functionality therefore, should mirror Id list/set methods
        Account account = new Account(
            Id = TestUtils.generateFakeId(Account.SObjectType)
        );
        Case testCase = new Case(
            Id = TestUtils.generateFakeId(Case.SObjectType)
        );
        Set<SObject> myRecords = new Set<SObject>{account, testCase};
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myRecords); 
        System.assertEquals('My_Custom_Field__c IN (\'' + account.Id + '\', \'' + testCase.Id + '\')', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myRecords); 
        System.assertEquals('My_Custom_Field__c NOT IN (\'' + account.Id + '\', \'' + testCase.Id + '\')', filter.toString());
    }

    @IsTest 
    static void shouldHandleListString() {
        List<String> statuses = new List<String>{'New', 'Closed Won'};
        QueryFilter filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.IN_COLLECTION, statuses); 
        System.assertEquals('StageName IN (\'New\', \'Closed Won\')', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.NOT_IN_COLLECTION, statuses); 
        System.assertEquals('StageName NOT IN (\'New\', \'Closed Won\')', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetString() {
        Set<String> statuses = new Set<String>{'New', 'Closed Won'};
        QueryFilter filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.IN_COLLECTION, statuses); 
        System.assertEquals('StageName IN (\'New\', \'Closed Won\')', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.NOT_IN_COLLECTION, statuses); 
        System.assertEquals('StageName NOT IN (\'New\', \'Closed Won\')', filter.toString());
    }

    @IsTest 
    static void shouldHandleListTime() {
        List<Time> myTimes = new List<Time>{
            DateTime.newInstance(2022, 01, 01, 12, 00, 00).time(),
            DateTime.newInstance(2022, 01, 01, 13, 00, 00).time()
        }; 
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myTimes);
        System.assertEquals('My_Custom_Field__c IN (12:00:00.000Z, 13:00:00.000Z)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myTimes);
        System.assertEquals('My_Custom_Field__c NOT IN (12:00:00.000Z, 13:00:00.000Z)', filter.toString());
    }

    @IsTest 
    static void shouldHandleSetTime() {
        Set<Time> myTimes = new Set<Time>{
            DateTime.newInstance(2022, 01, 01, 12, 00, 00).time(),
            DateTime.newInstance(2022, 01, 01, 13, 00, 00).time()
        }; 
        QueryFilter filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.IN_COLLECTION, myTimes);
        System.assertEquals('My_Custom_Field__c IN (12:00:00.000Z, 13:00:00.000Z)', filter.toString());
        // Same results for NOT IN
        filter = new QueryFilter('My_Custom_Field__c', QueryFilter.Operator.NOT_IN_COLLECTION, myTimes);
        System.assertEquals('My_Custom_Field__c NOT IN (12:00:00.000Z, 13:00:00.000Z)', filter.toString());
    }

    @IsTest 
    static void shouldChooseCorrectOperatorIfListTypeValue() {
        List<String> statuses = new List<String>{'New', 'Closed Won'};
        // If you accidentally use EQUALS with a list-type value, will automatically convert to IN
        QueryFilter filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.EQUALS, statuses); 
        System.assertEquals('StageName IN (\'New\', \'Closed Won\')', filter.toString()); 
        // If you accidentally use NOT_EQUALS with a list-type value, will automatically convert to NOT IN
        filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.NOT_EQUALS, statuses); 
        System.assertEquals('StageName NOT IN (\'New\', \'Closed Won\')', filter.toString()); 
    }

    @IsTest 
    static void shouldChooseCorrectOperatorIfSetTypeValue() {
        Set<String> statuses = new Set<String>{'New', 'Closed Won'}; 
        QueryFilter filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.EQUALS, statuses); 
        System.assertEquals('StageName IN (\'New\', \'Closed Won\')', filter.toString()); 
        // Set<String> w/NOT_EQUALS => NOT IN ()
        filter = new QueryFilter(Opportunity.StageName, QueryFilter.Operator.NOT_EQUALS, statuses); 
        System.assertEquals('StageName NOT IN (\'New\', \'Closed Won\')', filter.toString()); 
    }
}