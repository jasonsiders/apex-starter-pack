global virtual inherited sharing class Dml implements IDml {
    global virtual List<SObject> doInsert(List<SObject> records) {
        Database.insert(sorted(records)); 
        return records;
    }

    global virtual SObject doInsert(SObject record) {
        return this.doInsert(new List<SObject>{record})[0];
    }

    global virtual List<SObject> doUpdate(List<SObject> records) {
        Database.update(sorted(records)); 
        return records;
    }

    global virtual SObject doUpdate(SObject record) {
        return this.doUpdate(new List<SObject>{record})[0];
    }

    global virtual List<SObject> doUpsert(List<SObject> records) {
        Database.upsert(sorted(records)); 
        return records;
    }

    global virtual SObject doUpsert(SObject record) {
        return this.doUpsert(new List<SObject>{record})[0];
    }

    global virtual List<SObject> doUpsert(List<SObject> records, SObjectField externalIdField) {
        Database.upsert(sorted(records), externalIdField); 
        return records;
    }

    global virtual SObject doUpsert(SObject record, SObjectField externalIdField) {
        return this.doUpsert(new List<SObject>{record}, externalIdField)[0];
    }

    global virtual List<SObject> doUndelete(List<SObject> records) {
        Database.undelete(sorted(records)); 
        return records;
    }

    global virtual SObject doUndelete(SObject record) {
        return this.doUndelete(new List<SObject>{record})[0];
    }

    global virtual void doDelete(List<SObject> records) {
        Database.delete(sorted(records)); 
    }

    global virtual void doDelete(SObject record) {
        this.doDelete(new List<SObject>{record});
    }

    global virtual void doHardDelete(List<SObject> records) {
        Database.delete(sorted(records)); 
        Database.emptyRecycleBin(records); 
    }

    global virtual void doHardDelete(SObject record) {
        this.doHardDelete(new List<SObject>{record});
    }

    private static List<SObject> sorted(List<SObject> records) {
        records.sort();
        return records;
    }
}