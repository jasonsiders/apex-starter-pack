global inherited sharing virtual class SubQuery extends Soql {
	@TestVisible ChildRelationshipRef relationship;

	global SubQuery(Schema.ChildRelationship relationship) {
		this.relationship = new ChildRelationshipRef(relationship);
	}

	global SubQuery(SObjectField lookupField) {
		this(SchemaUtils.getChildRelationship(lookupField));
	}

	global override String toString() {
		return '(' + super.toString() + ')';
	}

	global override String getFrom() {
		return this.relationship?.toSchemaType()?.getRelationshipName();
	}
}
