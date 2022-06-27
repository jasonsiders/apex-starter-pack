@IsTest 
private class InvocableRollup_Test {
    @IsTest 
    static void shouldPerformSingleChildRollup() {
        setMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.CHILD); 
        input.records = account.Opportunities;
        input.rollup = rollupMdt;

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldPerformMultipleChildRollupsForSameParentSObject() {
        setMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, rollups);

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.CHILD); 
        input.records = account.Opportunities; 
        input.rollups = rollups;

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
        System.assertEquals(Decimal.valueOf(numOpps) - 1, account.NumberOfEmployees, 'Wrong COUNT of Closed Won Opportunities');
    }

    @IsTest 
    static void shouldPerformAllChildRollups() {
        setMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, rollups);
        
        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.CHILD); 
        input.records = account.Opportunities;
        // If no Rollup__mdts are defined, the method will query for & process all with a matching Parent_SObjectType__c
        input.rollup = null;
        input.rollups = null; 

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
        System.assertEquals(Decimal.valueOf(numOpps) - 1, account.NumberOfEmployees, 'Wrong COUNT of Closed Won Opportunities');
    }

    @IsTest 
    static void shouldPerformSingleParentRollup() {
        setMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.record = account; 
        input.rollup = rollupMdt;

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldPerformMultipleParentRollups() {
        setMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, rollups);

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.record = account; 
        input.rollups = rollups;

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
        System.assertEquals(Decimal.valueOf(numOpps) - 1, account.NumberOfEmployees, 'Wrong COUNT of Closed Won Opportunities');
    }

    @IsTest 
    static void shouldPerformAllParentRollups() {
        setMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, rollups);
        
        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.record = account;
        // If no Rollup__mdts are defined, the method will query for & process all with a matching Parent_SObjectType__c
        input.rollup = null;
        input.rollups = null; 

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
        System.assertEquals(Decimal.valueOf(numOpps) - 1, account.NumberOfEmployees, 'Wrong COUNT of Closed Won Opportunities');

    }

    @IsTest 
    static void shouldRunAsync() {
        setMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        // Since DML Behavior is ASYNC, everything will be done in a Queueable, later
        input.timing = String.valueOf(InvocableRollup.Timing.ASYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.record = account; 
        input.rollup = rollupMdt;

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldPerformRollupFromId() {
        setMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        SoqlMock.setMockResults(RollupMetadataHelper.BASE_QUERY_KEY, new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        // Since DML Behavior is ASYNC, everything will be done in a Queueable, later
        input.timing = String.valueOf(InvocableRollup.Timing.ASYNCHRONOUS);
        input.rollupContext = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.recordId = account.Id;
        input.rollup = rollupMdt;

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldThrowErrorForInvalidMdtFields() {
        setMocks(); 
        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        DatabaseLayer.DmlEngine.doInsert(account); 
        DmlMock.resetHistory(); 
        SoqlMock.setMockResults(Rollup.ROLLUP_QUERY, new List<Account>{account});

        Rollup__mdt template = new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = 'Amount',
            Calculation_Type__c = 'SUM',
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        ); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>();
        for (SObjectField metadataField : new List<SObjectField>{
            Rollup__mdt.Calculation_Field__c,
            Rollup__mdt.Child_Relationship_Name__c,
            Rollup__mdt.Child_SObjectType__c,
            Rollup__mdt.Parent_SObjectType__c,
            Rollup__mdt.Relationship_Field__c,
            Rollup__mdt.Target_Field__c
        }) {
            Rollup__mdt withNullField = template.clone(); 
            withNullField.put(metadataField, null);
            rollups.add(withNullField); 

            Rollup__mdt withInvalidField = template.clone(); 
            withInvalidField.put(metadataField, 'asdf'); 
            rollups.add(withInvalidField); 
        }

        Test.startTest();
        for (Rollup__mdt rollup : rollups) {
            InvocableRollup.Input input = new InvocableRollup.Input();
            input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
            input.rollupContext = String.valueOf(InvocableRollup.RollupContext.PARENT); 
            input.record = account; 
            input.rollup = rollup;

            Exception caughtError;
            try {
                InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
            } catch (InvocableRollup.InvalidInputException thrownError) {
                caughtError = thrownError; 
            }
            System.assertNotEquals(null, caughtError, 'An error was not thrown/caught');
        }
        Test.stopTest();
    }

    // **** HELPER **** //
    static void setMocks() {
        DatabaseLayer.setDmlEngine(new DmlMock()); 
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory()); 
    } 

    static Rollup__mdt getAccountRollup(SObjectField targetField, Boolean withFilters) {
        // Create the Rollup record
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = String.valueOf(targetField)
        );
        // Add Rollup Filters to the Rollup__mdt
        List<Rollup_Filter__mdt> rollupFilters = new List<Rollup_Filter__mdt>(); 
        if (withFilters) {
            Filter__mdt closedWonFilter = new Filter__mdt(
                Operator__c = 'EQUALS',
                SObjectField__c = 'StageName',
                SObjectType__c = 'Opportunity',
                Value__c = '"Closed Won"'
            );
            Rollup_Filter__mdt rollupFilter = (Rollup_Filter__mdt) ObjectUtils.setLookupField(
                new Rollup_Filter__mdt(Active__c = true),
                Rollup_Filter__mdt.Filter__c,
                closedWonFilter
            );
            rollupFilters.add(rollupFilter); 
        }
        return (Rollup__mdt) ObjectUtils.setReadOnlyField(
            rollupMdt, 
            'Rollup_Filters__r', 
            rollupFilters
        );
    }

    static Rollup__mdt getCampaignRollup(SObjectField targetField) {
        Rollup__mdt rollup = new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
            Child_Relationship_Name__c = 'Opportunities',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Campaign',
            Relationship_Field__c = 'CampaignId',
            Target_Field__c = String.valueOf(targetField)
        );
        return rollup; 
    }

    static Account getTestAccount(Integer numOpps) {
        Account account = new Account(Name = 'Test Account');
        Campaign campaign = new Campaign(Name = 'Test Campaign');
        DatabaseLayer.DmlEngine.doInsert(new List<SObject>{account, campaign}); 
        List<Opportunity> opportunities = new List<Opportunity>(); 
        for (Integer i = 0; i < numOpps; i++) {
            opportunities.add(new Opportunity(
                AccountId = account.Id,
                CampaignId = campaign.Id,
                Name = 'Test Opportunity #' + i,
                StageName = 'Closed Won'
            ));
        }
        // One of the opportunities will NOT be closed won
        opportunities[0].StageName = 'New';
        DatabaseLayer.DmlEngine.doInsert(opportunities); 
        return (Account) ObjectUtils.setReadOnlyField(account, 'Opportunities', opportunities); 
    }
}
