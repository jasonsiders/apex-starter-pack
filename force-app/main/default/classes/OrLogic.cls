public virtual class OrLogic extends FilterLogic {
    public OrLogic() {
        this.token = 'OR';
    }

    public override Boolean meetsCriteria(Object item) {
        for (ICriteria criteria : this.criterion) {
            if (criteria.meetsCriteria(item) == true) {
                return true;
            }
        }
        return false;
    }
}