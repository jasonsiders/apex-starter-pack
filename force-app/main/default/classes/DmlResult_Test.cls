@IsTest
private class DmlResult_Test {
    @IsTest 
    static void shouldConvertDeleteResults() {
        // This type can't be mocked without performing dml - hence the reason for the wrapper class
        List<Account> records = new List<Account>{new Account(Name = 'Test')};
        DatabaseLayer.DmlEngine.doInsert(records); 
        List<Database.DeleteResult> deleteResults = Database.delete(records, false); 

        Test.startTest();
        List<DmlResult> dmlResults = DmlResult.wrap(deleteResults); 
        Test.stopTest(); 

        System.assertEquals(deleteResults?.size(), dmlResults?.size(), 'Wrong # of results');
        for (Integer i = 0; i < dmlResults?.size(); i++) {
            DmlResult dmlResult = dmlResults[i];
            Database.DeleteResult deleteResult = deleteResults[i];
            System.assertEquals(deleteResult.getErrors()?.size(), dmlResult.errors?.size(), 'Wrong # of errors');
            System.assertEquals(deleteResult.getId(), dmlResult?.recordId, 'Wrong recordId');
            System.assertEquals(deleteResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
        }
    }

    @IsTest 
    static void shouldConvertSaveResults() {
        // This type can't be mocked without performing dml - hence the reason for the wrapper class
        List<Account> records = new List<Account>{new Account(Name = 'Test')};
        List<Database.SaveResult> saveResults = Database.insert(records, false); 

        Test.startTest();
        List<DmlResult> dmlResults = DmlResult.wrap(saveResults); 
        Test.stopTest(); 

        System.assertEquals(saveResults?.size(), dmlResults?.size(), 'Wrong # of results');
        for (Integer i = 0; i < dmlResults?.size(); i++) {
            DmlResult dmlResult = dmlResults[i];
            Database.SaveResult saveResult = saveResults[i];
            System.assertEquals(saveResult.getErrors()?.size(), dmlResult.errors?.size(), 'Wrong # of errors');
            System.assertEquals(saveResult.getId(), dmlResult?.recordId, 'Wrong recordId');
            System.assertEquals(saveResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
        }
    }

    @IsTest 
    static void shouldConvertUndeleteResults() {
        // This type can't be mocked without performing dml - hence the reason for the wrapper class
        List<Account> records = new List<Account>{new Account(Name = 'Test')};
        DatabaseLayer.DmlEngine.doInsert(records); 
        DatabaseLayer.DmlEngine.doDelete(records); 
        List<Database.UndeleteResult> undeleteResults = Database.undelete(records, false); 

        Test.startTest();
        List<DmlResult> dmlResults = DmlResult.wrap(undeleteResults); 
        Test.stopTest(); 

        System.assertEquals(undeleteResults?.size(), dmlResults?.size(), 'Wrong # of results');
        for (Integer i = 0; i < dmlResults?.size(); i++) {
            DmlResult dmlResult = dmlResults[i];
            Database.UndeleteResult undeleteResult = undeleteResults[i];
            List<Database.Error> dbErrors = undeleteResult.getErrors();
            Integer numDbErrors = (dbErrors != null) ? dbErrors.size() : 0;
            System.assertEquals(numDbErrors, dmlResult.errors?.size(), 'Wrong # of errors');
            System.assertEquals(undeleteResult.getId(), dmlResult?.recordId, 'Wrong recordId');
            System.assertEquals(undeleteResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
        }
    }

    @IsTest 
    static void shouldConvertUpsertResults() {
        // This type can't be mocked without performing dml - hence the reason for the wrapper class
        List<Account> records = new List<Account>{new Account(Name = 'Test')};
        List<Database.UpsertResult> upsertResults = Database.upsert(records, false); 

        Test.startTest();
        List<DmlResult> dmlResults = DmlResult.wrap(upsertResults); 
        Test.stopTest(); 

        System.assertEquals(upsertResults?.size(), dmlResults?.size(), 'Wrong # of results');
        for (Integer i = 0; i < dmlResults?.size(); i++) {
            DmlResult dmlResult = dmlResults[i];
            Database.UpsertResult upsertResult = upsertResults[i];
            System.assertEquals(upsertResult.getErrors()?.size(), dmlResult.errors?.size(), 'Wrong # of errors');
            System.assertEquals(upsertResult.getId(), dmlResult?.recordId, 'Wrong recordId');
            System.assertEquals(upsertResult.isSuccess(), dmlResult.isSuccess, 'Wrong isSuccess value');
        }
    }

    @IsTest 
    static void shouldConvertErrors() {
        // This type can't be mocked without performing dml - hence the reason for the wrapper class
        List<Account> records = new List<Account>{new Account(Name = 'Test')};
        List<Database.Error> errors = new List<Database.Error>();
        for (Database.SaveResult saveResult : Database.update(records, false)) {
            // Can't update SObjects if they don't already exist! This will produce errors
            errors.addAll(saveResult.getErrors()); 
        }

        Test.startTest();
        List<DmlResult.Error> dmlErrors = DmlResult.wrap(errors); 
        Test.stopTest(); 

        System.assertEquals(errors?.size(), dmlErrors?.size(), 'Wrong # of errors');
        for (Integer i = 0; i < dmlErrors?.size(); i++) {
            DmlResult.Error dmlError = dmlErrors[i];
            Database.Error error = errors[i];
            System.assertEquals(error.getFields(), dmlError.fields, 'Wrong fields');
            System.assertEquals(error.getMessage(), dmlError.message, 'Wrong message');
            System.assertEquals(error.getStatusCode(), dmlError.statusCode, 'Wrong status code');
        }
    }

    @IsTest 
    static void shouldAllowMockResults() {
        DatabaseLayer.setDmlEngine(new DmlMock()); 
        Account mockAccount = new Account(Name = 'Test Account');
        DatabaseLayer.DmlEngine.doInsert(mockAccount); 
        final String mockErrorMessage = 'cannot specify Id in an insert call';
        final StatusCode mockStatusCode = StatusCode.INVALID_FIELD_FOR_INSERT_UPDATE;
        List<DmlResult.Error> mockErrors = new List<DmlResult.Error>{
            new DmlResult.Error(
                new List<String>{String.valueOf(Account.Id)},
                mockErrorMessage,
                mockStatusCode
            )
        };

        Test.startTest();
        DmlResult result = new DmlResult(mockErrors, false, mockAccount?.Id);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess, 'Wrong isSuccess');
        System.assertEquals(mockAccount.Id, result.recordId, 'Wrong recordId');
        System.assertEquals(mockErrors, result.errors, 'Wrong errors');
    }

    @IsTest 
    static void shouldGenerateMockResultsFromSObjects() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account #' + (i + 1)));
        }
        DatabaseLayer.DmlEngine.doInsert(accounts); 

        Test.startTest();
        List<DmlResult> dmlResults = DmlResult.getMockResults(accounts);
        Test.stopTest();

        System.assertEquals(accounts?.size(), dmlResults?.size(), 'Wrong # of results');
        for (Integer i = 0; i < dmlResults?.size(); i++) {
            DmlResult dmlResult = dmlResults[i];
            Account account = accounts[i];
            System.assertEquals(true, dmlResult.isSuccess, 'Wrong isSuccess');
            System.assertEquals(account.Id, dmlResult.recordId, 'Wrong recordId');
            System.assertEquals(0, dmlResult?.errors?.size(), 'Wrong # of errors');
        }
    }

    @IsTest 
    static void shouldLogErrors() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Logger.settings = new Log_Setting__c(Level__c = 'FINEST', Enabled__c = true);
        Id fakeId = TestUtils.generateFakeId(Account.SObjectType);
        DmlResult.Error mockError = new DmlResult.Error(new List<String>(), 'Fake Error Message', null);
        List<DmlResult.Error> mockErrors = new List<DmlResult.Error>{mockError};
        DmlResult mockResult = new DmlResult(mockErrors, false, fakeId);

        Test.startTest();
        DmlResult.logErrors(new List<DmlResult>{mockResult});
        Test.stopTest(); 

        System.assertEquals(1, DatabaseLayer.DmlEngine.getPublishedEvents()?.size(), 'Wrong # of published events');
        Log_Event__e logEvent = (Log_Event__e) DatabaseLayer.DmlEngine.getPublishedEvents()[0];
        System.assertEquals(JSON.serializePretty(mockErrors), logEvent.Message__c, 'Wrong log message');
    }
}