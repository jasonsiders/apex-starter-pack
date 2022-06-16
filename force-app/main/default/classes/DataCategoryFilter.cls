public class DataCategoryFilter extends Filter {
    public static final Type ABOVE = AboveOperator.class;
    public static final Type AT = AtOperator.class;
    public static final Type BELOW = BelowOperator.class; 
    public static final Type ABOVE_OR_BELOW = AboveOrBelowOperator.class;

    public DataCategoryFilter(String category, Type operatorType, List<String> compareCategories) {
        super(category, operatorType, compareCategories); 
    }

    public DataCategoryFilter(String category, Type operatorType, String compareCategory) {
        super(category, operatorType, compareCategory); 
    }

    // **** INNER **** // 
    public interface Logic {
        // Marker interface indicates the FilterLogic belongs to this type
    }

    public class AndLogic extends FilterLogic.AndLogic implements Logic {
        public AndLogic(List<DataCategoryFilter> filters) {
            super(filters); 
        }
    }

    public class OrLogic extends FilterLogic.OrLogic implements Logic {
        public OrLogic(List<DataCategoryFilter> filters) {
            super(filters);
        }
    }
    
    public abstract class Operator extends Filter.Operator {
        public override String processStringValue(String value) {
            return value;
        }

        public override Boolean meetsCriteria(Object value, Object comparison) {
            // Note: All Operator types' meetsCriteria() method returns FALSE
            // We don't have a way of checking the hierarchy in apex, without SOQL (which gets a bit meta)
            // Since this class is primarily designed for use in SOQL itself, this is not really necessary
            return false;
        }
    }
    
    public class AboveOperator extends Operator {
        public override String getToken() {
            return 'ABOVE';
        }
    }

    public class AtOperator extends Operator {
        public override String getToken() {
            return 'AT';
        }
    }

    public class BelowOperator extends Operator {
        public override String getToken() {
            return 'BELOW';
        }
    }

    public class AboveOrBelowOperator extends Operator {
        public override String getToken() {
            return 'ABOVE_OR_BELOW';
        }
    }
}
