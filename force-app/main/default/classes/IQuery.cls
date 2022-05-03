global interface IQuery {
    IQuery addFields(List<SObjectField> fields);
    IQuery addFields(SObjectField field);
    IQuery addFields(List<String> fields); 
    IQuery addFields(String field);
    IQuery addAllFields();
    IQuery resetFields();

    IQuery setTargetSObject(SObjectType targetObject);

    IQuery addFilters(List<QueryFilter> filters);
    IQuery addFilters(QueryFilter filter);
    IQuery resetFilters();

    IQuery setFilterLogic(String logicString);
    IQuery resetFilterLogic(); 

    IQuery setOrderBy(QuerySort sortOrder);
    IQuery resetOrderBy();

    IQuery setLimit(Integer numResults); 
    IQuery resetLimit();

    IQuery addTags(List<String> queryTags);
    IQuery addTags(String queryTag);
    IQuery resetTags(); 
    
    IQuery reset();

    String getQueryString();
    List<SObject> run();
}