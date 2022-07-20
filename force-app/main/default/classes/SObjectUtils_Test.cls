@IsTest
private class SObjectUtils_Test {
    @IsTest 
    static void shouldSetReadOnlyField() {
        Opportunity testOpp = new Opportunity(); 

        Test.startTest();
        // Can't normally set the 'IsClosed' field
        testOpp = (Opportunity) SObjectUtils.setReadOnlyField(testOpp, Opportunity.IsClosed, true);
        Test.stopTest();

        System.assertEquals(true, testOpp.IsClosed, 'Did not set read only field');
    }

    @IsTest 
    static void shouldSetRelatedList() {
        // Child Object relationships (like Account.Contacts) are read-only fields too!
        DatabaseLayer.setDmlEngine(new DmlMock());
        Account testAccount = new Account(Name = 'Test Account');
        Databaselayer.Dml.doInsert(testAccount);
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(
                AccountId = testAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact #' + (i + 1)
            ));
        }
        Databaselayer.Dml.doInsert(contacts); 
        Schema.ChildRelationship contactRelationship = SchemaUtils.getChildRelationship(Contact.AccountId);

        Test.startTest();
        testAccount = (Account) SObjectUtils.setRelatedList(testAccount, contactRelationship, contacts); 
        Test.stopTest();
        
        System.assertEquals(contacts?.size(), testAccount.Contacts?.size(), 'Wrong # of child records');
        System.assertEquals(contacts, testAccount.Contacts, 'Does not match the supplied child records');
    }

    @IsTest 
    static void shouldSetLookupFieldWithParentValues() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Account testAccount = new Account(Name = 'Test Account');
        Databaselayer.Dml.doInsert(testAccount);

        Test.startTest();
        Contact testContact = new Contact(
            AccountId = testAccount.Id, 
            LastName = 'Test Contact'
        );
        testContact = (Contact) SObjectUtils.setLookupField(testContact, Contact.AccountId, testAccount);
        Test.stopTest();
        
        System.assertEquals(testAccount?.Id, testContact?.AccountId, 'Wrong AccountId');
        System.assertEquals(testAccount?.Name, testContact?.Account?.Name, 'Wrong Account.Name');
    }
}
