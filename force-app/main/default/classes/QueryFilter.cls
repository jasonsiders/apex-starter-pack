global class QueryFilter {
    global enum Operator {
        EQUALS,
        NOT_EQUALS,
        IN_COLLECTION,
        NOT_IN_COLLECTION,
        GREATER_THAN,
        GREATER_OR_EQUAL,
        LESS_THAN,
        LESS_OR_EQUAL,
        STARTS_WITH,
        ENDS_WITH,
        CONTAINS,
        NOT_STARTS_WITH,
        NOT_ENDS_WITH,
        NOT_CONTAINS
    }

    static final Map<Operator, String> OPERATOR_TOKENS = new Map<Operator, String>{
        Operator.EQUALS => '=',
        Operator.NOT_EQUALS => '!=',
        Operator.IN_COLLECTION => 'IN', 
        Operator.NOT_IN_COLLECTION => 'NOT IN',
        Operator.GREATER_THAN => '>',
        Operator.GREATER_OR_EQUAL => '>=',
        Operator.LESS_THAN => '<',
        Operator.LESS_OR_EQUAL => '<=',
        Operator.STARTS_WITH => 'LIKE',
        Operator.ENDS_WITH => 'LIKE',
        Operator.CONTAINS => 'LIKE',
        Operator.NOT_STARTS_WITH => 'NOT LIKE',
        Operator.NOT_ENDS_WITH => 'NOT LIKE',
        Operator.NOT_CONTAINS => 'NOT LIKE'
    };

    final String fieldName; 
    final Operator operator; 
    final Object value; 

    global QueryFilter(String fieldName, Operator operator, Object value) {
        this.fieldName = fieldName;
        this.operator = operator; 
        this.value = value; 
    }

    global QueryFilter(SObjectField field, Operator operator, Object value) {
        this(String.valueOf(field), operator, value); 
    }

    global override String toString() {
        return this.fieldName + ' ' + OPERATOR_TOKENS.get(this.operator) + ' ' + this.formatValue();
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

    private String processString(String stringValue) {
        // First, check if the string is actually checking a relative date value
        if (stringValue.startsWithIgnoreCase('LAST_N_DAYS:')) {
            return stringValue; 
        }
        // Else, process the string as a string
        switch on this.operator {
            when STARTS_WITH, NOT_STARTS_WITH {
                return '\'' + stringValue + '%\'';
            } when ENDS_WITH, NOT_ENDS_WITH {
                return '\'%' + stringValue + '\'';
            } when CONTAINS, NOT_CONTAINS {
                return '\'%' + stringValue + '%\'';
            } when else {
                return '\'' + stringValue + '\'';
            }
        }
    }

    private String processDate(Date dateValue) {
        final String soqlFormat = 'yyyy-MM-dd';
        DateTime dateTimeValue = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
        return dateTimeValue.formatGmt(soqlFormat);
    }

    private String processDateTime(DateTime dateTimeValue) {
        final String soqlFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        return dateTimeValue.formatGmt(soqlFormat); 
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
}