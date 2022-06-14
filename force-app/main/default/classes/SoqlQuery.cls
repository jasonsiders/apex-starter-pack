public inherited sharing virtual class SoqlQuery implements IQuery {
    @TestVisible Set<String> fields = new Set<String>{'Id'};
    @TestVisible SObjectType targetObject;
    @TestVisible FilterLogic filterLogic = new FilterLogic.AndLogic(); 
    @TestVisible QuerySort orderBy;
    @TestVisible List<String> queryTags = new List<String>(); 
    @TestVisible Integer queryLimit; 
    public String queryKey { get; private set; }
    
    public SoqlQuery(SObjectType targetObject) {
        this.setTargetSObject(targetObject); 
    }

    protected SoqlQuery() {
        // This constructor allows extending types to call super() methods
    }
    
    // **** Running a Query **** // 
    public virtual List<SObject> run() {
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

    public virtual String getQueryString() {
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
    public SoqlQuery setTargetSObject(SObjectType targetObject) {
        this.targetObject = targetObject; 
        return this; 
    }

    public SoqlQuery addFields(List<SObjectField> fields) {
        List<String> fieldStrings = new List<String>();
        for (SObjectField field : fields) {
            if (field != null) {
                fieldStrings.add(String.valueOf(field));
            }
        }
        return this.addFields(fieldStrings); 
    }

    public SoqlQuery addFields(SObjectField field) {
        return this.addFields(new List<SObjectField>{field});
    }

    public SoqlQuery addFields(List<String> fields) {
        this.fields.addAll(fields); 
        return this; 
    }

    public SoqlQuery addFields(String field) {
        return this.addFields(new List<String>{field});
    }

    public SoqlQuery addAllFields() {
        // Replicates SELECT * in SQL
        List<SObjectField> allFields = Describes.getSObjectDescribe(this.targetObject)?.fields?.getMap()?.values();
        return this.addFields(allFields); 
    }

    public SoqlQuery addSubQueries(List<SubQuery> subQueries) {
        List<String> childQueryStrings = new List<String>();
        for (SubQuery subQuery : subQueries) {
            childQueryStrings.add(subQuery.getQueryString());
        }
        return this.addFields(childQueryStrings); 
    }

    public SoqlQuery addSubQueries(SubQuery subQuery) {
        return this.addSubQueries(new List<SubQuery>{subQuery});
    }

    public SoqlQuery resetFields() {
        this.fields = new Set<String>{'Id'};
        return this; 
    }

    public SoqlQuery addFilters(List<Filter> filters) {
        this.filterLogic?.addFilters(filters);
        return this;
    }

    public SoqlQuery addFilters(Filter filter) {
        return this.addFilters(new List<Filter>{filter});
    }

    public SoqlQuery resetFilters() {
        this.filterLogic?.setFilters(new List<Filter>());
        return this;
    }

    public SoqlQuery setFilterLogic(Type logicType) {
        List<Filter> filters = this.filterLogic?.getFilters(); 
        this.filterLogic = ((FilterLogic) logicType.newInstance())?.setFilters(filters);
        return this;
    }

    public SoqlQuery resetFilterLogic() {
        return this.setFilterLogic(FilterLogic.AndLogic.class); 
    }

    public SoqlQuery setOrderBy(QuerySort orderBy) {
        this.orderBy = orderBy;
        return this; 
    }

    public SoqlQuery resetOrderBy() {
        this.orderBy = null; 
        return this; 
    }

    public SoqlQuery setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit; 
        return this;
    }

    public SoqlQuery resetLimit() {
        return this.setLimit(null); 
    }

    public SoqlQuery addTags(List<String> queryTags) {
        this.queryTags.addAll(queryTags);
        return this; 
    }

    public SoqlQuery addTags(String queryTag) {
        return this.addTags(new List<String>{queryTag});
    }

    public SoqlQuery resetTags() {
        this.queryTags.clear();
        return this; 
    }
    
    public SoqlQuery reset() {
        this.resetFields();
        this.resetFilters();
        this.resetFilterLogic(); 
        this.resetOrderBy(); 
        this.resetLimit();
        this.resetTags(); 
        return this; 
    }

    public SoqlQuery setQueryKey(String queryKey) {
        // Adds a queryKey, which tests can use to supply individual queries with mock data
        this.queryKey = queryKey; 
        return this; 
    }

    // **** PRIVATE **** // 
    protected virtual String getTargetObject() {
        return String.valueOf(this.targetObject);
    }

    private String getWhereClause() {
        return (this.filterLogic?.getFilters()?.isEmpty() == false)
            ? ' WHERE ' + this.filterLogic?.toString() 
            : '';
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