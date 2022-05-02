global inherited sharing virtual class SubQuery extends SoqlQuery {
    @TestVisible Schema.ChildRelationship relationship; 
    
    global SubQuery(Schema.ChildRelationship relationship) {
        this.relationship = relationship; 
    }

    global override String getQueryString() {
        return '(' + super.getQueryString() + ')';
    }

    protected override String getTargetObject() {
        return this.relationship?.getRelationshipName();
    }
}
