@IsTest
private class NamespaceUtils_Test {
	@IsTest
	static void shouldReturnCurrentNamespace() {
		List<ApexClass> matching = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'NamespaceUtils_Test'];
		ApexClass currentClass = (ApexClass) CollectionUtils.getIndexOf(matching, 0);
		String expected = currentClass?.NamespacePrefix;
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
}
