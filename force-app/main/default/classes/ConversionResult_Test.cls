@IsTest
private class ConversionResult_Test {
	@IsTest
	static void shouldConstructFromLeadConvertResult() {
		Lead testLead = new Lead(
			Company = 'Acme Inc.',
			Email = 'john.doe@test.com.invalid',
			FirstName = 'John',
			LastName = 'Doe',
			Phone = '+15555555555'
		);
		DB.Dml.doInsert(testLead);
		Soql statusQuery = DB.Soql.newQuery(LeadStatus.SObjectType)
			.selectFields(LeadStatus.MasterLabel)
			.whereCriteria(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
			.setRowLimit(1);
		String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
		Database.LeadConvert leadConvertObj = new Database.LeadConvert();
		leadConvertObj.setLeadId(testLead.Id);
		leadConvertObj.setConvertedStatus(status);
		Database.LeadConvertResult convertResult = Database.convertLead(leadConvertObj);

		Test.startTest();
		ConversionResult result = new ConversionResult(convertResult);
		Test.stopTest();

		System.assertEquals(convertResult.isSuccess(), result.isSuccess(), 'Wrong isSuccess()');
		System.assertEquals(convertResult.getAccountId(), result.getAccountId(), 'Wrong accountId');
		System.assertEquals(convertResult.getContactId(), result.getContactId(), 'Wrong contactId');
		System.assertEquals(convertResult.getLeadId(), result.getLeadId(), 'Wrong leadId');
		System.assertEquals(convertResult.getOpportunityId(), result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(
			convertResult.getRelatedPersonAccountId(),
			result.getPersonAccountId(),
			'Wrong personAccountId'
		);
		System.assertEquals(convertResult.getErrors()?.size(), result.getErrors()?.size(), 'Wrong # of getErrors()');
	}
}
