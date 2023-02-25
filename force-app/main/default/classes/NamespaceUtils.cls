global abstract class NamespaceUtils {
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
		for (String suffix : new List<String>{'__', '.'}) {
			if (typeName?.contains(suffix)) {
				String regex = '\\' + suffix; 
				List<String> parts = typeName?.split(regex);
				return parts[0];
			}
		}
		return null;
	}	
}
