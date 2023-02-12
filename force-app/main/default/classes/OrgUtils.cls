global abstract class OrgUtils {
	@TestVisible
	static Organization CurrentOrg;
	@TestVisible
	static Soql CurrentOrgQuery = OrgUtils.initQuery();
	static Decimal currentApiVersion;
	static final String DEV_ED_ORG_TYPE = 'Developer Edition';
	static final Decimal DEFAULT_API_VERSION = 55.0;

	global static Boolean isSandboxOrg() {
		return OrgUtils.getCurrentOrg().IsSandbox;
	}

	global static Boolean isDevOrg() {
		return OrgUtils.getCurrentOrg().OrganizationType == OrgUtils.DEV_ED_ORG_TYPE;
	}

	global static Boolean isProductionOrg() {
		return OrgUtils.isDevOrg() == false && OrgUtils.isSandboxOrg() == false;
	}

	static Soql initQuery() {
		List<SObjectField> fields = new List<SObjectField>{
			Organization.IsSandbox, 
			Organization.OrganizationType 
		};
		return DB.Soql.newQuery(Organization.SObjectType)?.selectFields(fields);
	}

	static Organization getCurrentOrg() {
		// Avoids querying more than once per transaction
		if (OrgUtils.CurrentOrg == null) {
			OrgUtils.CurrentOrg = ((List<Organization>) OrgUtils.CurrentOrgQuery?.run())[0];
		}
		return OrgUtils.CurrentOrg;
	}

	global static Decimal getCurrentApiVersion() {
		// There's no straightforward way to getting the latest API version
		// However, this is exposed via the 'attributes' object in SOQL
		if (OrgUtils.currentApiVersion == null) {
			Soql query = DB.Soql.newQuery(Profile.SObjectType).setRowLimit(1);
			QueryJson results = (QueryJson) CollectionUtils.getIndexOf(
				(List<QueryJson>) query.run(List<QueryJson>.class),
				0
			);
			OrgUtils.currentApiVersion = (results != null) ? results?.getApiVersion() : OrgUtils.DEFAULT_API_VERSION;
		}
		return OrgUtils.currentApiVersion;
	}

	// **** INNNER **** //
	private class QueryJson {
		Attributes attributes;

		private Decimal getApiVersion() {
			String version = this.attributes?.url?.substringAfter('/services/data/v')?.substringBefore('/sobjects');
			return Decimal.valueOf(version);
		}
	}

	private class Attributes {
		String url;
	}
}
