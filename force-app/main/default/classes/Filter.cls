global class Filter {
    // Note: Normally, I'd use an enum instead, but each item here has special logic behind it
    public static final Type EQUALS = EqualsOperator.class; 
    public static final Type NOT_EQUALS = NotEqualsOperator.class; 
    public static final Type IN_COLLECTION = InCollectionOperator.class; 
    public static final Type NOT_IN_COLLECTION = NotInCollectionOperator.class; 
    public static final Type GREATER_THAN = GreaterThanOperator.class; 
    public static final Type GREATER_OR_EQUAL = GreaterOrEqualOperator.class; 
    public static final Type LESS_THAN = LessThanOperator.class; 
    public static final Type LESS_OR_EQUAL = LessOrEqualOperator.class; 
    public static final Type STARTS_WITH = StartsWithOperator.class; 
    public static final Type NOT_STARTS_WITH = NotStartsWithOperator.class; 
    public static final Type ENDS_WITH = EndsWithOperator.class; 
    public static final Type NOT_ENDS_WITH = NotEndsWithOperator.class; 
    public static final Type CONTAINS = ContainsOperator.class; 
    public static final Type NOT_CONTAINS = NotContainsOperator.class;

    static final Map<String, Type> OPERATOR_ABBREVIATIONS = new Map<String, Type>{
        // This is terribly verbose, but necessary until apex supports reflection
        'EQUALS' => Filter.EQUALS,
        'NOT_EQUALS' => Filter.NOT_EQUALS,
        'IN_COLLECTION' => Filter.IN_COLLECTION,
        'NOT_IN_COLLECTION' => Filter.NOT_IN_COLLECTION,
        'GREATER_THAN' => Filter.GREATER_THAN,
        'GREATER_OR_EQUAL' => Filter.GREATER_OR_EQUAL,
        'LESS_THAN' => Filter.LESS_THAN,
        'LESS_OR_EQUAL' => Filter.LESS_OR_EQUAL,
        'STARTS_WITH' => Filter.STARTS_WITH,
        'NOT_STARTS_WITH' => Filter.NOT_STARTS_WITH,
        'ENDS_WITH' => Filter.ENDS_WITH,
        'NOT_ENDS_WITH' => Filter.NOT_ENDS_WITH,
        'CONTAINS' => Filter.CONTAINS,
        'NOT_CONTAINS' => Filter.NOT_CONTAINS
    };

    public final String fieldName { get; private set; }
    public final List<String> relationships { get; private set; }
    public final Operator operator { get; private set; }
    public final Object value { get; private set; }

    global Filter(String fieldReference, Type operatorType, Object value) {
        List<String> fieldParts = fieldReference?.split('\\.');
        if (fieldParts != null) {
            Integer fieldNameIndex = fieldParts?.size() - 1;
            this.fieldName = fieldParts[fieldNameIndex];
            fieldParts.remove(fieldNameIndex); 
            this.relationships = fieldParts;
        }
        this.operator = (Operator) operatorType?.newInstance();
        this.value = value; 
        this.validate(); 
    }

    global Filter(SObjectField field, Type operatorType, Object value) {
        this(String.valueOf(field), operatorType, value); 
    }

    global Filter(Filter__mdt filterRecord) {
        this(
            Filter.getFieldReferenceFromMdt(filterRecord),
            Filter.getOperationByItsAbbreviation(filterRecord?.Operator__c),
            TypeUtils.parseStringValue(filterRecord?.Value__c)
        );
    }

    global override String toString() {
        return this.getFieldName() + ' ' + this.operator?.getToken() + ' ' + this.formatValue();
    }

    public String getFieldName() {
        List<String> fieldParts = this.relationships?.clone();
        fieldParts?.add(this.fieldName); 
        return String.join(fieldParts, '.');
    }

    public Boolean meetsCriteria(SObject record) {
        // Returns TRUE if the given record meets the Filter's criteria
        SObject target = record;
        for (String relationship : this.relationships) {
            target = target.getSObject(relationship);
        }
        Object recordValue = target.get(this.fieldName); 
        return this.operator.meetsCriteria(recordValue, this.value); 
    }

    private String formatValue() {
        // Note: System.Type is not a valid switch expression type :(
        switch on TypeUtils.getType(this.value)?.getName().toUpperCase() {
            when null {
                return 'null';
            } when 'DATE' {
                return this.processDate((Date) this.value); 
            } when 'LIST<DATE>' {
                return this.processDateList((List<Date>) this.value);
            } when 'SET<DATE>' {
                return this.processDateList(new List<Date>((Set<Date>) this.value));
            } when 'DATETIME' {
                return this.processDateTime((DateTime) this.value); 
            } when 'LIST<DATETIME>' {
                return this.processDateTimeList((List<DateTime>) this.value);
            } when 'SET<DATETIME>' {
                return this.processDateTimeList(new List<DateTime>((Set<DateTime>) this.value));
            } when 'ID', 'STRING' {
                return this.processString((String) this.value);
            } when 'LIST<ID>', 'LIST<STRING>' {
                return this.processStringList((List<String>) this.value);
            } when 'SET<ID>' {
                // Note: For some reason, can't convert Set<Id> => Set<String> directly, 
                // but we can convert Set<Id> => List<Id> => List<String>
                return this.processStringList((List<String>) new List<Id>((Set<Id>) this.value));
            } when 'SET<STRING>' {
                return this.processStringList(new List<String>((Set<String>) this.value));
            } when else {
                // Can't convert from Set<ANY> to List<Object>, so this is the best we can do
                return (TypeUtils.isSet(this.value))
                    ? String.valueOf(this.value)?.replace('{', '(')?.replace('}', ')')
                    : String.valueOf(this.value); 
            }
        }
    }

    private String processString(String value) {
        // First, check if the string is actually checking a relative date value
        // Else, process the string as a string, according to its operator
        return value.startsWithIgnoreCase('LAST_N_DAYS:') ? value : this.operator?.processStringValue(value);
    }

    private String processDate(Date value) {
        final String soqlFormat = 'yyyy-MM-dd';
        DateTime dateTimeValue = DateTime.newInstance(value.year(), value.month(), value.day());
        return dateTimeValue.formatGmt(soqlFormat);
    }

    private String processDateTime(DateTime value) {
        final String soqlFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        return value.formatGmt(soqlFormat); 
    }

    private String processStringList(List<String> items) {
        List<String> results = new List<String>();
        for (String item : items) {
            String result = '\'' + item + '\'';
            results.add(result);
        }
        return '(' + String.join(results, ', ') + ')';
    }

    private String processDateList(List<Date> items) {
        List<String> results = new List<String>(); 
        for (Date item : items) {
            results.add(this.processDate(item));
        }
        return '(' + String.join(results, ', ') + ')';
    }

    private String processDateTimeList(List<DateTime> items) {
        List<String> results = new List<String>(); 
        for (DateTime item : items) {
            results.add(this.processDateTime(item));
        }
        return '(' + String.join(results, ', ') + ')';
    }

    private void validate() {
        if (this.fieldName == null || this.operator == null) {
            Exception error = new FilterException('Missing required fields: ' + JSON.serialize(this));
            Logger.logException(error);
            throw error;
        }
    }

    // **** STATIC **** //
    public static String getFieldReferenceFromMdt(Filter__mdt filterRecord) {
        return (filterRecord?.SObjectField__c != null) 
            ? String.valueOf(Describes.getSObjectFieldByName(filterRecord?.SObjectField__c))
            : filterRecord?.Field_Name__c;
    }

    private static Type getOperationByItsAbbreviation(String abbreviation) {
        return Filter.OPERATOR_ABBREVIATIONS?.get(abbreviation);
    }

    // **** INNER **** // 
    // Note: In the future, may consider breaking out into its own file
    // But I like being able to refer to the enumerated types almost like an enum (see top of file)
    @TestVisible 
    private abstract class Operator {
        @TestVisible
        private abstract String getToken();

        private abstract Boolean meetsCriteria(Object value, Object comparison); 

        protected virtual String processStringValue(String value) {
            return '\'' + value + '\'';
        }
    }

    private class EqualsOperator extends Operator {
        private override String getToken() {
            return '=';
        }
    
        private override Boolean meetsCriteria(Object value, Object comparison) {
            return value == comparison; 
        }
    }

    private class NotEqualsOperator extends Operator {
        private override String getToken() {
            return '!=';
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new EqualsOperator(); 
            return inverse?.meetsCriteria(value, comparison) == false; 
        }
    }

    private class InCollectionOperator extends Operator {
        private override String getToken() {
            return 'IN';
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            List<Object> valueList;
            if (TypeUtils.isList(comparison)) {
                valueList = (List<Object>) comparison;
            } else if (TypeUtils.isCollection(comparison)) {
                // Note: We cannot convert a Map/Set of a given type to a Map/Set<Object>, ex.:
                // ! Invalid conversion from runtime type Map<Id,Opportunity> to Map<ANY,ANY>  
                // Unfortunately, Apex's type system seems to be "broken": https://salesforce.stackexchange.com/questions/106068/apex-string-instanceof-object
                // ...but it still works for lists! If a non-list collection is provided, throw an error
                Exception error = new FilterException('IN_COLLECTION operations must use a List type');
                Logger.logException(error); 
                throw error; 
            }
            return (valueList != null) ? valueList.contains(value) : false;
        }
    }

    private class NotInCollectionOperator extends Operator {
        private override String getToken() {
            return 'NOT IN'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new InCollectionOperator(); 
            return (value != null && comparison != null) 
                ? inverse?.meetsCriteria(value, comparison) == false
                : false;
        }
    }

    private class GreaterThanOperator extends Operator {
        private override String getToken() {
            return '>'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            return TypeUtils.greaterThan(value, comparison); 
        }
    }

    private class GreaterOrEqualOperator extends Operator {
        private override String getToken() {
            return '>='; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new LessThanOperator(); 
            return TypeUtils.greaterThan(value, comparison) || value == comparison;
        }
    }

    private class LessThanOperator extends Operator {
        private override String getToken() {
            return '<'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            return TypeUtils.lessThan(value, comparison); 
        }
    }

    private class LessOrEqualOperator extends Operator {
        private override String getToken() {
            return '<='; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new GreaterThanOperator(); 
            return TypeUtils.lessThan(value, comparison) || value == comparison;
        }
    }

    private class StartsWithOperator extends Operator {
        private override String getToken() {
            return 'LIKE'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            // All types (including numbers) must be cast to string for this operation
            String valueString = String.valueOf(value); 
            String comparisonString = String.valueOf(comparison); 
            return value != null && comparison != null && valueString?.startsWithIgnoreCase(comparisonString); 
        }

        protected override String processStringValue(String value) {
            return '\'' + value + '%\''; 
        }
    }

    private class NotStartsWithOperator extends Operator {
        private override String getToken() {
            return 'NOT LIKE'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new StartsWithOperator(); 
            return (value != null && comparison != null) 
                ? inverse?.meetsCriteria(value, comparison) == false
                : false;
        }

        protected override String processStringValue(String value) {
            return '\'' + value + '%\''; 
        }
    }

    private class EndsWithOperator extends Operator {
        private override String getToken() {
            return 'LIKE'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            // All types (including numbers) must be cast to string for this operation
            String valueString = String.valueOf(value); 
            String comparisonString = String.valueOf(comparison); 
            return value != null && comparison != null && valueString?.endsWithIgnoreCase(comparisonString);
        }

        protected override String processStringValue(String value) {
            return '\'%' + value + '\'';
        }
    }

    private class NotEndsWithOperator extends Operator {
        private override String getToken() {
            return 'NOT LIKE'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new EndsWithOperator(); 
            return (value != null && comparison != null) 
                ? inverse?.meetsCriteria(value, comparison) == false
                : false; 
        }

        protected override String processStringValue(String value) {
            return '\'%' + value + '\'';
        }
    }

    private class ContainsOperator extends Operator {
        private override String getToken() {
            return 'LIKE'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            // All types (including numbers) must be cast to string for this operation
            String valueString = String.valueOf(value); 
            String comparisonString = String.valueOf(comparison); 
            return value != null && comparison != null && valueString?.containsIgnoreCase(comparisonString); 
        }

        protected override String processStringValue(String value) {
            return '\'%' + value + '%\'';
        }
    }

    private class NotContainsOperator extends Operator {
        private override String getToken() {
            return 'NOT LIKE'; 
        }

        private override Boolean meetsCriteria(Object value, Object comparison) {
            Operator inverse = new ContainsOperator(); 
            return (value != null && comparison != null) 
                ? inverse?.meetsCriteria(value, comparison) == false
                : false;
        }

        protected override String processStringValue(String value) {
            return '\'%' + value + '%\'';
        }
    }

    public class FilterException extends Exception {}
}