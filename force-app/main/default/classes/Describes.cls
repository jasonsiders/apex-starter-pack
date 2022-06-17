public class Describes {
    static Map<Schema.SObjectField, Schema.DescribeFieldResult> fieldDescribes = 
        new Map<Schema.SObjectField, Schema.DescribeFieldResult>();
    static Map<Schema.SObjectType, Schema.DescribeSObjectResult> sObjectDescribes = 
        new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();
    static Map<Schema.SObjectType, Map<String, Schema.ChildRelationship>> childRelationships = 
        new Map<Schema.SObjectType, Map<String, Schema.ChildRelationship>>();

    public static Schema.DescribeSObjectResult getSObjectDescribe(Schema.SObjectType objectType) {
        if (Describes.sObjectDescribes.containsKey(objectType) == false) {
            Describes.sObjectDescribes.put(objectType, objectType?.getDescribe());
        }
        return Describes.sObjectDescribes.get(objectType);
    }

    public static Schema.DescribeSObjectResult getSObjectDescribe(String objectName) {
        Schema.SObjectType objectType = Describes.getSObjectTypeByName(objectName); 
        return Describes.getSObjectDescribe(objectType); 
    }
    
    public static Schema.SObjectType getSObjectTypeByName(String objectName) {
        try {
            return ((SObject) Type.forName(objectName)?.newInstance())?.getSObjectType();
        } catch (System.NullPointerException nullError) {
            return null; 
        }
    }
 
    public static Schema.DescribeFieldResult getFieldDescribe(Schema.SObjectField field) {
        if (Describes.fieldDescribes.containsKey(field) == false) {
            Describes.fieldDescribes.put(field, field?.getDescribe());
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

    public static Schema.SObjectField getSObjectFieldByName(String dotNotationField) {
        // Assumes that input is in this format: "Account.OwnerId"
        // Originally designed for use with CMDT's 'FieldDefinition' data type, which stores data in this format
        String objectName;
        String fieldName; 
        List<String> fieldParts = dotNotationField?.split('\\.');
        if (fieldParts != null && fieldParts?.size() == 2) {
            objectName = fieldParts[0];
            fieldName = fieldParts[1];
        }
        return Describes.getSObjectFieldByName(objectName, fieldName); 
    }

    public static Schema.ChildRelationship getChildRelationship(SObjectType objectType, String relationshipName) {
        DescribeSObjectResult objectDescribe = Describes.getSObjectDescribe(objectType); 
        if (objectDescribe != null && Describes.childRelationships.containsKey(objectType) == false) {
            Map<String, Schema.ChildRelationship> relationshipsByName = new Map<String, Schema.ChildRelationship>();
            for (Schema.ChildRelationship childRelationship : objectDescribe?.getChildRelationships()) {
                String childRelationshipName = childRelationship?.getRelationshipName(); 
                // Note: Some relationships (like Quotes on Account) do not have a relationship name?
                // This method does not support these relationships;
                // Generally speaking, if it can't be accessed in SOQL, it can't be used here
                if (childRelationshipName != null) {
                    relationshipsByName.put(childRelationshipName, childRelationship); 
                }
            }
            Describes.childRelationships.put(objectType, relationshipsByName); 
        }
        return Describes.childRelationships?.get(objectType)?.get(relationshipName); 
    }

    public static Schema.ChildRelationship getChildRelationship(String objectName, String relationshipName) {
        SObjectType objectType = Describes.getSObjectTypeByName(objectName);
        return Describes.getChildRelationship(objectType, relationshipName); 
    }
}