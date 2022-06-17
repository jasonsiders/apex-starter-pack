public class SoqlSort {
    List<String> fieldNames = new List<String>();
    Order order;
    NullOrder nullOrder; 

    static final Map<Order, String> ORDER_BY_KEYS = new Map<Order, String>{
        Order.ASCENDING => 'ASC',
        Order.DESCENDING => 'DESC'
    };

    public SoqlSort(List<String> fieldNames, Order order, nullOrder nullOrder) {
        this.fieldNames = fieldNames;
        this.order = order; 
        this.nullOrder = nullOrder;
    }

    public SoqlSort(List<String> fieldNames, Order order) {
        this(fieldNames, order, null); 
    }

    public SoqlSort(String fieldName, Order order, nullOrder nullOrder) {
        this(new List<String>{fieldName}, order, nullOrder); 
    }

    public SoqlSort(String fieldName, Order order) {
        this(fieldName, order, null); 
    }

    public SoqlSort(List<SObjectField> fields, Order order, nullOrder nullOrder) {
        for (SObjectField field : fields) {
            this.fieldNames.add(String.valueOf(field)); 
        }
        this.order = order;
        this.nullOrder = nullOrder;
    }

    public SoqlSort(List<SObjectField> fields, Order order) {
        this(fields, order, null); 
    }

    public SoqlSort(SObjectField field, Order order, nullOrder nullOrder) {
        this(new List<SObjectField>{field}, order, nullOrder); 
    }

    public SoqlSort(SObjectField field, Order order) {
        this(field, order, null); 
    }

    public override String toString() {
        String nullOrder = (this.nullOrder != null) ? 'NULLS ' + String.valueOf(this.nullOrder) : ''; 
        return (String.join(fieldNames, ', ') + ' ' + ORDER_BY_KEYS.get(this.order) + ' ' + nullOrder).trim();
    }
    
    // **** INNER **** // 
    public enum Order {
        ASCENDING,
        DESCENDING
    }

    public enum NullOrder {
        FIRST,
        LAST
    }
}