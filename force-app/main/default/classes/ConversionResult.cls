global virtual class ConversionResult extends DmlResult {
	// This object wraps the Database.LeadConvertResult and allows for DML mocking
	protected Id accountId;
	protected Id contactId;
	protected Id opportunityId;
	protected Id personAccountId;

	public ConversionResult(Database.LeadConvertResult result) {
		super(result.getErrors(), result.isSuccess(), result.getLeadId(), Database.LeadConvertResult.class);
		this.accountId = result.getAccountId();
		this.contactId = result.getContactId();
		this.opportunityId = result.getOpportunityId();
		this.personAccountId = result.getRelatedPersonAccountId();
	}

	protected ConversionResult() {
		// Required for inheritance
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
