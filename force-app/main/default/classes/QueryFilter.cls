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
        return this.fieldName + ' ' + this.getOperatorToken() + ' ' + this.formatValue();
    }

    private String getOperatorToken() {
        Operator operator = this.operator; 
        Boolean isCollectionType = 
            // TODO: Hide this out in a TypeCollection utility
            this.value instanceOf List<Object> || 
            this.value instanceOf Set<Boolean> ||
            this.value instanceOf Set<Date> ||
            this.value instanceOf Set<DateTime> ||
            this.value instanceOf Set<Decimal> ||
            this.value instanceOf Set<Double> ||
            this.value instanceOf Set<Integer> || 
            this.value instanceOf Set<Long> ||
            this.value instanceOf Set<SObject> ||
            this.value instanceOf Set<String> ||
            this.value instanceOf Set<Time>; 
        if (isCollectionType && operator == QueryFilter.Operator.EQUALS) {
            operator = QueryFilter.Operator.IN_COLLECTION; 
        } else if (isCollectionType && operator == QueryFilter.Operator.NOT_EQUALS) {
            operator = QueryFilter.Operator.NOT_IN_COLLECTION; 
        }
        return OPERATOR_TOKENS.get(operator); 
    }

    private String formatValue() {
        // Note: This is suuuuper ugly. Should probably hide this in a TypeCollection utility method
        // Check for single types
        if (this.value == null) {
            return 'null';
        } else if (this.value instanceOf Date) {
            return this.processDateValue((Date) this.value);
        } else if (this.value instanceOf DateTime) {
            return this.processDateTimeValue((DateTime) this.value);
        } else if (this.value instanceOf String) {
            return this.processStringValue((String) this.value); 
        } 
        // Check for List types
        else if (this.value instanceOf List<Date>) {
            return this.processDateCollectionValue((List<Date>) this.value);
        } else if (this.value instanceOf List<DateTime>) {
            return this.processDateTimeCollectionValue((List<DateTime>) this.value); 
        } else if (this.value instanceOf List<SObject>) {
            return this.processSObjectCollectionValues((List<SObject>) this.value);
        } else if (this.value instanceOf List<String>) {
            return this.processStringCollectionValue((List<String>) this.value); 
        } 
        // Check for Set types
        else if (this.value instanceOf Set<Boolean>) {
            List<Boolean> booleans = new List<Boolean>((Set<Boolean>) this.value);
            return String.valueOf(booleans); 
        } else if (this.value instanceOf Set<Date>) {
            Set<Date> dates = (Set<Date>) this.value;
            return this.processDateCollectionValue(new List<Date>(dates)); 
        } else if (this.value instanceOf Set<DateTime>) {
           Set<DateTime> dateTimes = (Set<DateTime>) this.value; 
           return this.processDateTimeCollectionValue(new List<DateTime>(dateTimes));
        } else if (this.value instanceOf Set<Decimal>) {
            List<Decimal> decimals = new List<Decimal>((Set<Decimal>) this.value);
            return String.valueOf(decimals);
        } else if (this.value instanceOf Set<Double>) {
            List<Double> doubles = new List<Double>((Set<Double>) this.value);
            return String.valueOf(doubles);
        } else if (this.value instanceOf Set<Id>) {
            return this.processStringCollectionValue(new List<Id>((Set<Id>) this.value));
        } else if (this.value instanceOf Set<Integer>) {
            List<Integer> integers = new List<Integer>((Set<Integer>) this.value);
            return String.valueOf(integers);
        } else if (this.value instanceOf Set<SObject>) {
            return this.processSObjectCollectionValues(new List<SObject>((Set<SObject>) this.value));
        } else if (this.value instanceOf Set<String>) {
            Set<String> strings = (Set<String>) this.value; 
            return this.processStringCollectionValue(new List<String>(strings)); 
        } else if (this.value instanceOf Set<Time>) {
            List<Time> times = new List<Time>((Set<Time>) this.value);
            return String.valueOf(times);
        } else {
            return String.valueOf(this.value); 
        }
    }

    private String processStringValue(String stringValue) {
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

    private String processDateValue(Date dateValue) {
        final String soqlFormat = 'yyyy-MM-dd';
        DateTime dateTimeValue = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
        return dateTimeValue.formatGmt(soqlFormat);
    }

    private String processDateTimeValue(DateTime dateTimeValue) {
        final String soqlFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        return dateTimeValue.formatGmt(soqlFormat); 
    }

    private String processStringCollectionValue(List<String> items) {
        List<String> results = new List<String>();
        for (String item : items) {
            String result = '\'' + item + '\'';
            results.add(result);
        }
        return '(' + String.join(results, ', ') + ')';
    }

    private String processDateCollectionValue(List<Date> items) {
        List<String> results = new List<String>(); 
        for (Date item : items) {
            results.add(this.processDateValue(item));
        }
        return '(' + String.join(results, ', ') + ')';
    }

    private String processDateTimeCollectionValue(List<DateTime> items) {
        List<String> results = new List<String>(); 
        for (DateTime item : items) {
            results.add(this.processDateTimeValue(item));
        }
        return '(' + String.join(results, ', ') + ')';
    }

    private String processSObjectCollectionValues(List<SObject> records) {
        Set<Id> recordIds = new Map<Id, SObject>(records).keySet(); 
        return this.processStringCollectionValue(new List<Id>(recordIds)); 
    }
}