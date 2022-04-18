global virtual class DmlMock extends Dml {
    global DmlHistory inserted = new DmlHistory(); 
    global DmlHistory updated = new DmlHistory(); 
    global DmlHistory upserted = new DmlHistory(); 
    global DmlHistory deleted = new DmlHistory(); 
    global DmlHistory undeleted = new DmlHistory(); 

    @TestVisible DmlMock() {
        // This should not be used outside of test context, 
        // but @IsTest classes cannot be virtual
    }

    global override List<SObject> doInsert(List<SObject> records) {
        List<SObject> recordsWithIds = TestUtils.generateFakeIds(records);
        this.inserted.add(recordsWithIds); 
        return records;
    }

    global override List<SObject> doUpdate(List<SObject> records) {
        this.updated.add(records); 
        return records; 
    }

    global override List<SObject> doUpsert(List<SObject> records) {
        List<SObject> recordsWithIds = TestUtils.generateFakeIds(records); 
        this.upserted.add(recordsWithIds); 
        return records;
    }

    global override List<SObject> doUpsert(List<SObject> records, SObjectField externalIdField) {
        return this.doUpsert(records); 
    }

    global override List<SObject> doUndelete(List<SObject> records) {
        this.undeleted.add(records); 
        return records;
    }

    global override void doDelete(List<SObject> records) {
        this.deleted.add(records); 
    }

    global override void doHardDelete(List<SObject> records) {
        this.doDelete(records); 
    }

    global class DmlHistory {
        // A record of all records which were recordsBySObjectType by the DML engine, by SObjectType
        Map<SObjectType, List<SObject>> recordsBySObjectType = new Map<SObjectType, List<SObject>>(); 
        Map<Id, SObject> recordsById = new Map<Id, SObject>();

        global Boolean containsRecord(Id recordId) {
            return this.recordsById?.containsKey(recordId); 
        }

        global Boolean containsRecord(SObject record) {
            return this.containsRecord(record?.Id);
        }

        global SObject getRecord(Id recordId) {
            return this.recordsById?.get(recordId); 
        }

        global SObject getRecord(SObject record) {
            return this.getRecord(record?.Id);
        }   

        global List<SObject> getRecords(Schema.SObjectType objectType) {
            return this.recordsBySObjectType.get(objectType); 
        }

        global List<SObject> getAll() {
            List<SObject> allRecords = new List<SObject>();
            for (List<SObject> records : this.recordsBySObjectType.values()) {
                allRecords.addAll(records); 
            }
            return allRecords;
        }

        global void clear() {
            this.recordsBySObjectType = new Map<SObjectType, List<SObject>>(); 
        }

        private void add(List<SObject> records) {
            // Should only be used by the DmlMock class
            for (SObject record : records) {
                // Map the record by its Id (1:1)
                this.recordsById.put(record.Id, record); 
                // Map the record by its SObjectType (1:many)
                SObjectType objectType = record.getSObjectType();
                List<SObject> matchingRecords = this.recordsBySObjectType.get(objectType); 
                matchingRecords = (matchingRecords != null) ? matchingRecords : new List<SObject>();
                matchingRecords.add(record);
                this.recordsBySObjectType.put(objectType, matchingRecords); 
            }
        }
    }
}