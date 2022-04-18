global with sharing class PlatformEventDml implements IPlatformEventDml {
    @TestVisible List<SObject> publishedEvents = new List<SObject>(); 

    global virtual List<Database.SaveResult> publish(List<SObject> events) {
        List<Database.SaveResult> results = EventBus.publish(events); 
        this.publishedEvents.addAll(events); 
        return results;
    }

    global virtual Database.SaveResult publish(SObject event) {
        return this.publish(new List<SObject>{event})[0];
    }
}
