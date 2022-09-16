public abstract class TypeUtils {
	static final String TYPE_ERROR_PREFIX = 'Invalid conversion from runtime type ';
	static final String TYPE_ERROR_SUFFIX = ' to ' + UnknownType.class.getName();
	static final String LIST_PREFIX = 'List<';
	static final String MAP_PREFIX = 'Map<';
	static final String SET_PREFIX = 'Set<';

	public static Type getType(Object obj) {
		String typeName = TypeUtils.getTypeName(obj);
		return (typeName != null) ? Type.forName(typeName) : null;
	}

	public static String getTypeName(Object obj) {
		// Note: Type.forName() does not work on private types
		// If you need to dynamically get the type of a private object,
		// call this method instead + Type.forName() in the object's file to avoid errors
		String results;
		try {
			UnknownType dummyType = (UnknownType) obj;
		} catch (System.TypeException typeError) {
			return typeError.getMessage()?.substringAfter(TYPE_ERROR_PREFIX)?.substringBefore(TYPE_ERROR_SUFFIX);
		}
		return null;
	}

	public static Boolean isList(Object obj) {
		return TypeUtils.getType(obj)?.getName()?.startsWith(LIST_PREFIX);
	}

	public static Boolean isMap(Object obj) {
		return TypeUtils.getType(obj)?.getName()?.startsWith(MAP_PREFIX);
	}

	public static Boolean isSet(Object obj) {
		return TypeUtils.getType(obj)?.getName()?.startsWith(SET_PREFIX);
	}

	public static Boolean isCollection(Object obj) {
		String typeName = TypeUtils.getType(obj)?.getName();
		for (String token : new List<String>{ LIST_PREFIX, MAP_PREFIX, SET_PREFIX }) {
			if (typeName?.contains(token)) {
				return true;
			}
		}
		return false;
	}

	public static Object parseStringValue(String stringValue) {
		// Convert any string to an object of a specific type
		Object value = ((Map<String, Object>) JSON.deserializeUntyped('{"value":' + stringValue + '}')).values()[0];
		if (TypeUtils.getType(value) == String.class) {
			// Date/DateTimes are deserialized as Strings - must check for these manually
			for (Type typeCheck : new List<Type>{ Date.class, DateTime.class }) {
				try {
					value = JSON.deserialize(stringValue, typeCheck);
					break;
				} catch (System.JSONException error) {
					Logger.log(LoggingLevel.FINEST, value + ' is not a ' + typeCheck);
				}
			}
		}
		Logger.log(LoggingLevel.FINEST, stringValue + ' is a ' + TypeUtils.getTypeName(value));
		return value;
	}

	// Attempting to use < or > symbols directly on Objects will generate a compile error:
	// ! Inequality operator not allowed for this type: Object
	// Note: Blob, Boolean, Id, Long, String, and complex types are not supported in greater/less than operations
	public static Boolean greaterThan(Object value, Object comparison) {
		if (value != null && comparison != null) {
			switch on TypeUtils.getTypeName(value)?.toUpperCase() {
				when 'DATE', 'DATETIME' {
					DateTime dateValue = (DateTime) value;
					DateTime comparisonDate = (DateTime) comparison;
					Boolean result = dateValue > comparisonDate;
					return result;
				}
				when 'INTEGER', 'DECIMAL', 'DOUBLE' {
					Decimal decimalValue = (Decimal) value;
					Decimal comparisonDecimal = (Decimal) comparison;
					return decimalValue > comparisonDecimal;
				}
			}
		}
		return false;
	}

	public static Boolean lessThan(Object value, Object comparison) {
		if (value != null && comparison != null) {
			switch on TypeUtils.getTypeName(value)?.toUpperCase() {
				when 'DATE', 'DATETIME' {
					DateTime dateValue = (DateTime) value;
					DateTime comparisonDate = (DateTime) comparison;
					return dateValue < comparisonDate;
				}
				when 'INTEGER', 'DECIMAL', 'DOUBLE' {
					Decimal decimalValue = (Decimal) value;
					Decimal comparisonDecimal = (Decimal) comparison;
					return decimalValue < comparisonDecimal;
				}
			}
		}
		return false;
	}

	private class UnknownType {
	}
}
