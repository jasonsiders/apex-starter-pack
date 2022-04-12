global class QuerySort {
    List<String> fieldNames = new List<String>();
    Order order;

    static final Map<Order, String> abbreviatedOrders = new Map<Order, String>{
        Order.ASCENDING => 'ASC',
        Order.DESCENDING => 'DESC'
    };

    global QuerySort(List<String> fieldNames, Order order) {
        this.fieldNames = fieldNames;
        this.order = order; 
    }

    global QuerySort(String fieldName, Order order) {
        this(new List<String>{fieldName}, order); 
    }

    global QuerySort(List<SObjectField> fields, Order order) {
        for (SObjectField field : fields) {
            this.fieldNames.add(String.valueOf(field)); 
        }
        this.order = order;
    }

    global QuerySort(SObjectField field, Order order) {
        this(new List<SObjectField>{field}, order); 
    }

    global override String toString() {
        return String.join(fieldNames, ', ') + ' ' + abbreviatedOrders.get(this.order);
    }
    
    global enum Order {
        ASCENDING,
        DESCENDING
    }
}