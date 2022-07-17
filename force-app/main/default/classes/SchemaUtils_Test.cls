@IsTest
private class SchemaUtils_Test {
    @IsTest
    static void shouldReturnAFieldDesecribeFromAField() {
        Schema.DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, SchemaUtils.describeField(Account.OwnerId), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, 'Completed 200 getFieldDescribe(Account.OwnerId) calls in ' + total + 'ms'); 
    }

    @IsTest
    static void shouldReturnAFieldDescribeFromAString() {
        Schema.DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, SchemaUtils.describeField(Account.SObjectType, 'OwnerId'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, 'Completed 200 getFieldDescribe(Account.SObjectType, OwnerId) calls in ' + total + 'ms'); 
    }

    @IsTest 
    static void shouldReturnNullDescribeIfFieldIsNull() {
        SObjectField field;
        SObjectType objectType; 
        System.assertEquals(null, SchemaUtils.describeField(field), 'Unexpected desecribe results');
        System.assertEquals(null, SchemaUtils.describeField(objectType, 'OwnerId'), 'Unexpected describe reuslts');
    }

    @IsTest
    static void shouldReturnAnSObjectField() {
        System.assertEquals(Account.OwnerId, SchemaUtils.getSObjectField('Account', 'OwnerId'), 'Field does not match'); 
        final String nullObjectName;
        final String nullObjectField;
        System.assertEquals(null, SchemaUtils.getSObjectField(nullObjectName, nullObjectField), 'Null input did not return a null output');
    }

    @IsTest
    static void shouldReturnAnSObjectDescribeFromAnSObjectType() {
        Schema.DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, SchemaUtils.describeSObject(Account.SObjectType), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, 'Completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @IsTest
    static void shouldReturnAnSObjectDescribeFromAString() {
        Schema.DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, SchemaUtils.describeSObject('Account'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, 'Completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @IsTest 
    static void shouldReturnNullDescribeIfObjectIsNull() {
        SObjectType objectType;
        String objectName;
        System.assertEquals(null, SchemaUtils.describeSObject(objectType), 'Unexpected describe results');
        System.assertEquals(null, SchemaUtils.describeSObject(objectName), 'Unexpected describe results');
    }

    @IsTest
    static void shouldReturnAnSObjectType() {
        String objectName = 'Account';
        Schema.SObjectType objectType = Account.SObjectType; 
        System.assertEquals(objectType, SchemaUtils.getSObjectType(objectName), 'SObjectType does not match'); 
        objectName = null; 
        System.assertEquals(null, SchemaUtils.getSObjectType(objectName), 'Null input did not return null output');
    }

    @IsTest
    static void shouldReturnAnSObjectTypeFromSObjectField() {
        SObjectField field = Account.Name;
        System.assertEquals(Account.SObjectType, SchemaUtils.getSObjectType(field), 'Wrong SObjectType for Account.Name');
        field = Contact.AccountId;
        System.assertEquals(Contact.SObjectType, SchemaUtils.getSObjectType(field), 'Wrong SObjectType for Contact.AccountId');
    }

    @IsTest
    static void shouldReturnChildSObjectTypeFromLookupField() {
        SObjectField field = Contact.AccountId;
        System.assertEquals(Account.SObjectType, SchemaUtils.getParentSObjectType(field), 'Wrong Parent SObjectType for Contact.AccountId');
        field = Contact.Email;
        System.assertEquals(null, SchemaUtils.getParentSObjectType(field), 'Non-lookup field did not return null');
    }

    @IsTest
    static void shouldOutputSoqlReference() {
        String expected = 'Contact.Account.Owner.Profile.Name';
        List<SObjectField> fields = new List<SObjectField>{ Case.ContactId, Contact.AccountId, Account.OwnerId, User.ProfileId, Profile.Name };
        System.assertEquals(expected, SchemaUtils.getSoqlReference(fields), 'Unexpected reference for many fields');
        fields = new List<SObjectField>{ Account.OwnerId };
        System.assertEquals('OwnerId', SchemaUtils.getSoqlReference(fields), 'Unexpected reference for one field');
        System.assertEquals(true, String.isBlank(SchemaUtils.getSoqlReference(null)), 'Unexpected reference for null');
    }

    @IsTest
    static void shouldGetFieldByLocalName() {
        SObjectField packageField = Log__c.Message__c;
        SObjectField actual = SchemaUtils.getSObjectFieldByLocalName(Log__c.SObjectType, 'Message__c');
        System.assertEquals(packageField, actual, 'Wrong SObjectType');
        // If the field is invalid, or doesn't exist on the object, should return null
        System.assertEquals(
            null,
            SchemaUtils.getSObjectFieldByLocalName(Account.SObjectType, 'obviouslynotarealfield'),
            'Non-existent field did not return null'
        );
    }

    @IsTest 
    static void shouldReturnChildRelationship() {
        SObjectField field = Contact.AccountId;
        System.assertEquals('Contacts', SchemaUtils.getChildRelationship(field)?.getRelationshipName(), 'Wrong relationship');
        field = Contact.Email;
        System.assertEquals(null, SchemaUtils.getChildRelationship(field)?.getRelationshipName(), 'Non-lookup field did not return null');
    }
}