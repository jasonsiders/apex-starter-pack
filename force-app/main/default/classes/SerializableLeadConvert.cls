public inherited sharing class SerializableLeadConvert {
	/**
	 * Database.LeadConvert objects cannot be serialized, and therefore cannot be passed to async processes
	 * ! System.SerializationException: Not Serializable: com/salesforce/api/fast/List$$lcom/salesforce/api/Database/LeadConvert$$r...External entry point
	 * This object serves as a data access object based on the fairly open/transparent model documented below:
	 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_dml_convertLead.htm
	 **/
	@TestVisible
	Id accountId, contactId, leadId, opportunityId, ownerId; 
	@TestVisible
	String convertedStatus, opportunityName;
	@TestVisible
	Boolean doNotCreateOpportunity, overwriteLeadSource, sendNotificationEmail;
	@TestVisible
	SObject personAccount; // Note: Generic SObject, since not all orgs have PersonAccounts enabled

	public SerializableLeadConvert(Database.LeadConvert obj) {
		this.accountId = obj?.getAccountId();
		this.contactId = obj?.getContactId();
		this.convertedStatus = obj?.getConvertedStatus();
		this.leadId = obj?.getLeadId();
		this.opportunityId = obj?.getOpportunityId();
		this.opportunityName = obj?.getOpportunityName();
		this.ownerId = obj?.getOwnerId();
		this.personAccount = obj?.getRelatedPersonAccountRecord();
		this.doNotCreateOpportunity = obj?.isDoNotCreateOpportunity();
		this.overwriteLeadSource = obj?.isOverwriteLeadSource();
		this.sendNotificationEmail = obj?.isSendNotificationEmail();
	}

	public Database.LeadConvert toLeadConvert() {
		Database.LeadConvert obj = new Database.LeadConvert();
		obj.setAccountId(this.accountId);
		obj.setContactId(this.contactId);
		obj.setConvertedStatus(this.convertedStatus);
		obj.setLeadId(this.leadId);
		obj.setOpportunityId(this.opportunityId);
		obj.setOpportunityName(this.opportunityName);
		obj.setOwnerId(this.ownerId);
		obj.setRelatedPersonAccountId(this.personAccount?.Id);
		obj.setRelatedPersonAccountRecord(this.personAccount);
		obj.setDoNotCreateOpportunity(this.doNotCreateOpportunity);
		obj.setOverwriteLeadSource(this.overwriteLeadSource);
		obj.setSendNotificationEmail(this.sendNotificationEmail);
		return obj;
	}

	public static List<SerializableLeadConvert> wrap(List<Database.LeadConvert> leadConverts) {
		List<SerializableLeadConvert> results = new List<SerializableLeadConvert>();
		for (Database.LeadConvert leadConvert : leadConverts) {
			results.add(new SerializableLeadConvert(leadConvert));
		}
		return results;
	}

	public static List<Database.LeadConvert> unwrap(List<SerializableLeadConvert> wrappers) {
		List<Database.LeadConvert> results = new List<Database.LeadConvert>();
		for (SerializableLeadConvert wrapper : wrappers) {
			results.add(wrapper.toLeadConvert());
		}
		return results;
	}
}
