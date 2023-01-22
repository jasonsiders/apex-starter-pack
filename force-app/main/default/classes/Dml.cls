public virtual inherited sharing class Dml {
	@TestVisible
	static History Inserted = Test.isRunningTest() ? new History() : null;
	@TestVisible
	static History Updated = Test.isRunningTest() ? new History() : null;
	@TestVisible
	static History Upserted = Test.isRunningTest() ? new History() : null;
	@TestVisible
	static History Deleted = Test.isRunningTest() ? new History() : null;
	@TestVisible
	static History Undeleted = Test.isRunningTest() ? new History() : null;
	@TestVisible
	static History Converted = Test.isRunningTest() ? new History() : null;
	@TestVisible
	static History Published = Test.isRunningTest() ? new History()?.setAlternateIdField('ReplayId') : null;

	// Operation-based methods
	public List<DmlResult> doDml(
		Operation operation,
		List<SObject> records,
		SObjectField externalIdField,
		Boolean allOrNone
	) {
		List<DmlResult> results;
		switch on operation {
			when DO_PUBLISH {
				results = Databaselayer.Dml.doPublish(records);
			}
			when DO_INSERT {
				results = Databaselayer.Dml.doInsert(records, allOrNone);
			}
			when DO_UPDATE {
				results = Databaselayer.Dml.doUpdate(records, allOrNone);
			}
			when DO_UPSERT {
				results = Databaselayer.Dml.doUpsert(records, externalIdField, allOrNone);
			}
			when DO_DELETE {
				results = Databaselayer.Dml.doDelete(records, allOrNone);
			}
			when DO_UNDELETE {
				results = Databaselayer.Dml.doUndelete(records, allOrNone);
			}
			when DO_HARD_DELETE {
				results = Databaselayer.Dml.doHardDelete(records, allOrNone);
			}
		}
		return results;
	}

	public List<DmlResult> doDml(Operation operation, List<SObject> records, SObjectField externalIdField) {
		return this.doDml(operation, records, externalIdField, true);
	}

	public List<DmlResult> doDml(Operation operation, List<SObject> records, Boolean allOrNone) {
		return this.doDml(operation, records, null, allOrNone);
	}

	public List<DmlResult> doDml(Operation operation, List<SObject> records) {
		return this.doDml(operation, records, null, true);
	}

	public DmlResult doDml(Operation operation, SObject record, SObjectField externalIdField, Boolean allOrNone) {
		return this.doDml(operation, new List<SObject>{ record }, externalIdField, allOrNone)[0];
	}

	public DmlResult doDml(Operation operation, SObject record, SObjectField externalIdField) {
		return this.doDml(operation, new List<SObject>{ record }, externalIdField)[0];
	}

	public DmlResult doDml(Operation operation, SObject record, Boolean allOrNone) {
		return this.doDml(operation, new List<SObject>{ record }, allOrNone)[0];
	}

	public DmlResult doDml(Operation operation, SObject record) {
		return this.doDml(operation, new List<SObject>{ record })[0];
	}

	// Publish Methods
	public virtual List<DmlResult> doPublish(List<SObject> events) {
		Dml.Published?.add(events);
		List<Database.SaveResult> results = EventBus.publish(events);
		return DmlResult.wrap(results);
	}

	public virtual DmlResult doPublish(SObject event) {
		return this.doPublish(new List<SObject>{ event })[0];
	}

	// Insert Methods
	public virtual List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone) {
		List<Database.SaveResult> results = Database.insert(records, allOrNone);
		Dml.Inserted?.add(records);
		return DmlResult.wrap(results);
	}

	public virtual List<DmlResult> doInsert(List<SObject> records) {
		return this.doInsert(records, true);
	}

	public virtual DmlResult doInsert(SObject record, Boolean allOrNone) {
		return this.doInsert(new List<SObject>{ record }, allOrNone)[0];
	}

	public virtual DmlResult doInsert(SObject record) {
		return this.doInsert(record, true);
	}

	// Update Methods
	public virtual List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone) {
		Dml.Updated?.add(records);
		List<Database.SaveResult> results = Database.update(records, allOrNone);
		return DmlResult.wrap(results);
	}

	public virtual List<DmlResult> doUpdate(List<SObject> records) {
		return this.doUpdate(records, true);
	}

	public virtual DmlResult doUpdate(SObject record, Boolean allOrNone) {
		return this.doUpdate(new List<SObject>{ record }, allOrNone)[0];
	}

	public virtual DmlResult doUpdate(SObject record) {
		return this.doUpdate(record, true);
	}

	// Upsert Methods
	public virtual List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
		// Avoid this error from null externalIdField values:
		// ! System.NullPointerException: Argument 2 cannot be null
		List<Database.UpsertResult> results = (externalIdField != null)
			? Database.upsert(records, externalIdField, allOrNone)
			: Database.upsert(records, allOrNone);
		Dml.Upserted?.add(records);
		return DmlResult.wrap(results);
	}

	public virtual List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField) {
		return this.doUpsert(records, externalIdField, true);
	}

	public virtual List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone) {
		return this.doUpsert(records, null, allOrNone);
	}

	public virtual List<DmlResult> doUpsert(List<SObject> records) {
		return this.doUpsert(records, true);
	}

	public virtual DmlResult doUpsert(SObject record, SObjectField externalIdField, Boolean allOrNone) {
		return this.doUpsert(new List<SObject>{ record }, externalIdField, allOrNone)[0];
	}

	public virtual DmlResult doUpsert(SObject record, SObjectField externalIdField) {
		return this.doUpsert(record, externalIdField, true);
	}

	public virtual DmlResult doUpsert(SObject record, Boolean allOrNone) {
		return this.doUpsert(new List<SObject>{ record }, allOrNone)[0];
	}

	public virtual DmlResult doUpsert(SObject record) {
		return this.doUpsert(record, true);
	}

	// Delete Methods
	public virtual List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone) {
		Dml.Deleted?.add(records);
		List<Database.DeleteResult> results = Database.delete(records, allOrNone);
		return DmlResult.wrap(results);
	}

	public virtual List<DmlResult> doDelete(List<SObject> records) {
		return this.doDelete(records, true);
	}

	public virtual DmlResult doDelete(SObject record, Boolean allOrNone) {
		return this.doDelete(new List<SObject>{ record }, allOrNone)[0];
	}

	public virtual DmlResult doDelete(SObject record) {
		return this.doDelete(record, true);
	}

	// Hard Delete Methods
	public virtual List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone) {
		Dml.Deleted?.add(records);
		List<Database.DeleteResult> results = Database.delete(records, allOrNone);
		Database.emptyRecycleBin(records);
		return DmlResult.wrap(results);
	}

	public virtual List<DmlResult> doHardDelete(List<SObject> records) {
		return this.doHardDelete(records, true);
	}

	public virtual DmlResult doHardDelete(SObject record, Boolean allOrNone) {
		return this.doHardDelete(new List<SObject>{ record }, allOrNone)[0];
	}

	public virtual DmlResult doHardDelete(SObject record) {
		return this.doHardDelete(record, true);
	}

	// Undelete Methods
	public virtual List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone) {
		Dml.Undeleted?.add(records);
		List<Database.UndeleteResult> results = Database.undelete(records, allOrNone);
		return DmlResult.wrap(results);
	}

	public virtual List<DmlResult> doUndelete(List<SObject> records) {
		return this.doUndelete(records, true);
	}

	public virtual DmlResult doUndelete(SObject record, Boolean allOrNone) {
		return this.doUndelete(new List<SObject>{ record }, allOrNone)[0];
	}

	public virtual DmlResult doUndelete(SObject record) {
		return this.doUndelete(record, true);
	}

	// Lead Convert Methods
	public virtual List<DmlResult> doConvert(List<Database.LeadConvert> leadConvertObjs) {
		List<ConversionResult> results = new List<ConversionResult>();
		for (Database.LeadConvertResult convertResult : Database.convertLead(leadConvertObjs)) {
			ConversionResult result = new ConversionResult(convertResult);
			results.add(result);
			if (result?.isSuccess == true) {
				Lead lead = new Lead(Id = result.getLeadId());
				Dml.Converted?.add(new List<Lead>{ lead });
			}
		}
		return results;
	}

	public virtual DmlResult doConvert(Database.LeadConvert leadConvertObj) {
		return this.doConvert(new List<Database.LeadConvert>{ leadConvertObj })[0];
	}

	// **** INNER **** //
	public enum Operation {
		DO_PUBLISH,
		DO_INSERT,
		DO_UPDATE,
		DO_UPSERT,
		DO_DELETE,
		DO_UNDELETE,
		DO_HARD_DELETE
	}

	@TestVisible
	private class History {
		// A record of all records which were recordsBySObjectType by the DML engine, by SObjectType
		private Map<SObjectRef, List<SObject>> recordsBySObjectType = new Map<SObjectRef, List<SObject>>();
		private Map<Id, SObject> recordsById = new Map<Id, SObject>();
		private String idField = 'Id';

		private History() {
			// Not available for construction outside of this file
		}

		private History setAlternateIdField(String idField) {
			this.idField = idField;
			return this;
		}

		public Boolean containsRecord(Id recordId) {
			return this.recordsById?.containsKey(recordId);
		}

		public Boolean containsRecord(SObject record) {
			Id recordId = (Id) record?.get(this.idField);
			return this.containsRecord(recordId);
		}

		public SObject getRecord(Id recordId) {
			return this.recordsById?.get(recordId);
		}

		public SObject getRecord(SObject record) {
			Id recordId = (Id) record?.get(this.idField);
			return this.getRecord(recordId);
		}

		public List<SObject> getRecords(SObjectType objectType) {
			return this.recordsBySObjectType.get(new SObjectRef(objectType));
		}

		public List<SObject> getAll() {
			List<SObject> allRecords = new List<SObject>();
			for (List<SObject> records : this.recordsBySObjectType.values()) {
				allRecords.addAll(records);
			}
			return allRecords;
		}

		public void clear() {
			this.recordsBySObjectType?.clear();
		}

		public void add(List<SObject> records) {
			for (SObject record : records) {
				// Map the record by its Id (1:1)
				Id idField = (Id) record?.get(this.idField);
				SObject clone = record.clone(true, true, true, true);
				this.recordsById.put(idField, clone);
				// Map the record by its SObjectType (1:many)
				SObjectRef objectRef = new SObjectRef(record?.getSObjectType());
				List<SObject> matchingRecords = this.recordsBySObjectType.get(objectRef);
				matchingRecords = (matchingRecords != null) ? matchingRecords : new List<SObject>();
				matchingRecords?.add(clone);
				this.recordsBySObjectType.put(objectRef, matchingRecords);
			}
		}
	}
}