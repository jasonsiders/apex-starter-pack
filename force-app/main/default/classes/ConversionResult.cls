public class ConversionResult extends DmlResult {
    // This object wraps the Database.LeadConvertResult and allows for DML mocking
    Id accountId; 
    Id contactId;
    Id opportunityId;
    Id personAccountId; 
    
    public ConversionResult(Database.LeadConvertResult result) {
        super(result.getErrors(), result.isSuccess(), result.getLeadId());
        this.accountId = result.getAccountId();
        this.contactId = result.getContactId();
        this.opportunityId = result.getOpportunityId();
        this.personAccountId = result.getRelatedPersonAccountId(); 
    }

    @TestVisible
    private ConversionResult(List<DmlResult.Error> errors, Boolean isSuccess, Database.LeadConvert leadConvertObj) {
        super(errors, isSuccess, leadConvertObj?.getLeadId());
        this.accountId = leadConvertObj?.getAccountId();
        this.contactId = leadConvertObj?.getContactId();
        this.opportunityId = leadConvertObj?.getOpportunityId();
        this.personAccountId = leadConvertObj?.getRelatedPersonAccountId();
    }

    public Id getAccountId() {
        return this.accountId; 
    }

    public Id getContactId() {
        return this.contactId;
    }

    public Id getLeadId() {
        return this.recordId; 
    }

    public Id getOpportunityId() {
        return this.opportunityId; 
    }

    public Id getPersonAccountId() {
        return this.personAccountId;
    }
}
