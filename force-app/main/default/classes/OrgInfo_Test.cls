@IsTest 
private class OrgInfo_Test {
    @IsTest 
    static void shouldIndicateIfDevOrg() {
        DatabaseLayer.setQueryEngine(new QueryMock.Factory());
        // Should return true if Organization.OrganizationType is 'Developer Edition'
        Organization mockOrg = new Organization();
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.OrganizationType, 'Developer Edition');
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(true, OrgInfo.isDevOrg(), 'Dev org returned false');
        // Should return false if Organization.OrganizationType != 'Developer Edition'
        OrgInfo.currentOrg = null; // Allow the query to re-run
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.OrganizationType, 'Any other value');
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(false, OrgInfo.isDevOrg(), 'Non-dev org returned true');
    }

    @IsTest 
    static void shouldIndicateIfSandbox() {
        DatabaseLayer.setQueryEngine(new QueryMock.Factory());
        // Should return true if Organization.IsSandbox is true
        Organization mockOrg = new Organization();
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.IsSandbox, true);
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(true, OrgInfo.isSandboxOrg(), 'Sandbox org returned false');
        // Should return false if Organization.IsSandbox is false
        OrgInfo.currentOrg = null; 
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.IsSandbox, false);
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(false, OrgInfo.isSandboxOrg(), 'Non-Sandbox org returned true');
    }

    @IsTest 
    static void shouldIndicateIfProduction() {
        DatabaseLayer.setQueryEngine(new QueryMock.Factory());
        // Should return true if Organization.IsSandbox is false && Organization.OrganizationType != 'Developer Edition'
        Organization productionOrg = new Organization();
        productionOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg, Organization.IsSandbox, false);
        productionOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg, Organization.OrganizationType, 'Enterprise Edition');
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{productionOrg});
        System.assertEquals(true, OrgInfo.isProductionOrg(), 'Enterprise Edition org returned false');
        // If IsSandbox, will return false
        OrgInfo.currentOrg = null;
        Organization sandboxOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg.clone(), Organization.IsSandbox, true);
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{sandboxOrg});
        System.assertEquals(false, OrgInfo.isProductionOrg(), 'Sandbox org returned true');
        // If Dev Org, will return false
        OrgInfo.currentOrg = null;
        Organization devEdOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg.clone(), Organization.OrganizationType, 'Developer Edition');
        QueryMock.setMockResults(OrgInfo.CURRENT_ORG_QUERY, new List<Organization>{devEdOrg});
        System.assertEquals(false, OrgInfo.isProductionOrg(), 'Developer org returned true');
    }
}
