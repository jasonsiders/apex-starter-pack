@IsTest
private class SObjectRef_Test {
    @IsTest 
    static void shouldConstruct() {
        SObjectRef fromSchemaType = new SObjectRef(Account.SObjectType);
        System.assertEquals(Account.SObjectType, fromSchemaType?.toSchemaType(), 'Represents the wrong SObjectType');
        SObjectRef fromSchemaField = new SObjectRef(Account.OwnerId);
        System.assertEquals(Account.SObjectType, fromSchemaField?.toSchemaType(), 'Represents the wrong SObjectType');
        SObjectRef fromSObject = new SObjectRef(new Account()); 
        System.assertEquals(Account.SObjectType, fromSObject?.toSchemaType(), 'Represents the wrong SObjectType');
    }

    @IsTest 
    static void shouldSerialize() {
        SObjectType objectType = Account.SObjectType; 
        System.assertNotEquals(null, serialize(objectType), 'An error was not thrown while serializing a Schema.SObjectType');
        SObjectRef reference = new SObjectRef(objectType);
        System.assertEquals(null, serialize(reference), 'An error was thrown when serializing an SObjectRef');
        // Once serialized, should still be able to access the Schema type
        reference = (SObjectRef) JSON.deserialize(JSON.serialize(reference), SObjectRef.class);
        System.assertEquals(objectType, reference?.toSchemaType(), 'The SObjectType was lost after serialization');
    }

    @IsTest
    static void shouldDetermineIfRecordIsInstanceOfSObjectType() {
        SObjectRef ref = new SObjectRef(Account.SObjectType); 
        System.assertEquals(true, ref.isSObjectTypeOf(new Account()), ref?.toString() + '.SObjectType != new Account()?');
        System.assertEquals(false, ref.isSObjectTypeOf(new Contact()), ref?.toString() + '.SObjectType == new Contact()?');
        SObjectType nullObjectType = null; 
        ref = new SObjectRef(nullObjectType); 
        System.assertEquals(false, ref.isSObjectTypeOf(new Account()), ref?.toString() + '.SObjectType == new Account()?');
    }

    @IsTest 
    static void shouldBeUsableAsAMapKey() {
        Map<SObjectRef, String> objectsByName = new Map<SObjectRef, String>();
        List<SObjectType> objectTypes = new List<SObjectType>{
            Account.SObjectType, 
            Contact.SObjectType, 
            Lead.SObjectType
        };
        for (SObjectType objectType : objectTypes) {
            SObjectRef ref = new SObjectRef(objectType);
            objectsByName.put(ref, ref?.toString()); 
        }

        Test.startTest();
        for (SObjectType objectType : objectTypes) {
            // Without the equals() method, this would fail!
            SObjectRef ref = new SObjectRef(objectType); 
            System.assertEquals(ref?.toString(), objectsByName?.get(ref), 'No value found for ' + ref + ': ' + JSON.serializePretty(objectsByName));
        }
        Test.stopTest();
    }

    // **** HELPER **** //
    static Exception serialize(Object obj) {
        Exception caughtError;
        try {
            JSON.serialize(obj);
        } catch (System.JSONException jsonError) {
            caughtError = jsonError;
        }
        return caughtError; 
    }
}
