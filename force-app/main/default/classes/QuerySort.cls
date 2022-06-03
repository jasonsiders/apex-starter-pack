public class QuerySort {
    List<String> fieldNames = new List<String>();
    Order order;

    static final Map<Order, String> abbreviatedOrders = new Map<Order, String>{
        Order.ASCENDING => 'ASC',
        Order.DESCENDING => 'DESC'
    };

    public QuerySort(List<String> fieldNames, Order order) {
        this.fieldNames = fieldNames;
        this.order = order; 
    }

    public QuerySort(String fieldName, Order order) {
        this(new List<String>{fieldName}, order); 
    }

    public QuerySort(List<SObjectField> fields, Order order) {
        for (SObjectField field : fields) {
            this.fieldNames.add(String.valueOf(field)); 
        }
        this.order = order;
    }

    public QuerySort(SObjectField field, Order order) {
        this(new List<SObjectField>{field}, order); 
    }

    public override String toString() {
        return String.join(fieldNames, ', ') + ' ' + abbreviatedOrders.get(this.order);
    }
    
    public enum Order {
        ASCENDING,
        DESCENDING
    }
}