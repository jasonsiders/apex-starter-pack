public abstract class SchemaUtils {
    static Map<SObjectField, DescribeFieldResult> FieldDescribes; 
    static Map<SObjectType, DescribeSObjectResult> SObjectDescribes;
    static Map<SObjectField, ChildRelationship> ChildRelationships; 

    static {
        SchemaUtils.FieldDescribes = new Map<SObjectField, DescribeFieldResult>();
        SchemaUtils.SObjectDescribes = new Map<SObjectType, DescribeSObjectResult>();
        SchemaUtils.ChildRelationships = new Map<SObjectField, ChildRelationship>();
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

    public static SObjectType getSObjectType(SObjectField field) {
        // Retrieves the current SObjectType from any SObjectField
        // Surprising there isn't an easier/built in DescribeFieldResult method to do this
        try {
            new Account().put(field, null);
            return Account.SObjectType;
        } catch (System.SObjectException error) {
            final String objectName = error.getMessage()?.substringBefore('.');
            return getSObjectType(objectName);
        }
    }

    public static SObjectType getParentSObjectType(SObjectField lookupField) {
        // Retrieves the parent SObjectType that a lookup field points to
        // Any non-lookup fields will return null
        List<SObjectType> parentSObjectTypes = SchemaUtils.describeField(lookupField)?.getReferenceTo();
        return (parentSObjectTypes?.isEmpty() == false) ? parentSObjectTypes[0] : null;
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

    public static SObjectField getSObjectFieldByLocalName(SObjectType objectType, String localName) {
        // Note: You can't always rely on Strings to return consistent results in packaged/non-packaged environments
        // This method allows you to search for a specific field by its local name (sans-namespace)
        List<SObjectField> allFields = SchemaUtils.describeSObject(objectType)?.fields?.getMap()?.values();
        for (SObjectField field : allFields) {
            if (SchemaUtils.describeField(field)?.getLocalName() == localName) {
                return field;
            }
        }
        return null; // None found for the current SObjectType
    }

    public static String getSoqlReference(List<SObjectField> fields) {
        // Constructs a SOQL-usable String from multiple related SObjectFields
        // Fields must be listed in the order of their relationship
        // ex., "Contact.Account.Owner.Profile.Name"
        List<String> references = new List<String>();
        if (fields?.isEmpty() == false) {
            Integer lastIndex = fields.size() - 1;
            SObjectField lastField = fields[lastIndex];
            for (SObjectField field : fields) {
                String reference = (field != lastField) 
                    ? SchemaUtils.describeField(field)?.getRelationshipName() 
                    : String.valueOf(field);
                references.add(reference);
            }
        }
        return String.join(references, '.');
    }

    public static ChildRelationship getChildRelationship(SObjectField lookupField) {
        SObjectType parentObject = SchemaUtils.getParentSObjectType(lookupField);
        if (parentObject != null && SchemaUtils.ChildRelationships.containsKey(lookupField) == false) {
            // Map all relationships for the parent SObjectType by the relationship's lookup field
            for (ChildRelationship relationship : SchemaUtils.describeSObject(parentObject)?.getChildRelationships()) {
                SchemaUtils.ChildRelationships.put(relationship?.getField(), relationship); 
            }
        }
        return SchemaUtils.ChildRelationships.get(lookupField); 
    }
}