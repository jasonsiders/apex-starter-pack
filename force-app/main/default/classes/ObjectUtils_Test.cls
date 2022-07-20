@IsTest
private class ObjectUtils_Test {
    @IsTest
    static void shouldSetMultipleValues() {
        ExampleObject instance = new ExampleObject();
        Map<String, Object> testParams = new Map<String, Object>{
            'boolValue' => true,
            'dateValue' => Date.today(),
            'dateTimeValue' => DateTime.now(),
            'numValue' => 1234.56,
            'textValue' => 'Hello World!',
            'timeValue' => DateTime.now().time()
        };

        Test.startTest();
        instance = (ExampleObject) ObjectUtils.setParams(instance, testParams);
        Test.stopTest();

        System.assertEquals(testParams.get('boolValue'), instance.boolValue, 'Wrong boolValue');
        System.assertEquals(testParams.get('dateValue'), instance.dateValue, 'Wrong dateValue');
        System.assertEquals(testParams.get('dateTimeValue'), instance.dateTimeValue, 'Wrong dateTimeValue');
        System.assertEquals(testParams.get('numValue'), instance.numValue, 'Wrong numValue');
        System.assertEquals(testParams.get('textValue'), instance.textValue, 'Wrong textValue');
        System.assertEquals(testParams.get('timeValue'), instance.timeValue, 'Wrong timeValue');
    }

    @IsTest
    static void shouldSetSingleValue() {
        ExampleObject instance = new ExampleObject();

        Test.startTest();
        instance = (ExampleObject) ObjectUtils.setParams(instance, 'boolValue', true);
        Test.stopTest();

        System.assertEquals(true, instance.boolValue, 'Wrong boolValue');
        System.assertEquals(null, instance.dateValue, 'dateValue was overwritten');
        System.assertEquals(null, instance.dateTimeValue, 'dateTimeValue was overwritten');
        System.assertEquals(null, instance.numValue, 'numValue was overwritten');
        System.assertEquals(null, instance.textValue, 'textValue was overwritten');
        System.assertEquals(null, instance.timeValue, 'timeValue was overwritten');
    }

    @IsTest
    static void shouldConvertToMapFromStatic() {
        ExampleObject instance = new ExampleObject();
        instance.boolValue = false;
        instance.dateValue = Date.today().addDays(-90);
        instance.dateTimeValue = DateTime.now().addYears(100);
        instance.numValue = 34;
        instance.textValue = 'New text!';
        instance.timeValue = DateTime.now().time().addHours(12);

        Test.startTest();
        Map<String, Object> instanceMap = ObjectUtils.toMap(instance);
        Test.stopTest();

        System.assertEquals(instance.boolValue, instanceMap.get('boolValue'), 'Wrong boolValue');
        System.assertEquals(instance.numValue, instanceMap.get('numValue'), 'Wrong numValue');
        System.assertEquals(instance.textValue, instanceMap.get('textValue'), 'Wrong textValue');
    }

    @IsTest
    static void shouldNotWorkOnClassesWithUntypedObjects() {
        InvalidObject instance = new InvalidObject(); 
        Test.startTest();
        Exception caughtError;
        try {
            instance = (InvalidObject) ObjectUtils.setParams(instance, 'boolValue', true);
        } catch (System.JSONException thrownError) {
            // ! Apex Type unsupported in JSON: Object
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught. Instance: ' + instance);
    }

    @IsTest 
    static void shouldNotWorkOnPrivateClasses() {
        PrivateObject instance = new PrivateObject(); 
        
        Test.startTest();
        Exception caughtError; 
        try {
            instance = (PrivateObject) ObjectUtils.setParams(instance, 'boolValue', true);
        } catch (System.NullPointerException thrownError) {
            caughtError = thrownError;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtError, 'An error was not thrown/caught. Instance: ' + instance); 
    }

    @IsTest 
    static void shouldJoinUntypedObjects() {
        List<Integer> values = new List<Integer>{1, 2, 3, 4};
        String delimiter = 'eAndA'; // A music theory reference
        String expected = '1eAndA2eAndA3eAndA4';
        System.assertEquals(expected, ObjectUtils.joinValues(values, delimiter), 'Wrong delimited value'); 
    }

    // **** HELPER **** // 
    public virtual class ExampleObject {
        Boolean boolValue;
        Date dateValue;
        DateTime dateTimeValue;
        Decimal numValue;
        String textValue;
        Time timeValue;
    }

    public class InvalidObject extends ExampleObject {
        Object unknownValue = DateTime.now(); 
        // Note: Since a value is assigned to an Object property, 
        // an error will be thrown when using JSON.de/serialize()
        // For some reason, an error is NOT thrown if a value is not assigned
    }

    private class PrivateObject extends ExampleObject {
        // Note: TypeUtils.getType() should not work on private types,
        // since it uses a try/catch method to get the type name
    }
}