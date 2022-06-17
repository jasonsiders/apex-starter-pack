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
        System.assertEquals(Blob.class, TypeUtils.getType(Crypto.generateAesKey(128)), 'Wrong type');
        System.assertEquals(Boolean.class, TypeUtils.getType(true), 'Wrong type'); 
        System.assertEquals(Date.class, TypeUtils.getType(Date.today()), 'Wrong type');
        System.assertEquals(DateTime.class, TypeUtils.getType(DateTime.now()), 'Wrong type');
        System.assertEquals(Decimal.class, TypeUtils.getType(1.0), 'Wrong type');
        System.assertEquals(Double.class, TypeUtils.getType(Double.valueOf(1.0)), 'Wrong type'); 
        System.assertEquals(String.class, TypeUtils.getType(UserInfo.getUserId()), 'Wrong type'); // Watch out!
        System.assertEquals(Integer.class, TypeUtils.getType(Crypto.getRandomInteger()), 'Wrong type');
        System.assertEquals(Long.class, TypeUtils.getType(Crypto.getRandomLong()), 'Wrong type');
        System.assertEquals(String.class, TypeUtils.getType('Testing 123'), 'Wrong type');
        System.assertEquals(Time.class, TypeUtils.getType(DateTime.now().time()), 'Wrong type');
    }

    @IsTest 
    static void shouldReturnCorrectListType() {
        System.assertEquals(List<Blob>.class, TypeUtils.getType(new List<Blob>()), 'Wrong type');
        System.assertEquals(List<Boolean>.class, TypeUtils.getType(new List<Boolean>()), 'Wrong type'); 
        System.assertEquals(List<Date>.class, TypeUtils.getType(new List<Date>()), 'Wrong type');
        System.assertEquals(List<DateTime>.class, TypeUtils.getType(new List<DateTime>()), 'Wrong type');
        System.assertEquals(List<Decimal>.class, TypeUtils.getType(new List<Decimal>()), 'Wrong type');
        System.assertEquals(List<Double>.class, TypeUtils.getType(new List<Double>()), 'Wrong type'); 
        System.assertEquals(List<Id>.class, TypeUtils.getType(new List<Id>()), 'Wrong type'); 
        System.assertEquals(List<Integer>.class, TypeUtils.getType(new List<Integer>()), 'Wrong type');
        System.assertEquals(List<Long>.class, TypeUtils.getType(new List<Long>()), 'Wrong type');
        System.assertEquals(List<String>.class, TypeUtils.getType(new List<String>()), 'Wrong type');
        System.assertEquals(List<Time>.class, TypeUtils.getType(new List<Time>()), 'Wrong type');
    }

    @IsTest 
    static void shouldReturnCorrectSetType() {
        System.assertEquals(Set<Blob>.class, TypeUtils.getType(new Set<Blob>()), 'Wrong type');
        System.assertEquals(Set<Boolean>.class, TypeUtils.getType(new Set<Boolean>()), 'Wrong type'); 
        System.assertEquals(Set<Date>.class, TypeUtils.getType(new Set<Date>()), 'Wrong type');
        System.assertEquals(Set<DateTime>.class, TypeUtils.getType(new Set<DateTime>()), 'Wrong type');
        System.assertEquals(Set<Decimal>.class, TypeUtils.getType(new Set<Decimal>()), 'Wrong type');
        System.assertEquals(Set<Double>.class, TypeUtils.getType(new Set<Double>()), 'Wrong type'); 
        System.assertEquals(Set<Id>.class, TypeUtils.getType(new Set<Id>()), 'Wrong type'); 
        System.assertEquals(Set<Integer>.class, TypeUtils.getType(new Set<Integer>()), 'Wrong type');
        System.assertEquals(Set<Long>.class, TypeUtils.getType(new Set<Long>()), 'Wrong type');
        System.assertEquals(Set<String>.class, TypeUtils.getType(new Set<String>()), 'Wrong type');
        System.assertEquals(Set<Time>.class, TypeUtils.getType(new Set<Time>()), 'Wrong type');
    }

    @IsTest 
    static void shouldReturnCorrectMapType() {
        System.assertEquals(Map<Id, SObject>.class, TypeUtils.getType(new Map<Id, SObject>()), 'Wrong type');
        System.assertEquals(Map<String, Integer>.class, TypeUtils.getType(new Map<String, Integer>()), 'Wrong type');
        System.assertEquals(Map<Date, DateTime>.class, TypeUtils.getType(new Map<Date, DateTime>()), 'Wrong type');
    }

    @IsTest 
    static void shouldReturnNestedCollectionType() {
        Object obj = new Map<List<String>, List<List<Integer>>>();
        System.assertEquals(Map<List<String>, List<List<Integer>>>.class, TypeUtils.getType(obj), 'Wrong type');
    }

    @IsTest 
    static void shouldReturnCorrectSObjectType() {
        System.assertEquals(Account.class, TypeUtils.getType(new Account()), 'Wrong type');
        System.assertEquals(Case.class, TypeUtils.getType(new Case()), 'Wrong type');
        System.assertEquals(Lead.class, TypeUtils.getType(new Lead()), 'Wrong type');
        System.assertEquals(Opportunity.class, TypeUtils.getType(new Opportunity()), 'Wrong type');
        System.assertEquals(Task.class, TypeUtils.getType(new Task()), 'Wrong type');
    }

    @IsTest 
    static void shouldReturnAComplexType() {
        System.assertEquals(TypeUtils_Test.Example.class, TypeUtils.getType(new Example()), 'Wrong type');
    }

    @IsTest 
    static void shouldDetermineIfList() {
        System.assertEquals(true, TypeUtils.isList(new List<String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isList(new Set<String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isList(new Map<String, String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isList(new Map<List<String>, String>()), 'Wrong type');
    }

    @IsTest 
    static void shouldDetermineIfSet() {
        System.assertEquals(false, TypeUtils.isSet(new List<String>()), 'Wrong type');
        System.assertEquals(true, TypeUtils.isSet(new Set<String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isSet(new Map<String, String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isSet(new Map<List<String>, String>()), 'Wrong type');
    }

    @IsTest 
    static void shouldDetermineIfMap() {
        System.assertEquals(false, TypeUtils.isMap(new List<String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isMap(new Set<String>()), 'Wrong type');
        System.assertEquals(true, TypeUtils.isMap(new Map<String, String>()), 'Wrong type');
        System.assertEquals(true, TypeUtils.isMap(new Map<List<String>, String>()), 'Wrong type');
    }

    @IsTest 
    static void shouldDetermineIfCollection() {
        System.assertEquals(true, TypeUtils.isCollection(new List<String>()), 'Wrong type');
        System.assertEquals(true, TypeUtils.isCollection(new Set<String>()), 'Wrong type');
        System.assertEquals(true, TypeUtils.isCollection(new Map<String, String>()), 'Wrong type');
        System.assertEquals(true, TypeUtils.isCollection(new Map<List<String>, String>()), 'Wrong type');
        System.assertEquals(false, TypeUtils.isCollection('Not a collection!'), 'Wrong type');
    }

    @IsTest 
    static void shouldDetemineIfDateGreaterThan() {
        Object value1 = Date.newInstance(2022, 01, 01);
        Object value2 = Date.newInstance(2022, 01, 02);
        System.assertEquals(false, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2);
        value1 = Date.newInstance(2022, 01, 02);
        value2 = Date.newInstance(2022, 01, 01);
        System.assertEquals(true, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2);
        value1 = null;
        System.assertEquals(false, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2);
        value1 = DateTime.newInstanceGmt(2022, 01, 01);
        value2 = DateTime.newInstanceGmt(2022, 01, 02); 
        System.assertEquals(false, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2);
        value1 = DateTime.newInstanceGmt(2022, 01, 02);
        value2 = DateTime.newInstanceGmt(2022, 01, 01); 
        System.assertEquals(true, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2); 
        value1 = null;
        System.assertEquals(false, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2); 
    }

    @IsTest 
    static void shouldDetemineIfDateLessThan() {
        Object value1 = Date.newInstance(2022, 01, 01);
        Object value2 = Date.newInstance(2022, 01, 02);
        System.assertEquals(true, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2);
        value1 = Date.newInstance(2022, 01, 02);
        value2 = Date.newInstance(2022, 01, 01);
        System.assertEquals(false, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2);
        value1 = null;
        System.assertEquals(false, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2);
        value1 = DateTime.newInstanceGmt(2022, 01, 01);
        value2 = DateTime.newInstanceGmt(2022, 01, 02);
        System.assertEquals(true, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2); 
        value1 = DateTime.newInstanceGmt(2022, 01, 02);
        value2 = DateTime.newInstanceGmt(2022, 01, 01); 
        System.assertEquals(false, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2); 
        value1 = null;
        System.assertEquals(false, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2); 
    }

    @IsTest 
    static void shouldDetemineIfNumberGreaterThan() {
        Object value1 = 1;
        Object value2 = 2;
        System.assertEquals(false, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2); 
        value2 = 0;
        System.assertEquals(true, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2); 
        value2 = null;
        System.assertEquals(false, TypeUtils.greaterThan(value1, value2), value1 + ' > ' + value2); 
    }

    @IsTest 
    static void shouldDetemineIfNumberLessThan() {
        Object value1 = 1;
        Object value2 = 2;
        System.assertEquals(true, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2); 
        value2 = 0;
        System.assertEquals(false, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2); 
        value2 = null;
        System.assertEquals(false, TypeUtils.lessThan(value1, value2), value1 + ' < ' + value2); 
    }

    @IsTest 
    static void shouldDetemineIfInvalidDataTypeGreaterThan() {
        for (Object value : new List<Object>{
            Blob.valueOf(JSON.serialize(new Account())),
            true, 
            UserInfo.getUserId(),
            Crypto.getRandomLong(),
            'Hello world!'
        }) {
            System.assertEquals(false, TypeUtils.greaterThan(value, 1), value + ' > 1');
        }
    }

    @IsTest 
    static void shouldDetemineIfInvalidDataTypeLessThan() {
        for (Object value : new List<Object>{
            Blob.valueOf(JSON.serialize(new Account())),
            true, 
            UserInfo.getUserId(),
            Crypto.getRandomLong(),
            'Hello world!'
        }) {
            System.assertEquals(false, TypeUtils.lessThan(value, 1), value + ' < 1');
        }
    }

    @IsTest 
    static void shouldConvertStringToCorrectDataType() {
        System.assertEquals(true, TypeUtils.parseStringValue('true'), 'Did not return true');
        System.assertEquals(Date.newInstance(2022, 01, 01), TypeUtils.parseStringValue('"2022-01-01"'), 'Wrong Date');
        System.assertEquals(DateTime.newInstanceGmt(2022, 01, 01), TypeUtils.parseStringValue('"2022-01-01T00:00:00Z"'), 'Wrong DateTime');
        System.assertEquals(99.99, TypeUtils.parseStringValue('99.99'), 'Wrong Decimal');
        System.assertEquals(99, TypeUtils.parseStringValue('99'), 'Wrong Integer'); 
        System.assertEquals('Hello world!', TypeUtils.parseStringValue('"Hello world!"'), 'Wrong string value');
        System.assertEquals(null, TypeUtils.parseStringValue('null'), 'Not null');
        System.assertEquals(null, TypeUtils.parseStringValue(null), 'Not null');
    }

    public class Example {}
}
