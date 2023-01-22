public class SObjectRef implements Mappable {
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

	public SObjectRef(SObjectType objectType) {
		this.objectName = String.valueOf(objectType);
		this.objectType = objectType;
	}

	public SObjectRef(SObjectField field) {
		this(SchemaUtils.getSObjectType(field));
	}

	public SObjectRef(SObject record) {
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
		SObjectRef otherRef = (obj instanceof SObjectRef) ? (SObjectRef) obj : null;
		return otherRef?.toSchemaType() == this.toSchemaType();
	}

	public Integer hashCode() {
		// Note: Cannot return a null value, and System.hashCode() does not accept a null input
		return (this.objectType != null) ? System.hashCode(this.objectType) : System.hashCode('null');
	}
}
