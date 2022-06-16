public without sharing class Rollup {
    public SObjectType targetObject { get; private set; }
    public List<Relationship> relationships { get; private set;  }
    @TestVisible static final String ROLLUP_QUERY_KEY = 'Rollup_Records';
    @TestVisible static final String MDT_QUERY_KEY = 'Rollup_MDTs';

    public static final Map<String, Type> calculatorsByToken = new Map<String, Type>{
        'AVG' => AvgCalculator.class,
        'COUNT' => CountCalculator.class,
        'MAX' => MaxCalculator.class,
        'MIN' => MinCalculator.class,
        'SUM' => SumCalculator.class
    }; 

    public Rollup(SObjectType targetObject) {
        this.targetObject = targetObject;
        this.relationships = new List<Relationship>();
    }

    public Rollup addRelationship(Relationship relationship) {
        this.relationships.add(relationship); 
        return this; 
    }

    public List<SObject> run(Set<Id> targetRecordIds) {
        Soql query = DatabaseLayer.QueryEngine.newQuery(this.targetObject)
            .setQueryKey(ROLLUP_QUERY_KEY)
            .whereFilters(new Filter(
                'Id', 
                Filter.IN_COLLECTION, 
                targetRecordIds
            ));
        for (Relationship relationship : this.relationships) {
            SubQuery subQuery = relationship?.getSubQuery(); 
            query.selectSubQuery(subQuery); 
        }
        List<SObject> queryResults = query.run(); 
        for (SObject record : queryResults) {
            for (Relationship relationship : this.relationships) {
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

    public void addFromMetadata(Rollup__mdt rollupRecord) {
        // Avoid creating duplicate Relationship objects for the same ChildRelationship
        Map<ChildRelationship, Relationship> relationships = new Map<ChildRelationship, Relationship>();
        for (Relationship relationship : this.relationships) {
            relationships.put(relationship.childRelationship, relationship);
        }
        ChildRelationship childRelationship = Describes.getChildRelationship(
            rollupRecord?.Parent_SObjectType__c, 
            rollupRecord?.Child_Relationship_Name__c
        );
        // Find/Create a new relationship object for our ChildRelationship
        // Then add request(s) from the metadata object to that relationship
        Relationship relationship = relationships?.get(childRelationship);
        if (relationship == null) {
            relationship = new Relationship(childRelationship); 
            this.relationships.add(relationship); 
        }
        relationship.addFromMetadata(rollupRecord); 
    }

    // **** STATIC **** //
    public static List<Rollup> getRollupsForTrigger(SObjectType triggerObjectType) {
        Soql query = Rollup.rollupMdtQuery().whereFilters(new Filter(
            Rollup__mdt.Child_SObjectType__c,
            Filter.EQUALS,
            String.valueOf(triggerObjectType)
        ));
        List<Rollup__mdt> rollupRecords = (List<Rollup__mdt>) query.run(); 
        return Rollup.generateFromMetadata(rollupRecords); 
    }

    public static Soql rollupMdtQuery() {
        // A base query which can be built off of by other jobs.
        // It includes all necessary fields, and excludes inactive Filters/Rollups
        ChildRelationship rollupFilters = Describes.getChildRelationship(Rollup__mdt.SObjectType, 'Rollup_Filters__r');
        return DatabaseLayer.QueryEngine.newQuery(Rollup__mdt.SObjectType)
            .selectAll()
            .selectSubQuery((SubQuery) new SubQuery(rollupFilters)
                .selectFields(new List<String>{
                    'Filter__r.' + Filter__mdt.Field_Name__c,
                    'Filter__r.' + Filter__mdt.Operator__c,
                    'Filter__r.' + Filter__mdt.SObjectField__c,
                    'Filter__r.' + Filter__mdt.SObjectType__c,
                    'Filter__r.' + Filter__mdt.Value__c
                }).whereFilters(new Filter(
                    Rollup_Filter__mdt.Active__c, 
                    Filter.EQUALS, 
                    true
                ))
            ).whereFilters(new Filter(
                Rollup__mdt.Active__c,
                Filter.EQUALS,
                true
            )).setQueryKey(MDT_QUERY_KEY);
    }

    public static List<Rollup> generateFromMetadata(List<Rollup__mdt> rollupRecords) {
        Map<SObjectType, Rollup> rollupsBySObjectType = new Map<SObjectType, Rollup>();
        for (Rollup__mdt rollupRecord : rollupRecords) {
            SObjectType objectType = Describes.getSObjectTypeByName(rollupRecord.Parent_SObjectType__c);
            Rollup rollup = rollupsBySObjectType?.containsKey(objectType) 
                ? rollupsBySObjectType?.get(objectType) 
                : new Rollup(objectType);
            rollup.addFromMetadata(rollupRecord);
            rollupsBySObjectType.put(objectType, rollup); 
        }
        return rollupsBySObjectType.values();
    }
    
    // **** INNER **** // 
    public class Relationship {
        public ChildRelationship childRelationship { get; private set; }
        public List<Request> requests { get; private set; }

        public Relationship(ChildRelationship childRelationship) {
            this.childRelationship = childRelationship;
            this.requests = new List<Request>();
        }

        public Relationship(SObjectType objectType, String relationshipName) {
            this(Describes.getChildRelationship(objectType, relationshipName));
        }

        public Relationship(String objectName, String relationshipName) {
            this(Describes.getSObjectTypeByName(objectName), relationshipName);
        }
        
        public Relationship addRequest(Request request) {
            this.requests.add(request);
            return this;
        }

        public SubQuery getSubQuery() {
            SubQuery subQuery = new SubQuery(this.childRelationship);
            for (Request request : this.requests) {
                subQuery.selectFields(request.getFieldNames());   
            }
            return subQuery;
        }

        public void calculate(SObject targetRecord) {
            List<SObject> childRecords = targetRecord?.getSObjects(this.childRelationship?.getRelationshipName());
            for (Request request : this.requests) {
                request.calculate(targetRecord, childRecords);
            }
        }

        public void addFromMetadata(Rollup__mdt rollupRecord) {
            // Avoid creating duplicate Requests per target field
            Map<SObjectField, Request> requests = new Map<SObjectField, Request>();
            for (Request request : this.requests) {
                requests.put(request?.targetField, request); 
            }
            Request request = new Request(rollupRecord); 
            requests?.put(request?.targetField, request);
            this.requests = requests?.values();
        }
    }

    public virtual class Request {
        public SObjectField targetField { get; private set; } 
        public Calculator calculator { get; private set; }
        public List<Filter> filters { get; private set; }

        public Request(SObjectField targetField, Calculator calculator) {
            this.targetField = targetField;
            this.calculator = calculator;
            this.filters = new List<Filter>();
            this.validate(); 
        }

        public Request(Rollup__mdt rollupRecord) {
            this.targetField = Describes.getSObjectFieldByName(rollupRecord?.Target_Field__c);
            this.calculator = this.getCalculator(rollupRecord);
            this.filters = this.addRollupFilters(rollupRecord?.Rollup_Filters__r);
            this.validate(); 
        }

        public Request addFilters(List<Filter> queryFilters) {
            this.filters.addAll(queryFilters);
            return this;
        }
        
        public Request addFilters(Filter filter) {
            return this.addFilters(new List<Filter>{filter});
        }

        public List<String> getFieldNames() {
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

        public void calculate(SObject targetRecord, List<SObject> childRecords) {
            List<SObject> filteredRecords = this.doFilter(childRecords);
            Object targetValue = this.calculator.calculate(filteredRecords); 
            targetRecord.put(this.targetField, targetValue);
        }

        public List<Filter> addRollupFilters(List<Rollup_Filter__mdt> rollupFilters) {
            List<Filter> filters = new List<Filter>();
            for (Rollup_Filter__mdt rollupFilter : rollupFilters) {
                if (rollupFilter?.Active__c == true) {
                    Filter__mdt filterMdt = rollupFilter.Filter__r;
                    filters.add(new Filter(filterMdt));
                }
            }
            return filters;
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

        private void validate() {
            if (this.calculator == null || this.targetField == null) {
                Exception error = new RollupException('Missing required Request fields: ' + this);
                Logger.logException(error);
                throw error;
            }
        }

        private Calculator getCalculator(Rollup__mdt rollupRecord) {
            SObjectField calcField = Describes.getSObjectFieldByName(rollupRecord?.Calculation_Field__c);
            Type calcType = (rollupRecord?.Calculator_Class_Name__c != null) 
                ? Type.forName(rollupRecord?.Calculator_Class_Name__c)
                : Rollup.calculatorsByToken.get(rollupRecord?.Calculation_Type__c);
            return ((Calculator) calcType?.newInstance())?.setCalcField(calcField);
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
            Schema.SoapType dataType = Describes.getFieldDescribe(this.calcField)?.getSoapType(); 
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

        public virtual Boolean calculateBoolean(List<SObject> records) {
            return null; 
        }

        public virtual Date calculateDate(List<SObject> records) {
            return null; 
        }

        public virtual DateTime calculateDateTime(List<SObject> records) {
            return null;
        }

        public virtual Decimal calculateNumber(List<SObject> records) {
            return 0; 
        }

        public virtual String calculateText(List<SObject> records) {
            return null; 
        }
    }

    public class RollupException extends Exception {}
}
