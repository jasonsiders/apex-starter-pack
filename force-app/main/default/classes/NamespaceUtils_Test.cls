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

	// **** HELPER **** //
	static String queryNamespace() {
		List<ApexClass> matching = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'NamespaceUtils_Test'];
		ApexClass currentClass = (ApexClass) CollectionUtils.getIndexOf(matching, 0);
		return currentClass?.NamespacePrefix;
	}
}
