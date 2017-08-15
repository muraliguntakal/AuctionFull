@isTest
private class Test_Batchable_MergeContacts {
    private static string STATUS_MASTER = 'Master';
    private static string STATUS_DUP_MLH_ID = 'Duplicate:HasMLHid';  // do not merge
    private static string STATUS_DUP_MERGE = 'Duplicate:Merge';  // should be merged
    private static string testEmail = 'abe@me.com';
    private static string masterSuffix = '-M';
    private static string duplicateSuffix = '-X';

    static testMethod void testBigMerge() {    
    
    
       //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
            
        // Disable the Opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false);

        // Disable the Bid triggers
        upsert new TriggerSettings__c(name = 'BidTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'CreateBidContact', Status__c = false);
        upsert new TriggerSettings__c(name = 'FindWinningBid', Status__c = false);
        upsert new TriggerSettings__c(name = 'BidRegistrationTrigger', Status__c = false);

        integer batchSize = 10;
                       
        Contact master = new Contact(lastname='a smith');
        insert master;
        Contact contactUpdate = new Contact(id = master.id, mergeKey__c = master.id + masterSuffix);
        update contactUpdate;
        
        List<Contact> contacts = new List<Contact>();
        for (integer i=0; i<batchSize ; i++){
            contacts.add(new Contact(lastname = 'a smith', mergeMaster__c = master.id, mergeKey__c = master.id + duplicateSuffix));
        }
        insert contacts;
        
        List<Opportunity> ops = new List<Opportunity>();
        integer i=0;
        for (Contact con : contacts){
            ops.add(new Opportunity(seller__c = con.id, Name = 'Test op ' + i.format(), StageName = 'test stage', CloseDate = Date.today()));
            i++;
        }
        insert ops;

        List<Bidder_Registration__c> reg= new List<Bidder_Registration__c>();
        i=0;
        for (Contact con : contacts){
            reg.add(new Bidder_Registration__c(contact__c = con.id, mlh_Bidder_id__c = '12'));
            i++;
        }
        insert reg;
        system.debug('foo test data created.  Calling Batchable_MergeContacts.');
        
        Test.startTest();
        Batchable_MergeContacts batch = new Batchable_MergeContacts();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        Contact c = [select id, (select seller__c from Opportunities1__r), (select contact__c from Bidder_Registrations__r) from contact where id = :master.id];
        system.assertEquals(batchSize , c.Opportunities1__r.size(), 'All opportunities should be on the master');
        system.assertEquals(batchSize , c.Bidder_Registrations__r.size(), 'All Bidder Registrations should be on the master');
        
        contacts = [select id from contact where mergeMaster__c = :c.id];
        system.assertEquals(0, contacts.size(), 'There should be no duplicate contacts left');
    }
    
    static testMethod void testSmallMerges(){
    
        //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        
        // Disable the Opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false);

        // Disable the Bid triggers
        upsert new TriggerSettings__c(name = 'BidTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'CreateBidContact', Status__c = false);
        upsert new TriggerSettings__c(name = 'FindWinningBid', Status__c = false);
        upsert new TriggerSettings__c(name = 'BidRegistrationTrigger', Status__c = false);
        
                
        // Merge one contact
        Contact master = new Contact(lastname='a smith', title = 'VIP');
        insert master;
        Contact contactUpdate = new Contact(id = master.id, mergeKey__c = master.id + masterSuffix);
        update contactUpdate;
        Contact dup = new Contact(lastname = 'a smith', mergeMaster__c = master.id, mergeKey__c = master.id + duplicateSuffix, 
            Buyer_Contact_Status__c = 'new', title = 'worker bee');
        insert dup;
        Opportunity op = new Opportunity(seller__c = dup.id, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today());
        insert op;

        // Merge two contacts
        Contact master2 = new Contact(lastname='a smith', title = 'VIP');
        insert master2;
        contactUpdate = new Contact(id = master2.id, mergeKey__c = master2.id + masterSuffix);
        update contactUpdate;
        Contact dup1 = new Contact(lastname = 'a smith', mergeMaster__c = master2.id, mergeKey__c = master2.id + duplicateSuffix, 
            Buyer_Contact_Status__c = 'new', title = 'worker bee');
        insert dup1;
        Contact dup2 = new Contact(lastname = 'a smith', mergeMaster__c = master2.id, mergeKey__c = master2.id + duplicateSuffix, 
            Buyer_Contact_Status__c = 'new', title = 'worker bee');
        insert dup2;
        Opportunity op1 = new Opportunity(seller__c = dup1.id, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today());
        insert op1;
        Opportunity op2 = new Opportunity(seller__c = dup1.id, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today());
        insert op2;
        Bidder_Registration__c bidReg = new Bidder_Registration__c(contact__c = dup2.id, mlh_Bidder_id__c = '12');
        insert bidReg;
 
        Test.startTest();
        Batchable_MergeContacts batch = new Batchable_MergeContacts();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // test one contact
        Contact con = [select name, email, Buyer_Contact_Status__c, title, firstname, (select seller__c from Opportunities1__r) from contact where id = :master.id];
        system.assertEquals(1, con.Opportunities1__r.size());
        system.assertEquals('new', con.Buyer_Contact_Status__c, 'From the duplicate.');
        system.assertEquals('VIP', con.title, 'From the master');

        // test two contacts
        con = [select name, firstname, email, Buyer_Contact_Status__c, title, (select seller__c from Opportunities1__r),
            (select contact__c from Bidder_Registrations__r limit 1) from contact where id = :master2.id];
        system.assertEquals(2, con.Opportunities1__r.size());
        system.assertEquals(1, con.Bidder_Registrations__r.size());
        system.assertEquals('new', con.Buyer_Contact_Status__c, 'From the duplicate.');
        system.assertEquals('VIP', con.title, 'From the master');

     
    }
}