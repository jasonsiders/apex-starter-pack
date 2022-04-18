public inherited sharing class LogEventHandler extends TriggerHandler {
    public override void afterInsert() {
        new LogGenerator(this.triggerNew).generateLogs(); 
    }
}