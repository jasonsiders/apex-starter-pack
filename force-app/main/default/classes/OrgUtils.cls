public abstract class OrgUtils {
    @TestVisible static Organization currentOrg;
    static Decimal currentApiVersion;
    static final String DEV_ED_ORG_TYPE = 'Developer Edition';
    // TODO: Find a better way around this; mocking framework could be improved 
    @TestVisible static final String CURRENT_ORG_QUERY = 'CURRENT_ORG_QUERY';
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
        if (OrgUtils.currentOrg == null) {
            Soql query = Databaselayer.Soql.newQuery(Organization.SObjectType)
                .setQueryKey(OrgUtils.CURRENT_ORG_QUERY)
                .selectFields(new List<SObjectField>{
                    Organization.IsSandbox, 
                    Organization.OrganizationType
                });
            OrgUtils.currentOrg = ((List<Organization>) query.run())[0];
        }
        return OrgUtils.currentOrg;
    }

    public static Decimal getCurrentApiVersion() {
        // There's no straightforward way to getting the latest API version
        // However, this is exposed via the 'attributes' object in SOQL
        if (currentApiVersion == null) {
            Soql query = Databaselayer.Soql.newQuery(Profile.SObjectType).setRowLimit(1);
            List<QueryJson> results = ((List<QueryJson>) query.run(List<QueryJson>.class));
            currentApiVersion = (results?.isEmpty() == false) ? results[0]?.getApiVersion() : DEFAULT_API_VERSION; 
        }
        return currentApiVersion;  
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
