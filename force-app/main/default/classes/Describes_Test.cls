@isTest
private class Describes_Test {
    @isTest
    static void shouldReturnAFieldDesecribeFromAField() {
        Schema.DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getFieldDescribe(Account.OwnerId), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getFieldDescribe(Account.OwnerId) calls in ' + total + 'ms'); 
    }

    @isTest
    static void shouldReturnAFieldDescribeFromAString() {
        Schema.DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getFieldDescribe(Account.SObjectType, 'OwnerId'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getFieldDescribe(Account.SObjectType, OwnerId) calls in ' + total + 'ms'); 
    }

    @isTest
    static void shouldReturnAnSObjectField() {
        Schema.SObjectField field = Account.OwnerId;
        System.assertEquals(field, Describes.getSObjectFieldByName(Account.SObjectType, 'OwnerId'), 'Field does not match'); 
    }

    @isTest
    static void shouldReturnAnSObjectDescribeFromAnSObjectType() {
        Schema.DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getSObjectDescribe(Account.SObjectType), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @isTest
    static void shouldReturnAnSObjectDescribeFromAString() {
        Schema.DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getSObjectDescribe('Account'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @isTest
    static void shouldReturnAnSObjectType() {
        Schema.SObjectType objectType = Account.SObjectType; 
        System.assertEquals(objectType, Describes.getSObjectTypeByName('Account'), 'SObjectType does not match'); 
    }

    @IsTest 
    static void shouldReturnChildRelationship() {
        final String relationshipName = 'Contacts';
        Schema.ChildRelationship contactRelationship = Describes.getChildRelationship(Account.SObjectType, relationshipName);
        System.assertEquals(Contact.SObjectType, contactRelationship.getChildSObject(), 'Wrong Child SObject');
        System.assertEquals(relationshipName, contactRelationship.getRelationshipName(), 'Wrong relationship name');
    }

    @IsTest 
    static void shouldReturnChildRelationshipFromAString() {
        final String relationshipName = 'Contacts';
        Schema.ChildRelationship contactRelationship = Describes.getChildRelationship('Account', relationshipName);
        System.assertEquals(Contact.SObjectType, contactRelationship.getChildSObject(), 'Wrong Child SObject');
        System.assertEquals(relationshipName, contactRelationship.getRelationshipName(), 'Wrong relationship name');
    }
}