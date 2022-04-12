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
}