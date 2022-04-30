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

    private class UnknownType {}
}