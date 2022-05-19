public without sharing class Rollup {
    public SObjectType targetObject;
    public List<Relationship> relationships = new List<Relationship>();

    public Rollup(SObjectType targetObject) {
        this.targetObject = targetObject;
    }

    public Rollup addRelationship(Relationship relationship) {
        this.relationships.add(relationship); 
        return this; 
    }

    public List<SObject> run(Set<Id> targetRecordIds) {
        IQuery query = DatabaseLayer.QueryEngine.newQuery(this.targetObject)
            .addFilters(new Filter(
                'Id', 
                Filter.IN_COLLECTION, 
                targetRecordIds
            ));
        for (Relationship relationship : this.relationships) {
            SubQuery subQuery = relationship?.getSubQuery(); 
            query.addSubQueries(subQuery); 
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
    
    // **** INNER **** // 
    public interface ICalculator {
        Object calculate(List<SObject> records);
        SObjectField getCalcField(); 
    }
    
    public class Relationship {
        ChildRelationship childRelationship; 
        List<Request> requests = new List<Request>();

        public Relationship(ChildRelationship childRelationship) {
            this.childRelationship = childRelationship;
        }

        public Relationship(SObjectType objectType, String relationshipName) {
            this(Describes.getChildRelationship(objectType, relationshipName));
        }

        public Relationship(String objectName, String relationshipName) {
            this(Describes.getSobjectTypeByName(objectName), relationshipName);
        }
        
        public Relationship addRequest(Request request) {
            this.requests.add(request);
            return this;
        }

        public SubQuery getSubQuery() {
            SubQuery subQuery = new SubQuery(this.childRelationship);
            for (Request request : this.requests) {
                subQuery.addFields(request.getFieldNames());   
            }
            return subQuery;
        }

        public void calculate(SObject targetRecord) {
            List<SObject> childRecords = targetRecord?.getSObjects(this.childRelationship?.getRelationshipName());
            for (Request request : this.requests) {
                request.calculate(targetRecord, childRecords);
            }
        }
    }

    public virtual class Request {
        SObjectField targetField; 
        ICalculator calculator; 
        List<Filter> filters = new List<Filter>();

        public Request(SObjectField targetField, ICalculator calculator) {
            this.targetField = targetField;
            this.calculator = calculator;
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
}
