public with sharing class LogPublisher {
    @InvocableMethod(category='Logging' label='Publish Logs')
    public static void invoke() {
        Logger.publish();
    }
}
