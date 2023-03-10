@IsTest
global class DmlMock extends Dml {
	static Integer numIdsGenerated = 0;

	global static Id generateFakeId(SObjectType objectType) {
		String prefix = objectType?.getDescribe()?.getKeyPrefix();
		String suffix = String.valueOf(numIdsGenerated++);
		return prefix + '0'.repeat(15 - suffix?.length()) + suffix;
	}

	global static SObject generateFakeId(SObject record) {
		return generateFakeId(new List<SObject>{ record })[0];
	}

	global static List<SObject> generateFakeId(List<SObject> records) {
		for (SObject record : records) {
			record.Id = (record?.Id != null) ? record?.Id : generateFakeId(record?.getSObjectType());
		}
		return records;
	}

	global static void resetHistory() {
		// Sometimes in tests, it's useful to reset the Dml tracking,
		// especially to determine what changes were made during the test action itself, vs. setup
		for (
			Dml.History history : new List<Dml.History>{
				Dml.Inserted,
				Dml.Updated,
				Dml.Upserted,
				Dml.Deleted,
				Dml.Undeleted,
				Dml.Published,
				Dml.Converted
			}
		) {
			history.clear();
		}
	}

	// Publish Methods
	global override List<DmlResult> doPublish(List<SObject> platformEvents) {
		Dml.Published?.add(platformEvents);
		return this.mockDmlResults(platformEvents, Database.SaveResult.class);
	}

	// Insert Methods
	global override List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone) {
		records = DmlMock.generateFakeId(records);
		Dml.Inserted?.add(records);
		return this.mockDmlResults(records, Database.SaveResult.class);
	}

	// Update Methods
	global override List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone) {
		Dml.Updated?.add(records);
		return this.mockDmlResults(records, Database.SaveResult.class);
	}

	// Upsert Methods
	global override List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone) {
		records = DmlMock.generateFakeId(records);
		Dml.Upserted?.add(records);
		return this.mockDmlResults(records, Database.UpsertResult.class);
	}

	global override List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
		return this.doUpsert(records);
	}

	// Delete Methods
	global override List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone) {
		Dml.Deleted?.add(records);
		return this.mockDmlResults(records, Database.DeleteResult.class);
	}

	// Hard Delete Methods
	global override List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone) {
		this.doDelete(records);
		return this.mockDmlResults(records, Database.DeleteResult.class);
	}

	// Undelete Methods
	global override List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone) {
		Dml.Undeleted?.add(records);
		return this.mockDmlResults(records, Database.UndeleteResult.class);
	}

	// Convert Methods
	global override List<DmlResult> doConvert(List<Database.LeadConvert> leadConverts) {
		List<ConversionResult> results = new List<ConversionResult>();
		for (Database.LeadConvert leadConvert : leadConverts) {
			results.add((ConversionResult) this.doConvert(leadConvert));
		}
		return results;
	}

	global override DmlResult doConvert(Database.LeadConvert leadConvert) {
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
		return new MockConversionResult(new List<DmlResult.Error>(), true, leadConvert);
	}

	// Utility Methods
	global List<DmlResult> mockDmlResults(List<SObject> records, Type sourceType) {
		List<DmlResult> dmlResults = new List<DmlResult>();
		for (SObject record : records) {
			// Mocks by default are set to succeed
			DmlResult result = new DmlResult(new List<DmlResult.Error>(), true, record.Id, sourceType);
			dmlResults.add(result);
		}
		return dmlResults;
	}
}
