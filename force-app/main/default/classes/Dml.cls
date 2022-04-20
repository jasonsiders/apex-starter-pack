global virtual inherited sharing class Dml implements IDml {
    global List<SObject> publishedEvents = new List<SObject>();

    // Publish Methods
    global virtual List<DmlResult> doPublish(List<SObject> events) {
        this.publishedEvents.addAll(events); 
        List<Database.SaveResult> results = EventBus.publish(events); 
        return DmlResult.wrap(results); 
    }

    global virtual DmlResult doPublish(SObject event) {
        return this.doPublish(new List<SObject>{event})[0];
    }

    global virtual List<SObject> getPublishedEvents() {
        return this.publishedEvents; 
    }

    // Insert Methods
    global virtual List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone) {
        List<Database.SaveResult> results = Database.insert(records, allOrNone);
        return DmlResult.wrap(results);
    }
    
    global virtual List<DmlResult> doInsert(List<SObject> records) {
        return this.doInsert(records, true);
    }

    global virtual DmlResult doInsert(SObject record, Boolean allOrNone) {
        return this.doInsert(new List<SObject>{record}, allOrNone)[0];
    }

    global virtual DmlResult doInsert(SObject record) {
        return this.doInsert(record, true);
    }

    // Update Methods
    global virtual List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone) {
        List<Database.SaveResult> results = Database.update(records, allOrNone);
        return DmlResult.wrap(results);
    }
    
    global virtual List<DmlResult> doUpdate(List<SObject> records) {
        return this.doUpdate(records, true);
    }

    global virtual DmlResult doUpdate(SObject record, Boolean allOrNone) {
        return this.doUpdate(new List<SObject>{record}, allOrNone)[0];
    }

    global virtual DmlResult doUpdate(SObject record) {
        return this.doUpdate(record, true);
    }

    // Upsert Methods
    global virtual List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
        List<Database.UpsertResult> results = Database.upsert(records, externalIdField, allOrNone);
        return DmlResult.wrap(results); 
    }
    
    global virtual List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField) {
        return this.doUpsert(records, externalIdField, true);
    }
    
    global virtual List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone) {
        // Can't re-use the first doUpsert method, because externalIdField can't be null
        List<Database.UpsertResult> results = Database.upsert(records, allOrNone);
        return DmlResult.wrap(results);
    }
    
    global virtual List<DmlResult> doUpsert(List<SObject> records) {
        return this.doUpsert(records, true);
    }
    
    global virtual DmlResult doUpsert(SObject record, SObjectField externalIdField, Boolean allOrNone) {
        return this.doUpsert(new List<SObject>{record}, externalIdField, allOrNone)[0];
    }
    
    global virtual DmlResult doUpsert(SObject record, SObjectField externalIdField) {
        return this.doUpsert(record, externalIdField, true);
    }
    
    global virtual DmlResult doUpsert(SObject record, Boolean allOrNone) {
        return this.doUpsert(new List<SObject>{record}, allOrNone)[0];
    }
    
    global virtual DmlResult doUpsert(SObject record) {
        return this.doUpsert(record, true); 
    }

    // Delete Methods
    global virtual List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone) {
        List<Database.DeleteResult> results = Database.delete(records, allOrNone);
        return DmlResult.wrap(results); 
    }

    global virtual List<DmlResult> doDelete(List<SObject> records) {
        return this.doDelete(records, true); 
    }

    global virtual DmlResult doDelete(SObject record, Boolean allOrNone) {
        return this.doDelete(new List<SObject>{record}, allOrNone)[0];
    }

    global virtual DmlResult doDelete(SObject record) {
        return this.doDelete(record, true);
    }

    // Hard Delete Methods
    global virtual List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone) {
        List<Database.DeleteResult> results = Database.delete(records, allOrNone); 
        Database.emptyRecycleBin(records); 
        return DmlResult.wrap(results); 
    }

    global virtual List<DmlResult> doHardDelete(List<SObject> records) {
        return this.doHardDelete(records, true); 
    }

    global virtual DmlResult doHardDelete(SObject record, Boolean allOrNone) {
        return this.doHardDelete(new List<SObject>{record}, allOrNone)[0];
    }

    global virtual DmlResult doHardDelete(SObject record) {
        return this.doHardDelete(record, true);
    }

    // Undelete Methods
    global virtual List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone) {
        List<Database.UndeleteResult> results = Database.undelete(records, allOrNone);
        return DmlResult.wrap(results); 
    }

    global virtual List<DmlResult> doUndelete(List<SObject> records) {
        return this.doUndelete(records, true); 
    }

    global virtual DmlResult doUndelete(SObject record, Boolean allOrNone) {
        return this.doUndelete(new List<SObject>{record}, allOrNone)[0];
    }

    global virtual DmlResult doUndelete(SObject record) {
        return this.doUndelete(record, true); 
    }
}