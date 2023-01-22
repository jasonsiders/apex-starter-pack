public inherited sharing virtual class Soql {
	@TestVisible
	protected Set<String> selectClauses = new Set<String>{ 'Id' };
	protected SObjectRef fromSObject;
	protected Scope scope;
	protected SoqlWithClause withExpression;
	protected FilterLogic whereCriteria = new AndLogic();
	protected List<String> groupByClauses = new List<String>();
	protected FilterLogic havingCriteria = new AndLogic();
	protected SoqlSort orderByClause;
	protected Integer rowLimit;
	protected Integer rowOffset;
	protected Usage usage;

	@TestVisible
	protected Soql(SObjectType objectType) {
		this.fromSObject(objectType);
	}

	protected Soql() {
		// This constructor allows extending types to call super() methods
	}

	// **** Running a Query **** //
	public virtual List<SObject> run() {
		// Run the current query object through the database
		String soql = this.toString();
		List<SObject> results;
		try {
			results = Database.query(soql);
		} catch (System.QueryException queryError) {
			final String newMessage = queryError.getMessage() + '. Query: [' + soql + ']';
			queryError.setMessage(newMessage);
			throw queryError;
		}
		return results;
	}

	public virtual Object run(Type returnType) {
		// Return the query results as an instance of the returnType
		// Mostly useful for returning Aggregate Query results as a wrapper type
		return JSON.deserialize(JSON.serialize(this.run()), returnType);
	}

	public virtual override String toString() {
		// Outputs a SOQL Query string, following the syntax defined here:
		// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select.htm#:~:text=SOQL%20query%20syntax%20consists%20of,typeOfField%20whenExpression%5B...%5D
		List<String> queryArgs = new List<String>{ this.getSelect(), this.getFrom(), this.getOptionalArgs() };
		return String.format('SELECT {0} FROM {1} {2}', queryArgs)?.trim();
	}

	// **** Building a Query **** //
	public Soql selectFields(List<FieldRef> fieldReferences) {
		for (FieldRef fieldReference : fieldReferences) {
			this.selectClauses.add(fieldReference?.toString());
		}
		return this;
	}

	public Soql selectFields(FieldRef fieldReference) {
		return this.selectFields(new List<FieldRef>{ fieldReference });
	}

	public Soql selectFields(List<SObjectField> fields) {
		for (SObjectField field : fields) {
			this.selectClauses.add(String.valueOf(field));
		}
		return this;
	}

	public Soql selectFields(SObjectField field) {
		return this.selectFields(new List<SObjectField>{ field });
	}

	public Soql selectFields(List<String> fieldNames) {
		this.selectClauses.addAll(fieldNames);
		return this;
	}

	public Soql selectFields(String fieldName) {
		return this.selectFields(new List<String>{ fieldName });
	}

	public Soql selectAll() {
		List<SObjectField> allFields = this.fromSObject?.toSchemaType()?.getDescribe()?.fields?.getMap()?.values();
		return this.selectFields(allFields);
	}

	public Soql selectSubQuery(SubQuery subQuery) {
		return this.selectFields(subQuery.toString());
	}

	public Soql selectAggregation(SoqlAggregation aggregation) {
		// Note: 'Id' should never be included in the SELECT clause for Aggregate queries
		return this.deselectId()?.selectFields(aggregation?.toString());
	}

	public Soql deselectId() {
		// By default, Id will always be included in queries
		// Occasionally, (i.e., aggregate & inner queries), this isn't desirable
		this.selectClauses?.remove('Id');
		return this;
	}

	public Soql fromSObject(SObjectType objectType) {
		this.fromSObject = new SObjectRef(objectType);
		return this;
	}

	public Soql usingScope(Scope scope) {
		this.scope = scope;
		return this;
	}

	public Soql withExpression(SoqlWithClause withExpression) {
		this.withExpression = withExpression;
		return this;
	}

	public Soql whereCriteria(List<ICriteria> filters) {
		this.whereCriteria?.addCriteria(filters);
		return this;
	}

	public Soql whereCriteria(ICriteria filter) {
		return this.whereCriteria(new List<ICriteria>{ filter });
	}

	public Soql setWhereLogic(Type newLogicType) {
		List<ICriteria> filters = this.whereCriteria?.getCriteria();
		this.whereCriteria = ((FilterLogic) newLogicType.newInstance())?.setCriteria(filters);
		return this;
	}

	public Soql groupBy(List<FieldRef> fieldReferences) {
		for (FieldRef fieldReference : fieldReferences) {
			this.groupByClauses?.add(fieldReference?.toString());
		}
		return this;
	}

	public Soql groupBy(FieldRef fieldReference) {
		return this.groupBy(new List<FieldRef>{ fieldReference });
	}

	public Soql groupBy(List<SObjectField> fields) {
		for (SObjectField field : fields) {
			this.groupBy(String.valueOf(field));
		}
		return this;
	}

	public Soql groupBy(SObjectField field) {
		return this.groupBy(new List<SObjectField>{ field });
	}

	public Soql groupBy(List<String> fieldNames) {
		this.groupByClauses?.addAll(fieldNames);
		return this;
	}

	public Soql groupBy(String fieldName) {
		return this.groupBy(new List<String>{ fieldName });
	}

	public Soql havingCriteria(SoqlAggregation.AggregateFilter aggregateCriteria) {
		this.havingCriteria?.addCriteria(aggregateCriteria);
		return this;
	}

	public Soql setHavingLogic(Type newLogicType) {
		List<ICriteria> filters = this.havingCriteria?.getCriteria();
		this.havingCriteria = ((FilterLogic) newLogicType.newInstance())?.setCriteria(filters);
		return this;
	}

	public Soql orderBy(SoqlSort orderByClause) {
		this.orderByClause = orderByClause;
		return this;
	}

	public Soql setRowLimit(Integer rowLimit) {
		this.rowLimit = rowLimit;
		return this;
	}

	public Soql setRowOffset(Integer rowOffset) {
		this.rowOffset = rowOffset;
		return this;
	}

	public Soql forUsage(Usage usage) {
		this.usage = usage;
		return this;
	}

	// **** PRIVATE **** //
	private String getOptionalArgs() {
		List<String> optionalArgs = (List<String>) CollectionUtils.filterCollection(
			new List<String>{
				this.getUsingScope(),
				this.getFilter('WHERE', this.whereCriteria),
				this.getWith(),
				this.getGroupBy(),
				this.getFilter('HAVING', this.havingCriteria),
				this.getOrderBy(),
				this.getLimit('LIMIT', this.rowLimit),
				this.getLimit('OFFSET', this.rowOffset),
				this.getUsage()
			},
			new PrimitiveFilter(Filter.NOT_EQUALS, null),
			List<String>.class
		);
		return String.join(optionalArgs, ' ');
	}
	protected virtual String getSelect() {
		return String.join(new List<String>(this.selectClauses), ', ');
	}

	protected virtual String getFrom() {
		return String.valueOf(this.fromSObject);
	}

	protected virtual String getUsingScope() {
		return (this.scope != null) ? 'USING SCOPE ' + String.valueOf(this.scope)?.toLowerCase() : null;
	}

	protected virtual String getFilter(String token, FilterLogic logic) {
		return (logic?.getCriteria()?.isEmpty() == false) ? token + ' ' + logic?.toString() : null;
	}

	protected virtual String getWith() {
		return this.withExpression?.toString();
	}

	protected virtual String getGroupBy() {
		return (this.groupByClauses?.isEmpty() == false) ? 'GROUP BY ' + String.join(this.groupByClauses, ', ') : null;
	}

	protected virtual String getOrderBy() {
		return (this.orderByClause != null) ? 'ORDER BY ' + this.orderByClause.toString() : null;
	}

	protected virtual String getLimit(String token, Integer limitValue) {
		return (limitValue != null) ? token + ' ' + limitValue : null;
	}

	protected virtual String getUsage() {
		return (this.usage != null) ? String.valueOf(this.usage)?.replace('_', ' ') : null;
	}

	@TestVisible
	private SoqlMock toMock() {
		return (SoqlMock) this;
	}

	// **** INNER *** //
	// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm
	public enum Scope {
		DELEGATED,
		EVERYTHING,
		MINE,
		MINE_AND_MY_GROUPS,
		MY_TERRITORY,
		MY_TEAM_TERRITORY,
		TEAM
	}

	// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_view.htm
	// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_reference.htm
	// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_update.htm
	public enum Usage {
		ALL_ROWS,
		FOR_VIEW,
		FOR_REFERENCE,
		FOR_UPDATE
	}

	public class Factory implements DatabaseLayer.QueryFactory {
		public Soql newQuery(SObjectType fromSObject) {
			return new Soql(fromSObject);
		}
	}
}
