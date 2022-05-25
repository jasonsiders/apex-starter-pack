public class EnumUtils {
    public static Object valueOf(String stringValue, Type enumType) {
        try {
            String serialized = JSON.serialize(new List<Object>{stringValue}); 
            Type listType = Type.forName('List<' + enumType + '>');
            Object enumValue = ((List<Object>) JSON.deserialize(serialized, listType))[0];
            return enumValue;
        } catch (System.JsonException jsonError) {
            return null;
        }
    }
} 
