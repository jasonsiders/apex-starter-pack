public class Describes {
    private static Map<Schema.SObjectField, Schema.DescribeFieldResult> fieldDescribes = 
        new Map<Schema.SObjectField, Schema.DescribeFieldResult>();
    private static Map<Schema.SObjectType, Schema.DescribeSObjectResult> objectDescribes = 
        new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();
    private static Map<Schema.SObjectType, Map<String, Schema.ChildRelationship>> childRelationships = 
        new Map<Schema.SObjectType, Map<String, Schema.ChildRelationship>>();

    public static Schema.DescribeSObjectResult getSObjectDescribe(Schema.SObjectType objectType) {
        if (Describes.objectDescribes.containsKey(objectType) == false) {
            Describes.objectDescribes.put(objectType, objectType.getDescribe());
        }
        return Describes.objectDescribes.get(objectType);
    }

    public static Schema.DescribeSObjectResult getSObjectDescribe(String objectName) {
        Schema.SObjectType objectType = Describes.getSObjectTypeByName(objectName); 
        return Describes.getSObjectDescribe(objectType); 
    }
    
    public static Schema.SObjectType getSObjectTypeByName(String objectName) {
        return ((SObject) Type.forName(objectName)?.newInstance())?.getSObjectType();
    }
 
    public static Schema.DescribeFieldResult getFieldDescribe(Schema.SObjectField field) {
        if (Describes.fieldDescribes.containsKey(field) == false) {
            Describes.fieldDescribes.put(field, field.getDescribe());
        }
        return Describes.fieldDescribes.get(field); 
    }

    public static Schema.DescribeFieldResult getFieldDescribe(Schema.SObjectType objectType, String fieldName) {
        Schema.SObjectField field = Describes.getSObjectFieldByName(objectType, fieldName);
        return Describes.getFieldDescribe(field);
    }

    public static Schema.SObjectField getSObjectFieldByName(Schema.SObjectType objectType, String fieldName) {
        return Describes.getSObjectDescribe(objectType)?.fields?.getMap().get(fieldName); 
    }

    public static Schema.SObjectField getSObjectFieldByName(String objectName, String fieldName) {
        Schema.SObjectType objectType = Describes.getSObjectTypeByName(objectName); 
        return Describes.getSObjectFieldByName(objectType, fieldName); 
    }

    public static Schema.ChildRelationship getChildRelationship(SObjectType objectType, String relationshipName) {
        if (Describes.childRelationships.containsKey(objectType) == false) {
            Map<String, ChildRelationship> relationshipsByName = new Map<String, ChildRelationship>(); 
            for (Schema.ChildRelationship relationship : Describes.getSObjectDescribe(objectType).getChildRelationships()) {
                relationshipsByName.put(relationship.getRelationshipName(), relationship);
            }
            Describes.childRelationships.put(objectType, relationshipsByName); 
        }
        return Describes.childRelationships.get(objectType).get(relationshipName);
    }

    public static Schema.ChildRelationship getChildRelationship(String objectName, String relationshipName) {
        SObjectType objectType = Describes.getSobjectTypeByName(objectName);
        return Describes.getChildRelationship(objectType, relationshipName); 
    }
}