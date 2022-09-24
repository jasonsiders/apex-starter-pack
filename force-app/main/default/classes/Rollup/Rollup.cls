public virtual without sharing class Rollup implements System.Queueable, Database.Batchable<SObject> {
    @TestVisible
    static Soql RollupQuery = DatabaseLayer.Soql.newQuery(null); 
    @TestVisible
    static Soql TargetRecordQuery = DatabaseLayer.Soql.newQuery(null); 
    
    Set<Id> recordIds;
    RuntimeConfig runtime;
    FieldRef recordKey;
    Target target;
    
    public Rollup(Target target) {
        this.recordIds = new Set<Id>(); 
        this.runtime = new RuntimeConfig(); 
        this.target = target; 
    }

    public Rollup addRecords(Set<Id> recordIds, SObjectField lookupField) {
        this.recordIds?.addAll(recordIds);
        this.recordKey = (lookupField != null) ? new FieldRef(lookupField) : null;
        return this; 
    }

    public Rollup addRecords(List<SObject> records, SObjectField lookupField) {
        return this.addRecords(
            new Map<Id, SObject>(records)?.keySet(), 
            lookupField
        );
    }

    public Rollup addRecords(Set<Id> recordIds) {
        return this.addRecords(recordIds, null); 
    }

    public Rollup addRecords(List<SObject> records) {
        return this.addRecords(new Map<Id, SObject>(records)?.keySet()); 
    }

    public Rollup addOperation(SObjectField lookupField, Operation operation) {
        this.target?.addOperation(lookupField, operation); 
        return this; 
    }

    public Rollup setRuntime(RuntimeConfig runtime) {
        this.runtime = runtime; 
        return this; 
    }

    public Id run() {
        this.getTargetRecords();
        Integer numRecords = this.recordIds?.size();
        Runtime.Context timing = this.runtime.getRuntimeContext(numRecords);
        switch on timing {
            when BATCHAPEX {
                return Database.executeBatch(this, this.runtime?.batchSize);
            }
            when QUEUEABLE {
                return System.enqueueJob(this);
            }
            when else {
                this.execute(null); 
                return null;
            }
        }
    }

    private void getTargetRecords() {
        // When child records are given, the Rollup must first find the target records 
        // using the recordKey as a reference to those target objects
        if (this.recordKey != null) {
            // Build an inner query from the current recordIds
            Id recordId = (Id) CollectionUtils.getIndexOf(new List<Id>(this.recordIds), 1);
            SObjectType childObject = recordId?.getSObjectType(); 
            Filter inRecordIds = new Filter('Id', Filter.IN_COLLECTION, new List<Id>(this.recordIds));
            Soql innerQuery = DatabaseLayer.Soql.newQuery(childObject)
                .deselectId()
                .selectFields(this.recordKey)
                .whereCriteria(inRecordIds);
            // Query for the target records based on the inner query
            SObjectType targetObject = this.target?.objectType?.toSchemaType(); 
            Filter inInnerQuery = new Filter('Id', Filter.IN_COLLECTION, innerQuery);
            Soql query = Rollup.TargetRecordQuery?.clone()?.fromSObject(targetObject).whereCriteria(inInnerQuery);
            List<SObject> targetRecords = query.run();
            this.recordIds = new Map<Id, SObject>(targetRecords)?.keySet();
        }
    }

    // **** QUEUEABLE **** //
    public void execute(System.QueueableContext context) {
        List<SObject> updatedRecords = this.target.doRollup(this.recordIds);
        List<DmlResult> saveResults = DatabaseLayer.Dml.doUpdate(updatedRecords, false);
        DmlResult.logErrors(saveResults);
    }

    // **** BATCHABLE **** // 
    public List<SObject> start(Database.BatchableContext context) {
        Soql query = this.target?.getQuery(this.recordIds); 
        return query.run();
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        this.target.process(scope); 
        List<DmlResult> saveResults = DatabaseLayer.Dml.doUpdate(scope, false);
        DmlResult.logErrors(saveResults);
    }

    public void finish(Database.BatchableContext context) {
        // Nothing needed here
    }

    // **** INNER **** // 
    public class Target {
        public SObjectRef objectType { get; protected set; }
        public Map<FieldRef, Relationship> relationships { get; protected set; }

        public Target(SObjectType objectType) {
            this.objectType = new SObjectRef(objectType); 
            this.relationships = new Map<FieldRef, Relationship>();
        }
    
        public Target addOperation(SObjectField lookupField, Operation operation) {
            FieldRef ref = new FieldRef(lookupField); 
            Relationship relationship = this.relationships.containsKey(ref) 
                ? this.relationships.get(ref) 
                : new Relationship(lookupField);
            relationship.addOperation(operation);
            this.relationships.put(ref, relationship); 
            return this; 
        }

        public List<SObject> doRollup(Set<Id> recordIds) {
            Soql query = this.getQuery(recordIds); 
            List<SObject> results = query.run(); 
            this.process(results);
            return results; 
        }

        public List<SObject> doRollup(List<SObject> records) {
            // Assumes that the caller hasn't properly queried for record data yet
            return this.doRollup(new Map<Id, SObject>(records)?.keySet()); 
        }

        private void process(List<SObject> records) {
            for (SObject record : records) {
                this.calculate(record); 
            }
        }

        private void calculate(SObject record) {
            for (Relationship relationship : this.relationships?.values()) {
                relationship?.calculate(record);
            }
        }

        private Soql getQuery(Set<Id> targetRecordIds) {
            // Note: Filter.IN_COLLECTION doesn't work with Sets
            List<Id> recordIds = new List<Id>(targetRecordIds); 
            SObjectType objectType = this.objectType?.toSchemaType();
            Soql query = Rollup.RollupQuery?.clone()?.fromSObject(objectType);
            query.whereCriteria(new Filter('Id', Filter.IN_COLLECTION, recordIds));
            for (Relationship relationship : this.relationships?.values()) {
                SubQuery subQuery = relationship.getSubQuery();
                query.selectSubQuery(subQuery);
            }
            return query; 
        }
    }

    @TestVisible
    private class Relationship {
        public ChildRelationshipRef childRelationship { get; private set; }
        public Map<FieldRef, Operation> operations { get; private set; }

        private Relationship(SObjectField lookupField) {
            this.childRelationship = new ChildRelationshipRef(lookupField);
            this.operations = new Map<FieldRef, Operation>();
        }

        private Relationship addOperation(Operation operation) {
            this.operations.put(operation?.targetField, operation); 
            return this; 
        }

        private SubQuery getSubQuery() {
            SubQuery subQuery = new SubQuery(this.childRelationship?.toSchemaType());
			for (Operation operation : this.operations?.values()) {
				Set<String> fieldNames = operation?.getFieldNames();
				subQuery.selectFields(new List<String>(fieldNames));
			}
			return subQuery;
        }

        private void calculate(SObject record) {
            String relationshipName = this.childRelationship?.toSchemaType()?.getRelationshipName();
            // Note: Supplying a null value to SObject.getSObjects() will cause a System.NullPointerException
			if (relationshipName != null) {
				List<SObject> childRecords = record?.getSObjects(relationshipName);
				for (Operation operation : this.operations?.values()) {
					operation?.calculate(record, childRecords);
				}
			}
        }
    }

    public class Operation {
        public FieldRef targetField { get; private set; }
        public Calculator calculator { get; private set; }
        public FilterLogic filterLogic { get; private set; }

        public Operation(SObjectField targetField, Calculator calculator, FilterLogic baseLogic) {
            this.targetField = new FieldRef(targetField);
            this.calculator = calculator;
            this.filterLogic = baseLogic; 
        }

        public Operation(SObjectField targetField, Calculator calculator, Filter filter) {
            this(targetField, calculator);
            this.addCriteria(filter);
        }

        public Operation(SObjectField targetField, Calculator calculator) {
            this(targetField, calculator, new AndLogic()); 
        }

        public Operation addCriteria(ICriteria criteria) {
            this.filterLogic?.addCriteria(criteria); 
            return this; 
        }

        private void calculate(SObject targetRecord, List<SObject> childRecords) {
            List<SObject> filteredRecords = this.filterRecords(childRecords);
			SObjectField field = this.targetField?.toSchemaType();
			Object value = this.calculator.calculate(filteredRecords);
			targetRecord.put(field, value);
        }

        private List<SObject> filterRecords(List<SObject> records) {
			List<SObject> results = new List<SObject>();
			for (SObject record : records) {
				if (this.filterLogic?.meetsCriteria(record)) {
					results.add(record);
				}
			}
			return results;
		}

        private Set<String> getFieldNames() {
			Set<String> fieldNames = this.filterLogic?.getFieldNames();
            fieldNames.add(String.valueOf(this.calculator?.getCalcField()));
            fieldNames.remove(null); 
            return fieldNames; 
		}
    }

    public abstract class Calculator {
        @TestVisible
        protected FieldRef calcField { get; protected set; }
        protected String label; 
        
        public FieldRef getCalcField() {
            return this.calcField; 
        }
        
        // Sets the key field to be used in calculation operations
        public virtual Calculator setCalcField(FieldRef calcField) {
            this.calcField = calcField; 
            return this;
        }

        public Calculator setCalcField(SObjectField calcField) {
            return this.setCalcField(new FieldRef(calcField));
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

    public virtual class RuntimeConfig extends Runtime {
        Integer batchSize;

        public RuntimeConfig() {
            this.setAsyncThreshold(100); 
            this.setBatchSize(200); 
            this.setBatchThreshold(200); 
        }

        public RuntimeConfig setBatchSize(Integer batchSize) {
            this.batchSize = batchSize;
            return this; 
        }
    }
}
