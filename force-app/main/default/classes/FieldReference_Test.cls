@IsTest
private class FieldReference_Test {
    @IsTest 
    static void shouldConstructFromSingleField() {
        SObjectField field = Account.Name; 
        FieldReference ref = new FieldReference(field); 
        System.assertEquals('Name', ref.toString(), 'Wrong SOQL reference');
        System.assertEquals(field, ref.toSchemaType(), 'Wrong destination SObjectField');
    }

    @IsTest 
    static void shouldConstructFromChainOfRelatedFields() {
        List<SObjectField> fields = new List<SObjectField>{
            Case.ContactId,
            Contact.AccountId,
            Account.Name
        };
        FieldReference ref = new FieldReference(fields); 
        System.assertEquals('Contact.Account.Name', ref.toString(), 'Wrong SOQL reference');
        System.assertEquals(Account.Name, ref.toSchemaType(), 'Wrong destination SObjectField');
    }

    @IsTest 
    static void simpleFieldShouldBeSerializable() {
        SObjectField field = Account.Name;
        System.assertNotEquals(null, testSerialize(field), 'SObjectField is serializable?');
        FieldReference ref = new FieldReference(field); 
        System.assertEquals(null, testSerialize(ref), 'FieldReference is not serializable?');
        // After serializiation, should still function the same as before
        FieldReference deserializedRef = (FieldReference) JSON.deserialize(JSON.serialize(ref), FieldReference.class); 
        Account testAcount = new Account(Name = 'Foo');
        System.assertEquals(testAcount.Name, deserializedRef.getValue(testAcount), 'Post-serialization, could not retrieve the correct field value'); 
    }

    @IsTest 
    static void complexFieldShouldBeSerializable() {
        List<SObjectField> fields = new List<SObjectField>{
            Case.ContactId,
            Contact.AccountId,
            Account.Name
        };
        FieldReference ref = new FieldReference(fields); 
        System.assertEquals(null, testSerialize(ref), 'FieldReference is not serializable?');
        // After serializiation, should still function the same as before
        FieldReference deserializedRef = (FieldReference) JSON.deserialize(JSON.serialize(ref), FieldReference.class); 
        Account testAccount = new Account(Name = 'Foo');
        Contact testContact = (Contact) ObjectUtils.setLookupField(new Contact(), Contact.AccountId, testAccount);
        Case testCase = (Case) ObjectUtils.setLookupField(new Case(), Case.ContactId, testContact); 
        System.assertEquals(testAccount.Name, deserializedRef.getValue(testCase), 'Post-serialization, could not retrieve the correct field value'); 
    }

    @IsTest 
    static void shouldThrowErrorIfGettingFieldFromSObjectOfWrongType() {
        Account testAccount = new Account(Name = 'Test'); 
        Contact testContact = (Contact) ObjectUtils.setLookupField(new Contact(), Contact.AccountId, testAccount); 
        FieldReference ref = new FieldReference(Account.Name); 

        Test.startTest();
        Exception caughtError;
        try {
            ref.getValue(testContact); // ! Account.Name is not a column on Contact.SObjectType
        } catch (System.SObjectException thrownError) {
            caughtError = thrownError; 
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown');
    }

    @IsTest 
    static void shouldBeUsableAsAMapKey() {
        Map<FieldReference, String> fieldMap = new Map<FieldReference, String>();
        List<SObjectField> chainedFields = new List<SObjectField>{Case.ContactId, Contact.AccountId, Account.Name};
        List<FieldReference> fieldReferences = new List<FieldReference>{
            new FieldReference(chainedFields),
            new FieldReference(Case.ContactId),
            new FieldReference(Contact.AccountId),
            new FieldReference(Account.Name)
        };
        for (FieldReference fieldReference : fieldReferences) {
            fieldMap.put(fieldReference, fieldReference.toString()); 
        }

        Test.startTest();
        FieldReference ref = new FieldReference(chainedFields);
        for (FieldReference fieldReference : fieldReferences) {
            FieldReference newRef = fieldReference.clone();
            System.assertEquals(true, fieldMap.containsKey(newRef), 'Map does not contain ' + newRef);
        }
        Test.stopTest();
    }
    
    // **** HELPER **** // 
    static Exception testSerialize(Object obj) {
        Exception caughtError; 
        try {
            JSON.serialize(obj); 
        } catch (System.JSONException jsonError) {
            caughtError = jsonError;
        }
        return caughtError; 
    }
}
