@IsTest
global class SoqlMock extends Soql {
	List<SObject> mockResults = new List<SObject>();

	public SoqlMock(SObjectType objectType) {
		super(objectType);
	}

	global override List<SObject> run() {
		return this.mockResults;
	}

	global void setMockResults(List<SObject> mockResults) {
		this.mockResults = mockResults;
	}

	global class Factory implements DB.QueryFactory {
		global Soql newQuery(SObjectType objectType) {
			return new SoqlMock(objectType);
		}
	}
}
