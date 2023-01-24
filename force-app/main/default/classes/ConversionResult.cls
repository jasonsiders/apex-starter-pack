global class ConversionResult extends DmlResult {
	// This object wraps the Database.LeadConvertResult and allows for DML mocking
	Id accountId;
	Id contactId;
	Id opportunityId;
	Id personAccountId;

	public ConversionResult(Database.LeadConvertResult result) {
		super(result.getErrors(), result.isSuccess(), result.getLeadId(), Database.LeadConvertResult.class);
		this.accountId = result.getAccountId();
		this.contactId = result.getContactId();
		this.opportunityId = result.getOpportunityId();
		this.personAccountId = result.getRelatedPersonAccountId();
	}

	@TestVisible
	private ConversionResult(List<DmlResult.Error> errors, Boolean isSuccess, Database.LeadConvert leadConvertObj) {
		super(errors, isSuccess, leadConvertObj?.getLeadId(), Database.LeadConvertResult.class);
		this.accountId = leadConvertObj?.getAccountId();
		this.contactId = leadConvertObj?.getContactId();
		this.opportunityId = leadConvertObj?.getOpportunityId();
		this.personAccountId = leadConvertObj?.getRelatedPersonAccountId();
	}

	global Id getAccountId() {
		return this.accountId;
	}

	global Id getContactId() {
		return this.contactId;
	}

	global Id getLeadId() {
		return this.getId();
	}

	global Id getOpportunityId() {
		return this.opportunityId;
	}

	global Id getPersonAccountId() {
		return this.personAccountId;
	}
}
