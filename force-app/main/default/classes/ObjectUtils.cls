global abstract class ObjectUtils {
	global static Object setParams(Object target, Map<String, Object> newValues) {
		Map<String, Object> parameters = ObjectUtils.toMap(target);
		parameters.putAll(newValues);
		String jsonString = JSON.serialize(parameters);
		Type targetType = TypeUtils.getType(target);
		return JSON.deserialize(jsonString, targetType);
	}

	global static Object setParams(Object target, String paramName, Object value) {
		return ObjectUtils.setParams(target, new Map<String, Object>{ paramName => value });
	}

	global static Map<String, Object> toMap(Object target) {
		return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(target));
	}

	global static String joinValues(List<Object> items, String delimiter) {
		List<String> values = new List<String>();
		for (Object item : items) {
			values.add(String.valueOf(item));
		}
		return String.join(values, delimiter);
	}
}
