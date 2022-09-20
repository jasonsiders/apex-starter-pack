@IsTest 
private class PropertyRef_Test {
    @IsTest 
    static void shouldConstructASimpleProperty() {
        String propertyName = 'value';
        PropertyRef ref = new PropertyRef(propertyName);
        System.assertEquals(propertyName, ref?.toString(), 'Wrong property name'); 
        
        InnerClass obj = new InnerClass();
        String value = (String) ref.getValue(obj); 
        System.assertEquals('hello world', value, 'Wrong value');
    }

    @IsTest 
    static void shouldConstructAChildProperty() {
        String propertyName = 'innerClass.value';
        PropertyRef ref = new PropertyRef(propertyName);
        System.assertEquals(propertyName, ref?.toString(), 'Wrong property name'); 
        
        OuterClass obj = new OuterClass();
        String value = (String) ref.getValue(obj); 
        System.assertEquals('hello world', value, 'Wrong value');
    }

    @IsTest 
    static void shouldReturnNullForInvalidSimpleProperty() {
        InnerClass obj = new InnerClass();
        PropertyRef invalidRef = new PropertyRef('asdf');
        System.assertEquals(null, invalidRef.getValue(obj), 'Invalid ref did not return null');
    }

    @IsTest 
    static void shouldReturnNullForInvalidChildProperty() {
        InnerClass obj = new InnerClass();
        PropertyRef invalidRef = new PropertyRef('asdf.asdf');
        System.assertEquals(null, invalidRef.getValue(obj), 'Invalid ref did not return null');
    }

    @IsTest 
    static void shouldGetValueFromSObjects() {
        Account account = new Account(Name = 'Test');
        PropertyRef ref = new PropertyRef('Name');
        System.assertEquals('Test', ref.getValue(account), 'Wrong Account.Name');
    }

    @IsTest 
    static void shouldGetValueFromMultiLayerSObjects() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Account account = new Account(Name = 'Test');
        DatabaseLayer.Dml.doInsert(account); 
        Opportunity opp = (Opportunity) SObjectUtils.setLookupField(new Opportunity(), Opportunity.AccountId, account);
        PropertyRef ref = new PropertyRef('Account.Name');
        System.assertEquals(account.Name, ref.getValue(opp), 'Wrong Opportunity.Account.Name');
    }

    @IsTest 
    static void shouldBeMappable() {
        OuterClass outerObj = new OuterClass();
        InnerClass innerObj = outerObj.innerClass;
        PropertyRef childRef = new PropertyRef('value');
        PropertyRef parentRef = new PropertyRef('innerClass.value');

        Map<PropertyRef, Object> propertyMap = new Map<PropertyRef, Object>(); 
        propertyMap.put(childRef, innerObj.value);
        propertyMap.put(parentRef, outerObj.innerClass.value); 

        System.assertEquals(2, propertyMap?.size(), 'Wrong # of map keys');
        System.assertEquals(innerObj?.value, propertyMap?.get(childRef), 'Wrong childRef.value');
        System.assertEquals(outerObj?.innerClass?.value, propertyMap?.get(parentRef), 'Wrong parentRef.innerClass.value');
    }

    // **** HELPER **** // 
    public class OuterClass {
        InnerClass innerClass = new InnerClass(); 
    }

    public class InnerClass {
        String value = 'hello world';
    }
}
