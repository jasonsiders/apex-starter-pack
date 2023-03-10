global abstract class CollectionUtils {
	global static Object filterCollection(List<Object> items, ICriteria filter, Type outputType) {
		Set<Object> validItems = new Set<Object>(items);
		for (Object item : validItems) {
			if (filter.meetsCriteria(item) == false) {
				validItems.remove(item);
			}
		}
		return JSON.deserialize(JSON.serialize(validItems), outputType);
	}

	global static Object mapByUniqueKey(List<Object> items, String key, Type outputType) {
		Map<Object, Object> results = new Map<Object, Object>();
		for (Object item : items) {
			String serialized = JSON.serialize(item);
			Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(serialized);
			Object keyValue = deserialized.get(key);
			results.put(keyValue, item);
		}
		return JSON.deserialize(JSON.serialize(results), outputType);
	}

	global static Object mapByUniqueKey(List<SObject> records, SObjectField keyField, Type outputType) {
		return CollectionUtils.mapByUniqueKey(records, String.valueOf(keyField), outputType);
	}

	global static Object mapByCommonKey(List<Object> items, String key, Type outputType) {
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

	global static Object mapByCommonKey(List<SObject> records, SObjectField keyField, Type outputType) {
		return CollectionUtils.mapByCommonKey(records, String.valueOf(keyField), outputType);
	}

	global static Object getIndexOf(List<Object> items, Integer index) {
		if (index != null && items != null) {
			Integer size = items?.size();
			Integer minSize = (index + 1);
			Integer maxIndex = size - 1;
			Boolean isValid = (size >= minSize && index >= 0 && index <= maxIndex);
			return (isValid) ? items[index] : null;
		}
		return null;
	}

	global static Integer getMaxIndex(List<Object> items) {
		// Returns the "last" index of a collection
		// ex., if size == 1, will return 0; if size == 2, will return 1
		// If null or empty, will return null
		return items?.isEmpty() == false ? items.size() - 1 : null;
	}

	global static Object extractValues(List<Object> items, String key, Type returnType) {
		List<Object> values = new List<Object>();
		for (Object item : items) {
			Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(item));
			Object value = jsonMap.get(key);
			values.add(value);
		}
		return JSON.deserialize(JSON.serialize(values), returnType);
	}

	global static Object extractValues(List<Object> items, SObjectField field, Type returnType) {
		return CollectionUtils.extractValues(items, String.valueOf(field), returnType);
	}

	global static Object split(List<Object> items, Integer chunkSize, Type resultType) {
		List<Object> shallowCopy = items?.clone(); // Avoid transforming the original list
		List<Object> results = new List<Object>();
		while (shallowCopy?.isEmpty() == false) {
			List<Object> current = new List<Object>();
			for (Integer i = 0; i < chunkSize; i++) {
				Integer maxIndex = CollectionUtils.getMaxIndex(shallowCopy);
				Object lastItem = CollectionUtils.getIndexOf(shallowCopy, maxIndex);
				if (lastItem != null) {
					current?.add(lastItem);
					shallowCopy?.remove(maxIndex);
				}
			}
			results.add(current);
		}
		return JSON.deserialize(JSON.serialize(results), resultType);
	}

	global static Set<Object> toSet(List<Object> items) {
		return (items != null) ? new Set<Object>(items) : new Set<Object>();
	}
}
