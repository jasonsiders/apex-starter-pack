@IsTest
public class SoqlMock extends Soql {
	List<SObject> mockResults = new List<SObject>();

	public SoqlMock(SObjectType objectType) {
		super(objectType);
	}

	public override List<SObject> run() {
		return this.mockResults;
	}

	public void setMockResults(List<SObject> mockResults) {
		this.mockResults = mockResults;
	}

	public class Factory implements DB.QueryFactory {
		public Soql newQuery(SObjectType objectType) {
			return new SoqlMock(objectType);
		}
	}
}
