@IsTest 
private class TypeUtils_Test {
    @IsTest 
    static void shouldReturnNull() {
        Object obj = null;
        System.assertEquals(null, TypeUtils.getType(obj), 'Null type did not return null'); 
        // If the variable has a type, but is null - will still return null
        String myString = null;
        System.assertEquals(null, TypeUtils.getType(myString), 'Null string did not return null');
    }

    @IsTest 
    static void shouldReturnCorrectPrimitiveType() {
        System.assertEquals(Blob.class, TypeUtils.getType(Crypto.generateAesKey(128)));
        System.assertEquals(Boolean.class, TypeUtils.getType(true)); 
        System.assertEquals(Date.class, TypeUtils.getType(Date.today()));
        System.assertEquals(DateTime.class, TypeUtils.getType(DateTime.now()));
        System.assertEquals(Decimal.class, TypeUtils.getType(1.0));
        System.assertEquals(Double.class, TypeUtils.getType(Double.valueOf(1.0))); 
        System.assertEquals(String.class, TypeUtils.getType(UserInfo.getUserId())); // Watch out!
        System.assertEquals(Integer.class, TypeUtils.getType(Crypto.getRandomInteger()));
        System.assertEquals(Long.class, TypeUtils.getType(Crypto.getRandomLong()));
        System.assertEquals(String.class, TypeUtils.getType('Testing 123'));
        System.assertEquals(Time.class, TypeUtils.getType(DateTime.now().time()));
    }

    @IsTest 
    static void shouldReturnCorrectListType() {
        System.assertEquals(List<Blob>.class, TypeUtils.getType(new List<Blob>()));
        System.assertEquals(List<Boolean>.class, TypeUtils.getType(new List<Boolean>())); 
        System.assertEquals(List<Date>.class, TypeUtils.getType(new List<Date>()));
        System.assertEquals(List<DateTime>.class, TypeUtils.getType(new List<DateTime>()));
        System.assertEquals(List<Decimal>.class, TypeUtils.getType(new List<Decimal>()));
        System.assertEquals(List<Double>.class, TypeUtils.getType(new List<Double>())); 
        System.assertEquals(List<Id>.class, TypeUtils.getType(new List<Id>())); 
        System.assertEquals(List<Integer>.class, TypeUtils.getType(new List<Integer>()));
        System.assertEquals(List<Long>.class, TypeUtils.getType(new List<Long>()));
        System.assertEquals(List<String>.class, TypeUtils.getType(new List<String>()));
        System.assertEquals(List<Time>.class, TypeUtils.getType(new List<Time>()));
    }

    @IsTest 
    static void shouldReturnCorrectSetType() {
        System.assertEquals(Set<Blob>.class, TypeUtils.getType(new Set<Blob>()));
        System.assertEquals(Set<Boolean>.class, TypeUtils.getType(new Set<Boolean>())); 
        System.assertEquals(Set<Date>.class, TypeUtils.getType(new Set<Date>()));
        System.assertEquals(Set<DateTime>.class, TypeUtils.getType(new Set<DateTime>()));
        System.assertEquals(Set<Decimal>.class, TypeUtils.getType(new Set<Decimal>()));
        System.assertEquals(Set<Double>.class, TypeUtils.getType(new Set<Double>())); 
        System.assertEquals(Set<Id>.class, TypeUtils.getType(new Set<Id>())); 
        System.assertEquals(Set<Integer>.class, TypeUtils.getType(new Set<Integer>()));
        System.assertEquals(Set<Long>.class, TypeUtils.getType(new Set<Long>()));
        System.assertEquals(Set<String>.class, TypeUtils.getType(new Set<String>()));
        System.assertEquals(Set<Time>.class, TypeUtils.getType(new Set<Time>()));
    }

    @IsTest 
    static void shouldReturnCorrectMapType() {
        System.assertEquals(Map<Id, SObject>.class, TypeUtils.getType(new Map<Id, SObject>()));
        System.assertEquals(Map<String, Integer>.class, TypeUtils.getType(new Map<String, Integer>()));
        System.assertEquals(Map<Date, DateTime>.class, TypeUtils.getType(new Map<Date, DateTime>()));
    }

    @IsTest 
    static void shouldReturnNestedCollectionType() {
        Object obj = new Map<List<String>, List<List<Integer>>>();
        System.assertEquals(Map<List<String>, List<List<Integer>>>.class, TypeUtils.getType(obj));
    }

    @IsTest 
    static void shouldReturnCorrectSObjectType() {
        System.assertEquals(Account.class, TypeUtils.getType(new Account()));
        System.assertEquals(Case.class, TypeUtils.getType(new Case()));
        System.assertEquals(Lead.class, TypeUtils.getType(new Lead()));
        System.assertEquals(Opportunity.class, TypeUtils.getType(new Opportunity()));
        System.assertEquals(Task.class, TypeUtils.getType(new Task()));
    }

    @IsTest 
    static void shouldReturnAComplexType() {
        System.assertEquals(TypeUtils_Test.Example.class, TypeUtils.getType(new Example()));
    }

    @IsTest 
    static void shouldDetermineIfList() {
        System.assertEquals(true, TypeUtils.isList(new List<String>()));
        System.assertEquals(false, TypeUtils.isList(new Set<String>()));
        System.assertEquals(false, TypeUtils.isList(new Map<String, String>()));
        System.assertEquals(false, TypeUtils.isList(new Map<List<String>, String>()));
    }

    @IsTest 
    static void shouldDetermineIfSet() {
        System.assertEquals(false, TypeUtils.isSet(new List<String>()));
        System.assertEquals(true, TypeUtils.isSet(new Set<String>()));
        System.assertEquals(false, TypeUtils.isSet(new Map<String, String>()));
        System.assertEquals(false, TypeUtils.isSet(new Map<List<String>, String>()));
    }

    @IsTest 
    static void shouldDetermineIfMap() {
        System.assertEquals(false, TypeUtils.isMap(new List<String>()));
        System.assertEquals(false, TypeUtils.isMap(new Set<String>()));
        System.assertEquals(true, TypeUtils.isMap(new Map<String, String>()));
        System.assertEquals(true, TypeUtils.isMap(new Map<List<String>, String>()));
    }

    @IsTest 
    static void shouldDetermineIfCollection() {
        System.assertEquals(true, TypeUtils.isCollection(new List<String>()));
        System.assertEquals(true, TypeUtils.isCollection(new Set<String>()));
        System.assertEquals(true, TypeUtils.isCollection(new Map<String, String>()));
        System.assertEquals(true, TypeUtils.isCollection(new Map<List<String>, String>()));
    }

    public class Example {}
}