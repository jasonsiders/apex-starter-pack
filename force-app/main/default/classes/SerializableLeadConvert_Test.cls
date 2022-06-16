@IsTest
private class SerializableLeadConvert_Test {
    @IsTest 
    static void shouldConstructLeadConvertObject() {
        DatabaseLayer.setDmlEngine(new DmlMock());
        Lead testLead = new Lead(); 
        DatabaseLayer.DmlEngine.doInsert(testLead);
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(testLead.Id);

        // Convert to a wrapper - should be equivalent
        SerializableLeadConvert wrapper = new SerializableLeadConvert(leadConvert);
        System.assertEquals(leadConvert.getAccountId(), wrapper.accountId, 'Wrong getAccountId()');
        System.assertEquals(leadConvert.getContactId(), wrapper.contactId, 'Wrong getContactId()');
        System.assertEquals(leadConvert.getConvertedStatus(), wrapper.convertedStatus, 'Wrong getConvertedStatus()');
        System.assertEquals(leadConvert.getLeadId(), wrapper.leadId, 'Wrong getLeadId()');
        System.assertEquals(leadConvert.getOpportunityName(), wrapper.opportunityName, 'Wrong getOpportunityName()');
        System.assertEquals(leadConvert.getOwnerId(), wrapper.ownerId, 'Wrong getOwnerId()');
        System.assertEquals(leadConvert.getRelatedPersonAccountId(), wrapper.personAccount?.Id, 'Wrong getContactId()');
        System.assertEquals(leadConvert.getRelatedPersonAccountRecord(), wrapper.personAccount, 'Wrong getRelatedPersonAccountRecord()');
        System.assertEquals(leadConvert.isDoNotCreateOpportunity(), wrapper.doNotCreateOpportunity, 'Wrong isDoNotCreateOpportunity()');
        System.assertEquals(leadConvert.isOverwriteLeadSource(), wrapper.overwriteLeadSource, 'Wrong isOverwriteLeadSource()');
        System.assertEquals(leadConvert.isSendNotificationEmail(), wrapper.sendNotificationEmail, 'Wrong isSendNotificationEmail()');

        // Now convert back to a lead convert - should be same values as before!
        Database.LeadConvert unwrapped = wrapper.toLeadConvert(); 
        System.assertEquals(leadConvert.getAccountId(), unwrapped.getAccountId(), 'Wrong getAccountId()');
        System.assertEquals(leadConvert.getContactId(), unwrapped.getContactId(), 'Wrong getContactId()');
        System.assertEquals(leadConvert.getConvertedStatus(), unwrapped.getConvertedStatus(), 'Wrong getConvertedStatus()');
        System.assertEquals(leadConvert.getLeadId(), unwrapped.getLeadId(), 'Wrong getLeadId()');
        System.assertEquals(leadConvert.getOpportunityName(), unwrapped.getOpportunityName(), 'Wrong getOpportunityName()');
        System.assertEquals(leadConvert.getOwnerId(), unwrapped.getOwnerId(), 'Wrong getOwnerId()');
        System.assertEquals(leadConvert.getRelatedPersonAccountId(), unwrapped.getRelatedPersonAccountId(), 'Wrong getContactId()');
        System.assertEquals(leadConvert.getRelatedPersonAccountRecord(), unwrapped.getRelatedPersonAccountRecord(), 'Wrong getRelatedPersonAccountRecord()');
        System.assertEquals(leadConvert.isDoNotCreateOpportunity(), unwrapped.isDoNotCreateOpportunity(), 'Wrong isDoNotCreateOpportunity()');
        System.assertEquals(leadConvert.isOverwriteLeadSource(), unwrapped.isOverwriteLeadSource(), 'Wrong isOverwriteLeadSource()');
        System.assertEquals(leadConvert.isSendNotificationEmail(), unwrapped.isSendNotificationEmail(), 'Wrong isSendNotificationEmail()');
    }

    @IsTest 
    static void shouldWrapMultipeLeadConvertObjects() {
        Integer randomNum = Integer.valueOf(Math.random() * 10) + 1;
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>(); 
        for (Integer i = 0; i < randomNum; i++) {
            leadConverts.add(new Database.LeadConvert());
        }

        // Convert from List<Database.LeadConvert> => List<SerializableLeadConvert>
        List<SerializableLeadConvert> wrappers = SerializableLeadConvert.wrap(leadConverts);
        System.assertEquals(leadConverts?.size(), wrappers?.size(), 'Wrong # of wrapped SerializableLeadConvert objects');
        // Convert back to List<Database.LeadConvert>
        List<Database.LeadConvert> unwrapped = SerializableLeadConvert.unwrap(wrappers); 
        System.assertEquals(leadConverts?.size(), unwrapped?.size(), 'Wrong # of unwrapped Database.LeadConvert objects');
    }

    @IsTest 
    static void shouldAllowAsyncLeadConvert() {
        Lead testLead = new Lead(
            Company = 'Acme Inc.',
            Email = 'john.doe@test.com.invalid',
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '+15555555555'
        );
        DatabaseLayer.DmlEngine.doInsert(testLead); 
        Soql statusQuery = DatabaseLayer.QueryEngine.newQuery(LeadStatus.SObjectType)
            .selectFields(LeadStatus.MasterLabel)
            .whereFilters(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
            .setRowLimit(1);
        String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
        Database.LeadConvert leadConvertObj = new Database.LeadConvert();
        leadConvertObj.setLeadId(testLead.Id); 
        leadConvertObj.setConvertedStatus(status);

        Test.startTest(); 
        try {
            System.enqueueJob(new GoodAsyncJob(leadConvertObj)); 
        } catch (System.SerializationException thrownError) {
            System.assert(false, 'An error was thrown: ' + thrownError); 
        }
        Test.stopTest(); 

        Soql query = DatabaseLayer.QueryEngine.newQuery(Lead.SObjectType)
            .whereFilters(new Filter(Lead.IsConverted, Filter.EQUALS, true));
        Map<Id, Lead> convertedLeads = new Map<Id, Lead>((List<Lead>) query.run()); 
        System.assertEquals(true, convertedLeads.containsKey(testLead.Id), 'Lead was not converted'); 
    }

    @IsTest 
    static void shouldNotAllowAsyncLeadConvert() {
        Lead testLead = new Lead(
            Company = 'Acme Inc.',
            Email = 'john.doe@test.com.invalid',
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '+15555555555'
        );
        DatabaseLayer.DmlEngine.doInsert(testLead); 
        Soql statusQuery = DatabaseLayer.QueryEngine.newQuery(LeadStatus.SObjectType)
            .selectFields(LeadStatus.MasterLabel)
            .whereFilters(new Filter(LeadStatus.IsConverted, Filter.EQUALS, true))
            .setRowLimit(1);
        String status = ((LeadStatus) statusQuery.run()[0]).MasterLabel;
        Database.LeadConvert leadConvertObj = new Database.LeadConvert();
        leadConvertObj.setLeadId(testLead.Id); 
        leadConvertObj.setConvertedStatus(status);

        Test.startTest(); 
        Exception caughtError;
        try {
            System.enqueueJob(new BadAsyncJob(leadConvertObj)); 
        } catch (System.SerializationException thrownError) {
            caughtError = thrownError; 
        }
        Test.stopTest(); 

        System.assertNotEquals(null, caughtError, 'A System.SerializationException was not thrown for the Database.LeadConvert object'); 
    }

    // **** INNER **** // 
    public class BadAsyncJob implements System.Queueable {
        // This job will always fail, since Queueable serializes all members
        // And the Database.LeadConvert "leadConvert" property is not allowed to be serialized
        Database.LeadConvert leadConvert;
        
        public BadAsyncJob(Database.LeadConvert leadConvert) {
            this.leadConvert = leadConvert; 
        }

        public void execute(System.QueueableContext context) {
            DatabaseLayer.DmlEngine.doConvert(this.leadConvert); 
        }
    }

    public class GoodAsyncJob implements System.Queueable {
        SerializableLeadConvert convertObj;

        public GoodAsyncJob(Database.LeadConvert leadConvert) {
            this.convertObj = new SerializableLeadConvert(leadConvert);
        }

        public void execute(System.QueueableContext context) {
            Database.LeadConvert leadConvert = this.convertObj.toLeadConvert(); 
            DatabaseLayer.DmlEngine.doConvert(leadConvert); 
        }
    }
}