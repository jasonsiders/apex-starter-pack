global class QueryFilter {
    global enum Operator {
        EQUALS,
        NOT_EQUALS,
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

    private Object formatValue() {
        if (this.value instanceof String) {
            return this.processStringValue(); 
        } else if (this.value instanceof Date) {
            return this.processDateValue();
        } else if (this.value instanceof DateTime) {
            return this.processDateTimeValue();
        } else {
            return this.value; 
        }
    }

    private String processStringValue() {
        String valueString = String.valueOf(this.value); 
        // First, check if the string is actually checking a relative date value
        if (valueString.startsWithIgnoreCase('LAST_N_DAYS:')) {
            return valueString; 
        }
        // Else, process the string as a string
        switch on this.operator {
            when STARTS_WITH, NOT_STARTS_WITH {
                return '\'' + valueString + '%\'';
            } when ENDS_WITH, NOT_ENDS_WITH {
                return '\'%' + valueString + '\'';
            } when CONTAINS, NOT_CONTAINS {
                return '\'%' + valueString + '%\'';
            } when else {
                return '\'' + valueString + '\'';
            }
        }
    }

    private String processDateValue() {
        final String soqlFormat = 'yyyy-MM-dd';
        Date dateValue = Date.valueOf(this.value); 
        DateTime dateTimeValue = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
        return dateTimeValue.formatGmt(soqlFormat);
    }

    private String processDateTimeValue() {
        final String soqlFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        DateTime dateTimeValue = DateTime.valueOf(this.value); 
        return dateTimeValue.formatGmt(soqlFormat); 
    }
}