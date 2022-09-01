public inherited sharing abstract class InvocableRollup implements System.Queueable {
    /**
     *  This class provides a flexible, metadata-driven way to execute Rollups from flow
     *  It has a number of features:
     *  - Can run parent or child rollups
     *  - Can run all rollups for the record, or a specific list passed in
     *  - Can run asynchronously, or in real-time
    **/
    @InvocableMethod(
        category='Rollup'
        description='Execute rollup(s) from metadata on parent or child records'
        label='Rollup'
    )
    public static void invoke(List<Input> inputs) {
        // Note: Because of the way Flow boxcars input values,
        // we should treat certain values as consistent across the entire List<Input>
        Input firstInput = (Input) CollectionUtils.getIndexOf(inputs, 0);
        RollupContext context = (RollupContext) EnumUtils.valueOf(firstInput?.rollupContext, RollupContext.class);
        Timing timing = firstInput?.getTiming(); 
        SObjectType objectType = firstInput?.getSObjectType(); 
        InvocableRollup job = (context == InvocableRollup.RollupContext.CHILD) 
            ? (InvocableRollup) new ChildRollup(inputs, objectType, timing)
            : (InvocableRollup) new ParentRollup(inputs, objectType, timing); 
        job.run(); 
    }

    // **** MEMBER **** // 
    SObjectRef objectType; 
    Timing timing; 
    Map<Id, SObject> records = new Map<Id, SObject>();

    // **** ABSTRACT **** // 
    protected abstract List<SObject> calculateRollups(); 
    protected abstract SObjectField getMatchingField(); 

    protected virtual void run() {
        if (this.timing == InvocableRollup.Timing.ASYNCHRONOUS) {
            System.enqueueJob(this); 
        } else {
            this.runSynchronously();
        }
    }

    public void execute(System.QueueableContext context) {
        this.runSynchronously();
    }

    protected void runSynchronously() {
        List<SObject> rollupResults = this.calculateRollups(); 
        DatabaseLayer.Dml.doUpdate(rollupResults); 
    }

    protected List<Rollup__mdt> getAllMatchingRollups() {
        // Retrieve all Rollups where the SObjectType matches the records' SObjectType
        SObjectField matchingField = this.getMatchingField(); 
        Soql mdtQuery = RollupMetadataHelper.BaseQuery.whereFilters(new Filter(
            matchingField, 
            Filter.EQUALS, 
            String.valueOf(this.objectType)
        ));
        List<Rollup__mdt> results = (List<Rollup__mdt>) mdtQuery.run(); 
        return results;
    }

    protected void validateMetadata(List<Rollup__mdt> rollups) {
        // Iterate through rollups and assert that required fields are present. If not, surface a relevant error message.
        // Note: Ideally, we wouldn't need to enforce this in apex, and use CMDT Metadata Relationships instead
        // However, discovered some strange behavior for these types that prevents us from using, chronicled here:
        // https://github.com/jasonsiders/apex-starter-pack/issues/90
        for (Rollup__mdt rollup : rollups) {
            // Check Parent Object values
            SObjectType parentObject = SchemaUtils.getSObjectType(rollup.Parent_SObjectType__c); 
            SObjectType childObject = SchemaUtils.getSObjectType(rollup.Child_SObjectType__c); 
            SObjectField targetField = SchemaUtils.getSObjectField(parentObject, rollup.Target_Field__c);
            SObjectField relField = SchemaUtils.getSObjectField(childObject, rollup.Relationship_Field__c); 
            ChildRelationship childRel = SchemaUtils.getChildRelationship(relField); 
            // Check Child Object values
            for (Object item : new List<Object>{
                parentObject, 
                childObject, 
                targetField, 
                relField,
                childRel
            }) {
                if (item == null) {
                    throw new InvalidInputException(rollup);
                }
            }
            // Note: Calculation_Field__c is not required if the Calculation Type is COUNT
            SObjectField calcField = SchemaUtils.getSObjectField(childObject, rollup.Calculation_Field__c); 
            if (calcField == null && rollup.Calculation_Type__c != 'COUNT') {
                throw new InvalidInputException(rollup);
            }
        }
    }

    // **** INNER **** // 
    public enum RollupContext {
        CHILD,
        PARENT
    }

    public enum Timing {
        ASYNCHRONOUS,
        SYNCHRONOUS
    }

    public class InvalidInputException extends Exception {
        private InvalidInputException(Rollup__mdt rollup) {
            this.setMessage('Invalid Rollup__mdt: ' + JSON.serializePretty(rollup));
        }
    }

    private class ChildRollup extends InvocableRollup {
        Map<SObjectField, List<Rollup__mdt>> rollupMdts = new Map<SObjectField, List<Rollup__mdt>>();
        Map<SObjectField, Rollup> rollupMap = new Map<SObjectField, Rollup>();

        private ChildRollup(List<Input> inputs, SObjectType sObjectType, Timing timing) {
            this.objectType = new SObjectRef(sObjectType);
            this.timing = timing; 
            for (Input input : inputs) {
                this.records.putAll(new Map<Id, SObject>(input.getRecords())); 
                this.mapByRelationshipField(input.getRollups()); 
            } 
            if (this.rollupMdts.isEmpty()) {
                // If a user doesn't specify a Rollup__mdt(s), retrieve all that match the SObjectType
                List<Rollup__mdt> allRollups = this.getAllMatchingRollups(); 
                this.mapByRelationshipField(allRollups); 
            }
            for (SObjectField field : this.rollupMdts.keySet()) {
                List<Rollup__mdt> matching = this.rollupMdts.get(field); 
                this.validateMetadata(matching); 
                RollupMetadataHelper helper = new RollupMetadataHelper(matching);
                // Note: This should always a size 1 in this case
                Rollup rollup = (Rollup) CollectionUtils.getIndexOf(helper.getRollups(), 0);
                this.rollupMap.put(field, rollup);
            }
        }

        private void mapByRelationshipField(List<Rollup__mdt> rollups) {
            for (Rollup__mdt rollup : rollups) {
                SObjectType childSObjectType = SchemaUtils.getSObjectType(rollup.Child_SObjectType__c); 
                SObjectField relationshipField = SchemaUtils.getSObjectField(childSObjectType, rollup.Relationship_Field__c); 
                List<Rollup__mdt> matching = rollupMdts?.containsKey(relationshipField) 
                    ? this.rollupMdts.get(relationshipField)
                    : new List<Rollup__mdt>();
                matching.add(rollup); 
                this.rollupMdts.put(relationshipField, matching); 
            }
        }

        public override List<SObject> calculateRollups() {
            List<SObject> results = new List<SObject>();
            for (SObjectField field : this.rollupMap.keySet()) {
                Rollup rollup = this.rollupMap.get(field); 
                results.addAll(rollup?.runFromChild(this.records?.values(), field)); 
            }
            return results;
        }

        public override SObjectField getMatchingField() {
            return Rollup__mdt.Child_SObjectType__c; 
        }
    }

    private class ParentRollup extends InvocableRollup {
        List<Rollup> rollups = new List<Rollup>();

        private ParentRollup(List<Input> inputs, SObjectType sObjectType, Timing timing) {
            this.objectType = new SObjectRef(sObjectType);
            this.timing = timing; 
            List<Rollup__mdt> rollupMdts = this.getRollupsFromInputs(inputs); 
            this.validateMetadata(rollupMdts); 
            this.rollups = new RollupMetadataHelper(rollupMdts).getRollups(); 
        }
    
        public override List<SObject> calculateRollups() {
            // Proecss the Rollups
            Map<Id, SObject> updates = this.records;
            for (Rollup rollup : this.rollups) {
                List<SObject> results = rollup.run(updates?.values());
                updates.putAll(new Map<Id, SObject>(results)); 
            }
            return updates.values(); 
        }

        public override SObjectField getMatchingField() {
            return Rollup__mdt.Parent_SObjectType__c; 
        }

        private List<Rollup__mdt> getRollupsFromInputs(List<Input> inputs) {
            List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>();
            for (Input input : inputs) {
                rollupMdts.addAll(input.getRollups()); 
                this.records.putAll(new Map<Id, SObject>(input.getRecords())); 
            }
            if (rollupMdts?.isEmpty()) {
                // If a user doesn't specify a Rollup__mdt(s), retrieve all that match the SObjectType
                rollupMdts = this.getAllMatchingRollups(); 
            }
            return rollupMdts; 
        }
    }

    public class Input {
        @InvocableVariable(description='Indicates if the Rollup will be executed in real-time, or asynchronously' label='Timing' required=true)
        public String timing;

        @InvocableVariable(description='Indicates if the records are the parent or child records in the rollup equation' label='Rollup Context' required=true)
        public String rollupContext; 

        @InvocableVariable(description='You must provide at least one Record/Id via the single/list variables' label='Record Id')
        public Id recordId;

        @InvocableVariable(description='You must provide at least one Record/Id via the single/list variables' label='Record')
        public SObject record;

        @InvocableVariable(description='You must provide at least one Record/Id via the single/list variables' label='Records')
        public List<SObject> records = new List<SObject>(); 

        @InvocableVariable(description='You must provide at least one Rollup__mdt via single/list variables' label='Rollup')
        public Rollup__mdt rollup; 

        @InvocableVariable(description='You must provide at least one Rollup__mdt via single/list variables' label='Rollups')
        public List<Rollup__mdt> rollups = new List<Rollup__mdt>(); 

        private List<SObject> allRecords;
        private List<Rollup__mdt> allRollups; 

        public SObjectType getSObjectType() {
            SObject record = (SObject) CollectionUtils.getIndexOf(this.getRecords(), 0);
            return record?.getSObjectType();
        }

        public Timing getTiming() {
            return (Timing) EnumUtils.valueOf(this.timing, Timing.class); 
        }

        public List<SObject> getRecords() {
            // Combine the multiple SObject/Id variables into a single List<SObject>
            // Note: @InvocableVariables do not allow getter/setters, so lazy-load pattern employed here
            if (this.allRecords == null) {
                this.allRecords = (this.records != null) ? this.records : new List<SObject>(); 
                if (this.recordId != null) {
                    SObject newRecord = this.recordId?.getSobjectType()?.newSObject(this.recordId);
                    this.allRecords.add(newRecord); 
                }
                if (this.record != null) {
                    this.allRecords.add(this.record); 
                }
            }
            return this.allRecords;
        }

        public List<Rollup__mdt> getRollups() {
            // Combine the multiple Rollup__mdt variables into a single List<Rollup__mdt>
            // Note: @InvocableVariables do not allow getter/setters, so lazy-load pattern employed here
            if (this.allRollups == null) {
                this.allRollups = (this.rollups != null) ? this.rollups : new List<Rollup__mdt>(); 
                if (this.rollup != null) {
                    this.allRollups.add(this.rollup); 
                }
            }
            return this.allRollups; 
        }
    }
}
