@IsTest
private class Rollup_Test {
    @IsTest 
    static void shouldRunFromParent() {
        Soql accountQuery = DatabaseLayer.QueryEngine.newQuery(Account.SObjectType)
            .selectSubQuery(new SubQuery(Account.SObjectType, 'Opportunities'));
        List<Account> accounts = (List<Account>) accountQuery.run();

        Test.startTest(); 
        Rollup rollup = getSumCalculator(); 
        List<Account> results = (List<Account>) rollup.run(accounts); 
        Test.stopTest();

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(3000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount'); 
    }

    @IsTest 
    static void shouldRunFromChild() {
        Soql oppQuery = DatabaseLayer.QueryEngine.newQuery(Opportunity.SObjectType).selectFields(Opportunity.AccountId);
        List<Opportunity> opportunities = (List<Opportunity>) oppQuery.run(); 

        Test.startTest();
        Rollup rollup = getSumCalculator(); 
        List<Account> results = (List<Account>) rollup.runFromChild(opportunities, Opportunity.AccountId); 
        Test.stopTest();

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(3000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount'); 
    }

    @IsTest 
    static void shouldFilterRecords() {
        Soql oppQuery = DatabaseLayer.QueryEngine.newQuery(Opportunity.SObjectType).selectFields(Opportunity.AccountId);
        List<Opportunity> opportunities = (List<Opportunity>) oppQuery.run(); 
        // Update one of the Opportunities amounts to 0
        Set<Id> accountIds = new Set<Id>();
        Opportunity invalidOpp = opportunities[0];
        accountIds.add(invalidOpp.AccountId); 
        invalidOpp.Amount = 0; 
        DatabaseLayer.DmlEngine.doUpdate(invalidOpp); 

        Test.startTest(); 
        Rollup rollup = new Rollup(Account.SObjectType).addRelationship(
            new Rollup.Relationship(
                'Account',
                'Opportunities'
            ).addRequest(new Rollup.Request(
                Account.AnnualRevenue,
                new SumCalculator()?.setCalcField(Opportunity.Amount)
            ).addFilters(new Filter(
                Opportunity.Amount, 
                Filter.GREATER_THAN,
                0
            )))
        );
        List<Account> results = (List<Account>) rollup.run(accountIds);
        Test.stopTest(); 

        System.assertEquals(1, results?.size(), 'Wrong # of results');
        System.assertEquals(2000, results[0].AnnualRevenue, 'Wrong sum of Opportunity.Amount (where Amount > 0)');
    }

    @IsTest 
    static void shouldConstructSimpleRollupFromMdt() {
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Target_Field__c = 'Account.AnnualRevenue'
        ); 

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(new List<Rollup__mdt>{rollupMdt});
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups generated');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject, 'Wrong targetObject'); 
        System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationships'); 
        Rollup.Relationship relationship = rollup.relationships[0];
        System.assertEquals(rollupMdt.Child_Relationship_Name__c, relationship?.childRelationship?.getRelationshipName(), 'Wrong child relationship');
        System.assertEquals(1, relationship?.requests?.size(), 'Wrong # of requests');
        Rollup.Request request = relationship?.requests[0];
        System.assertEquals(Account.AnnualRevenue, request?.targetField, 'Wrong targetField');
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
                Child_Relationship_Name__c = 'Opportunities',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.AnnualRevenue'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_Relationship_Name__c = 'Opportunities',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.NumberOfEmployees'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_Relationship_Name__c = 'Opportunities',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.DunsNumber'
            )
        };

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(rollupMdts);
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject, 'Wrong targetObject');
        System.assertEquals(1, rollup?.relationships?.size(), 'Wrong # of relationships');
        Rollup.Relationship relationship = rollup?.relationships[0];
        System.assertEquals('Opportunities', relationship?.childRelationship?.getRelationshipName(), 'Wrong relationship name');
        System.assertEquals(rollupMdts?.size(), relationship?.requests?.size(), 'Wrong # of requests');
    }

    @IsTest 
    static void shouldConstructMultipleRelationshipsForSameRollup() {
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>{
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = null, 
                Calculation_Type__c = 'COUNT',
                Child_Relationship_Name__c = 'Opportunities',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.AnnualRevenue'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = 'Case.CreatedDate', 
                Calculation_Type__c = 'COUNT',
                Child_Relationship_Name__c = 'Cases',
                Child_SObjectType__c = 'Case', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.AnnualRevenue'
            )
        };

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(rollupMdts);
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups generated');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject, 'Wrong targetObject'); 
        System.assertEquals(2, rollup.relationships?.size(), 'Wrong # of relationships'); 
        for (Rollup.Relationship relationship : rollup?.relationships) {
            System.assertEquals(1, relationship?.requests?.size(), 'Wrong # of requests: ' + relationship?.requests);
        }
    }

    @IsTest 
    static void shouldConstructMultipleRollups() {
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>();
        rollupMdts.add(new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null,
            Calculation_Type__c = 'COUNT',
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Target_Field__c = 'Account.AnnualRevenue'
        ));
        rollupMdts.add(new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null,
            Calculation_Type__c = 'COUNT',
            Child_Relationship_Name__c = 'Tasks',
            Child_SObjectType__c = 'Task',
            Parent_SObjectType__c = 'Lead',
            Target_Field__c = 'Lead.NumberOfEmployees'
        ));

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(rollupMdts);
        Test.stopTest();

        System.assertEquals(2, rollups?.size(), 'Wrong # of rollups');
        for (Rollup rollup : rollups) {
            System.assertEquals(1, rollup?.relationships?.size(), 'Wrong # of relationships');
            System.assertEquals(1, rollup?.relationships[0]?.requests?.size(), 'Wrong # of requests');
        }
    }

    @IsTest 
    static void shouldConstructRollupWithFiltersFromMdt() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Target_Field__c = 'Account.AnnualRevenue'
        ); 
        DatabaseLayer.DmlEngine.doInsert(rollupMdt);
        Filter__mdt filterMdt = new Filter__mdt(
            Operator__c = 'EQUALS',
            SObjectField__c = 'Opportunity.StageName',
            SObjectType__c = 'Opportunity',
            Value__c = '"Closed Won"'
        );
        DatabaseLayer.DmlEngine.doInsert(filterMdt);
        Rollup_Filter__mdt rollupFilterMdt = new Rollup_Filter__mdt(Active__c = true);
        rollupFilterMdt = (Rollup_Filter__mdt) ObjectUtils.setLookupField(
            rollupFilterMdt, 
            Rollup_Filter__mdt.Filter__c, 
            filterMdt
        ); 
        DatabaseLayer.DmlEngine.doInsert(rollupFilterMdt);
        rollupMdt = (Rollup__mdt) ObjectUtils.setReadOnlyField(
            rollupMdt, 
            'Rollup_Filters__r', 
            new List<Rollup_Filter__mdt>{rollupFilterMdt}
        );

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(new List<Rollup__mdt>{rollupMdt});
        Test.stopTest();
            
        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups generated');
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup.targetObject, 'Wrong targetObject'); 
        System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationships'); 
        Rollup.Relationship relationship = rollup.relationships[0];
        System.assertEquals(rollupMdt.Child_Relationship_Name__c, relationship?.childRelationship?.getRelationshipName(), 'Wrong child relationship');
        System.assertEquals(1, relationship?.requests?.size(), 'Wrong # of requests');
        Rollup.Request request = relationship?.requests[0];
        System.assertEquals(Account.AnnualRevenue, request?.targetField, 'Wrong targetField');
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
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Target_Field__c = 'Account.AnnualRevenue'
        ); 
        DatabaseLayer.DmlEngine.doInsert(rollupMdt);
        List<Filter__mdt> filterMdts = new List<Filter__mdt>{
            new Filter__mdt(
                Operator__c = 'EQUALS',
                SObjectField__c = 'Opportunity.StageName',
                SObjectType__c = 'Opportunity',
                Value__c = '"Closed Won"'
            ),
            new Filter__mdt(
                Operator__c = 'GREATER_THAN',
                SObjectField__c = 'Opportunity.Amount',
                SObjectTYpe__c = 'Opportunity',
                Value__c = '1000'
            ), 
            new Filter__mdt(
                Operator__c = 'NOT_EQUALS',
                SObjectField__c = 'Opportunity.CloseDate',
                SObjectType__c = 'Opportunity',
                Value__c = '"2022-01-01"'
            )
        };
        DatabaseLayer.DmlEngine.doInsert(filterMdts);
        List<Rollup_Filter__mdt> rollupFilterMdts = new List<Rollup_Filter__mdt>();
        for (Integer i = 0; i < filterMdts?.size(); i++) {
            Filter__mdt filterMdt = filterMdts[i];
            Rollup_Filter__mdt rollupFilter = new Rollup_Filter__mdt(
                // Only 2/3 should be added to the request; 1st one is inactive
                Active__c = (i == 0) ? false : true
            );
            rollupFilter = (Rollup_Filter__mdt) ObjectUtils.setLookupField(rollupFilter, Rollup_Filter__mdt.Filter__c, filterMdt);
            rollupFilterMdts.add(rollupFilter);
        }
        DatabaseLayer.DmlEngine.doInsert(rollupFilterMdts);
        rollupmdt = (Rollup__mdt) ObjectUtils.setReadOnlyField(
            rollupMdt, 
            'Rollup_Filters__r', 
            rollupFilterMdts
        );

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(new List<Rollup__mdt>{rollupMdt});
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups');
        System.assertEquals(1, rollups[0].relationships?.size(), 'Wrong # of relationships');
        System.assertEquals(1, rollups[0].relationships[0]?.requests?.size(), 'Wrong # of requests');
        System.assertEquals(rollupFilterMdts?.size() - 1, rollups[0].relationships[0].requests[0].filters?.size(), 'Wrong # of filters');
    }

    @IsTest 
    static void shouldUseCustomCalculator() {
        String calculatorClassName = 'CountCalculator';
        // Note: Normally, you'd define your own calculator class here
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = 'Opportunity.Amount',
            Calculator_Class_Name__c = calculatorClassName,
            Calculation_Type__c = null,
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Target_Field__c = 'Account.AnnualRevenue'
        ); 

        Test.startTest();
        List<Rollup> rollups = Rollup.generateFromMetadata(new List<Rollup__mdt>{rollupMdt});
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of Rollups');
        Rollup rollup = rollups[0];
        System.assertEquals(1, rollup?.relationships?.size(), 'Wrong # of relationships');
        Rollup.Relationship relationship = rollup?.relationships[0];
        System.assertEquals(1, relationship.requests?.size(), 'Wrong # of requests');
        Rollup.Request request = relationship?.requests[0];
        System.assertNotEquals(null, request?.calculator, 'Null calculator'); 
        System.assertEquals(true, request?.calculator instanceOf CountCalculator, 'Wrong calculator type');
    }

    @IsTest 
    static void shouldThrowErrorForInvalidCalculatorClass() {
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Calculation_Field__c = 'Opportunity.Amount',
            Calculator_Class_Name__c = 'Fake class 123',
            Calculation_Type__c = null,
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Target_Field__c = 'Account.AnnualRevenue'
        ); 

        Test.startTest();
        Exception caughtError; 
        List<Rollup> rollups;
        try {
            rollups = Rollup.generateFromMetadata(new List<Rollup__mdt>{rollupMdt});
        } catch (Rollup.RollupException thrownError) {
            caughtError = thrownError; 
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught: ' + rollups);
    }

    @IsTest 
    static void shouldProvideDefaultCalculatorValues() {
        List<Opportunity> opportunities = new List<Opportunity>();
        Rollup.Calculator calc = new MockCalculator(); 
        calc.setCalcField(Opportunity.IsClosed); 
        System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for Boolean');
        calc.setCalcField(Opportunity.CloseDate);
        System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for Date');
        calc.setCalcField(Opportunity.CreatedDate); 
        System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for DateTime');
        calc.setCalcField(Opportunity.Amount);
        System.assertEquals(0, calc.calculate(opportunities), 'Wrong default value for Number');
        calc.setCalcField(Opportunity.Name); 
        System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for Text');
        calc.setCalcField(null); 
        System.assertEquals(null, calc.calculate(opportunities), 'Wrong default value for null calcField');
    }

    @IsTest 
    static void shouldGetMdtRollupsForUseInTrigger() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>{
            new Rollup__mdt(
                Active__c = true,
                Calculation_Field__c = 'Opportunity.Amount',
                Calculation_Type__c = 'SUM',
                Child_Relationship_Name__c = 'Opportunities',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.AnnualRevenue'
            ),
            new Rollup__mdt(
                Active__c = true,
                Calculation_Type__c = 'COUNT',
                Child_Relationship_Name__c = 'Opportunities',
                Child_SObjectType__c = 'Opportunity', 
                Parent_SObjectType__c = 'Account',
                Target_Field__c = 'Account.NumberOfEmployees'
            )
        };
        DatabaseLayer.DmlEngine.doInsert(rollupMdts);
        Filter__mdt oppIsClosedFilter = new Filter__mdt(
            Operator__c = 'EQUALS',
            SObjectField__c = 'Opportunity.IsClosed',
            SObjectType__c = 'Opportunity',
            Value__c = 'true'
        );
        DatabaseLayer.DmlEngine.doInsert(oppIsClosedFilter);
        List<Rollup__mdt> rollupRecords = new List<Rollup__mdt>(); 
        for (Rollup__mdt rollupMdt : rollupMdts) {
            Rollup_Filter__mdt rollupFilter = new Rollup_Filter__mdt(Active__c = true);
            rollupFilter = (Rollup_Filter__mdt) ObjectUtils.setLookupField(rollupFilter, Rollup_Filter__mdt.Rollup__c, rollupMdt);
            rollupFilter = (Rollup_Filter__mdt) ObjectUtils.setLookupField(rollupFilter, Rollup_Filter__mdt.Filter__c, oppIsClosedFilter); 
            rollupRecords?.add((Rollup__mdt) ObjectUtils.setReadOnlyField(
                rollupMdt, 
                'Rollup_Filters__r', 
                new List<Rollup_Filter__mdt>{rollupFilter}
            ));
        }
        SoqlMock.setMockResults(Rollup.MDT_QUERY_KEY, rollupRecords); 

        Test.startTest();
        List<Rollup> rollups = Rollup.getRollupsForTrigger(Opportunity.SObjectType); 
        Test.stopTest();

        System.assertEquals(1, rollups?.size(), 'Wrong # of rollups'); 
        Rollup rollup = rollups[0];
        System.assertEquals(Account.SObjectType, rollup?.targetObject, 'Wrong targetObject'); 
        System.assertEquals(1, rollup.relationships?.size(), 'Wrong # of relationships'); 
        Rollup.Relationship relationship = rollups[0].relationships[0];
        System.assertEquals('Opportunities', relationship?.childRelationship?.getRelationshipName(), 'Wrong ChildRelationship');
        System.assertEquals(2, relationship?.requests?.size(), 'Wrong # of requests');
        for (Rollup.Request request : relationship?.requests) {
            System.assertEquals(1, request?.filters?.size(), 'Wrong # of filters');
            System.assertEquals('IsClosed = true', request?.filters[0]?.toString(), 'Wrong filter'); 
            if (request?.targetField == Account.AnnualRevenue) {
                System.assertEquals(true, request?.calculator instanceOf SumCalculator, 'Wrong type of calculator: ' + TypeUtils.getTypeName(request?.calculator));
            } else if (request?.targetField == Account.NumberOfEmployees) {
                System.assertEquals(true, request?.calculator instanceOf CountCalculator, 'Wrong type of calculator: ' + TypeUtils.getTypeName(request?.calculator));
            } else {
                System.assert(false, 'Unexpected target field: ' + request?.targetField + ': Request: ' + request);
            }
        }
    }

    // **** HELPER **** // 
    @TestSetup 
    static void setup() {
        Account account = new Account(Name = 'Test Account');
        DatabaseLayer.DmlEngine.doInsert(account); 
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
        DatabaseLayer.DmlEngine.doInsert(opportunities); 
    }

    private static Rollup getSumCalculator() {
        return new Rollup(Account.SObjectType).addRelationship(
            new Rollup.Relationship(
                'Account',
                'Opportunities'
            ).addRequest(new Rollup.Request(
                Account.AnnualRevenue,
                new SumCalculator()?.setCalcField(Opportunity.Amount)
            ))
        );
    }

    // **** INNER **** // 
    public class MockCalculator extends Rollup.Calculator {}
}
