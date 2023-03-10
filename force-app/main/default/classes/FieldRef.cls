global class FieldRef implements Mappable, IProperty {
	global String soqlReference { get; private set; }
	global SObjectRef rootSObjectType { get; private set; }
	global List<FieldRef> relationshipFields = new List<FieldRef>();
	global SObjectRef destinationSObjectType { get; private set; }
	private String destinationFieldName;
	transient SObjectField destinationField {
		// Note: SObjectFields aren't serializable; use a getter to manually reconstruct if null
		get {
			if (this.destinationField == null) {
				this.destinationField = SchemaUtils.getSObjectField(
					this.destinationSObjectType?.toSchemaType(),
					this.destinationFieldName
				);
			}
			return this.destinationField;
		}
		private set;
	}

	global FieldRef(SObjectField field) {
		// When given a single SObjectField, the root and destination are the same
		this.setDestinationDetails(field);
		this.rootSObjectType = this.destinationSObjectType;
		this.soqlReference = this.destinationFieldName;
	}

	global FieldRef(List<SObjectField> fieldChain) {
		// To be used for a chain of related fields from a source SObjectType
		// ex., [Case.ContactId, Contact.AccountId, Account.OwnerId] => "Case.Contact.Account.OwnerId"
		this.soqlReference = SchemaUtils.getSoqlReference(fieldChain);
		SObjectField firstField = (SObjectField) CollectionUtils.getIndexOf(fieldChain, 0);
		this.rootSObjectType = new SObjectRef(firstField);
		Integer maxIndex = CollectionUtils.getMaxIndex(fieldChain);
		SObjectField lastField = (SObjectField) CollectionUtils.getIndexOf(fieldChain, maxIndex);
		this.setDestinationDetails(lastField);
		fieldChain.remove(maxIndex);
		for (SObjectField relField : fieldChain) {
			FieldRef relReference = new FieldRef(relField);
			this.relationshipFields.add(relReference);
		}
	}

	global Object getValue(SObject record) {
		for (FieldRef relationshipField : this.relationshipFields) {
			record = relationshipField?.getLookupValue(record);
		}
		return record?.get(this.destinationField);
	}

	global Object getValue(Object obj) {
		SObject record = (SObject) obj;
		return this.getValue(record);
	}

	global SObject getLookupValue(SObject record) {
		return record?.getSObject(this.destinationField);
	}

	global SObjectField toSchemaType() {
		return this.destinationField;
	}

	global override String toString() {
		return this.soqlReference;
	}

	global String getFullName() {
		return String.valueOf(this.rootSObjectType) + '.' + this.toString();
	}

	private void setDestinationDetails(SObjectField field) {
		this.destinationField = field;
		this.destinationFieldName = String.valueOf(field);
		this.destinationSObjectType = new SObjectRef(field);
	}

	// **** MAPPABLE **** //
	public Boolean equals(Object obj) {
		// Any FieldReferences with the same root object and SOQL reference can be considered equal
		FieldRef otherRef = (obj instanceof FieldRef) ? (FieldRef) obj : null;
		return (otherRef?.rootSObjectType == this.rootSObjectType && otherRef?.toString() == this.toString());
	}

	public Integer hashCode() {
		String fullName = this.getFullName();
		return (fullName != null) ? System.hashCode(fullName) : System.hashCode('null');
	}
	
	// **** STATIC **** //
	global static FieldRef getReferenceTo(SObjectField field) {
		// FieldRefs can technically be initialized with a null SObjectField value
		// Call this method instead of the constructor directly to guard against this
		return (field != null) ? new FieldRef(field) : null;
	}
}
