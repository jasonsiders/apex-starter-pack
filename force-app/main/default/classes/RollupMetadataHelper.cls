public class RollupMetadataHelper {
    // In addition to defining Rollup objects on the fly in apex,
    // callers have the option of defining Rollup__mdt custom metadata objects
    // This class is used to convert Rollup__mdt => Rollup objects
    Map<SObjectType, Rollup> rollups = new Map<SObjectType, Rollup>();
    public static final Soql BASE_QUERY = RollupMetadataHelper.getBaseQuery(); 
    @TestVisible static final String BASE_QUERY_KEY = 'Rollup_MDT_Base_Query';
    static final Map<String, Type> CALCULATOR_BY_TOKEN = new Map<String, Type>{
        'AVG' => AvgCalculator.class,
        'COUNT' => CountCalculator.class,
        'MAX' => MaxCalculator.class,
        'MIN' => MinCalculator.class,
        'SUM' => SumCalculator.class
    };
    
    public RollupMetadataHelper(List<Rollup__mdt> rollupMdts) {
        for (Rollup__mdt rollupMdt : rollupMdts) {
            SObjectType objectType = Describes.getSObjectTypeByName(rollupMdt.Parent_SObjectType__c); 
            Rollup rollup = this.rollups.containsKey(objectType) 
                ? this.rollups.get(objectType) 
                : new Rollup(objectType);
            this.addRequest(rollup, rollupMdt); 
            this.rollups.put(objectType, rollup); 
        }
    }   

    public List<Rollup> getRollups() {
        return this.rollups?.values(); 
    }

    // **** PRIVATE **** //
    private void addRequest(Rollup rollup, Rollup__mdt rollupMdt) {
        rollup?.addRelationship(new Rollup.Relationship(Describes.getChildRelationship(
            rollupMdt?.Parent_SObjectType__c, 
            rollupMdt?.Child_Relationship_Name__c
        )).addRequest(new Rollup.Request(
            Describes.getSObjectFieldByName(
                rollupMdt?.Parent_SObjectType__c,
                rollupMdt?.Target_Field__c
            ),
            this.getCalculator(rollupMdt),
            this.getFilters(rollupMdt?.Rollup_Filters__r)
        )));
    }

    private Rollup.Calculator getCalculator(Rollup__mdt rollupMdt) {
        Schema.SObjectField calcField = Describes.getSObjectFieldByName(
            rollupMdt?.Child_SObjectType__c, 
            rollupMdt?.Calculation_Field__c
        ); 
        Type calcType = (String.isNotBlank(rollupMdt?.Calculator_Class_Name__c))
            ? Type.forName(rollupMdt?.Calculator_Class_Name__c)
            : RollupMetadataHelper.CALCULATOR_BY_TOKEN.get(rollupMdt?.Calculation_Type__c);
        return ((Rollup.Calculator) calcType?.newInstance())?.setCalcField(calcField); 
    } 

    private List<Filter> getFilters(List<Rollup_Filter__mdt> rollupFilters) {
        List<Filter> results = new List<Filter>(); 
        for (Rollup_Filter__mdt rollupFilter : rollupFilters) {
            if (rollupFilter.Active__c) {
                Filter__mdt filterMdt = rollupFilter.Filter__r; 
                results.add(new Filter(filterMdt)); 
            }
        }
        return results; 
    }

    static Soql getBaseQuery() {
        // Returns a base query which can be extended by callers.
        // It includes all necessary fields, and excludes inactive Filters/Rollups
        Filter activeFilter = new Filter('Active__c', Filter.EQUALS, true);
        SubQuery filtersQuery = (SubQuery) new SubQuery(Rollup__mdt.SObjectType, 'Rollup_Filters__r');
        filtersQuery.selectFields(Rollup_Filter__mdt.Active__c); 
        final String parentRelationship = Describes.getFieldDescribe(Rollup_Filter__mdt.Filter__c)?.getRelationshipName();
        for (SObjectField parentField : new List<SObjectField>{
            Filter__mdt.Operator__c, 
            Filter__mdt.SObjectField__c, 
            Filter__mdt.SObjectType__c,
            Filter__mdt.Value__c
        }) {
            String reference = parentRelationship + '.' + parentField; 
            filtersQuery.selectFields(reference);
        }
        return Databaselayer.Soql.newQuery(Rollup__mdt.SObjectType)
            .selectAll()
            .selectSubQuery(filtersQuery).whereFilters(activeFilter)
            .whereFilters(activeFilter)
            .setQueryKey(BASE_QUERY_KEY); 
    }
}
