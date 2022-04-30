public class TypeUtils {
    static final String TYPE_ERROR_PREFIX = 'Invalid conversion from runtime type ';
    static final String TYPE_ERROR_SUFFIX = ' to ' + UnknownType.class.getName();

    public static Type getType(Object obj) {
        Type results; 
        try {
            UnknownType dummyType = (UnknownType) obj; 
        } catch (System.TypeException typeError) {
            String typeName = typeError.getMessage()?.substringAfter(TYPE_ERROR_PREFIX)?.substringBefore(TYPE_ERROR_SUFFIX);
            return Type.forName(typeName);
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