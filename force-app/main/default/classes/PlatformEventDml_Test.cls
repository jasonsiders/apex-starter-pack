@IsTest
private class PlatformEventDml_Test {
    @IsTest 
    static void shouldDoPublish() {
        Log_Event__e event = new Log_Event__e(Message__c = 'Testing 123');
        Test.startTest();
        PlatformEventDml dml = new PlatformEventDml(); 
        dml.publish(event);
        Test.stopTest();
        Test.getEventBus().deliver();
        // Unlike "normal" DML, platform events are not given an ID after insert/publish
        System.assertEquals(null, event.ReplayId);
        System.assertEquals(1, dml.publishedEvents?.size());
    }

    @IsTest 
    static void shouldInsertNormalSObject() {
        // Note: There isn't currently a `PlatformEventSObject` interface/type,
        // nor is there a way to identify/prevent "normal" SObjects from being passed here
        // EventBus.publish by default will insert "normal" SObjects instead of publish them
        // but by no means should we actually go try and do this in real life!
        Account notAnEvent = new Account(Name = 'Test'); 
        Database.SaveResult result = new PlatformEventDml().publish(notAnEvent);
        System.assertEquals(true, result.isSuccess(), 'Account publish failed: ' + JSON.serialize(result));
        System.assertEquals(false, [SELECT Id FROM Account WHERE Id = :result.getId()]?.isEmpty(), 'Account was not inserted');
    }
}
