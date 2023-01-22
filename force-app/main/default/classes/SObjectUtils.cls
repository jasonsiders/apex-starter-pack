public abstract class SObjectUtils {
	public static SObject setLookupField(SObject target, SObjectField lookupField, SObject parent) {
		// Populate the lookup field itself
		Map<String, Object> mappedTarget = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(target));
		mappedTarget.put(String.valueOf(lookupField), parent?.Id);
		// Add an 'Attributes' object to the parent record - required when mocking via JSON (see below)
		Map<String, Object> mappedParent = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(parent));
		mappedParent.put('attributes', new RecordAttributes(parent));
		// Link the parent back to the target
		mappedTarget.put(SchemaUtils.describeField(lookupField)?.getRelationshipName(), mappedParent);
		return (SObject) JSON.deserialize(JSON.serialize(mappedTarget), SObject.class);
	}

	public static SObject setRelatedList(SObject target, ChildRelationship relationship, Object value) {
		Map<String, Object> targetMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(target));
		List<SObject> childRecords = (List<SObject>) value;
		// Add an 'Attributes' object to the parent record - required when mocking via JSON (see below)
		targetMap.put(relationship?.getRelationshipName(), new RecordListAttributes(childRecords));
		return (SObject) JSON.deserialize(JSON.serializePretty(targetMap), SObject.class);
	}

	public static SObject setReadOnlyFields(SObject target, Map<SObjectField, Object> values) {
		Map<String, Object> targetMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(target));
		for (SObjectField field : values.keySet()) {
			Object value = values.get(field);
			targetMap.put(String.valueOf(field), value);
		}
		return (SObject) JSON.deserialize(JSON.serializePretty(targetMap), SObject.class);
	}

	public static SObject setReadOnlyField(SObject target, SObjectField field, Object value) {
		return SObjectUtils.setReadOnlyFields(target, new Map<SObjectField, Object>{ field => value });
	}

	// Note: These classes mock the QueryResult object(s), which is visible in SOQL via JSON.serialize()
	// Objects of this type **must** be included when mocking parent/child values, or may get this error:
	// ! System.JSONException: QueryResult must start with '{'
	// https://salesforce.stackexchange.com/questions/149574/salesforce-queryresult-must-start-with
	private class RecordAttributes {
		String type, url;

		public RecordAttributes(SObject record) {
			this.type = String.valueOf(record?.getSObjectType());
			this.url = String.format(
				'/services/data/{0}/sobjects/{1}/{2}',
				new List<String>{ OrgUtils.getCurrentApiVersion()?.toPlainString(), this.type, record?.Id }
			);
		}
	}

	private class RecordListAttributes {
		List<SObject> records;
		Integer totalSize;
		Boolean done = true;

		public RecordListAttributes(List<SObject> records) {
			this.records = records;
			this.totalSize = records?.size();
		}
	}
}
