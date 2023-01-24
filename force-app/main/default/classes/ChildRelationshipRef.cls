global class ChildRelationshipRef implements Mappable {
	FieldRef lookupReference;
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

	global ChildRelationshipRef(ChildRelationship relationship) {
		SObjectField lookupField = relationship?.getField();
		this.lookupReference = new FieldRef(lookupField);
		this.relationship = relationship;
	}

	global ChildRelationshipRef(SObjectField lookupField) {
		this.lookupReference = new FieldRef(lookupField);
		this.relationship = SchemaUtils.getChildRelationship(lookupField);
		if (this.relationship == null) {
			throw new InvalidFieldException(this.lookupReference);
		}
	}

	global ChildRelationship toSchemaType() {
		return this.relationship;
	}

	global override String toString() {
		SObjectField lookupField = this.lookupReference?.toSchemaType();
		SObjectType parentType = SchemaUtils.getParentSObjectType(lookupField);
		return parentType + '.' + this.relationship?.getRelationshipName();
	}

	// **** MAPPABLE **** //
	public Boolean equals(Object obj) {
		ChildRelationshipRef otherRef = (obj instanceof ChildRelationshipRef) ? (ChildRelationshipRef) obj : null;
		return otherRef?.toSchemaType() == this.toSchemaType();
	}

	public Integer hashCode() {
		return (this.relationship != null) ? System.hashCode(this.relationship) : System.hashCode('null');
	}

	// **** INNER **** //
	public class InvalidFieldException extends Exception {
		public InvalidFieldException(FieldRef fieldRef) {
			this.setMessage(fieldRef?.toString() + ' is not a lookup field');
		}
	}
}
