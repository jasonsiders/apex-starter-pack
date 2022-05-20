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
}
