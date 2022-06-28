public abstract class SchemaUtils {
    static Map<SObjectField, DescribeFieldResult> FieldDescribes; 
    static Map<SObjectType, DescribeSObjectResult> SObjectDescribes;
    static Map<SObjectType, Map<String, ChildRelationship>> ChildRelationships;

    static {
        SchemaUtils.FieldDescribes = new Map<SObjectField, DescribeFieldResult>();
        SchemaUtils.SObjectDescribes = new Map<SObjectType, DescribeSObjectResult>();
        SchemaUtils.ChildRelationships = new Map<SObjectType, Map<String, ChildRelationship>>();
    }

    public static DescribeSObjectResult describeSObject(SObjectType objectType) {
        if (SchemaUtils.SObjectDescribes.containsKey(objectType) == false) {
            SchemaUtils.SObjectDescribes.put(objectType, objectType?.getDescribe());
        }
        return SchemaUtils.SObjectDescribes.get(objectType);
    }

    public static DescribeSObjectResult describeSObject(String objectName) {
        SObjectType objectType = SchemaUtils.getSObjectType(objectName); 
        return SchemaUtils.describeSObject(objectType); 
    }
    
    public static SObjectType getSObjectType(String objectName) {
        try {
            return ((SObject) Type.forName(objectName)?.newInstance())?.getSObjectType();
        } catch (System.NullPointerException nullError) {
            return null; 
        }
    }
 
    public static DescribeFieldResult describeField(SObjectField field) {
        if (SchemaUtils.FieldDescribes.containsKey(field) == false) {
            SchemaUtils.FieldDescribes.put(field, field?.getDescribe());
        }
        return SchemaUtils.FieldDescribes.get(field); 
    }

    public static DescribeFieldResult describeField(SObjectType objectType, String fieldName) {
        SObjectField field = SchemaUtils.getSObjectField(objectType, fieldName);
        return SchemaUtils.describeField(field);
    }

    public static SObjectField getSObjectField(SObjectType objectType, String fieldName) {
        return SchemaUtils.describeSObject(objectType)?.fields?.getMap().get(fieldName); 
    }

    public static SObjectField getSObjectField(String objectName, String fieldName) {
        SObjectType objectType = SchemaUtils.getSObjectType(objectName); 
        return SchemaUtils.getSObjectField(objectType, fieldName); 
    }

    public static ChildRelationship getChildRelationship(SObjectType objectType, String relationshipName) {
        DescribeSObjectResult objectDescribe = SchemaUtils.describeSObject(objectType); 
        if (objectDescribe != null && SchemaUtils.ChildRelationships.containsKey(objectType) == false) {
            Map<String, ChildRelationship> relationshipsByName = new Map<String, ChildRelationship>();
            for (ChildRelationship childRelationship : objectDescribe?.getChildRelationships()) {
                String childRelationshipName = childRelationship?.getRelationshipName(); 
                // Note: Some relationships (like Quotes on Account) do not have a relationship name?
                // This method does not support these relationships;
                // Generally speaking, if it can't be accessed in SOQL, it can't be used here
                if (childRelationshipName != null) {
                    relationshipsByName.put(childRelationshipName, childRelationship); 
                }
            }
            SchemaUtils.ChildRelationships.put(objectType, relationshipsByName); 
        }
        return SchemaUtils.ChildRelationships?.get(objectType)?.get(relationshipName); 
    }

    public static ChildRelationship getChildRelationship(String objectName, String relationshipName) {
        SObjectType objectType = SchemaUtils.getSObjectType(objectName);
        return SchemaUtils.getChildRelationship(objectType, relationshipName); 
    }
}