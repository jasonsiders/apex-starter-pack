public class SObjectReference implements Mappable {
    // Wraps the SObjectType class, which is not JSON serializable
    String objectName;
    transient SObjectType objectType {
        get {
            if (this.objectType == null) {
                this.objectType = SchemaUtils.getSObjectType(this.objectName);
            }
            return this.objectType;
        }
        private set;
    }

    public SObjectReference(SObjectType objectType) {
        this.objectName = String.valueOf(objectType); 
        this.objectType = objectType;
    }

    public SObjectReference(SObjectField field) {
        this(SchemaUtils.getSObjectType(field));
    }

    public SObjectReference(SObject record) {
        this(record?.getSObjectType());
    }

    public Boolean isSObjectTypeOf(SObject record) {
        return record?.getSObjectType() == this.toSchemaType();
    }

    public SObjectType toSchemaType() {
        return this.objectType;
    }

    public override String toString() {
        return this.objectName; 
    }

    // **** MAPPABLE **** // 
    public Boolean equals(Object obj) {
        // Any SObjectReferences with a like getSchemaType() should be considered equal
        SObjectReference otherRef = (obj instanceOf SObjectReference) ? (SObjectReference) obj : null;
        return otherRef?.toSchemaType() == this.toSchemaType();
    }

    public Integer hashCode() {
        return System.hashCode(this.objectType);
    }
}
