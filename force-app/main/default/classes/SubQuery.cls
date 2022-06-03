public inherited sharing virtual class SubQuery extends SoqlQuery {
    @TestVisible Schema.ChildRelationship relationship; 
    
    public SubQuery(Schema.ChildRelationship relationship) {
        this.relationship = relationship; 
    }

    public override String getQueryString() {
        return '(' + super.getQueryString() + ')';
    }

    protected override String getTargetObject() {
        return this.relationship?.getRelationshipName();
    }
}
