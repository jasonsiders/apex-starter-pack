@IsTest 
private class InvocableRollup_Test {
    @IsTest 
    static void shouldPerformSingleChildRollup() {
        setDatabaseMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.CHILD); 
        input.records = account.Opportunities;
        input.rollups = new List<Rollup__mdt>{rollupMdt};

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldPerformMultipleChildRollupsForSameParentSObject() {
        setDatabaseMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollups);

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.CHILD); 
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
        setDatabaseMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollups);
        
        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.CHILD); 
        input.records = account.Opportunities;
        // If no Rollup__mdts are defined, the method will query for & process all with a matching Parent_SObjectType__c
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
        setDatabaseMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.records = new List<Account>{account}; 
        input.rollups = new List<Rollup__mdt>{rollupMdt};

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldPerformMultipleParentRollups() {
        setDatabaseMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollups);

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.records = new List<Account>{account}; 
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
        setDatabaseMocks(); 
        Rollup__mdt withoutFilter = getAccountRollup(Account.AnnualRevenue, false); 
        Rollup__mdt withFilter = getAccountRollup(Account.NumberOfEmployees, true); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{withFilter, withoutFilter};
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollups);
        
        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory();

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        input.timing = String.valueOf(InvocableRollup.Timing.SYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.records = new List<Account>{account};
        // If no Rollup__mdts are defined, the method will query for & process all with a matching Parent_SObjectType__c
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
        setDatabaseMocks(); 
        Rollup__mdt rollupMdt = getAccountRollup(Account.AnnualRevenue, false); 
        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(new List<Rollup__mdt>{rollupMdt});

        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});
        DmlMock.resetHistory(); 

        InvocableRollup.Input input = new InvocableRollup.Input(); 
        // Since DML Behavior is ASYNC, everything will be done in a Queueable, later
        input.timing = String.valueOf(InvocableRollup.Timing.ASYNCHRONOUS);
        input.context = String.valueOf(InvocableRollup.RollupContext.PARENT); 
        input.records = new List<Account>{account}; 
        input.rollups = new List<Rollup__mdt>{rollupMdt};

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(account), 'Account was not updated'); 
        System.assertEquals(Decimal.valueOf(numOpps), account.AnnualRevenue, 'Wrong COUNT of Opportunities');
    }

    @IsTest 
    static void shouldHandleMultipleInputsOfSameType() {
        setDatabaseMocks();
        Integer numOpps = 10; 
        Account testAccount = getTestAccount(numOpps); 
        List<SObjectField> fields = new List<SObjectField>{Account.AnnualRevenue, Account.NumberOfEmployees};
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>();
        List<InvocableRollup.Input> inputs = new List<InvocableRollup.Input>();
        for (SObjectField field : fields) {
            Rollup__mdt rollupMdt = getAccountRollup(field, false);
            rollupMdts.add(rollupMdt);
            InvocableRollup.Input input = new InvocableRollup.Input(); 
            input.timing = String.valueOf(InvocableRollup.TIMING.SYNCHRONOUS);
            input.context = String.valueOf(InvocableRollup.RollupContext.CHILD);
            input.records = testAccount.Opportunities; 
            input.rollups = new List<Rollup__mdt>{rollupMdt}; 
            inputs.add(input);
        }

        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollupMdts);
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{testAccount});

        Test.startTest();
        InvocableRollup.invoke(inputs); 
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(testAccount), 'Account was not updated');
        System.assertEquals(Decimal.valueOf(numOpps), testAccount.AnnualRevenue, 'Wrong COUNT of Opportunities in AnnualRevenue');
        System.assertEquals(Decimal.valueOf(numOpps), testAccount.NumberOfEmployees, 'Wrong COUNT of Opportunities in NumberOfEmployees');
    }

    @IsTest
    static void shouldHandleMultipleInputsOfDifferentTypes() {
        setDatabaseMocks();
        Integer numOpps = 10; 
        Account testAccount = getTestAccount(numOpps); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>{ 
            getAccountRollup(Account.AnnualRevenue, false), 
            getAccountRollup(Account.NumberOfEmployees, false) 
        };
        InvocableRollup.Input childInput = new InvocableRollup.Input(); 
        childInput.timing = String.valueOf(InvocableRollup.TIMING.SYNCHRONOUS);
        childInput.context = String.valueOf(InvocableRollup.RollupContext.CHILD);
        childInput.records = testAccount.Opportunities; 
        childInput.rollups = new List<Rollup__mdt>{rollups[0]};
        InvocableRollup.Input parentInput = new InvocableRollup.Input(); 
        parentInput.timing = String.valueOf(InvocableRollup.TIMING.ASYNCHRONOUS);
        parentInput.context = String.valueOf(InvocableRollup.RollupContext.PARENT);
        parentInput.records = new List<Account>{testAccount};
        parentInput.rollups = new List<Rollup__mdt>{rollups[1]};

        RollupMetadataHelper.BaseQuery?.toMock()?.setMockResults(rollups);
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{testAccount});

        Test.startTest();
        InvocableRollup.invoke(new List<InvocableRollup.Input>{ childInput, parentInput });
        Test.stopTest();

        System.assertEquals(true, Dml.Updated.containsRecord(testAccount), 'Account was not updated');
        System.assertEquals(Decimal.valueOf(numOpps), testAccount.AnnualRevenue, 'Wrong COUNT of Opportunities in AnnualRevenue');
        System.assertEquals(Decimal.valueOf(numOpps), testAccount.NumberOfEmployees, 'Wrong COUNT of Opportunities in NumberOfEmployees');
    }

    @IsTest 
    static void shouldThrowErrorForInvalidMdtFields() {
        setDatabaseMocks(); 
        Integer numOpps = 10; 
        Account account = getTestAccount(numOpps); 
        Databaselayer.Dml.doInsert(account); 
        DmlMock.resetHistory(); 
        Rollup.RollupQuery?.toMock()?.setMockResults(new List<Account>{account});

        Rollup__mdt template = new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = 'Amount',
            Calculation_Type__c = 'SUM',
            Child_SObjectType__c = 'Opportunity', 
            Parent_SObjectType__c = 'Account',
            Relationship_Field__c = 'AccountId',
            Target_Field__c = 'AnnualRevenue'
        ); 
        List<Rollup__mdt> rollups = new List<Rollup__mdt>();
        for (SObjectField metadataField : new List<SObjectField>{
            Rollup__mdt.Calculation_Field__c,
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
            input.context = String.valueOf(InvocableRollup.RollupContext.PARENT); 
            input.records = new List<Account>{account}; 
            input.rollups = new List<Rollup__mdt>{rollup};

            Exception caughtError;
            try {
                InvocableRollup.invoke(new List<InvocableRollup.Input>{input});
            } catch (InvocableRollup.InvalidInputException thrownError) {
                caughtError = thrownError; 
            }
            System.assertNotEquals(null, caughtError, 'An error was not thrown/caught. Rollup: ' + JSON.serializePretty(rollup));
        }
        Test.stopTest();
    }

    // **** HELPER **** //
    static void setDatabaseMocks() {
        DatabaseLayer.setDmlEngine(new DmlMock()); 
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory()); 
    } 

    static Rollup__mdt getAccountRollup(SObjectField targetField, Boolean withFilters) {
        // Create the Rollup record
        Rollup__mdt rollupMdt = new Rollup__mdt(
            Active__c = true,
            Calculation_Field__c = null, 
            Calculation_Type__c = 'COUNT',
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
            Rollup_Filter__mdt rollupFilter = (Rollup_Filter__mdt) SObjectUtils.setLookupField(
                new Rollup_Filter__mdt(Active__c = true),
                Rollup_Filter__mdt.Filter__c,
                closedWonFilter
            );
            rollupFilters.add(rollupFilter); 
        }
        return (Rollup__mdt) SObjectUtils.setRelatedList(
            rollupMdt, 
            SchemaUtils.getChildRelationship(Rollup_Filter__mdt.Rollup__c),
            rollupFilters
        );
    }

    static Account getTestAccount(Integer numOpps) {
        Account account = new Account(Name = 'Test Account');
        Campaign campaign = new Campaign(Name = 'Test Campaign');
        Databaselayer.Dml.doInsert(new List<SObject>{account, campaign}); 
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
        Databaselayer.Dml.doInsert(opportunities); 
        return (Account) SObjectUtils.setRelatedList(account, SchemaUtils.getChildRelationship(Opportunity.AccountId), opportunities); 
    }
}
