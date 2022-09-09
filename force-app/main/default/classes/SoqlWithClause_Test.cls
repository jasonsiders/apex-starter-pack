@IsTest
private class SoqlWithClause_Test {
	@IsTest
	static void shouldGenerateWithUserModeClause() {
		SoqlWithClause withClause = new SoqlWithClause.ContextExpression(SoqlWithClause.Context.USER_MODE);
		System.assertEquals('WITH USER_MODE', withClause.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldGenerateWithSystemModeClause() {
		SoqlWithClause withClause = new SoqlWithClause.ContextExpression(SoqlWithClause.Context.SYSTEM_MODE);
		System.assertEquals('WITH SYSTEM_MODE', withClause.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldGenerateWithSecurityEnforcedClause() {
		SoqlWithClause withClause = new SoqlWithClause.ContextExpression(SoqlWithClause.Context.SECURITY_ENFORCED);
		System.assertEquals('WITH SECURITY_ENFORCED', withClause.toString(), 'Unexpected output');
	}

	@IsTest
	static void shouldGenerateDataCategoryClause() {
		DataCategoryFilter filter = new DataCategoryFilter('CategoryA__c', DataCategoryFilter.ABOVE, 'CategoryB__c');
		DataCategoryFilter.AndLogic logic = new DataCategoryFilter.AndLogic(new List<DataCategoryFilter>{ filter });
		SoqlWithClause withClause = new SoqlWithClause.DataCategoryExpression(logic);
		System.assertEquals('WITH CategoryA__c ABOVE CategoryB__c', withClause.toString(), 'Unexpected output');
	}
}
