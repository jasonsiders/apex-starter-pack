@IsTest
public class DmlMock extends Dml {
    // Publish Methods
    public override List<DmlResult> doPublish(List<SObject> platformEvents) {
        Dml.Published.add(platformEvents); 
        return this.mockDmlResults(platformEvents);
    }
    
    // Insert Methods
    public override List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone) {
        records = TestUtils.generateFakeIds(records);
        Dml.Inserted.add(records); 
        return this.mockDmlResults(records);
    }

    // Update Methods
    public override List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone) {
        Dml.Updated.add(records); 
        return this.mockDmlResults(records);
    }

    // Upsert Methods
    public override List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone) {
        records = TestUtils.generateFakeIds(records); 
        Dml.Upserted.add(records); 
        return this.mockDmlResults(records);
    }

    public override List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
        return this.doUpsert(records); 
    }

    // Delete Methods
    public override List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone) {
        Dml.Deleted.add(records); 
        return this.mockDmlResults(records);
    }

    // Hard Delete Methods
    public override List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone) {
        this.doDelete(records); 
        return this.mockDmlResults(records);
    }

    // Undelete Methods
    public override List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone) {
        Dml.Undeleted.add(records); 
        return this.mockDmlResults(records);
    }

    // Convert Methods
    public override List<DmlResult> doConvert(List<Database.LeadConvert> leadConverts) {
        List<ConversionResult> results = new List<ConversionResult>();
        for (Database.LeadConvert leadConvert : leadConverts) {
            results.add((ConversionResult) this.doConvert(leadConvert));
        }   
        return results;
    }

    public override DmlResult doConvert(Database.LeadConvert leadConvert) {
        // 1. Find/Create an Account, and populate the LeadConvert object with its Id
        Boolean isPersonAccount = leadConvert.getRelatedPersonAccountId() != null; 
        Account account = new Account(
            OwnerId = leadConvert.getOwnerId(),   
            Id = (isPersonAccount) ? leadConvert.getRelatedPersonAccountId() : leadConvert.getAccountId()
        );
        if (account.Id == null) {
            this.doInsert(account);
        }
        leadConvert.setAccountId(account.Id); 
        // 2. Find/Create a Contact, and populate the LeadConvert object with its Id
        Contact contact = new Contact(
            AccountId = account.Id,
            Id = leadConvert.getContactId(),
            OwnerId = leadConvert.getOwnerId()
        );
        if (contact.Id == null) {
            this.doInsert(contact); 
        }
        leadConvert.setContactId(contact.Id);
        // 3. Find/Create an Opportunity, and populate the LeadConvert object with its Id
        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            Id = leadConvert.getOpportunityId(),
            Name = leadConvert.getOpportunityName(),
            OwnerId = leadConvert.getOwnerId()
        );
        if (opportunity.Id == null && leadConvert.isDoNotCreateOpportunity() == false) {
            this.doInsert(opportunity); 
        }
        leadConvert.setOpportunityId(opportunity.Id); 
        return new ConversionResult(new List<DmlResult.Error>(), true, leadConvert); 
    }

    // Utility Methods
    @TestVisible
    private List<DmlResult> mockDmlResults(List<SObject> records) {
        List<DmlResult> dmlResults = new List<DmlResult>();
        for (SObject record : records) {
            dmlResults.add(new DmlResult(
                new List<DmlResult.Error>(), 
                true, 
                record.Id
            ));
        }
        return dmlResults;
    }
}