public abstract class OrgInfo {
    @TestVisible static Organization currentOrg;
    @TestVisible static final String CURRENT_ORG_QUERY = 'CURRENT_ORG_QUERY';
    static final String DEV_ED_ORG_TYPE = 'Developer Edition';

    public static Boolean isSandboxOrg() {
        return OrgInfo.getCurrentOrg().IsSandbox;
    }

    public static Boolean isDevOrg() {
        return OrgInfo.getCurrentOrg().OrganizationType == OrgInfo.DEV_ED_ORG_TYPE;
    }

    public static Boolean isProductionOrg() {
        return OrgInfo.isDevOrg() == false && OrgInfo.isSandboxOrg() == false;
    }
    
    static Organization getCurrentOrg() {
        if (OrgInfo.currentOrg == null) {
            Soql query = DatabaseLayer.QueryEngine.newQuery(Organization.SObjectType)
                .setQueryKey(OrgInfo.CURRENT_ORG_QUERY)
                .selectFields(new List<SObjectField>{
                    Organization.IsSandbox, 
                    Organization.OrganizationType
                });
            OrgInfo.currentOrg = ((List<Organization>) query.run())[0];
        }
        return OrgInfo.currentOrg;
    }
}
