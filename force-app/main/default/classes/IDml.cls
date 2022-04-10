global interface IDml {
    List<SObject> doInsert(List<SObject> records);
    SObject doInsert(SObject record);
    List<SObject> doUpdate(List<SObject> records);
    SObject doUpdate(SObject record);
    List<SObject> doUpsert(List<SObject> records);
    SObject doUpsert(SObject record);
    List<SObject> doUpsert(List<SObject> records, SObjectField externalIdField);
    SObject doUpsert(SObject record, SObjectField externalIdField);
    List<SObject> doUndelete(List<SObject> records);
    SObject doUndelete(SObject record);
    void doDelete(List<SObject> records);
    void doDelete(SObject record);
    void doHardDelete(List<SObject> records);
    void doHardDelete(SObject record); 
}