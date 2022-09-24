public abstract class Runtime {
    // This class can be used by other objects to handle elasticity
    // Callers can use the Context enum in conjunction with the getRuntimeContext() method
    // to determine what context operations should run in
    protected Context explicitContext; 
    protected Integer asyncThreshold;
    protected Integer batchThreshold;
    
    public virtual Context getRuntimeContext(Integer numRecords) {
        return this.explicitContext != null 
            ? this.explicitContext 
            : this.calculateContext(numRecords); 
    }

    public virtual Runtime setExplicitContext(Context context) {
        this.explicitContext = context;
        return this;
    }

    public virtual Runtime setAsyncThreshold(Integer threshold) {
        this.asyncThreshold = threshold; 
        return this; 
    }

    public virtual Runtime setBatchThreshold(Integer threshold) {
        this.batchThreshold = threshold; 
        return this; 
    }

    protected virtual Context calculateContext(Integer numRecords) {
        if (this.asyncThreshold > numRecords) {
            return Context.REAL_TIME;
        } else if (this.batchThreshold > numRecords && LimitUtils.isQueueableSafe()) {
            return Context.QUEUEABLE;
        } else {
            return Context.BATCHAPEX;
        }
    }

    // **** INNER **** // 
    public enum Context {
        BATCHAPEX,
        QUEUEABLE,
        REAL_TIME
    }
}
