public class LogGenerator {
	List<Log_Event__e> events;

	public LogGenerator(List<Log_Event__e> events) {
		this.events = events;
	}

	public void createLogRecords() {
		List<Log__c> logs = new List<Log__c>();
		for (Log_Event__e event : this.events) {
			logs.add(
				new Log__c(
					Apex_Class__c = event.Apex_Class__c,
					Context__c = event.Context__c,
					Level__c = event.Level__c,
					Logged_At__c = event.Logged_At__c,
					Message__c = event.Message__c,
					Running_User__c = event.Running_User__c,
					Sequence__c = event.Sequence__c,
					Stack_Trace__c = event.Stack_Trace__c,
					Transaction_Id__c = event.Transaction_Id__c
				)
			);
		}
		Database.insert(logs, false);
	}
}
