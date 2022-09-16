public without sharing class Rollup {
	@TestVisible
	SObjectRef targetObject { get; private set; }
	@TestVisible
	Map<ChildRelationshipRef, Relationship> relationships { get; private set; }

	// Note: this query's FromSObject isn't known until runtime; set by the run() method
	@TestVisible
	static Soql RollupQuery = DatabaseLayer.Soql.newQuery(null);

	public Rollup(SObjectType sObjectType) {
		this.targetObject = new SObjectRef(sObjectType);
		this.relationships = new Map<ChildRelationshipRef, Relationship>();
	}

	public Rollup addRelationship(Relationship relationship) {
		ChildRelationshipRef childRelationship = relationship?.childRelationship;
		Relationship existingRelationship = (this.relationships?.containsKey(childRelationship))
			? this.relationships?.get(childRelationship)?.addAllRequests(relationship)
			: relationship;
		this.relationships.put(childRelationship, existingRelationship);
		return this;
	}

	public List<SObject> run(Set<Id> targetRecordIds) {
		Rollup.RollupQuery = Rollup.RollupQuery.fromSObject(this.targetObject?.toSchemaType())
			.whereFilters(new Filter('Id', Filter.IN_COLLECTION, targetRecordIds));
		for (Relationship relationship : this.relationships.values()) {
			SubQuery subQuery = relationship?.getSubQuery();
			Rollup.RollupQuery.selectSubQuery(subQuery);
		}
		List<SObject> queryResults = Rollup.RollupQuery.run();
		for (SObject record : queryResults) {
			this.calculateRecord(record);
		}
		return queryResults;
	}

	public List<SObject> run(List<SObject> targetRecords) {
		Set<Id> targetRecordIds = new Map<Id, SObject>(targetRecords)?.keySet();
		return this.run(targetRecordIds);
	}

	public List<SObject> runFromChild(List<SObject> sourceRecords, SObjectField targetIdField) {
		// Note: Not using CollectionUtils.extractValues() here to void JSON errors when using mock DML
		// Ex: ! System.JSONException: malformed id 001000000000000000
		Set<Id> targetIds = new Set<Id>();
		for (SObject record : sourceRecords) {
			Id targetId = (Id) record.get(targetIdField);
			targetIds.add(targetId);
		}
		return this.run(new Set<Id>(targetIds));
	}

	private void calculateRecord(SObject record) {
		for (Relationship relationship : this.relationships.values()) {
			relationship.calculate(record);
		}
	}

	// **** INNER **** //
	public class Relationship {
		public ChildRelationshipRef childRelationship { get; private set; }
		public Map<FieldRef, Request> requests { get; private set; }

		public Relationship(ChildRelationship childRelationship) {
			this.childRelationship = new ChildRelationshipRef(childRelationship);
			this.requests = new Map<FieldRef, Request>();
		}

		public Relationship(FieldRef lookupField) {
			this(SchemaUtils.getChildRelationship(lookupField?.toSchemaType()));
		}

		public Relationship addRequest(Request request) {
			this.requests.put(request?.targetField, request);
			return this;
		}

		private Relationship addAllRequests(Relationship otherRelationship) {
			// This is mostly used for deduping purposes
			this.requests?.putAll(otherRelationship?.requests);
			return this;
		}

		private SubQuery getSubQuery() {
			SubQuery subQuery = new SubQuery(this.childRelationship?.toSchemaType());
			for (Request request : this.requests?.values()) {
				subQuery.selectFields(request.getFieldNames());
			}
			return subQuery;
		}

		private void calculate(SObject targetRecord) {
			String relationshipName = this.childRelationship?.toSchemaType()?.getRelationshipName();
			// ! Supplying a null value to SObject.getSObjects() will cause a System.NullPointerException
			if (relationshipName != null) {
				List<SObject> childRecords = targetRecord?.getSObjects(relationshipName);
				for (Request request : this.requests?.values()) {
					request.calculate(targetRecord, childRecords);
				}
			}
		}
	}

	public class Request {
		public FieldRef targetField { get; private set; }
		public Calculator calculator { get; private set; }
		public List<Filter> filters { get; private set; }

		public Request(FieldRef targetField, Calculator calculator, List<Filter> filters) {
			this.targetField = targetField;
			this.calculator = calculator;
			this.filters = filters;
		}

		public Request(FieldRef targetField, Calculator calculator) {
			this(targetField, calculator, new List<Filter>());
		}

		public Request addFilters(List<Filter> queryFilters) {
			this.filters.addAll(queryFilters);
			return this;
		}

		public Request addFilters(Filter filter) {
			return this.addFilters(new List<Filter>{ filter });
		}

		public void calculate(SObject targetRecord, List<SObject> childRecords) {
			List<SObject> filteredRecords = this.doFilter(childRecords);
			SObjectField field = this.targetField?.toSchemaType();
			Object value = this.calculator.calculate(filteredRecords);
			targetRecord.put(field, value);
		}

		private List<String> getFieldNames() {
			List<String> fieldNames = new List<String>();
			SObjectField calcField = this.calculator.getCalcField()?.toSchemaType();
			if (calcField != null) {
				fieldNames.add(String.valueOf(calcField));
			}
			for (Filter filter : this.filters) {
				fieldNames?.add(filter?.getFieldName());
			}
			return fieldNames;
		}

		private List<SObject> doFilter(List<SObject> records) {
			List<SObject> filteredRecords = new List<SObject>();
			for (SObject record : records) {
				if (this.meetsFilterCriteria(record)) {
					filteredRecords.add(record);
				}
			}
			return filteredRecords;
		}

		private Boolean meetsFilterCriteria(SObject record) {
			for (Filter filter : this.filters) {
				if (filter.meetsCriteria(record) == false) {
					return false;
				}
			}
			return true;
		}
	}

	public abstract class Calculator {
		public FieldRef calcField { get; protected set; }

		public FieldRef getCalcField() {
			return this.calcField;
		}

		public virtual Calculator setCalcField(FieldRef calcField) {
			this.calcField = calcField;
			return this;
		}

		public virtual Object calculate(List<SObject> records) {
			records = (records != null) ? records : new List<SObject>();
			Schema.SoapType dataType = SchemaUtils.describeField(this.calcField?.toSchemaType())?.getSoapType();
			switch on dataType {
				when BOOLEAN {
					return this.calculateBoolean(records);
				}
				when DATE {
					return this.calculateDate(records);
				}
				when DATETIME {
					return this.calculateDateTime(records);
				}
				when DECIMAL, DOUBLE, INTEGER {
					return this.calculateNumber(records);
				}
				when ID, STRING {
					return this.calculateText(records);
				}
			}
			return null;
		}

		protected virtual Boolean calculateBoolean(List<SObject> records) {
			return null;
		}

		protected virtual Date calculateDate(List<SObject> records) {
			return null;
		}

		protected virtual DateTime calculateDateTime(List<SObject> records) {
			return null;
		}

		protected virtual Decimal calculateNumber(List<SObject> records) {
			return 0;
		}

		protected virtual String calculateText(List<SObject> records) {
			return null;
		}
	}
}
