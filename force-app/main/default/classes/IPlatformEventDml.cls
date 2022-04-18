public interface IPlatformEventDml {
    List<Database.SaveResult> publish(List<SObject> events);
    Database.SaveResult publish(SObject event);
}