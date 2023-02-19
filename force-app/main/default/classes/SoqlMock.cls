@IsTest
global class SoqlMock extends Soql {
	List<SObject> mockResults = new List<SObject>();

	global SoqlMock(SObjectType objectType) {
		super(objectType);
	}

	global SoqlMock() {
		super();
	}

	global override List<SObject> run() {
		return this.mockResults;
	}

	global Soql setMockResults(List<SObject> mockResults) {
		this.mockResults = mockResults;
		return this;
	}

	global class Factory implements DB.QueryFactory {
		global Soql newQuery(SObjectType objectType) {
			return new SoqlMock(objectType);
		}
	}
}
