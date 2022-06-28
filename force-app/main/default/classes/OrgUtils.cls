public abstract class OrgUtils {
    // TODO: Find a better way around this; mocking framework could be improved 
    static final Decimal DEFAULT_API_VERSION = 55.0; 
    static Decimal currentApiVersion;

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
