@IsTest
private class SoqlQuery_Test {
    @IsTest 
    static void shouldGenerateSimpleQuery() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType).addFields(Account.OwnerId);
        System.assertEquals('SELECT Id, OwnerId FROM Account', query.getQueryString());
    }

    @IsTest 
    static void shouldGenerateQueryWithOneWhereClause() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFilters(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000));
        System.assertEquals('SELECT Id FROM Account WHERE AnnualRevenue > 1000', query.getQueryString()); 
        checkIfQueryIsValid(query); 
    }

    @IsTest
    static void shouldGenerateQueryWithMultipleWhereClauses() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFilters(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
            .addFilters(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()));
        System.assertEquals(
            'SELECT Id FROM Account WHERE AnnualRevenue > 1000 AND OwnerId = \'' + UserInfo.getUserId() + '\'', 
            query.getQueryString()
        );
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldGenerateQueryWithFilterLogic() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFilters(new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000))
            .addFilters(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
            .addFilters(new Filter(Account.CreatedDate, Filter.LESS_THAN, DateTime.newInstanceGmt(2022, 01, 01)))
            .setFilterLogic('{0} AND ({1} OR {2})');
        final String expected = 
            'SELECT Id FROM Account ' + 
            'WHERE AnnualRevenue > 1000 AND (' + 
                'OwnerId = \'' + UserInfo.getUserId() + '\' OR ' + 
                'CreatedDate < 2022-01-01T00:00:00Z' + 
            ')';
        System.assertEquals(expected, query.getQueryString());
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldGenerateQueryWithParentFields() {
        SoqlQuery query = new SoqlQuery(Opportunity.SObjectType)
            .addFilters(new Filter('Account.AnnualRevenue', Filter.GREATER_THAN, 1000));
        System.assertEquals('SELECT Id FROM Opportunity WHERE Account.AnnualRevenue > 1000', query.getQueryString()); 
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldGenerateQueryWithSpecialTags() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addTags('WITH SECURITY_ENFORCED');
        System.assertEquals('SELECT Id FROM Account WITH SECURITY_ENFORCED', query.getQueryString());
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldAddSingleOrderBy() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .setOrderBy(new QuerySort(Account.AnnualRevenue, QuerySort.Order.ASCENDING));
        System.assertEquals('SELECT Id FROM Account ORDER BY AnnualRevenue ASC', query.getQueryString());
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldAddMultipleOrdersBy() {
        QuerySort orderBy = new QuerySort(
            new List<SObjectField>{Account.AnnualRevenue, Account.CreatedDate}, 
            QuerySort.Order.ASCENDING
        );
        SoqlQuery query = new SoqlQuery(Account.SObjectType).setOrderBy(orderBy);
        System.assertEquals(
            'SELECT Id FROM Account ORDER BY AnnualRevenue, CreatedDate ASC',
            query.getQueryString()
        );
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldAddLimit() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType).setLimit(200); 
        System.assertEquals('SELECT Id FROM Account LIMIT 200', query.getQueryString()); 
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldHandleRelativeDateQuery() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFilters(new Filter(Account.CreatedDate, Filter.EQUALS, 'LAST_N_DAYS:10'));
        System.assertEquals('SELECT Id FROM Account WHERE CreatedDate = LAST_N_DAYS:10', query.getQueryString());
        checkIfQueryIsValid(query); 
    }

    @IsTest 
    static void shouldHandleComplexQuery() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFields(new List<SObjectField>{Account.Id, Account.CreatedDate, Account.Name})
            .addFields('Owner.ProfileId')
            .addFilters(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'))
            .addFilters(new Filter(Account.CreatedDate, Filter.GREATER_THAN, DateTime.newInstanceGmt(2022, 01, 01)))
            .addFilters(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
            .setFilterLogic('{0} AND ({1} OR {2})')
            .setOrderBy(new QuerySort(new List<String>{'CreatedDate', 'AnnualRevenue'}, QuerySort.Order.DESCENDING))
            .setLimit(200)
            .addTags('WITH SECURITY_ENFORCED');
        final String expected = 
            'SELECT Id, CreatedDate, Name, Owner.ProfileId FROM Account ' +
            'WHERE Name LIKE \'Test Account%\' AND (' + 
                'CreatedDate > 2022-01-01T00:00:00Z OR ' + 
                'OwnerId = \'' + UserInfo.getUserId() + '\'' +
            ') ' + 
            'WITH SECURITY_ENFORCED ' +  
            'ORDER BY CreatedDate, AnnualRevenue DESC ' + 
            'LIMIT 200';
        System.assertEquals('"' + expected + '"', '"' + query.getQueryString() + '"'); 
        checkIfQueryIsValid(query); 
    }

    @IsTest
    static void shouldResetQuery() {
        final String filterLogic = '{0} AND ({1} OR {2})';
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFields(new List<SObjectField>{Account.Id, Account.CreatedDate, Account.Name})
            .addFilters(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'))
            .addFilters(new Filter(Account.CreatedDate, Filter.GREATER_THAN, Date.today()))
            .addFilters(new Filter(Account.OwnerId, Filter.EQUALS, UserInfo.getUserId()))
            .setFilterLogic(filterLogic)
            .setOrderBy(new QuerySort(Account.CreatedDate, QuerySort.Order.DESCENDING))
            .setLimit(200)
            .addTags('WITH SECURITY_ENFORCED');
        System.assertEquals(3, query.fields?.size());
        System.assertEquals(3, query.filters?.size());
        System.assertEquals(filterLogic, query.filterLogic);
        System.assertEquals('CreatedDate DESC', query.orderBy?.toString());
        System.assertEquals(200, query.queryLimit); 
        System.assertEquals(1, query.queryTags?.size()); 
        Test.startTest();
        query.reset();
        Test.stopTest();
        System.assertEquals(1, query.fields?.size());
        System.assertEquals(true, query.fields.contains('Id'));
        System.assertEquals(0, query.filters?.size());
        System.assertEquals(null, query.filterLogic);
        System.assertEquals(null, query.orderBy); 
        System.assertEquals(null, query.queryLimit); 
        System.assertEquals(0, query.queryTags?.size()); 
    }

    @IsTest 
    static void shouldReturnSoqlResults() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
        }
        DatabaseLayer.DmlEngine.doInsert(accounts);
        SoqlQuery query = new SoqlQuery(Account.SObjectType)
            .addFields(new List<SObjectField>{Account.Id, Account.CreatedDate, Account.Name})
            .addFilters(new Filter(Account.Name, Filter.STARTS_WITH, 'Test Account'))
            .setOrderBy(new QuerySort(Account.CreatedDate, QuerySort.Order.DESCENDING))
            .setLimit(200);
        Test.startTest();
        List<SObject> results = query.run();
        Test.stopTest();
        System.assertEquals(accounts?.size(), results?.size(), 'Wrong # of results');
        for (Account account : (List<Account>) results) {
            System.assertNotEquals(null, account.Id);
            System.assertNotEquals(null, account.CreatedDate); 
            System.assertNotEquals(null, account.Name);
        }
    }

    @IsTest
    static void shouldGenerateNewQuery() {
        IQueryFactory factory = new SoqlQuery.Factory();
        IQuery query = factory.newQuery(null); 
        System.assertEquals(true, query instanceOf SoqlQuery, 'Wrong type of IQuery generated');
    }

    @IsTest 
    static void shouldThrowErrorIfInvalidQuery() {
        IQuery query = DatabaseLayer.QueryEngine.newQuery(Account.SObjectType).addFields('lajksdf');
        Test.startTest();
        Exception caughtError; 
        try {
            query.run(); 
        } catch (System.QueryException thrownError) {
            caughtError = thrownError; 
        }
        System.assertNotEquals(null, caughtError, 'An error was not thrown for an invalid query');
    }

    @IsTest 
    static void shouldAllowSubqueries() {
        Schema.ChildRelationship contactsRelationship = Describes.getChildRelationship(Account.SObjectType, 'Contacts');
        SubQuery subQuery = new SubQuery(contactsRelationship); 

        Test.startTest();
        SoqlQuery query = new SoqlQuery(Account.SObjectType).addSubQueries(subQuery);
        System.assertEquals('SELECT Id, (SELECT Id FROM Contacts) FROM Account', query.getQueryString(), 'Unexpected query string');
        try {
            query.run();
        } catch (System.QueryException thrownError) {
            System.assert(false, 'Invalid Query: ' + thrownError);
        }
        Test.stopTest();
    }

    @IsTest 
    static void shouldAddAllFields() {
        SoqlQuery query = new SoqlQuery(Account.SObjectType).addAllFields();
        for (SObjectField field : Describes.getSObjectDescribe(Account.SObjectType)?.fields?.getMap()?.values()) {
            String fieldName = String.valueOf(field); 
            System.assert(query.fields?.contains(fieldName), 'Missing field (' + fieldName + '): ' + JSON.serialize(query.fields));
        }
        checkIfQueryIsValid(query); 
    }

    static void checkIfQueryIsValid(SoqlQuery query) {
        try {
            query.run();
        } catch (System.QueryException queryError) {
            System.assert(false, queryError);
        }
    }
}