public class FieldReference {
    String soqlReference;
    SObjectReference rootSObjectType;
    List<FieldReference> relationshipFields = new List<FieldReference>();
    String destinationFieldName;
    SObjectReference destinationSObjectType; 
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
    
    public FieldReference(SObjectField field) {
        // When given a single SObjectField, the root and destination are the same
        this.setDestinationDetails(field); 
        this.rootSObjectType = this.destinationSObjectType; 
        this.soqlReference = this.destinationFieldName;
    }

    public FieldReference(List<SObjectField> fieldChain) {
        // To be used for a chain of related fields from a source SObjectType
        // ex., [Case.ContactId, Contact.AccountId, Account.OwnerId] => "Case.Contact.Account.OwnerId"
        this.soqlReference = SchemaUtils.getSoqlReference(fieldChain); 
        SObjectField firstField = (SObjectField) CollectionUtils.getIndexOf(fieldChain, 0);
        this.rootSObjectType = new SObjectReference(firstField); 
        Integer maxIndex = CollectionUtils.getMaxIndex(fieldChain);
        SObjectField lastField = (SObjectField) CollectionUtils.getIndexOf(fieldChain, maxIndex);
        this.setDestinationDetails(lastField);
        fieldChain.remove(maxIndex);
        for (SObjectField relField : fieldChain) {
            FieldReference relReference = new FieldReference(relField);
            this.relationshipFields.add(relReference);
        }
    }

    public Object getValue(SObject record) {
        for (FieldReference relationshipField : this.relationshipFields) {
            record = relationshipField?.getLookupValue(record); 
        }
        return record?.get(this.destinationField);
    }

    public SObject getLookupValue(SObject record) {
        return record?.getSObject(this.destinationField); 
    }

    public override String toString() {
        return this.soqlReference;
    }

    public SObjectField toSchemaType() {
        return this.destinationField;
    }

    private void setDestinationDetails(SObjectField field) {
        this.destinationField = field; 
        this.destinationFieldName = String.valueOf(field);
        this.destinationSObjectType = new SObjectReference(field); 
    }
}
