@IsTest
private class NamespaceUtils_Test {
	@IsTest
	static void shouldReturnCurrentNamespace() {
		List<ApexClass> matching = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'NamespaceUtils_Test'];
		ApexClass thisClass = (ApexClass) CollectionUtils.getIndexOf(matching, 0);
		String expected = thisClass?.NamespacePrefix;

		Test.startTest();
		String namespace = NamespaceUtils.getCurrent();
		Test.stopTest();

		System.assertEquals(expected, namespace, 'Wrong namespace returned');
	}

	@IsTest
	static void shouldOnlyQueryOnce() {
		for (Integer i = 0; i < 101; i++) {
			// This would break if we were calling SOQL each time!
			NamespaceUtils.getCurrent();
		}
		System.assertEquals(1, Limits.getQueries(), 'Wrong # of queries made');
	}
}
