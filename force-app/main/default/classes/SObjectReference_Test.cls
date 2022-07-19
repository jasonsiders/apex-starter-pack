@IsTest
private class SObjectReference_Test {
    @IsTest 
    static void shouldConstruct() {
        SObjectReference fromSchemaType = new SObjectReference(Account.SObjectType);
        System.assertEquals(Account.SObjectType, fromSchemaType?.toSchemaType(), 'Represents the wrong SObjectType');
        SObjectReference fromSchemaField = new SObjectReference(Account.OwnerId);
        System.assertEquals(Account.SObjectType, fromSchemaField?.toSchemaType(), 'Represents the wrong SObjectType');
        SObjectReference fromSObject = new SObjectReference(new Account()); 
        System.assertEquals(Account.SObjectType, fromSObject?.toSchemaType(), 'Represents the wrong SObjectType');
    }

    @IsTest 
    static void shouldSerialize() {
        SObjectType objectType = Account.SObjectType; 
        System.assertNotEquals(null, serialize(objectType), 'An error was not thrown while serializing a Schema.SObjectType');
        SObjectReference reference = new SObjectReference(objectType);
        System.assertEquals(null, serialize(reference), 'An error was thrown when serializing an SObjectReference');
        // Once serialized, should still be able to access the Schema type
        reference = (SObjectReference) JSON.deserialize(JSON.serialize(reference), SObjectReference.class);
        System.assertEquals(objectType, reference?.toSchemaType(), 'The SObjectType was lost after serialization');
    }

    @IsTest
    static void shouldDetermineIfRecordIsInstanceOfSObjectType() {
        SObjectReference ref = new SObjectReference(Account.SObjectType); 
        System.assertEquals(true, ref.isSObjectTypeOf(new Account()), ref?.toString() + '.SObjectType != new Account()?');
        System.assertEquals(false, ref.isSObjectTypeOf(new Contact()), ref?.toString() + '.SObjectType == new Contact()?');
        SObjectType nullObjectType = null; 
        ref = new SObjectReference(nullObjectType); 
        System.assertEquals(false, ref.isSObjectTypeOf(new Account()), ref?.toString() + '.SObjectType == new Account()?');
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
