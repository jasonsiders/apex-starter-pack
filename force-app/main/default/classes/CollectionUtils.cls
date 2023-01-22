public abstract class CollectionUtils {
	public static Object filterCollection(List<Object> items, ICriteria filter, Type outputType) {
		Set<Object> validItems = new Set<Object>(items);
		for (Object item : validItems) {
			if (filter.meetsCriteria(item) == false) {
				validItems.remove(item);
			}
		}
		return JSON.deserialize(JSON.serialize(validItems), outputType);
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

	public static Object getIndexOf(List<Object> items, Integer index) {
		// Safely returns an item at a given index. If the index does not exist, will return null
		// Note: Indexes starts at 0, but <List>.size() starts at 1
		Integer size = (items != null) ? items?.size() : 0;
		Integer minSize = (index + 1);
		return (size >= minSize) ? items[index] : null;
	}

	public static Integer getMaxIndex(List<Object> items) {
		// Returns the "last" index of a collection
		// ex., if size == 1, will return 0; if size == 2, will return 1
		// If null or empty, will return null
		return items?.isEmpty() == false ? items.size() - 1 : null;
	}

	public static Object extractValues(List<Object> items, String key, Type returnType) {
		List<Object> values = new List<Object>();
		for (Object item : items) {
			Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(item));
			Object value = jsonMap.get(key);
			values.add(value);
		}
		return JSON.deserialize(JSON.serialize(values), returnType);
	}

	public static Object extractValues(List<Object> items, SObjectField field, Type returnType) {
		return CollectionUtils.extractValues(items, String.valueOf(field), returnType);
	}
}
