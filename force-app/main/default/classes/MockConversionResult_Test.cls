@IsTest 
private class MockConversionResult_Test {
    
	@IsTest
	static void shouldConstructFromMock() {
		DB.setDmlEngine(new DmlMock());
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

		Test.startTest(); 
		ConversionResult result = new MockConversionResult(new List<DmlResult.Error>(), true, leadConvertObj);
		Test.stopTest();

		System.assertEquals(true, result.isSuccess(), 'Wrong isSuccess()');
		System.assertEquals(leadConvertObj.getAccountId(), result.getAccountId(), 'Wrong accountId');
		System.assertEquals(leadConvertObj.getContactId(), result.getContactId(), 'Wrong contactId');
		System.assertEquals(leadConvertObj.getLeadId(), result.getLeadId(), 'Wrong leadId');
		System.assertEquals(leadConvertObj.getOpportunityId(), result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(
			leadConvertObj.getRelatedPersonAccountId(),
			result.getPersonAccountId(),
			'Wrong personAccountId'
		);
		System.assertEquals(0, result.getErrors()?.size(), 'Wrong # of getErrors()');
	}
}