global with sharing class PropertyRef implements Mappable, IProperty {
	// This class can be used to store multi-level property names,
	// and to give stronger typing to object properties than a String representation
	String fullPropertyName;
	String rootPropertyName;
	List<String> relationships;

	global PropertyRef(String fullPropertyName) {
		this.fullPropertyName = fullPropertyName;
		List<String> propertyParts = fullPropertyName?.split('\\.');
		if (propertyParts != null) {
			Integer rootIndex = propertyParts?.size() - 1;
			this.rootPropertyName = propertyParts[rootIndex];
			propertyParts.remove(rootIndex);
			this.relationships = propertyParts;
		}
	}

	global Object getValue(Object obj) {
		Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
		for (String relationship : this.relationships) {
			Object value = objMap?.get(relationship);
			objMap = (Map<String, Object>) value;
		}
		return objMap?.get(this.rootPropertyName);
	}

	global Object getValue(SObject record) {
		for (String relationship : this.relationships) {
			record = record?.getSObject(relationship);
		}
		return record?.get(this.rootPropertyName);
	}

	global override String toString() {
		return this.fullPropertyName;
	}

	// **** MAPPABLE **** //
	public Boolean equals(Object obj) {
		PropertyRef otherRef = (obj instanceof PropertyRef) ? (PropertyRef) obj : null;
		return otherRef?.toString() == this.toString();
	}

	public Integer hashCode() {
		return (this.toString() != null) ? System.hashCode(this.toString()) : System.hashCode('null');
	}
}
