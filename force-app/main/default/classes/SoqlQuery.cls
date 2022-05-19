global inherited sharing virtual class SoqlQuery implements IQuery {
    @TestVisible Set<String> fields = new Set<String>{'Id'};
    @TestVisible SObjectType targetObject;
    @TestVisible List<Filter> filters = new List<Filter>();
    @TestVisible QuerySort orderBy;
    @TestVisible List<String> queryTags = new List<String>(); 
    @TestVisible Integer queryLimit; 
    @TestVisible String filterLogic; 
    
    global SoqlQuery(SObjectType targetObject) {
        this.setTargetSObject(targetObject); 
    }

    protected SoqlQuery() {
        // This constructor allows extending types to call super() methods
    }
    
    // **** Running a Query **** // 
    global virtual List<SObject> run() {
        // Run the current query object through the database
        String soql = this.getQueryString(); 
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

    global virtual String getQueryString() {
        // Output the current SoqlQuery object as a SOQL Query string
        // SELECT {fields} FROM {targetObject} {WHERE filters} {ORDER BY orderBy} {LIMIT limit} {queryTags}
        String template = 'SELECT {0} FROM {1}{2}{3}{4}{5}';
        return String.format(template, new String[]{
            String.join(new List<String>(this.fields), ', '),
            this.getTargetObject(),
            this.getWhereClause(),
            this.getSpecialTags(),
            this.getOrderByClause(),
            this.getLimitClause()
        });
    }

    // **** Building a Query **** //
    global SoqlQuery setTargetSObject(SObjectType targetObject) {
        this.targetObject = targetObject; 
        return this; 
    }

    global SoqlQuery addFields(List<SObjectField> fields) {
        List<String> fieldStrings = new List<String>();
        for (SObjectField field : fields) {
            if (field != null) {
                fieldStrings.add(String.valueOf(field));
            }
        }
        return this.addFields(fieldStrings); 
    }

    global SoqlQuery addFields(SObjectField field) {
        return this.addFields(new List<SObjectField>{field});
    }

    global SoqlQuery addFields(List<String> fields) {
        this.fields.addAll(fields); 
        return this; 
    }

    global SoqlQuery addFields(String field) {
        return this.addFields(new List<String>{field});
    }

    global SoqlQuery addAllFields() {
        // Replicates SELECT * in SQL
        List<SObjectField> allFields = Describes.getSObjectDescribe(this.targetObject)?.fields?.getMap()?.values();
        return this.addFields(allFields); 
    }

    global SoqlQuery addSubQueries(List<SubQuery> subQueries) {
        List<String> childQueryStrings = new List<String>();
        for (SubQuery subQuery : subQueries) {
            childQueryStrings.add(subQuery.getQueryString());
        }
        return this.addFields(childQueryStrings); 
    }

    global SoqlQuery addSubQueries(SubQuery subQuery) {
        return this.addSubQueries(new List<SubQuery>{subQuery});
    }

    global SoqlQuery resetFields() {
        this.fields = new Set<String>{'Id'};
        return this; 
    }

    global SoqlQuery addFilters(List<Filter> filters) {
        this.filters.addAll(filters); 
        return this;
    }

    global SoqlQuery addFilters(Filter filter) {
        return this.addFilters(new List<Filter>{filter});
    }

    global SoqlQuery resetFilters() {
        this.filters.clear();
        return this;
    }

    global SoqlQuery setFilterLogic(String formattedLogicString) {
        // Expects a String.format() template with and/or logic in between
        // i.e., '{0} AND {1} AND ({2} OR {3})'
        this.filterLogic = formattedLogicString;
        return this;
    }

    global SoqlQuery resetFilterLogic() {
        return this.setFilterLogic(null); 
    }

    global SoqlQuery setOrderBy(QuerySort orderBy) {
        this.orderBy = orderBy;
        return this; 
    }

    global SoqlQuery resetOrderBy() {
        this.orderBy = null; 
        return this; 
    }

    global SoqlQuery setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit; 
        return this;
    }

    global SoqlQuery resetLimit() {
        return this.setLimit(null); 
    }

    global SoqlQuery addTags(List<String> queryTags) {
        this.queryTags.addAll(queryTags);
        return this; 
    }

    global SoqlQuery addTags(String queryTag) {
        return this.addTags(new List<String>{queryTag});
    }

    global SoqlQuery resetTags() {
        this.queryTags.clear();
        return this; 
    }
    
    global SoqlQuery reset() {
        this.resetFields();
        this.resetFilters();
        this.resetFilterLogic(); 
        this.resetOrderBy(); 
        this.resetLimit();
        this.resetTags(); 
        return this; 
    }

    // **** PRIVATE **** // 
    protected virtual String getTargetObject() {
        return String.valueOf(this.targetObject);
    }

    private String getWhereClause() {
        return (this.filters?.isEmpty() == false)
            ? ' WHERE ' + this.joinFilters()
            : '';
    }

    private String joinFilters() {
        List<String> filterStrings = new List<String>(); 
        for (Filter filter : this.filters) {
            filterStrings.add(filter.toString()); 
        }
        return (this.filterLogic != null) 
            ? String.format(this.filterLogic, filterStrings)
            : String.join(filterStrings, ' AND ');
    }

    private String getOrderByClause() {
        return (this.orderBy != null) ? ' ORDER BY ' + this.orderBy.toString() : '';
    }

    private String getLimitClause() {
        return (this.queryLimit != null) ? ' LIMIT ' + this.queryLimit : '';
    }

    private String getSpecialTags() {
        return (this.queryTags?.isEmpty() == false) ? ' ' + String.join(this.queryTags, ' ') : '';
    }

    public class Factory implements IQueryFactory {
        public IQuery newQuery(SObjectType objectType) {
            return new SoqlQuery(objectType); 
        }
    }
}