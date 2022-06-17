public inherited sharing virtual class SubQuery extends Soql {
    @TestVisible Schema.ChildRelationship relationship; 
    
    public SubQuery(Schema.ChildRelationship relationship) {
        this.relationship = relationship; 
    }

    public SubQuery(SObjectType objectType, String relationshipName) {
        this(Describes.getChildRelationship(objectType, relationshipName)); 
    }

    public override String toString() {
        return '(' + super.toString() + ')';
    }

    protected override String getFrom() {
        return this.relationship?.getRelationshipName();
    }
}
