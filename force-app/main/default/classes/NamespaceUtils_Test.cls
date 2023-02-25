@IsTest
private class NamespaceUtils_Test {
	@IsTest 
	static void shouldReturnNamespaceOfObject() {
		String expected = NamespaceUtils_Test.queryNamespace(); 
		Object obj = DB.Soql.newQuery(Account.SObjectType); // An object in this namespace

		Test.startTest();
		String namespace = NamespaceUtils.getNamespaceOf(obj); 
		Test.stopTest();

		System.assertEquals(expected, namespace, 'Wrong namespace returned');
	}

	@IsTest
	static void shouldReturnNamespaceOfType() {
		String expected = NamespaceUtils_Test.queryNamespace();
		Type classType = NamespaceUtils_Test.class;

		Test.startTest();
		String namespace = NamespaceUtils.getNamespaceOf(classType);
		Test.stopTest();

		System.assertEquals(expected, namespace, 'Wrong namespace returned');
	}

	@IsTest 
	static void shouldReturnNullForNonNamespacedObject() {
		Account account = new Account(); // Never will have a namespace
		System.assertEquals(null, NamespaceUtils.getNamespaceOf(account), 'Account has a namespace');
	}

	@IsTest 
	static void shouldReturnCorrectValuesForInnerTypes() {
		String expected = NamespaceUtils_Test.queryNamespace(); 
		Object obj = new InnerClass(); 
		System.assertEquals(expected, NamespaceUtils.getNamespaceOf(obj), 'Inner Class should not have a namespace');
	}

	@IsTest 
	static void shouldReturnNamespaceOfStandardApexObjects() {
		// Many standard apex objects actually have a namespace - though they can be often be referenced w/out it
		Object obj = System.LoggingLevel.DEBUG;
		System.assertEquals('System', NamespaceUtils.getNamespaceOf(obj), 'Wrong namespace');
	}

	// **** HELPER **** //
	static String queryNamespace() {
		List<ApexClass> matching = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'NamespaceUtils_Test'];
		ApexClass currentClass = (ApexClass) CollectionUtils.getIndexOf(matching, 0);
		return currentClass?.NamespacePrefix;
	}

	public class InnerClass {}
}
