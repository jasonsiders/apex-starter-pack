public without sharing class LogEventHandler extends TriggerHandler {
    @TestVisible
    List<Log_Event__e> triggerNew = (Trigger.isExecuting) ? (List<Log_Event__e>) Trigger.new : new List<Log_Event__e>();

    public override void afterInsert() {
        new LogGenerator(this.triggerNew)?.createLogRecords(); 
    }

    protected override Type getHandlerType() {
        return LogEventHandler.class; 
    }
}
