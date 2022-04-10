@isTest
private class Describes_Test {
    @isTest
    static void itShouldReturnAFieldDesecribeFromAField() {
        DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getFieldDescribe(Account.OwnerId), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getFieldDescribe(Account.OwnerId) calls in ' + total + 'ms'); 
    }

    @isTest
    static void itShouldReturnAFieldDescribeFromAString() {
        DescribeFieldResult expected = Account.OwnerId.getDescribe(); 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getFieldDescribe(Account.SObjectType, 'OwnerId'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getFieldDescribe(Account.SObjectType, OwnerId) calls in ' + total + 'ms'); 
    }

    @isTest
    static void itShouldReturnAnSObjectField() {
        SObjectField field = Account.OwnerId;
        System.assertEquals(field, Describes.getSObjectFieldByName(Account.SObjectType, 'OwnerId'), 'Field does not match'); 
    }

    @isTest
    static void itShouldReturnAnSObjectDescribeFromAnSObjectType() {
        DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getSObjectDescribe(Account.SObjectType), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @isTest
    static void itShouldReturnAnSObjectDescribeFromAString() {
        DescribeSObjectResult expected = SObjectType.Account; 
        Decimal start = Limits.getCpuTime(); 
        for (Integer i = 0; i < 200; i++) {
            System.assertEquals(expected, Describes.getSObjectDescribe('Account'), 'Describe does not match');
        }
        Decimal total = Limits.getCpuTime() - start;
        System.debug(LoggingLevel.FINEST, '@Describes_Test: completed 200 getSObjectDescribe(Account.SObjectType) calls in ' + total + 'ms'); 
    }

    @isTest
    static void itShouldReturnAnSObjectType() {
        SObjectType objectType = Account.SObjectType; 
        System.assertEquals(objectType, Describes.getSObjectTypeByName('Account'), 'SObjectType does not match'); 
    }
}