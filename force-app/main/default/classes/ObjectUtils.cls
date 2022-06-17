public class ObjectUtils {
    public static Object setParams(Object target, Map<String, Object> newValues) {
        Map<String, Object> parameters = ObjectUtils.toMap(target);
        parameters.putAll(newValues);
        String jsonString = JSON.serialize(parameters); 
        Type targetType = TypeUtils.getType(target); 
        return JSON.deserialize(jsonString, targetType);
    }

    public static Object setParams(Object target, String paramName, Object value) {
        return ObjectUtils.setParams(target, new Map<String, Object>{paramName => value});
    }

    public static Map<String, Object> toMap(Object target) {
        return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(target));
    }

    public static SObject setReadOnlyField(
        SObject target, 
        Schema.SObjectField fieldName, 
        Object value
    ) {
        return ObjectUtils.setReadOnlyField(target, String.valueOf(fieldName), value);
    }

    public static SObject setReadOnlyField(
        SObject target, 
        Schema.ChildRelationship childRelationship, 
        Object value
    ) {
        return ObjectUtils.setReadOnlyField(target, childRelationship?.getRelationshipName(), value);
    }

    public static SObject setReadOnlyField(SObject target, String fieldName, Object value) {
        // Allows us to (mostly) get around Apex restrictions around certain SObjectFields,
        // along with 
        String jsonString = JSON.serialize(target);
        Map<String, Object> targetMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        if (value instanceOf List<SObject>) {
            // When populating child records via JSON, take special precautions to avoid this error:
            // ! System.JSONException: QueryResult must start with '{'
            // https://salesforce.stackexchange.com/questions/149574/salesforce-queryresult-must-start-with
            List<SObject> childRecords = (List<SObject>) value; 
            value = new Map<String, Object>{
                'totalSize' => childRecords?.size(),
                'done' => true,
                'records' => childRecords
            };
        }
        targetMap.put(fieldName, value); 
        jsonString = JSON.serializePretty(targetMap); 
        return (SObject) JSON.deserialize(jsonString, SObject.class);
    }

    public static SObject setLookupField(SObject target, SObjectField field, SObject parent) {
        // Allows us to set lookup fields, complete with parent object values
        // This is especially useful in mocking without the need for SOQL
        String serializedTarget = JSON.serialize(target);
        Map<String, Object> mappedTarget = (Map<String, Object>) JSON.deserializeUntyped(serializedTarget); 
        mappedTarget.put(String.valueOf(field), parent?.Id); 
        // Note: When populating parent records via JSON, must also include a "hidden" relationship object
        String parentSObjectName = String.valueOf(parent?.getSObjectType());
        String serializedParent = JSON.serialize(parent); 
        Map<String, Object> mappedParent = (Map<String, Object>) JSON.deserializeUntyped(serializedParent);
        mappedParent.put('attributes', new Map<String, Object>{
            'type' => parentSObjectName,
            'url' => String.format('/services/data/{0}/sobjects/{1}/{2}', new List<String>{
                OrgUtils.getCurrentApiVersion()?.toPlainString(),
                parentSObjectName,
                parent?.Id
            })
        });
        // The relationship object's key is the same as the Id field, minus "Id"/"__c" (depending if Standard/Custom)
        String relationshipName = Describes.getFieldDescribe(field)?.getRelationshipName();
        mappedTarget.put(relationshipName, mappedParent);
        return (SObject) JSON.deserialize(JSON.serialize(mappedTarget), SObject.class);
    }

    public static String joinValues(List<Object> items, String delimiter) {
        List<String> values = new List<String>();
        for (Object item : items) {
            values.add(String.valueOf(item));
        }
        return String.join(values, delimiter);
    }
}
