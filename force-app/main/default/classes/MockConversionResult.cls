@IsTest 
global class MockConversionResult extends ConversionResult {
    // Gives visibility into the ConversionResult class constructor outside the package
	global MockConversionResult(List<DmlResult.Error> errors, Boolean isSuccess, Database.LeadConvert leadConvertObj) {
        this.errors = errors; 
        this.isSuccess = isSuccess; 
        this.recordId = leadConvertObj?.getLeadId();
        this.sourceType = Database.LeadConvertResult.class;
		this.accountId = leadConvertObj?.getAccountId();
		this.contactId = leadConvertObj?.getContactId();
		this.opportunityId = leadConvertObj?.getOpportunityId();
		this.personAccountId = leadConvertObj?.getRelatedPersonAccountId();
	}
}