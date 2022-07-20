public class FieldReference {
    public String soqlReference { get; private set; }
    private SObjectReference rootSObjectType;
    private List<FieldReference> relationshipFields = new List<FieldReference>();
    private String destinationFieldName;
    private SObjectReference destinationSObjectType; 
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

    public SObjectField toSchemaType() {
        return this.destinationField;
    }

    public override String toString() {
        return this.soqlReference;
    }

    // Note: These methods are necessary to allow this type to be safely used as a map key
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_collections_maps_keys_userdefined.htm
    public Boolean equals(Object obj) {
        // Any FieldReferences with the same root object and SOQL reference can be considered equal
        FieldReference otherRef = (obj instanceOf FieldReference) ? (FieldReference) obj : null;
        return (
            otherRef?.rootSObjectType == this.rootSObjectType && 
            otherRef?.toString() == this.toString()
        );
    }

    public Integer hashCode() {
        return System.hashCode(this.destinationFieldName);
    }

    private void setDestinationDetails(SObjectField field) {
        this.destinationField = field; 
        this.destinationFieldName = String.valueOf(field);
        this.destinationSObjectType = new SObjectReference(field); 
    }
}
