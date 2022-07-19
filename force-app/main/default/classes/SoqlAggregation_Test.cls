@IsTest 
private class SoqlAggregation_Test {
    @IsTest 
    static void shouldOutputAggregateFunctionWithAlias() {
        SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.COUNT, Account.Id, 'numAccs');
        System.assertEquals('COUNT(Id) numAccs', aggregation.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldOutputAggregateFunctionWithoutAlias() {
        SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.COUNT, 'Owner.Name');
        System.assertEquals('COUNT(Owner.Name)', aggregation.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldOutputAggregationWithParentField() {
        FieldReference fieldRef = new FieldReference(new List<SObjectField>{
            Case.ContactId,
            Contact.AccountId,
            Account.AnnualRevenue
        });
        SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.SUM, fieldRef);
        System.assertEquals('SUM(Contact.Account.AnnualRevenue)', aggregation.toString(), 'Unexpected output');
    }

    @IsTest 
    static void shouldGenerateAggregateFilter() {
        SoqlAggregation aggregation = new SoqlAggregation(SoqlAggregation.Function.COUNT, Lead.Name); 
        Filter testFilter = new SoqlAggregation.AggregateFilter(aggregation, Filter.GREATER_THAN, 100);
        System.assertEquals('COUNT(Name) > 100', testFilter.toString(), 'Unexpected output'); 
    }
}
