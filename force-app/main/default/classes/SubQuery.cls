public inherited sharing virtual class SubQuery extends Soql {
    @TestVisible ChildRelationshipRef relationship; 
    
    public SubQuery(Schema.ChildRelationship relationship) {
        this.relationship = new ChildRelationshipRef(relationship);
    }

    public SubQuery(SObjectField lookupField) {
        this(SchemaUtils.getChildRelationship(lookupField)); 
    }

    public override String toString() {
        return '(' + super.toString() + ')';
    }

    protected override String getFrom() {
        return this.relationship?.toSchemaType()?.getRelationshipName();
    }
}
