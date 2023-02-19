global inherited sharing virtual class Soql {
	static final String ID_REFERENCE = 'Id';

	global Set<String> selectClauses { get; private set; }
	global SObjectRef fromSObject { get; private set; }
	global Scope scope { get; private set; }
	global SoqlWithClause withExpression { get; private set; }
	global FilterLogic whereCriteria { get; private set; }
	global List<String> groupByClauses { get; private set; }
	global FilterLogic havingCriteria { get; private set; }
	global SoqlSort orderByClause { get; private set; }
	global Integer rowLimit { get; private set; }
	global Integer rowOffset { get; private set; }
	global Usage usage { get; private set; }

	@TestVisible
	protected Soql(SObjectType objectType) {
		this(); 
		this.fromSObject(objectType);
	}

	protected Soql() {
		this.selectClauses = new Set<String>{ID_REFERENCE};
		this.whereCriteria = new AndLogic();
		this.groupByClauses = new List<String>();
		this.havingCriteria = new AndLogic(); 
	}

	// **** Running a Query **** //
	global virtual List<SObject> run() {
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

	global virtual Object run(Type returnType) {
		// Return the query results as an instance of the returnType
		// Mostly useful for returning Aggregate Query results as a wrapper type
		return JSON.deserialize(JSON.serialize(this.run()), returnType);
	}

	global virtual override String toString() {
		// Outputs a SOQL Query string, following the syntax defined here:
		// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select.htm#:~:text=SOQL%20query%20syntax%20consists%20of,typeOfField%20whenExpression%5B...%5D
		List<String> queryArgs = new List<String>{ this.getSelect(), this.getFrom(), this.getOptionalArgs() };
		return String.format('SELECT {0} FROM {1} {2}', queryArgs)?.trim();
	}

	// **** Building a Query **** //
	global Soql selectFields(List<FieldRef> fieldReferences) {
		for (FieldRef fieldReference : fieldReferences) {
			this.selectClauses.add(fieldReference?.toString());
		}
		return this;
	}

	global Soql selectFields(FieldRef fieldReference) {
		return this.selectFields(new List<FieldRef>{ fieldReference });
	}

	global Soql selectFields(List<SObjectField> fields) {
		for (SObjectField field : fields) {
			this.selectClauses.add(String.valueOf(field));
		}
		return this;
	}

	global Soql selectFields(SObjectField field) {
		return this.selectFields(new List<SObjectField>{ field });
	}

	global Soql selectFields(List<String> fieldNames) {
		this.selectClauses.addAll(fieldNames);
		return this;
	}

	global Soql selectFields(String fieldName) {
		return this.selectFields(new List<String>{ fieldName });
	}

	global Soql selectAll() {
		List<SObjectField> allFields = this.fromSObject?.toSchemaType()?.getDescribe()?.fields?.getMap()?.values();
		return this.selectFields(allFields);
	}

	global Soql selectSubQuery(SubQuery subQuery) {
		return this.selectFields(subQuery.toString());
	}

	global Soql selectAggregation(SoqlAggregation aggregation) {
		// Note: Id should never be included in the SELECT clause for Aggregate queries
		return this.deselectId()?.selectFields(aggregation?.toString());
	}

	global Soql deselectId() {
		// By default, Id will always be included in queries
		// Occasionally, (i.e., aggregate & inner queries), this isn't desirable
		this.selectClauses?.remove(ID_REFERENCE);
		return this;
	}

	global Soql fromSObject(SObjectType objectType) {
		this.fromSObject = new SObjectRef(objectType);
		return this;
	}

	global Soql usingScope(Scope scope) {
		this.scope = scope;
		return this;
	}

	global Soql withExpression(SoqlWithClause withExpression) {
		this.withExpression = withExpression;
		return this;
	}

	global Soql whereCriteria(List<ICriteria> filters) {
		this.whereCriteria?.addCriteria(filters);
		return this;
	}

	global Soql whereCriteria(ICriteria filter) {
		return this.whereCriteria(new List<ICriteria>{ filter });
	}

	global Soql setWhereLogic(Type newLogicType) {
		List<ICriteria> filters = this.whereCriteria?.getCriteria();
		this.whereCriteria = ((FilterLogic) newLogicType.newInstance())?.setCriteria(filters);
		return this;
	}

	global Soql groupBy(List<FieldRef> fieldReferences) {
		for (FieldRef fieldReference : fieldReferences) {
			this.groupByClauses?.add(fieldReference?.toString());
		}
		return this;
	}

	global Soql groupBy(FieldRef fieldReference) {
		return this.groupBy(new List<FieldRef>{ fieldReference });
	}

	global Soql groupBy(List<SObjectField> fields) {
		for (SObjectField field : fields) {
			this.groupBy(String.valueOf(field));
		}
		return this;
	}

	global Soql groupBy(SObjectField field) {
		return this.groupBy(new List<SObjectField>{ field });
	}

	global Soql groupBy(List<String> fieldNames) {
		this.groupByClauses?.addAll(fieldNames);
		return this;
	}

	global Soql groupBy(String fieldName) {
		return this.groupBy(new List<String>{ fieldName });
	}

	global Soql havingCriteria(SoqlAggregation.AggregateFilter aggregateCriteria) {
		this.havingCriteria?.addCriteria(aggregateCriteria);
		return this;
	}

	global Soql setHavingLogic(Type newLogicType) {
		List<ICriteria> filters = this.havingCriteria?.getCriteria();
		this.havingCriteria = ((FilterLogic) newLogicType.newInstance())?.setCriteria(filters);
		return this;
	}

	global Soql orderBy(SoqlSort orderByClause) {
		this.orderByClause = orderByClause;
		return this;
	}

	global Soql setRowLimit(Integer rowLimit) {
		this.rowLimit = rowLimit;
		return this;
	}

	global Soql setRowOffset(Integer rowOffset) {
		this.rowOffset = rowOffset;
		return this;
	}

	global Soql forUsage(Usage usage) {
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
	global virtual String getSelect() {
		return String.join(new List<String>(this.selectClauses), ', ');
	}

	global virtual String getFrom() {
		return String.valueOf(this.fromSObject);
	}

	global virtual String getUsingScope() {
		return (this.scope != null) ? 'USING SCOPE ' + String.valueOf(this.scope)?.toLowerCase() : null;
	}

	global virtual String getFilter(String token, FilterLogic logic) {
		return (logic?.getCriteria()?.isEmpty() == false) ? token + ' ' + logic?.toString() : null;
	}

	global virtual String getWith() {
		return this.withExpression?.toString();
	}

	global virtual String getGroupBy() {
		return (this.groupByClauses?.isEmpty() == false) ? 'GROUP BY ' + String.join(this.groupByClauses, ', ') : null;
	}

	global virtual String getOrderBy() {
		return (this.orderByClause != null) ? 'ORDER BY ' + this.orderByClause.toString() : null;
	}

	global virtual String getLimit(String token, Integer limitValue) {
		return (limitValue != null) ? token + ' ' + limitValue : null;
	}

	global virtual String getUsage() {
		return (this.usage != null) ? String.valueOf(this.usage)?.replace('_', ' ') : null;
	}

	// **** INNER *** //
	global enum Scope {
		// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm
		DELEGATED,
		EVERYTHING,
		MINE,
		MINE_AND_MY_GROUPS,
		MY_TERRITORY,
		MY_TEAM_TERRITORY,
		TEAM
	}

	global enum Usage {
		// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_view.htm
		// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_reference.htm
		// https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_update.htm
		ALL_ROWS,
		FOR_VIEW,
		FOR_REFERENCE,
		FOR_UPDATE
	}

	global class Factory implements DB.QueryFactory {
		global Soql newQuery(SObjectType fromSObject) {
			return new Soql(fromSObject);
		}
	}
}
