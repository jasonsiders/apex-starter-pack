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
		Databaselayer.Dml.doInsert(testLead);
		Soql statusQuery = Databaselayer.Soql.newQuery(LeadStatus.SObjectType)
			.selectFields(LeadStatus.MasterLabel)
			.whereFilters(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
			.setRowLimit(1);
		String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
		Database.LeadConvert leadConvertObj = new Database.LeadConvert();
		leadConvertObj.setLeadId(testLead.Id);
		leadConvertObj.setConvertedStatus(status);
		Database.LeadConvertResult convertResult = Database.convertLead(leadConvertObj);

		Test.startTest();
		ConversionResult result = new ConversionResult(convertResult);
		Test.stopTest();

		System.assertEquals(convertResult.isSuccess(), result.isSuccess, 'Wrong isSuccess');
		System.assertEquals(convertResult.getAccountId(), result.getAccountId(), 'Wrong accountId');
		System.assertEquals(convertResult.getContactId(), result.getContactId(), 'Wrong contactId');
		System.assertEquals(convertResult.getLeadId(), result.getLeadId(), 'Wrong leadId');
		System.assertEquals(convertResult.getOpportunityId(), result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(
			convertResult.getRelatedPersonAccountId(),
			result.getPersonAccountId(),
			'Wrong personAccountId'
		);
		System.assertEquals(convertResult.getErrors()?.size(), result.errors?.size(), 'Wrong # of errors');
	}

	@IsTest
	static void shouldConstructFromMock() {
		DatabaseLayer.setDmlEngine(new DmlMock());
		Lead testLead = new Lead(
			Company = 'Acme Inc.',
			Email = 'john.doe@test.com.invalid',
			FirstName = 'John',
			LastName = 'Doe',
			Phone = '+15555555555'
		);
		Databaselayer.Dml.doInsert(testLead);
		Soql statusQuery = Databaselayer.Soql.newQuery(LeadStatus.SObjectType)
			.selectFields(LeadStatus.MasterLabel)
			.whereFilters(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
			.setRowLimit(1);
		String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
		Database.LeadConvert leadConvertObj = new Database.LeadConvert();
		leadConvertObj.setLeadId(testLead.Id);
		leadConvertObj.setConvertedStatus(status);

		Test.startTest();
		ConversionResult result = new ConversionResult(new List<DmlResult.Error>(), true, leadConvertObj);
		Test.stopTest();

		System.assertEquals(true, result.isSuccess, 'Wrong isSuccess');
		System.assertEquals(leadConvertObj.getAccountId(), result.getAccountId(), 'Wrong accountId');
		System.assertEquals(leadConvertObj.getContactId(), result.getContactId(), 'Wrong contactId');
		System.assertEquals(leadConvertObj.getLeadId(), result.getLeadId(), 'Wrong leadId');
		System.assertEquals(leadConvertObj.getOpportunityId(), result.getOpportunityId(), 'Wrong opportunityId');
		System.assertEquals(
			leadConvertObj.getRelatedPersonAccountId(),
			result.getPersonAccountId(),
			'Wrong personAccountId'
		);
		System.assertEquals(0, result.errors?.size(), 'Wrong # of errors');
	}
}
