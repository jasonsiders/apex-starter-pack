public abstract class TriggerHandler {  
    public List<SObject> triggerNew { get; protected set; } 
    public List<SObject> triggerOld { get; protected set; }
    public Map<Id, SObject> triggerNewMap { get; protected set; } 
    public Map<Id, SObject> triggerOldMap { get; protected set; }
    @TestVisible System.TriggerOperation operation = Trigger.operationType; 
    static Boolean isEnabled = true; 

    public TriggerHandler() {
        this.setTriggerCollections(); 
    }
    
    public virtual void run() {
        if (isEnabled) {
            switch on this.operation {
                when BEFORE_INSERT  { 
                    this.beforeInsert();  
                } when BEFORE_UPDATE  { 
                    this.beforeUpdate();  
                } when BEFORE_DELETE  { 
                    this.beforeDelete();  
                } when AFTER_INSERT   { 
                    this.afterInsert();   
                } when AFTER_UPDATE   { 
                    this.afterUpdate();   
                } when AFTER_DELETE   { 
                    this.afterDelete();   
                } when AFTER_UNDELETE { 
                    this.afterUndelete(); 
                }
            }
        }
    }

    public static void disable() {
        isEnabled = false;
    }

    public static void enable() {
        isEnabled = true; 
    }

    public Boolean isNew(SObject record) {
        // Returns true if a SObject is being inserted
        // Trigger.old will not contain the record on insert
        return this.triggerOldMap?.containsKey(record?.Id) != true; 
    }
    
    public Boolean isChanged(SObject record, SObjectField field) {
        // Returns true if a SOBjectField value is changed. To be run in Trigger context only. 
        SObject oldRecord = this.triggerOldMap.get(record?.Id);
        Object oldValue = oldRecord?.get(field);
        Object newValue = record?.get(field); 
        return oldValue != newValue;
    }

    public Boolean isChangedFrom(SObject record, SObjectField field, Object fromValue) {
        SObject oldRecord = this.triggerOldMap.get(record?.Id);
        Object oldValue = oldRecord?.get(field);
        Object newValue = record?.get(field); 
        return (oldValue != newValue && oldValue == fromValue); 
    }

    public Boolean isChangedTo(SObject record, SObjectField field, Object toValue) {
        SObject oldRecord = this.triggerOldMap.get(record?.Id);
        Object oldValue = oldRecord?.get(field);
        Object newValue = record?.get(field); 
        return (oldValue != newValue && newValue == toValue); 
    }

    public Boolean isChangedFromTo(SObject record, SObjectField field, Object fromValue, Object toValue) {
        return isChangedFrom(record, field, fromValue) && isChangedTo(record, field, toValue);
    }

    // **** VIRTUAL **** // 
    public virtual void beforeInsert() {}
    public virtual void beforeUpdate() {}
    public virtual void beforeDelete() {}
    public virtual void afterInsert() {}
    public virtual void afterUpdate() {}
    public virtual void afterDelete() {}
    public virtual void afterUndelete() {}

    protected virtual void setTriggerCollections() {
        this.triggerNew = (Trigger.isExecuting) ? Trigger.new : new List<SObject>();
        this.triggerOld = (Trigger.isExecuting) ? Trigger.old : new List<SObject>();
        this.triggerNewMap = (Trigger.isExecuting) ? Trigger.newMap : new Map<Id, SObject>();
        this.triggerOldMap = (Trigger.isExecuting) ? Trigger.oldMap : new Map<Id, SObject>();
    }
}