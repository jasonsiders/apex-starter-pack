public abstract class NamespaceUtils {
	static String namespace;
	static Boolean fetched = false;

	public static String getCurrent() {
		// Retrieves the namespace used by this package in the current org
		// Returns null if no namespace is used
		namespace = (fetched) ? namespace : fetchNamespace();
		return namespace;
	}

	static String fetchNamespace() {
		// Query for the current namespace. This should only be done once
		List<ApexClass> classes = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'NamespaceUtils'];
		ApexClass currentClass = (ApexClass) CollectionUtils.getIndexOf(classes, 0);
		String namespace = currentClass?.NamespacePrefix;
		NamespaceUtils.fetched = true;
		return namespace;
	}
}
