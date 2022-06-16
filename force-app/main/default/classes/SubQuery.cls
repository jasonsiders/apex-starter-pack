public inherited sharing virtual class SubQuery extends Soql {
    @TestVisible Schema.ChildRelationship relationship; 
    
    public SubQuery(Schema.ChildRelationship relationship) {
        this.relationship = relationship; 
    }

    public override String toString() {
        return '(' + super.toString() + ')';
    }

    protected override String getFrom() {
        return this.relationship?.getRelationshipName();
    }
}
