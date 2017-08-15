@isTest
private class Test_BatchableFlagContactsRelObj {

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
        upsert new TriggerSettings__c(name = 'VaultActivityTriggers', Status__c = false);  
            
        Account acct = new Account(name = 'test account');
        insert acct;
        Contact con1 = new Contact(accountID = acct.id, lastname = 'test1');
        insert con1;
        Contact con2 = new Contact(accountID = acct.id, lastname = 'test2');
        insert con2;
        Opportunity op2 = new Opportunity(seller__c = con2.id, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today()+ 12);
        insert op2;
        Contact con3 = new Contact(accountID = acct.id, lastname = 'test2', email ='assetconsideration@auction.com');
        insert con3;
        Task task3 = new Task(whoId = con3.id, whatId = op2.id, Subject = 'test', Type='test', priority= 'Low', 
                            status = 'Not Started',description = 'test Description');
        insert task3;
        
        Test.startTest();
        BatchableFlagContactsRelObj batch = new BatchableFlagContactsRelObj(acct.id);
        Id batchId = Database.executeBatch(batch, 2000);
        Test.stopTest();
        
        Contact con = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Contact where id = :con1.id];
        system.assertEquals(-1, con.HasRelatedObjects__c, 'This contact has no activities.');
        system.assertNotEquals(null, con.HasRelatedObjectsVerified__c);
        
        con = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Contact where id = :con2.id];
        system.assertEquals(1, con.HasRelatedObjects__c, 'This contact should have an opportunity.');
        system.assertNotEquals(null, con.HasRelatedObjectsVerified__c);
        
        con = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Contact where id = :con3.id];
        system.assertEquals(1, con.HasRelatedObjects__c, 'This contact should have a task.');
        system.assertNotEquals(null, con.HasRelatedObjectsVerified__c);
        
        
    }
}