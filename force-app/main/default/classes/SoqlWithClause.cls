public abstract class SoqlWithClause {
    public abstract String output();

    public override String toString() {
        return String.format('WITH {0}', new List<String>{this.output()});
    }

    // **** INNER **** // 
    public enum Context {
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm
        USER_MODE,
        SYSTEM_MODE,
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_with_security_enforced.htm
        SECURITY_ENFORCED
    }

    public class ContextExpression extends SoqlWithClause {
        Context context; 
        
        public ContextExpression(Context context) {
            this.context = context;
        }
    
        public override String output() {
            return String.valueOf(this.context); 
        }
    }

    public class DataCategoryExpression extends SoqlWithClause {
        DataCategoryFilter.Logic logic; 
    
        public DataCategoryExpression(DataCategoryFilter.Logic logic) {
            this.logic = logic; 
        }
    
        public override String output() {
            return logic?.toString(); 
        }
    }
}
