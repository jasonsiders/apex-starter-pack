@IsTest 
private class RollupMetadataHelper_Test {
    @IsTest  
    static void shouldConstructSimpleRollupFromMdt() {
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        );  

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(new List<Rollup__mdt>{rollupMdt}).getRollups();
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups generated');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject?.toSchemaType(), 'Wrong targetObject'); 
        System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationships'); 
        Rollup.Relationship relationship = rollup.relationships?.values()[0];
        System.assertEquals(1, relationship?.requests?.size(), 'Wrong # of requests');
        Rollup.Request request = relationship?.requests?.values()[0];
        System.assertEquals(Account.AnnualRevenue, request?.targetField?.toSchemaType(), 'Wrong targetField');
        System.assertEquals(true, request?.calculator instanceOf CountCalculator, 'Wrong Calculator type');
        System.assertEquals(0, request?.filters?.size(), 'Wrong # of filters');
    }

    @IsTest 
    static void shouldConstructMultipleRequestsForSameRelationship() {
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>{
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'AnnualRevenue'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'NumberOfEmployees'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'DunsNumber'
            )
        };

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(rollupMdts).getRollups();
        Test.stopTest(); 

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject?.toSchemaType(), 'Wrong targetObject');
        System.assertEquals(1, rollup?.relationships?.size(), 'Wrong # of relationships');
        Rollup.Relationship relationship = rollup?.relationships.values()[0];
        System.assertEquals('Opportunities', relationship?.childRelationship?.toSchemaType()?.getRelationshipName(), 'Wrong relationship name');
        System.assertEquals(rollupMdts?.size(), relationship?.requests?.values()?.size(), 'Wrong # of requests');
    }

    @IsTest 
    static void shouldConstructMultipleRelationshipsForSameRollup() {
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>{
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'AnnualRevenue'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = 'CreatedDate', 
                Calculation_Type__c = 'COUNT',
                Child_SObjectType__c = 'Case', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'AnnualRevenue'
            )
        };

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(rollupMdts).getRollups();
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups generated');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject?.toSchemaType(), 'Wrong targetObject'); 
        System.assertEquals(2, rollup.relationships?.size(), 'Wrong # of relationships'); 
        for (Rollup.Relationship relationship : rollup?.relationships.values()) {
            System.assertEquals(1, relationship?.requests?.values()?.size(), 'Wrong # of requests: ' + relationship?.requests?.values());
        }
    }

    @IsTest 
    static void shouldConstructMultipleRollups() {
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>();
        rollupMdts.add(new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null,
            Calculation_Type__c = 'COUNT',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        ));
        rollupMdts.add(new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null,
            Calculation_Type__c = 'COUNT',
            Child_SObjectType__c = 'Task',
            Parent_SObjectType__c = 'Lead',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'NumberOfEmployees'
        ));

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(rollupMdts).getRollups();
        Test.stopTest();

        System.assertEquals(2, rollups?.size(), 'Wrong # of rollups');
        for (Rollup rollup : rollups) {
            System.assertEquals(1, rollup?.relationships?.values().size(), 'Wrong # of relationships');
            System.assertEquals(1, rollup?.relationships?.values()[0]?.requests?.size(), 'Wrong # of requests');
        }
    }

    @IsTest 
    static void shouldConstructRollupWithFiltersFromMdt() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        ); 
        Databaselayer.Dml.doInsert(rollupMdt);
        Filter__mdt filterMdt = new Filter__mdt(
            Operator__c = 'EQUALS',
            SObjectField__c = 'StageName',
            SObjectType__c = 'Opportunity',
            Value__c = '"Closed Won"'
        ); 
        Databaselayer.Dml.doInsert(filterMdt);
        Rollup_Filter__mdt rollupFilterMdt = new Rollup_Filter__mdt(Active__c = true);
        rollupFilterMdt = (Rollup_Filter__mdt) SObjectUtils.setLookupField(
            rollupFilterMdt, 
            Rollup_Filter__mdt.Filter__c, 
            filterMdt
        ); 
        Databaselayer.Dml.doInsert(rollupFilterMdt);
        rollupMdt = (Rollup__mdt) SObjectUtils.setRelatedList(
            rollupMdt, 
            SchemaUtils.getChildRelationship(Rollup_Filter__mdt.Rollup__c),
            new List<Rollup_Filter__mdt>{rollupFilterMdt}
        );

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(new List<Rollup__mdt>{rollupMdt}).getRollups();
        Test.stopTest();
            
        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups generated');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject?.toSchemaType(), 'Wrong targetObject'); 
        System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationships'); 
        Rollup.Relationship relationship = rollup.relationships?.values()[0];
        System.assertEquals(1, relationship?.requests?.values()?.size(), 'Wrong # of requests');
        Rollup.Request request = relationship?.requests?.values()[0];
        System.assertEquals(Account.AnnualRevenue, request?.targetField?.toSchemaType(), 'Wrong targetField');
        System.assertEquals(true, request?.calculator instanceOf CountCalculator, 'Wrong Calculator type');
        System.assertEquals(1, request?.filters?.size(), 'Wrong # of filters');
        Filter filterObj = request?.filters[0];
        System.assertEquals('StageName = \'Closed Won\'', request?.filters[0]?.toString(), 'Wrong filter');
    }

    @IsTest 
    static void shouldIgnoreInactiveFilters() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        ); 
        Databaselayer.Dml.doInsert(rollupMdt);
        List<Filter__mdt> filterMdts = new List<Filter__mdt>{
            new Filter__mdt(
                Operator__c = 'EQUALS',
                SObjectField__c = 'StageName',
                SObjectType__c = 'Opportunity',
                Value__c = '"Closed Won"'
            ),
            new Filter__mdt(
                Operator__c = 'GREATER_THAN',
                SObjectField__c = 'Amount',
                SObjectTYpe__c = 'Opportunity',
                Value__c = '1000'
            ), 
            new Filter__mdt(
                Operator__c = 'NOT_EQUALS',
                SObjectField__c = 'CloseDate',
                SObjectType__c = 'Opportunity',
                Value__c = '"2022-01-01"'
            )
        };
        Databaselayer.Dml.doInsert(filterMdts);
        List<Rollup_Filter__mdt> rollupFilterMdts = new List<Rollup_Filter__mdt>();
        for (Integer i = 0; i < filterMdts?.size(); i++) {
            Filter__mdt filterMdt = filterMdts[i];
            Rollup_Filter__mdt rollupFilter = new Rollup_Filter__mdt(
                // Only 2/3 should be added to the request; 1st one is inactive
                Active__c = (i == 0) ? false : true
            );
            rollupFilter = (Rollup_Filter__mdt) SObjectUtils.setLookupField(rollupFilter, Rollup_Filter__mdt.Filter__c, filterMdt);
            rollupFilterMdts.add(rollupFilter);
        }
        Databaselayer.Dml.doInsert(rollupFilterMdts);
        rollupmdt = (Rollup__mdt) SObjectUtils.setRelatedList(
            rollupMdt, 
            SchemaUtils.getChildRelationship(Rollup_Filter__mdt.Rollup__c),
            rollupFilterMdts
        );

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(new List<Rollup__mdt>{rollupMdt}).getRollups();
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups');
        System.assertEquals(1, rollups[0].relationships?.size(), 'Wrong # of relationships');
        System.assertEquals(1, rollups[0].relationships?.values()[0]?.requests?.size(), 'Wrong # of requests');
        System.assertEquals(rollupFilterMdts?.size() - 1, rollups[0].relationships?.values()[0].requests?.values()[0].filters?.size(), 'Wrong # of filters');
    }

    @IsTest 
    static void shouldUseCustomCalculator() {
        String calculatorClassName = 'CountCalculator';
        // Note: Normally, you'd define your own calculator class here
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = 'Amount',
            Calculator_Class_Name__c = calculatorClassName,
            Calculation_Type__c = null,
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        ); 

        Test.startTest();
        List<Rollup> rollups = new RollupMetadataHelper(new List<Rollup__mdt>{rollupMdt}).getRollups();
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of Rollups');
        Rollup rollup = rollups[0];
        System.assertEquals(1, rollup?.relationships?.size(), 'Wrong # of relationships');
        Rollup.Relationship relationship = rollup?.relationships?.values()[0];
        System.assertEquals(1, relationship.requests?.size(), 'Wrong # of requests');
        Rollup.Request request = relationship?.requests?.values()[0];
        System.assertNotEquals(null, request?.calculator, 'Null calculator'); 
        System.assertEquals(true, request?.calculator instanceOf CountCalculator, 'Wrong calculator type');
    }

    @IsTest 
    static void shouldGetMdtRollupsForUseInTrigger() {
        // This demonstrates one potential use of this class; 
        // quickly/easily generating Rollups from MDT to run in a trigger
        DatabaseLayer.setDmlEngine(new DmlMock());
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>{
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = 'Amount',
                Calculation_Type__c = 'SUM',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'AnnualRevenue'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Type__c = 'COUNT',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Relationship_Field__c = 'AccountId',
                Target_Field__c = 'NumberOfEmployees'
            )
        };
        Databaselayer.Dml.doInsert(rollupMdts);
        Filter__mdt oppIsClosedFilter = new Filter__mdt(
            Operator__c = 'EQUALS',
            SObjectField__c = 'IsClosed',
            SObjectType__c = 'Opportunity',
            Value__c = 'true'
        );
        Databaselayer.Dml.doInsert(oppIsClosedFilter);
        List<Rollup__mdt> rollupRecords = new List<Rollup__mdt>(); 
        for (Rollup__mdt rollupMdt : rollupMdts) {
            Rollup_Filter__mdt rollupFilter = new Rollup_Filter__mdt(Active__c = true);
            rollupFilter = (Rollup_Filter__mdt) SObjectUtils.setLookupField(rollupFilter, Rollup_Filter__mdt.Rollup__c, rollupMdt);
            rollupFilter = (Rollup_Filter__mdt) SObjectUtils.setLookupField(rollupFilter, Rollup_Filter__mdt.Filter__c, oppIsClosedFilter); 
            rollupRecords?.add((Rollup__mdt) SObjectUtils.setRelatedList(
                rollupMdt, 
                SchemaUtils.getChildRelationship(Rollup_Filter__mdt.Rollup__c),
                new List<Rollup_Filter__mdt>{rollupFilter}
            ));
        }
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollupRecords); 

        Test.startTest();
        Soql mdtQuery = RollupMetadataHelper.BaseQuery.whereFilters(new Filter(
            Rollup__mdt.Child_SObjectType__c,
            Filter.EQUALS,
            String.valueOf(Opportunity.SObjectType)
        ));
        List<Rollup__mdt> queryResults = (List<Rollup__mdt>) mdtQuery.run();
        List<Rollup> rollups = new RollupMetadataHelper(queryResults).getRollups(); 
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups'); 
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup?.targetObject?.toSchemaType(), 'Wrong targetObject'); 
        System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationships'); 
        Rollup.Relationship relationship = rollups[0].relationships?.values()[0];
        System.assertEquals('Opportunities', relationship?.childRelationship?.toSchemaType()?.getRelationshipName(), 'Wrong ChildRelationship');
        System.assertEquals(2, relationship?.requests?.values()?.size(), 'Wrong # of requests');
        for (Rollup.Request request : relationship?.requests?.values()) {
            System.assertEquals(1, request?.filters?.size(), 'Wrong # of filters');
            System.assertEquals('IsClosed = true', request?.filters[0]?.toString(), 'Wrong filter'); 
            if (request?.targetField?.toSchemaType() == Account.AnnualRevenue) {
                System.assertEquals(true, request?.calculator instanceOf SumCalculator, 'Wrong type of calculator: ' + TypeUtils.getTypeName(request?.calculator));
            } else if (request?.targetField?.toSchemaType() == Account.NumberOfEmployees) {
                System.assertEquals(true, request?.calculator instanceOf CountCalculator, 'Wrong type of calculator: ' + TypeUtils.getTypeName(request?.calculator));
            } else {
                System.assert(false, 'Unexpected target field: ' + request?.targetField + ': Request: ' + request);
            }
        }
    }

    @IsTest 
    static void shouldProvideBaseQuery() {
        Soql query = RollupMetadataHelper.BaseQuery; 
        List<Rollup__mdt> results; 

        Test.startTest(); 
        try {
            results = query.run(); 
        } catch (System.QueryException thrownError) {
            System.assert(false, 'Invalid query: ' + thrownError); 
        }
        Test.stopTest(); 

        // Note: We can't insert MDT directly from apex, so we can't guarantee results will be returned w/out mocking
        // This query should still return the same # of results as the below SOQL
        System.assertEquals([SELECT Id FROM Rollup__mdt WHERE Active__c = true]?.size(), results?.size(), 'Wrong # of results');
    }

    // **** HELPER **** // 
    @TestSetup 
    static void setup() {
        Account account = new Account(Name = 'Test Account');
        Databaselayer.Dml.doInsert(account); 
        List<Opportunity> opportunities = new List<Opportunity>(); 
        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(
                AccountId = account.Id,
                Amount = 1000,
                CloseDate = Date.today(),
                Name = 'Test Opportunity #' + (i + 1),
                StageName = 'New'
            ));
        }
        Databaselayer.Dml.doInsert(opportunities); 
    }
}
