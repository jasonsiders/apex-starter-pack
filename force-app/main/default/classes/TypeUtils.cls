public class TypeUtils {
    static final String TYPE_ERROR_PREFIX = 'Invalid conversion from runtime type ';
    static final String TYPE_ERROR_SUFFIX = ' to ' + UnknownType.class.getName();

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
        return TypeUtils.getType(obj)?.getName()?.startsWith('List<');
    }

    public static Boolean isSet(Object obj) {
        return TypeUtils.getType(obj)?.getName()?.startsWith('Set<');
    }

    public static Boolean isMap(Object obj) {
        return TypeUtils.getType(obj)?.getName()?.startsWith('Map<');
    }

    public static Boolean isCollection(Object obj) {
        String typeName = TypeUtils.getType(obj)?.getName(); 
        return (
            typeName?.startsWith('List<') == true || 
            typeName?.startsWith('Set<') == true || 
            typeName?.startsWith('Map<') == true
        );
    }

    private class UnknownType {}
}