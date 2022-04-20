global interface IDml {
    // Publish Methods (for platform events)
    // Note: Platform Events do not share a common interface; must use "normal" SObjects here
    List<DmlResult> doPublish(List<SObject> platformEvents);
    DmlResult doPublish(SObject platformEvent);
    List<SObject> getPublishedEvents(); 

    // Insert Methods
    List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone);
    List<DmlResult> doInsert(List<SObject> records);
    DmlResult doInsert(SObject record, Boolean allOrNone);
    DmlResult doInsert(SObject record);

    // Update Methods
    List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone);
    List<DmlResult> doUpdate(List<SObject> records);
    DmlResult doUpdate(SObject record, Boolean allOrNone);
    DmlResult doUpdate(SObject record);

    // Upsert Methods
    List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone);
    List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField);
    List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone);
    List<DmlResult> doUpsert(List<SObject> records);
    DmlResult doUpsert(SObject record, SObjectField externalIdField, Boolean allOrNone);
    DmlResult doUpsert(SObject record, SObjectField externalIdField);
    DmlResult doUpsert(SObject record, Boolean allOrNone);
    DmlResult doUpsert(SObject record);

    // Delete Methods
    List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone);
    List<DmlResult> doDelete(List<SObject> records);
    DmlResult doDelete(SObject record, Boolean allOrNone);
    DmlResult doDelete(SObject record);

    // Hard Delete Methods
    List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone);
    List<DmlResult> doHardDelete(List<SObject> records);
    DmlResult doHardDelete(SObject record, Boolean allOrNone); 
    DmlResult doHardDelete(SObject record); 

    // Undelete Methods
    List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone);
    List<DmlResult> doUndelete(List<SObject> records);
    DmlResult doUndelete(SObject record, Boolean allOrNone);
    DmlResult doUndelete(SObject record);
}