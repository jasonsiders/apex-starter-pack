public class SoqlSort {
    List<String> fieldNames = new List<String>();
    Order order;
    NullOrder nullOrder; 

    static final Map<Order, String> ORDER_BY_KEYS = new Map<Order, String>{
        Order.ASCENDING => 'ASC',
        Order.DESCENDING => 'DESC'
    };

    public SoqlSort(List<FieldRef> fieldReferences, Order order, NullOrder nullOrder) {
        for (FieldRef fieldReference : fieldReferences) {
            this.fieldNames.add(fieldReference?.toString());
        }
        this.order = order; 
        this.nullOrder = nullOrder;
    }

    public SoqlSort(List<FieldRef> fieldReferences, Order order) {
        this(fieldReferences, order, null); 
    }

    public SoqlSort(FieldRef fieldReference, Order order, NullOrder nullOrder) {
        this(new List<FieldRef>{fieldReference}, order, nullOrder);
    }

    public SoqlSort(FieldRef fieldReference, Order order) {
        this(fieldReference, order, null); 
    }

    public SoqlSort(List<SObjectField> fields, Order order, NullOrder nullOrder) {
        for (SObjectField field : fields) {
            this.fieldNames.add(String.valueOf(field)); 
        }
        this.order = order;
        this.nullOrder = nullOrder;
    }

    public SoqlSort(List<SObjectField> fields, Order order) {
        this(fields, order, null); 
    }

    public SoqlSort(SObjectField field, Order order, NullOrder nullOrder) {
        this(new List<SObjectField>{field}, order, nullOrder); 
    }

    public SoqlSort(SObjectField field, Order order) {
        this(field, order, null); 
    }

    public SoqlSort(List<String> fieldNames, Order order, NullOrder nullOrder) {
        this.fieldNames = fieldNames;
        this.order = order; 
        this.nullOrder = nullOrder;
    }

    public SoqlSort(List<String> fieldNames, Order order) {
        this(fieldNames, order, null); 
    }

    public SoqlSort(String fieldName, Order order, NullOrder nullOrder) {
        this(new List<String>{fieldName}, order, nullOrder); 
    }

    public SoqlSort(String fieldName, Order order) {
        this(fieldName, order, null); 
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