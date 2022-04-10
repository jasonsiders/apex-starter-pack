public class Describes {
    private static Map<SObjectField, DescribeFieldResult> fieldDescribes = 
        new Map<SObjectField, DescribeFieldResult>();
    private static Map<SObjectType, DescribeSObjectResult> objectDescribes = 
        new Map<SObjectType, DescribeSObjectResult>();

    // **** FIELD DESCRIBES **** //    
    public static DescribeFieldResult getFieldDescribe(SObjectField field) {
        DescribeFieldResult describe = fieldDescribes.get(field); 
        if (describe == null && field != null) {
            describe = field.getDescribe(); 
            fieldDescribes.put(field, describe); 
        }
        return describe;
    }

    public static DescribeFieldResult getFieldDescribe(SObjectType objectType, String fieldName) {
        SObjectField field = getSObjectFieldByName(objectType, fieldName);
        return getFieldDescribe(field);
    }

    public static SObjectField getSObjectFieldByName(SObjectType objectType, String fieldName) {
        DescribeSObjectResult objectDescribe = getSObjectDescribe(objectType); 
        return objectDescribe?.fields?.getMap().get(fieldName); 
    }
    
    // **** SOBJECT DESCRIBES **** // 
    public static DescribeSObjectResult getSObjectDescribe(SObjectType objectType) {
        DescribeSObjectResult describe = objectDescribes.get(objectType); 
        if (describe == null && objectType != null) {
            describe = objectType.getDescribe(); 
            objectDescribes.put(objectType, describe); 
        }
        return describe;
    }

    public static DescribeSObjectResult getSObjectDescribe(String objectName) {
        SObjectType objectType = getSObjectTypeByName(objectName); 
        return getSObjectDescribe(objectType); 
    }
    
    public static SObjectType getSObjectTypeByName(String objectName) {
        return ((SObject) Type.forName(objectName)?.newInstance())?.getSObjectType();
    }
}