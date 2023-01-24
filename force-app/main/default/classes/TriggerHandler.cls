global abstract class TriggerHandler implements TypeAware {
	global List<SObject> triggerNew { get; protected set; }
	global List<SObject> triggerOld { get; protected set; }
	global Map<Id, SObject> triggerNewMap { get; protected set; }
	global Map<Id, SObject> triggerOldMap { get; protected set; }
	@TestVisible
	System.TriggerOperation operation = Trigger.operationType;

	static Boolean IsEnabled = true;
	static Set<Type> BypassedHandlers = new Set<Type>();

	global TriggerHandler() {
		this.setTriggerCollections();
	}

	// Required for bypass purposes. This method should always return the current type (ex., AccountTriggerHandler.class)
	global abstract Type getType();

	global void run() {
		if (this.isEnabled()) {
			switch on this.operation {
				when BEFORE_INSERT {
					this.beforeInsert();
				}
				when BEFORE_UPDATE {
					this.beforeUpdate();
				}
				when BEFORE_DELETE {
					this.beforeDelete();
				}
				when AFTER_INSERT {
					this.afterInsert();
				}
				when AFTER_UPDATE {
					this.afterUpdate();
				}
				when AFTER_DELETE {
					this.afterDelete();
				}
				when AFTER_UNDELETE {
					this.afterUndelete();
				}
			}
		}
	}

	global Boolean isNew(SObject record) {
		// Returns true if a SObject is being inserted
		// Trigger.old will not contain the record on insert
		return this.triggerOldMap?.containsKey(record?.Id) != true;
	}

	global Boolean isChanged(SObject record, SObjectField field) {
		// Returns true if a SOBjectField value is changed. To be run in Trigger context only.
		SObject oldRecord = this.triggerOldMap.get(record?.Id);
		Object oldValue = oldRecord?.get(field);
		Object newValue = record?.get(field);
		return oldValue != newValue;
	}

	global Boolean isChangedFrom(SObject record, SObjectField field, Object fromValue) {
		SObject oldRecord = this.triggerOldMap.get(record?.Id);
		Object oldValue = oldRecord?.get(field);
		Object newValue = record?.get(field);
		return (oldValue != newValue && oldValue == fromValue);
	}

	global Boolean isChangedTo(SObject record, SObjectField field, Object toValue) {
		SObject oldRecord = this.triggerOldMap.get(record?.Id);
		Object oldValue = oldRecord?.get(field);
		Object newValue = record?.get(field);
		return (oldValue != newValue && newValue == toValue);
	}

	global Boolean isChangedFromTo(SObject record, SObjectField field, Object fromValue, Object toValue) {
		return isChangedFrom(record, field, fromValue) && isChangedTo(record, field, toValue);
	}

	// **** VIRTUAL **** //
	global virtual void beforeInsert() {
	}
	global virtual void beforeUpdate() {
	}
	global virtual void beforeDelete() {
	}
	global virtual void afterInsert() {
	}
	global virtual void afterUpdate() {
	}
	global virtual void afterDelete() {
	}
	global virtual void afterUndelete() {
	}

	protected void setTriggerCollections() {
		this.triggerNew = (Trigger.isExecuting) ? Trigger.new : new List<SObject>();
		this.triggerOld = (Trigger.isExecuting) ? Trigger.old : new List<SObject>();
		this.triggerNewMap = (Trigger.isExecuting) ? Trigger.newMap : new Map<Id, SObject>();
		this.triggerOldMap = (Trigger.isExecuting) ? Trigger.oldMap : new Map<Id, SObject>();
	}

	protected Boolean isEnabled() {
		// For the handler to run, the TriggerHandler must be enabled,
		// and the specific handler must not be bypassed
		return (TriggerHandler.IsEnabled && TriggerHandler.BypassedHandlers?.contains(this.getType()) == false);
	}

	// **** STATIC **** //
	global static void enableAll() {
		TriggerHandler.enable();
		TriggerHandler.BypassedHandlers?.clear();
	}

	global static void enable() {
		TriggerHandler.IsEnabled = true;
	}

	global static void disable() {
		TriggerHandler.IsEnabled = false;
	}

	global static void enable(Type handlerType) {
		TriggerHandler.IsEnabled = true;
		TriggerHandler.BypassedHandlers?.remove(handlerType);
	}

	global static void disable(Type handlerType) {
		TriggerHandler.BypassedHandlers?.add(handlerType);
	}
}
