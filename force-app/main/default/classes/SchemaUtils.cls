global abstract class SchemaUtils {
	global static SObjectType getSObjectType(String objectName) {
		try {
			return ((SObject) Type.forName(objectName)?.newInstance())?.getSObjectType();
		} catch (System.NullPointerException nullError) {
			return null;
		}
	}

	global static SObjectType getSObjectType(SObjectField field) {
		return field?.getDescribe()?.getSObjectType(); 
	}

	global static SObjectType getParentSObjectType(SObjectField lookupField) {
		// Retrieves the parent SObjectType that a lookup field points to
		// Any non-lookup fields will return null
		List<SObjectType> parentSObjectTypes = lookupField?.getDescribe()?.getReferenceTo();
		return (parentSObjectTypes?.isEmpty() == false) ? parentSObjectTypes[0] : null;
	}

	global static SObjectField getSObjectField(SObjectType objectType, String fieldName) {
		return objectType?.getDescribe()?.fields?.getMap().get(fieldName);
	}

	global static String getSoqlReference(List<SObjectField> fields) {
		// Constructs a SOQL-usable String from multiple related SObjectFields
		// Fields must be listed in the order of their relationship
		// ex., "Contact.Account.Owner.Profile.Name"
		List<String> references = new List<String>();
		if (fields?.isEmpty() == false) {
			Integer maxIndex = CollectionUtils.getMaxIndex(fields);
			SObjectField lastField = fields[maxIndex];
			for (SObjectField field : fields) {
				String reference = (field != lastField)
					? field?.getDescribe()?.getRelationshipName()
					: String.valueOf(field);
				references.add(reference);
			}
		}
		return String.join(references, '.');
	}

	global static ChildRelationship getChildRelationship(SObjectField lookupField) {
		SObjectType parentObject = SchemaUtils.getParentSObjectType(lookupField);
		List<ChildRelationship> rels = parentObject?.getDescribe()?.getChildRelationships();
		rels = (rels != null) ? rels : new List<ChildRelationship>();
		for (ChildRelationship rel : rels) {
			SObjectField relField = rel?.getField();
			if (relField == lookupField) {
				return rel;
			}
		}
		return null;
	}
}
