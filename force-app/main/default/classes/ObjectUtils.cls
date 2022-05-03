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
}