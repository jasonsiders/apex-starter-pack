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
        Schema.SObjectType objectType = Account.SObjectType; 
        System.assertEquals(objectType, SchemaUtils.getSObjectType('Account'), 'SObjectType does not match'); 
        System.assertEquals(null, SchemaUtils.getSObjectType(null), 'Null input did not return null output');
    }

    @IsTest 
    static void shouldReturnChildRelationship() {
        SObjectType objectType = Account.SObjectType; 
        String relationshipName = 'Contacts';
        Schema.ChildRelationship contactRelationship = SchemaUtils.getChildRelationship(objectType, relationshipName);
        System.assertEquals(Contact.SObjectType, contactRelationship.getChildSObject(), 'Wrong Child SObject');
        System.assertEquals(relationshipName, contactRelationship.getRelationshipName(), 'Wrong relationship name');
        relationshipName = null;
        contactRelationship = SchemaUtils.getChildRelationship(objectType, relationshipName);
        System.assertEquals(null, contactRelationship, 'Null Relationship name did not return null');
        objectType = null;
        relationshipName = 'Contacts';
        contactRelationship = SchemaUtils.getChildRelationship(objectType, relationshipName);
        System.assertEquals(null, contactRelationship, 'Null SObject name did not return null');
    }

    @IsTest 
    static void shouldReturnChildRelationshipFromAString() {
        final String relationshipName = 'Contacts';
        Schema.ChildRelationship contactRelationship = SchemaUtils.getChildRelationship('Account', relationshipName);
        System.assertEquals(Contact.SObjectType, contactRelationship.getChildSObject(), 'Wrong Child SObject');
        System.assertEquals(relationshipName, contactRelationship.getRelationshipName(), 'Wrong relationship name');
    }
}