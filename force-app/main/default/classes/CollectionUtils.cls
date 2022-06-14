public abstract class CollectionUtils {
    public static Object filterCollection(List<Object> items, FilterLogic logic, Type outputType) {
        Set<Object> validItems = new Set<Object>(items); 
        for (Object item : validItems) {
            if (logic.meetsCriteria(item) == false) {
                validItems.remove(item); 
            }
        }
        return JSON.deserialize(JSON.serialize(validItems), outputType);
    }

    public static Object filterCollection(List<Object> items, Filter filter, Type outputType) {
        List<Filter> filters = new List<Filter>{filter};
        return CollectionUtils.filterCollection(items, new FilterLogic.AndLogic(filters), outputType);
    }

    public static Object mapByUniqueKey(List<Object> items, String key, Type outputType) {
        Map<Object, Object> results = new Map<Object, Object>(); 
        for (Object item : items) {
            String serialized = JSON.serialize(item); 
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(serialized);
            Object keyValue = deserialized.get(key); 
            results.put(keyValue, item);
        }
        return JSON.deserialize(JSON.serialize(results), outputType);
    }

    public static Object mapByUniqueKey(List<SObject> records, SObjectField keyField, Type outputType) {
        return CollectionUtils.mapByUniqueKey(records, String.valueOf(keyField), outputType); 
    }

    public static Object mapByCommonKey(List<Object> items, String key, Type outputType) {
        Map<Object, List<Object>> results = new Map<Object, List<Object>>(); 
        for (Object item : items) {
            String serialized = JSON.serialize(item);
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(serialized);
            Object keyValue = deserialized.get(key); 
            List<Object> matching = results.containsKey(keyValue) ? results.get(keyValue) : new List<Object>();
            matching.add(item); 
            results.put(keyValue, matching); 
        }
        return JSON.deserialize(JSON.serialize(results), outputType);
    }

    public static Object mapByCommonKey(List<SObject> records, SObjectField keyField, Type outputType) {
        return CollectionUtils.mapByCommonKey(records, String.valueOf(keyField), outputType); 
    }
}
