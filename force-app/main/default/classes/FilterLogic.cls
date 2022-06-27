public abstract class FilterLogic {
    protected List<Filter> filters = new List<Filter>(); 

    public abstract Boolean meetsCriteria(Object item);
    public abstract override String toString();

    public virtual List<Filter> getFilters() {
        return this.filters; 
    } 

    public virtual FilterLogic addFilters(List<Filter> filters) {
        this.filters.addAll(filters); 
        return this; 
    }

    public virtual FilterLogic addFilters(Filter filter) {
        return this.addFilters(new List<Filter>{filter});
    }
    
    public virtual FilterLogic setFilters(List<Filter> filters) {
        this.filters = filters;
        return this; 
    }   

    public virtual FilterLogic setFilters(Filter filter) {
        return this.setFilters(new List<Filter>{filter});
    }

    // **** IMPLEMENTATIONS **** // 
    public virtual class AndLogic extends FilterLogic {
        public AndLogic(List<Filter> filters) {
            this.filters = filters; 
        }

        public AndLogic() {
            // Default constructor available to allow callers to use the setFilters() methods instead
        }

        public override Boolean meetsCriteria(Object item) {
            for (Filter filter : this.filters) {
                if (filter.meetsCriteria(item) == false) {
                    return false;
                }
            }
            return true; 
        }

        public override String toString() {
            // Should return a list of filter.toString() delimited by "AND"
            // ex., Field1__c = 'value' AND Field2__c > 1234
            return ObjectUtils.joinValues(this.filters, ' AND ');
        }
    }

    public virtual class OrLogic extends FilterLogic {
        public OrLogic(List<Filter> filters) {
            this.filters = filters; 
        }

        public OrLogic() {
            // Default constructor available to allow callers to use the setFilters() methods instead
        }
        
        public override Boolean meetsCriteria(Object item) {
            for (Filter filter : this.filters) {
                if (filter.meetsCriteria(item) == true) {
                    return true; 
                }
            }
            return false;
        }

        public override String toString() {
            // Should return a list of filter.toString() delimited by "OR"
            // ex., Field1__c = 'value' OR Field2__c > 1234
            return ObjectUtils.joinValues(this.filters, ' OR ');
        }
    }
}
