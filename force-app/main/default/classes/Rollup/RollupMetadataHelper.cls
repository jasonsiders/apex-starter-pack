public class RollupMetadataHelper {
	// In addition to defining Rollup objects on the fly in apex,
	// callers have the option of defining Rollup__mdt custom metadata objects
	// This class is used to convert Rollup__mdt => Rollup objects
	Map<SObjectRef, Rollup> rollups = new Map<SObjectRef, Rollup>();

	public static Soql BaseQuery = RollupMetadataHelper.getBaseQuery();
	static final Map<String, Type> CALCULATOR_BY_TOKEN = new Map<String, Type>{
		'AVG' => AvgCalculator.class,
		'COUNT' => CountCalculator.class,
		'MAX' => MaxCalculator.class,
		'MIN' => MinCalculator.class,
		'SUM' => SumCalculator.class
	};

	public RollupMetadataHelper(List<Rollup__mdt> rollupMdts) {
		for (Rollup__mdt rollupMdt : rollupMdts) {
			SObjectType objectType = SchemaUtils.getSObjectType(rollupMdt.Parent_SObjectType__c);
			SObjectRef objectRef = new SObjectRef(objectType);
			Rollup rollup = this.rollups.containsKey(objectRef) ? this.rollups.get(objectRef) : new Rollup(objectType);
			this.addRequest(rollup, rollupMdt);
			this.rollups.put(objectRef, rollup);
		}
	}

	public List<Rollup> getRollups() {
		return this.rollups?.values();
	}

	// **** PRIVATE **** //
	private void addRequest(Rollup rollup, Rollup__mdt rollupMdt) {
		SObjectType childSObjectType = SchemaUtils.getSObjectType(rollupMdt?.Child_SObjectType__c);
		SObjectType parentSObjectType = SchemaUtils.getSObjectType(rollupMdt?.Parent_SObjectType__c);
		SObjectField relationshipField = SchemaUtils.getSObjectField(
			childSObjectType,
			rollupMdt?.Relationship_Field__c
		);
		SObjectField targetField = SchemaUtils.getSObjectField(parentSObjectType, rollupMdt?.Target_Field__c);
		ChildRelationship childRelationship = SchemaUtils.getChildRelationship(relationshipField);
		List<Filter> filters = this.getFilters(rollupMdt?.Rollup_Filters__r);
		FilterLogic logic = new FilterLogic.AndLogic(filters);
		Rollup.Request req = new Rollup.Request(targetField, this.getCalculator(rollupMdt), logic);
		rollup?.addRelationship(new Rollup.Relationship(childRelationship).addRequest(req));
	}

	private Rollup.Calculator getCalculator(Rollup__mdt rollupMdt) {
		SObjectType childSObjectType = SchemaUtils.getSObjectType(rollupMdt?.Child_SObjectType__c);
		Schema.SObjectField calcField = SchemaUtils.getSObjectField(childSObjectType, rollupMdt?.Calculation_Field__c);
		Type calcType = (String.isNotBlank(rollupMdt?.Calculator_Class_Name__c))
			? Type.forName(rollupMdt?.Calculator_Class_Name__c)
			: RollupMetadataHelper.CALCULATOR_BY_TOKEN.get(rollupMdt?.Calculation_Type__c);
		return ((Rollup.Calculator) calcType?.newInstance())?.setCalcField(new FieldRef(calcField));
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
		SubQuery filtersQuery = (SubQuery) new SubQuery(Rollup_Filter__mdt.Rollup__c);
		filtersQuery.selectFields(Rollup_Filter__mdt.Active__c);
		for (
			SObjectField parentField : new List<SObjectField>{
				Filter__mdt.Operator__c,
				Filter__mdt.SObjectField__c,
				Filter__mdt.SObjectType__c,
				Filter__mdt.Value__c
			}
		) {
			FieldRef reference = new FieldRef(new List<SObjectField>{ Rollup_Filter__mdt.Filter__c, parentField });
			filtersQuery.selectFields(reference);
		}
		return Databaselayer.Soql.newQuery(Rollup__mdt.SObjectType)
			.selectAll()
			.selectSubQuery(filtersQuery)
			.whereFilters(activeFilter)
			.whereFilters(activeFilter);
	}
}
