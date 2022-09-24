public virtual class AndLogic extends FilterLogic {
    public AndLogic() {
        this.token = 'AND';
    }

    public override Boolean meetsCriteria(Object item) {
        for (ICriteria criteria : this.criterion) {
            if (criteria.meetsCriteria(item) == false) {
                return false;
            }
        }
        return true;
    }
}