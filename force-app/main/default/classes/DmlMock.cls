@IsTest
public class DmlMock extends Dml {
    // Publish Methods
    public override List<DmlResult> doPublish(List<SObject> platformEvents) {
        Dml.Published.add(platformEvents); 
        return DmlResult.getMockResults(platformEvents);
    }

    public override List<SObject> getPublishedEvents() {
        return Dml.Published.getAll();
    }
    
    // Insert Methods
    public override List<DmlResult> doInsert(List<SObject> records, Boolean allOrNone) {
        records = TestUtils.generateFakeIds(records);
        Dml.Inserted.add(records); 
        return DmlResult.getMockResults(records);
    }

    // Update Methods
    public override List<DmlResult> doUpdate(List<SObject> records, Boolean allOrNone) {
        Dml.Updated.add(records); 
        return DmlResult.getMockResults(records);
    }

    // Upsert Methods
    public override List<DmlResult> doUpsert(List<SObject> records, Boolean allOrNone) {
        records = TestUtils.generateFakeIds(records); 
        Dml.Upserted.add(records); 
        return DmlResult.getMockResults(records);
    }

    public override List<DmlResult> doUpsert(List<SObject> records, SObjectField externalIdField, Boolean allOrNone) {
        return this.doUpsert(records); 
    }

    // Delete Methods
    public override List<DmlResult> doDelete(List<SObject> records, Boolean allOrNone) {
        Dml.Deleted.add(records); 
        return DmlResult.getMockResults(records);
    }

    // Hard Delete Methods
    public override List<DmlResult> doHardDelete(List<SObject> records, Boolean allOrNone) {
        this.doDelete(records); 
        return DmlResult.getMockResults(records);
    }

    // Undelete Methods
    public override List<DmlResult> doUndelete(List<SObject> records, Boolean allOrNone) {
        Dml.Undeleted.add(records); 
        return DmlResult.getMockResults(records);
    }
}