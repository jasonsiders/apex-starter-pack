@IsTest
private class Describes_Test {
    @IsTest
    static void shouldReturnAFieldDesecribeFromAField() {
        Schema.DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getFieldDescribe(Account.OwnerId), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getFieldDescribe(Account.OwnerId) calls in ' + total + 'ms'); 
    }

    @IsTest
    static void shouldReturnAFieldDescribeFromAString() {
        Schema.DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getFieldDescribe(Account.SObjectType, 'OwnerId'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getFieldDescribe(Account.SObjectType, OwnerId) calls in ' + total + 'ms'); 
    }

    @IsTest 
    static void shouldReturnNullDescribeIfFieldIsNull() {
        SObjectField field;
        SObjectType objectType; 
        System.assertEquals(null, Describes.getFieldDescribe(field), 'Unexpected desecribe results');
        System.assertEquals(null, Describes.getFieldDescribe(objectType, 'OwnerId'), 'Unexpected describe reuslts');
    }

    @IsTest
    static void shouldReturnAnSObjectField() {
        System.assertEquals(Account.OwnerId, Describes.getSObjectFieldByName('Account', 'OwnerId'), 'Field does not match'); 
        final String nullObjectName;
        final String nullObjectField;
        System.assertEquals(null, Describes.getSObjectFieldByName(nullObjectName, nullObjectField), 'Null input did not return a null output');
    }

    @IsTest
    static void shouldReturnAnSObjectDescribeFromAnSObjectType() {
        Schema.DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getSObjectDescribe(Account.SObjectType), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @IsTest
    static void shouldReturnAnSObjectDescribeFromAString() {
        Schema.DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getSObjectDescribe('Account'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @IsTest 
    static void shouldReturnNullDescribeIfObjectIsNull() {
        SObjectType objectType;
        String objectName;
        System.assertEquals(null, Describes.getSObjectDescribe(objectType), 'Unexpected describe results');
        System.assertEquals(null, Describes.getSObjectDescribe(objectName), 'Unexpected describe results');
    }

    @IsTest
    static void shouldReturnAnSObjectType() {
        Schema.SObjectType objectType = Account.SObjectType; 
        System.assertEquals(objectType, Describes.getSObjectTypeByName('Account'), 'SObjectType does not match'); 
        System.assertEquals(null, Describes.getSObjectTypeByName(null), 'Null input did not return null output');
    }

    @IsTest 
    static void shouldReturnChildRelationship() {
        SObjectType objectType = Account.SObjectType; 
        String relationshipName = 'Contacts';
        Schema.ChildRelationship contactRelationship = Describes.getChildRelationship(objectType, relationshipName);
        System.assertEquals(Contact.SObjectType, contactRelationship.getChildSObject(), 'Wrong Child SObject');
        System.assertEquals(relationshipName, contactRelationship.getRelationshipName(), 'Wrong relationship name');
        relationshipName = null;
        contactRelationship = Describes.getChildRelationship(objectType, relationshipName);
        System.assertEquals(null, contactRelationship, 'Null Relationship name did not return null');
        objectType = null;
        relationshipName = 'Contacts';
        contactRelationship = Describes.getChildRelationship(objectType, relationshipName);
        System.assertEquals(null, contactRelationship, 'Null SObject name did not return null');
    }

    @IsTest 
    static void shouldReturnChildRelationshipFromAString() {
        final String relationshipName = 'Contacts';
        Schema.ChildRelationship contactRelationship = Describes.getChildRelationship('Account', relationshipName);
        System.assertEquals(Contact.SObjectType, contactRelationship.getChildSObject(), 'Wrong Child SObject');
        System.assertEquals(relationshipName, contactRelationship.getRelationshipName(), 'Wrong relationship name');
    }
}