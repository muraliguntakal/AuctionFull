@isTest
private class Test_BatchableFlagContactsRelObj_2 {

   static testMethod void mainTest() {
       
       
               //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        // Disable the opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false); 
        upsert new TriggerSettings__c(name = 'CountContactTasks', Status__c = false);  
        upsert new TriggerSettings__c(name = 'ActivityTriggers', Status__c = false);   
        upsert new TriggerSettings__c(name = 'CallrecordTrigger', Status__c = false);  
            
        Account acct = new Account(name = 'test account');
        insert acct;
        Contact con1 = new Contact(accountID = acct.id, lastname = 'test1');
        insert con1;
        
        Contact con2 = new Contact(accountID = acct.id, lastname = 'test2');
        insert con2;
        Note note1 = new Note(parentId = con2.id, title='test note');
        insert note1;
        
        Contact returnContact = [select id, (select parentId from Notes) from Contact where id = :con2.id];
        Contact con3 = new Contact(accountID = acct.id, lastname = 'test2', email ='assetconsideration@auction.com');
        insert con3;

        CallRecord__c call = new CallRecord__c(contact__c = con3.id);
        insert call;
        
        Test.startTest();
        BatchableFlagContactsRelObj_2 batch = new BatchableFlagContactsRelObj_2(acct.id);
        Id batchId = Database.executeBatch(batch, 2000);
        Test.stopTest();
        
        Contact con = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Contact where id = :con1.id];
        if (con.HasRelatedObjects__c == 0) con.HasRelatedObjects__c = null;
        system.assertEquals(null, con.HasRelatedObjects__c, 'This contact has no activities so no update to this record should occur in this Stage 2 class.');
        system.assertEquals(null, con.HasRelatedObjectsVerified__c, 'This stage 2 class should have skipped it.');
/*        
        con = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Contact where id = :con2.id];
        system.assertEquals(1, con.HasRelatedObjects__c, 'This contact should have a note.');
        system.assertNotEquals(null, con.HasRelatedObjectsVerified__c);
        
        con = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Contact where id = :con3.id];
        system.assertEquals(1, con.HasRelatedObjects__c, 'This contact should have a call record.');
        system.assertNotEquals(null, con.HasRelatedObjectsVerified__c);
*/        
        
    }
}