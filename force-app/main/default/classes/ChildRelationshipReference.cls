public class ChildRelationshipReference implements Mappable {
    FieldReference lookupReference;
    transient ChildRelationship relationship {
        get {
            if (this.relationship == null) {
                SObjectField lookupField = this.lookupReference?.toSchemaType();
                this.relationship = SchemaUtils.getChildRelationship(lookupField);
            }
            return this.relationship;
        }
        private set;
    }

    public ChildRelationshipReference(ChildRelationship relationship) {
        SObjectField lookupField = relationship?.getField(); 
        this.lookupReference = new FieldReference(lookupField);
        this.relationship = relationship; 
    }

    public ChildRelationshipReference(SObjectField lookupField) {
        this.lookupReference = new FieldReference(lookupField);
        this.relationship = SchemaUtils.getChildRelationship(lookupField);
        if (this.relationship == null) {
            throw new InvalidFieldException(this.lookupReference);
        }
    }

    public ChildRelationship toSchemaType() {
        return this.relationship; 
    }

    public override String toString() {
        SObjectField lookupField = this.lookupReference?.toSchemaType();
        SObjectType parentType = SchemaUtils.getParentSObjectType(lookupField);
        return parentType + '.' + this.relationship?.getRelationshipName();
    }

    // **** MAPPABLE **** //
    public Boolean equals(Object obj) {
        ChildRelationshipReference otherRef = (obj instanceOf ChildRelationshipReference) 
            ? (ChildRelationshipReference) obj : null;
        return otherRef?.toSchemaType() == this.toSchemaType();
    }

    public Integer hashCode() {
        return System.hashCode(this.relationship);
    }

    // **** INNER **** //
    public class InvalidFieldException extends Exception {
        public InvalidFieldException(FieldReference fieldRef) {
            this.setMessage(fieldRef?.toString() + ' is not a lookup field');
        }
    }
}
