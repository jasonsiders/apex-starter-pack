@IsTest 
private class OrgUtils_Test {
    @IsTest 
    static void shouldReturnCurrentApiVersion() {
        System.assertNotEquals(null, OrgUtils.getCurrentApiVersion(), 'Did not return the current API version');
    }

    @IsTest 
    static void shouldIndicateIfDevOrg() {
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        // Should return true if Organization.OrganizationType is 'Developer Edition'
        Organization mockOrg = new Organization();
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.OrganizationType, 'Developer Edition');
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(true, OrgUtils.isDevOrg(), 'Dev org returned false');
        // Should return false if Organization.OrganizationType != 'Developer Edition'
        OrgUtils.currentOrg = null; // Allow the query to re-run
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.OrganizationType, 'Any other value');
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(false, OrgUtils.isDevOrg(), 'Non-dev org returned true');
    }

    @IsTest 
    static void shouldIndicateIfSandbox() {
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        // Should return true if Organization.IsSandbox is true
        Organization mockOrg = new Organization();
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.IsSandbox, true);
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(true, OrgUtils.isSandboxOrg(), 'Sandbox org returned false');
        // Should return false if Organization.IsSandbox is false
        OrgUtils.currentOrg = null; 
        mockOrg = (Organization) ObjectUtils.setReadOnlyField(mockOrg, Organization.IsSandbox, false);
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{mockOrg});
        System.assertEquals(false, OrgUtils.isSandboxOrg(), 'Non-Sandbox org returned true');
    }

    @IsTest 
    static void shouldIndicateIfProduction() {
        DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
        // Should return true if Organization.IsSandbox is false && Organization.OrganizationType != 'Developer Edition'
        Organization productionOrg = new Organization();
        productionOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg, Organization.IsSandbox, false);
        productionOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg, Organization.OrganizationType, 'Enterprise Edition');
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{productionOrg});
        System.assertEquals(true, OrgUtils.isProductionOrg(), 'Enterprise Edition org returned false');
        // If IsSandbox, will return false
        OrgUtils.currentOrg = null;
        Organization sandboxOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg.clone(), Organization.IsSandbox, true);
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{sandboxOrg});
        System.assertEquals(false, OrgUtils.isProductionOrg(), 'Sandbox org returned true');
        // If Dev Org, will return false
        OrgUtils.currentOrg = null;
        Organization devEdOrg = (Organization) ObjectUtils.setReadOnlyField(productionOrg.clone(), Organization.OrganizationType, 'Developer Edition');
        SoqlMock.setMockResults(OrgUtils.CURRENT_ORG_QUERY, new List<Organization>{devEdOrg});
        System.assertEquals(false, OrgUtils.isProductionOrg(), 'Developer org returned true');
    }
}
