public abstract class EnumUtils {
    public static Object valueOf(String stringValue, Type enumType) {
        try {
            // Note: You can't deserialize to Enums like you can for primitive types,
            // but you CAN use JSON.deserialize() to convert a List<Object> to a List<Enum>
            Type listType = Type.forName('List<' + enumType + '>');
            String serialized = JSON.serialize(new List<Object>{stringValue}); 
            Object enumValue = ((List<Object>) JSON.deserialize(serialized, listType))[0];
            return enumValue;
        } catch (System.JsonException jsonError) {
            return null;
        }
    }
} 
