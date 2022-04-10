global virtual class DmlMock extends Dml {
    global Map<Id, SObject> inserted = new Map<Id, SObject>(); 
    global Map<Id, SObject> updated = new Map<Id, SObject>(); 
    global Map<Id, SObject> upserted = new Map<Id, SObject>(); 
    global Map<Id, SObject> deleted = new Map<Id, SObject>(); 
    global Map<Id, SObject> undeleted = new Map<Id, SObject>(); 

    @TestVisible DmlMock() {
        // This should not be used outside of test context, 
        // but @IsTest classes cannot be virtual
    }

    global override List<SObject> doInsert(List<SObject> records) {
        Map<Id, SObject> recordsWithIds = new Map<Id, SObject>(TestUtils.generateFakeIds(records));
        this.inserted.putAll(recordsWithIds); 
        return records;
    }

    global override List<SObject> doUpdate(List<SObject> records) {
        this.updated.putAll(new Map<Id, SObject>(records)); 
        return records; 
    }

    global override List<SObject> doUpsert(List<SObject> records) {
        Map<Id, SObject> recordsWithIds = new Map<Id, SObject>(TestUtils.generateFakeIds(records));
        this.upserted.putAll(recordsWithIds); 
        return records;
    }

    global override List<SObject> doUpsert(List<SObject> records, SObjectField externalIdField) {
        return this.doUpsert(records); 
    }

    global override List<SObject> doUndelete(List<SObject> records) {
        this.undeleted.putAll(new Map<Id, SObject>(records)); 
        return records;
    }

    global override void doDelete(List<SObject> records) {
        this.deleted.putAll(new Map<Id, SObject>(records)); 
    }

    global override void doHardDelete(List<SObject> records) {
        this.doDelete(records); 
    }
}