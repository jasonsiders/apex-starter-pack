public without sharing class Rollup {
    @TestVisible SObjectType targetObject { get; private set; }
    @TestVisible Map<Schema.ChildRelationship, Relationship> relationships { get; private set;  }
    @TestVisible static final String ROLLUP_QUERY = 'Rollup_Query';

    public Rollup(SObjectType targetObject) {
        this.targetObject = targetObject;
        this.relationships = new Map<Schema.ChildRelationship, Relationship>();
    }

    public Rollup addRelationship(Relationship relationship) {
        Schema.ChildRelationship childRelationship = relationship?.childRelationship; 
        Relationship existingRelationship = (this.relationships.containsKey(childRelationship))
            ? this.relationships.get(childRelationship)?.addAllRequests(relationship)
            : relationship;
        this.relationships.put(childRelationship, existingRelationship); 
        return this; 
    }

    public List<SObject> run(Set<Id> targetRecordIds) {
        Soql query = Databaselayer.Soql.newQuery(this.targetObject)
            .setQueryKey(ROLLUP_QUERY)
            .whereFilters(new Filter(
                'Id', 
                Filter.IN_COLLECTION, 
                targetRecordIds
            ));
        for (Relationship relationship : this.relationships.values()) {
            SubQuery subQuery = relationship?.getSubQuery(); 
            query.selectSubQuery(subQuery); 
        }
        List<SObject> queryResults = query.run(); 
        for (SObject record : queryResults) {
            for (Relationship relationship : this.relationships.values()) {
                relationship.calculate(record); 
            }
        }
        return queryResults; 
    }

    public List<SObject> run(List<SObject> targetRecords) {
        Set<Id> targetRecordIds = new Map<Id, SObject>(targetRecords)?.keySet();
        return this.run(targetRecordIds); 
    }

    public List<SObject> runFromChild(List<SObject> sourceRecords, SObjectField targetIdField) {
        Set<Id> targetIds = new Set<Id>();
        for (SObject record : sourceRecords) {
            Id targetId = (Id) record?.get(targetIdField); 
            targetIds.add(targetId); 
        }
        return this.run(targetIds);
    }
    
    // **** INNER **** // 
    public class Relationship {
        public ChildRelationship childRelationship { get; private set; }
        public Map<SObjectField, Request> requests { get; private set; }

        public Relationship(ChildRelationship childRelationship) {
            this.childRelationship = childRelationship;
            this.requests = new Map<SObjectField, Request>();
        }

        public Relationship(SObjectType objectType, String relationshipName) {
            this(SchemaUtils.getChildRelationship(objectType, relationshipName));
        }

        public Relationship(String objectName, String relationshipName) {
            this(SchemaUtils.getSObjectType(objectName), relationshipName);
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
            SubQuery subQuery = new SubQuery(this.childRelationship);
            for (Request request : this.requests?.values()) {
                subQuery.selectFields(request.getFieldNames());   
            }
            return subQuery;
        }

        private void calculate(SObject targetRecord) {
            List<SObject> childRecords = targetRecord?.getSObjects(this.childRelationship?.getRelationshipName());
            for (Request request : this.requests?.values()) {
                request.calculate(targetRecord, childRecords);
            }
        } 
    }

    public class Request {
        public SObjectField targetField { get; private set; } 
        public Calculator calculator { get; private set; }
        public List<Filter> filters { get; private set; }

        public Request(SObjectField targetField, Calculator calculator, List<Filter> filters) {
            this.targetField = targetField;
            this.calculator = calculator;
            this.filters = filters;
        }
        
        public Request(SObjectField targetField, Calculator calculator) {
            this(targetField, calculator, new List<Filter>());
        }

        public Request addFilters(List<Filter> queryFilters) {
            this.filters.addAll(queryFilters);
            return this;
        }
        
        public Request addFilters(Filter filter) {
            return this.addFilters(new List<Filter>{filter});
        }

        public void calculate(SObject targetRecord, List<SObject> childRecords) {
            List<SObject> filteredRecords = this.doFilter(childRecords);
            Object targetValue = this.calculator.calculate(filteredRecords); 
            targetRecord.put(this.targetField, targetValue);
        }

        private List<String> getFieldNames() {
            List<String> fieldNames = new List<String>();
            SObjectField calcField = this.calculator.getCalcField();
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
        public SObjectField calcField { get; protected set; }

        public SObjectField getCalcField() {
            return this.calcField; 
        }

        public virtual Calculator setCalcField(SObjectField calcField) {
            this.calcField = calcField;
            return this; 
        }

        public virtual Object calculate(List<SObject> records) {
            records = (records != null) ? records : new List<SObject>();
            Schema.SoapType dataType = SchemaUtils.describeField(this.calcField)?.getSoapType(); 
            switch on dataType {
                when BOOLEAN {
                    return this.calculateBoolean(records); 
                } when DATE {
                    return this.calculateDate(records); 
                } when DATETIME {
                    return this.calculateDateTime(records); 
                } when DECIMAL, DOUBLE, INTEGER {
                    return this.calculateNumber(records); 
                } when ID, STRING {
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
