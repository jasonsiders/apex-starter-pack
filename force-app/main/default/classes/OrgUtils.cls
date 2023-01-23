public abstract class OrgUtils {
	@TestVisible
	static Organization CurrentOrg;
	@TestVisible
	static Soql CurrentOrgQuery = DB.Soql.newQuery(Organization.SObjectType)
		.selectFields(new List<SObjectField>{ Organization.IsSandbox, Organization.OrganizationType });
	static Decimal currentApiVersion;
	static final String DEV_ED_ORG_TYPE = 'Developer Edition';
	static final Decimal DEFAULT_API_VERSION = 55.0;

	public static Boolean isSandboxOrg() {
		return OrgUtils.getCurrentOrg().IsSandbox;
	}

	public static Boolean isDevOrg() {
		return OrgUtils.getCurrentOrg().OrganizationType == OrgUtils.DEV_ED_ORG_TYPE;
	}

	public static Boolean isProductionOrg() {
		return OrgUtils.isDevOrg() == false && OrgUtils.isSandboxOrg() == false;
	}

	static Organization getCurrentOrg() {
		// Avoids querying more than once per transaction
		if (OrgUtils.CurrentOrg == null) {
			OrgUtils.CurrentOrg = ((List<Organization>) OrgUtils.CurrentOrgQuery?.run())[0];
		}
		return OrgUtils.CurrentOrg;
	}

	public static Decimal getCurrentApiVersion() {
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
