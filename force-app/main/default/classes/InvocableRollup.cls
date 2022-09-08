public inherited sharing abstract class InvocableRollup implements System.Queueable {
    /**
     *  This class provides a flexible, metadata-driven way to execute Rollups from flow
     *  It has a number of features:
     *  - Can run parent or child rollups
     *  - Can run all rollups for the record, or a specific list passed in
     *  - Can run asynchronously, or in real-time
    **/
    @InvocableMethod(category='Rollup' configurationEditor='c-cpe-rollup' label='Rollup')
    public static void invoke(List<Input> inputs) {
        // Group all inputs by their RollupContext, SObjectType, and Timing. Like inputs can all be run together
        // Note: It's best practice to design your flows so that as few of these will run at once - else, may hit limits
        Map<SObjectType, Container> containers = new Map<SObjectType, Container>();
        for (Input input : inputs) {
            SObjectType objectType = input?.getSObjectType();
            Container container = containers?.containsKey(objectType) 
                ? containers?.get(objectType) 
                : new Container(objectType);
            containers?.put(objectType, container?.addInput(input));
        }
        // Run all valid rollups from each container
        for (Container container : containers?.values()) {
            container?.run(); 
        }
    }

    // **** MEMBER **** // 
    protected SObjectRef objectType; 
    protected Timing timing; 
    protected Map<Id, SObject> records = new Map<Id, SObject>();

    // **** ABSTRACT **** // 
    protected abstract InvocableRollup addInput(Input input);
    protected abstract List<SObject> calculateRollups(); 
    protected abstract SObjectField getMatchingField(); 

    protected virtual void run() {
        if (this.isValidInstanceOf(InvocableRollup.Timing.ASYNCHRONOUS)) {
            System.enqueueJob(this);
        } else if (this.isValidInstanceOf(InvocableRollup.Timing.SYNCHRONOUS)) {
            this.runSynchronously(); 
        }
    }

    public void execute(System.QueueableContext context) {
        // Runs the Rollup logic asynchronously
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
            for (Object item : new List<Object>{parentObject, childObject, targetField, relField, childRel}) {
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

    protected Boolean isValidInstanceOf(Timing expectedTiming) {
        // Returns true if the current Timing value matches, and the object has records
        return this.timing == expectedTiming && this.records?.isEmpty() == false;
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

    private virtual class ChildRollup extends InvocableRollup {
        // Defines logic for running rollups when given the child records (ex., the Opportunities of an Account)
        Map<SObjectField, List<Rollup__mdt>> rollupMdts = new Map<SObjectField, List<Rollup__mdt>>();
        Map<SObjectField, Rollup> rollupMap = new Map<SObjectField, Rollup>();

        private ChildRollup(SObjectType sObjectType, Timing timing) {
            this.objectType = new SObjectRef(sObjectType);
            this.timing = timing; 
        }

        protected override InvocableRollup addInput(Input input) {
            this.records.putAll(new Map<Id, SObject>(input.getRecords())); 
            this.mapByRelationshipField(input.getRollups()); 
            return this; 
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

        protected override List<SObject> calculateRollups() {
            this.preProcess();
            List<SObject> results = new List<SObject>();
            for (SObjectField field : this.rollupMap.keySet()) {
                Rollup rollup = this.rollupMap.get(field); 
                results.addAll(rollup?.runFromChild(this.records?.values(), field)); 
            }
            return results;
        }

        protected override SObjectField getMatchingField() {
            return Rollup__mdt.Child_SObjectType__c; 
        }

        private void preProcess() {
            if (this.rollupMdts.isEmpty()) {
                // If a user doesn't specify a Rollup__mdt(s), retrieve all that match the SObjectType
                List<Rollup__mdt> allRollups = this.getAllMatchingRollups(); 
                this.mapByRelationshipField(allRollups); 
            }
            for (SObjectField field : this.rollupMdts.keySet()) {
                List<Rollup__mdt> matching = this.rollupMdts.get(field); 
                RollupMetadataHelper helper = new RollupMetadataHelper(matching);
                this.validateMetadata(matching); 
                // Note: This should always a size 1 in this case
                Rollup rollup = (Rollup) CollectionUtils.getIndexOf(helper.getRollups(), 0);
                this.rollupMap.put(field, rollup);
            }
        }
    }

    private virtual class ParentRollup extends InvocableRollup {
        // Defines logic for running rollups when given the parent records (ex., Accounts that have Opportunities)
        List<Rollup> rollups = new List<Rollup>();
        List<Rollup__mdt> rollupMdts = new List<Rollup__mdt>(); 

        private ParentRollup(SObjectType sObjectType, Timing timing) {
            this.objectType = new SObjectRef(sObjectType);
            this.timing = timing; 
        }
    
        protected override List<SObject> calculateRollups() {
            // Process the Rollups
            this.preProcess();
            Map<Id, SObject> updates = this.records;
            for (Rollup rollup : this.rollups) {
                List<SObject> results = rollup.run(updates?.values());
                updates.putAll(new Map<Id, SObject>(results)); 
            }
            return updates.values(); 
        }

        protected override SObjectField getMatchingField() {
            return Rollup__mdt.Parent_SObjectType__c; 
        }

        public override InvocableRollup addInput(Input input) {
            List<Rollup__mdt> inputMdts = input?.getRollups(); 
            this.rollupMdts.addAll(input?.getRollups());
            this.records?.putAll(new Map<Id, SObject>(input?.getRecords()));
            return this; 
        }

        private void preProcess() {
            if (this.rollupMdts?.isEmpty()) {
                // If a user doesn't specify a Rollup__mdt(s), retrieve all that match the SObjectType
                this.rollupMdts = this.getAllMatchingRollups(); 
            }
            this.rollups = new RollupMetadataHelper(this.rollupMdts).getRollups(); 
            this.validateMetadata(this.rollupMdts);
        }
    }

    private class Container {
        // Used to group alike flow Inputs together. This class is necessary 
        // because of the way that flow boxcars invocable inputs into one transaction
        Map<InvocableRollup.RollupContext, Map<InvocableRollup.Timing, InvocableRollup>> matchingRollups = 
            new Map<InvocableRollup.RollupContext, Map<InvocableRollup.Timing, InvocableRollup>>();

        public Container(SObjectType objectType) {
            this.matchingRollups.put(InvocableRollup.RollupContext.CHILD, new Map<InvocableRollup.Timing, InvocableRollup>{ 
                InvocableRollup.Timing.ASYNCHRONOUS => new ChildRollup(objectType, InvocableRollup.Timing.ASYNCHRONOUS),
                InvocableRollup.Timing.SYNCHRONOUS => new ChildRollup(objectType, InvocableRollup.Timing.SYNCHRONOUS)
            });
            this.matchingRollups.put(InvocableRollup.RollupContext.PARENT, new Map<InvocableRollup.Timing, InvocableRollup>{ 
                InvocableRollup.Timing.ASYNCHRONOUS => new ParentRollup(objectType, InvocableRollup.Timing.ASYNCHRONOUS),
                InvocableRollup.Timing.SYNCHRONOUS => new ParentRollup(objectType, InvocableRollup.Timing.SYNCHRONOUS)
            });
        }

        public Container addInput(Input input) {
            RollupContext context = input?.getContext(); 
            Timing timing = input?.getTiming(); 
            this.matchingRollups?.get(context)?.get(timing)?.addInput(input); 
            return this;  
        }

        public void run() {
            for (InvocableRollup job : this.getJobs()) {
                job?.run();
            }
        }

        private List<InvocableRollup>  getJobs() {
            List<InvocableRollup> jobs = new List<InvocableRollup>();
            for (Map<InvocableRollup.Timing, InvocableRollup> jobMap : this.matchingRollups?.values()) {
                jobs.addAll(jobMap?.values());
            }
            return jobs; 
        }
    }

    public class Input {
        @InvocableVariable
        public String timing;

        @InvocableVariable
        public String context; 

        @InvocableVariable
        public SObject record;

        @InvocableVariable
        public List<SObject> records;

        @InvocableVariable
        public Rollup__mdt rollup; 

        @InvocableVariable
        public List<Rollup__mdt> rollups;

        // Note: These variables are necessary to handle single/list types for each
        // Unfortunately, @InvocableVariables do not support { get; set; }
        private List<SObject> allRecords;
        private List<Rollup__mdt> allRollups;

        public RollupContext getContext() {
            return (RollupContext) EnumUtils.valueOf(this?.context, RollupContext.class);
        }

        public SObjectType getSObjectType() {
            SObject record = (SObject) CollectionUtils.getIndexOf(this.getRecords(), 0);
            return record?.getSObjectType();
        }

        public Timing getTiming() {
            return (Timing) EnumUtils.valueOf(this.timing, Timing.class); 
        }

        public List<SObject> getRecords() {
            this.allRecords = (this.allRecords == null) 
                ? this.combineRecordVars(this.records, this.record) 
                : this.allRecords;
            return this.allRecords;
        }

        public List<Rollup__mdt> getRollups() {
            this.allRollups = (this.allRollups == null) 
                ? (List<Rollup__mdt>) this.combineRecordVars(this.rollups, this.rollup)
                : this.allRollups;
            return this.allRollups; 
        }

        private List<SObject> combineRecordVars(List<SObject> recordList, SObject record) {
            Set<SObject> recordSet = (recordList != null) ? new Set<SObject>(recordList) : new Set<SObject>();
            recordSet.add(record);
            recordSet.remove(null);
            return new List<SObject>(recordSet);
        }
    }
}
