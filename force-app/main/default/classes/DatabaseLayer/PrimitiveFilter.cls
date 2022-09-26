public class PrimitiveFilter extends Filter {
    // Used to compare Primitive types (Integer, String, etc)
    // Since they do not have a property, will always compare the item itself
    public PrimitiveFilter(Type operatorType, Object value) {
        super('', operatorType, value);
    }

    public override Boolean meetsCriteria(Object item) {
        return this.operator?.meetsCriteria(item, this.value);
    } 
}