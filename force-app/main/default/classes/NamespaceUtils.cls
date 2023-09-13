global abstract class NamespaceUtils {
	static final String PACKAGE_NAMESPACE = 'apxsp'; 

	global static String getNamespaceOf(Object obj) {
		String typeName = TypeUtils.getTypeName(obj); 
		return NamespaceUtils.getNamespaceOf(typeName); 
	}

	global static String getNamespaceOf(Type type) {
		String typeName = String.valueOf(type);
		return NamespaceUtils.getNamespaceOf(typeName);
	}

	global static String getNamespaceOf(String typeName) {
		// Return the namespace of a specific object type
		for (String separator : new List<String>{'__', '.'}) {
			if (typeName?.contains(separator) == true) {
				String regex = '\\' + separator; 
				List<String> parts = typeName?.split(regex);
				return parts?.isEmpty() == false ? parts[0] : null;
			}
		}
		return null;
	}

	@AuraEnabled(cacheable=true)
	global static String getPackageNamespace() {
		// Returns the namespace of the current package if in a packaged context, or null if in an unpackaged context
		String typeName = NamespaceUtils.class?.getName();
		return (typeName?.startsWith(PACKAGE_NAMESPACE)) ? PACKAGE_NAMESPACE : null;
	}
}
