@IsTest
global class DmlMock extends Dml {
    global DmlHistory inserted = new DmlHistory(); 
    global DmlHistory updated = new DmlHistory(); 
    global DmlHistory upserted = new DmlHistory(); 
    global DmlHistory deleted = new DmlHistory(); 
    global DmlHistory undeleted = new DmlHistory(); 
    global DmlHistory published = new DmlHistory();

    // Publish Methods
    global override List<DmlResult> doPublish(List<SObject> platformEvents) {
        this.published.add(platformEvents); 
        return DmlResult.getMockResults(platformEvents);
    }

    global override List<SObject> getPublishedEvents() {
        return this.published.getAll();
    }
    
    // Insert Methods
    global override List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone) {
        records = TestUtils.generateFakeIds(records);
        this.inserted.add(records); 
        return DmlResult.getMockResults(records);
    }

    // Update Methods
    global override List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone) {
        this.updated.add(records); 
        return DmlResult.getMockResults(records);
    }

    // Upsert Methods
    global override List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone) {
        records = TestUtils.generateFakeIds(records); 
        this.upserted.add(records); 
        return DmlResult.getMockResults(records);
    }

    global override List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
        return this.doUpsert(records); 
    }

    // Delete Methods
    global override List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone) {
        this.deleted.add(records); 
        return DmlResult.getMockResults(records);
    }

    // Hard Delete Methods
    global override List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone) {
        this.doDelete(records); 
        return DmlResult.getMockResults(records);
    }

    // Undelete Methods
    global override List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone) {
        this.undeleted.add(records); 
        return DmlResult.getMockResults(records);
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