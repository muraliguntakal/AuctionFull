@isTest
private class Test_Batchable_Flag_AOA_Ops {

    static testMethod void testUpdate() {
    
    
            //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        // Disable the Opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false); 
        upsert new TriggerSettings__c(name = 'InsertUpdateOptyId', Status__c = false); 
        
        // Disable AOA triggers
        upsert new TriggerSettings__c(name = 'AOATrigger', Status__c = false); 
        
        
        Account acct = new Account(name = 'test account');
        insert acct;    

        Opportunity op1 = new Opportunity(accountId = acct.Id, Name = 'Test op 1', StageName = 'test stage', CloseDate = Date.today()+ 12);
        insert op1;
        Opportunity op2 = new Opportunity(accountId = acct.Id, HasAOA_records__c = 1, Name = 'Test op 2', StageName = 'test stage', CloseDate = Date.today()+ 12);
        insert op2;
        Opportunity op3 = new Opportunity(accountId = acct.Id, HasAOA_records__c = 1, Name = 'Test op 3', StageName = 'test stage', CloseDate = Date.today()+ 12);
        insert op3;
        Opportunity op4 = new Opportunity(accountId = acct.Id, HasAOA_records__c = -1, Name = 'Test op 4', StageName = 'test stage', CloseDate = Date.today()+ 12);
        insert op4;
        
        Auction_Opportunity_Assignment__c AOA1 = new Auction_Opportunity_Assignment__c(opportunity__c = op3.id);
        insert AOA1;
        
        Auction_Opportunity_Assignment__c AOA2 = new Auction_Opportunity_Assignment__c(opportunity__c = op4.id);
        insert AOA2;
       
        Test.startTest();
        Batchable_Flag_AOA_Ops bat = new Batchable_Flag_AOA_Ops();
        Id batchId = Database.executeBatch(bat, 2000);
        Test.stopTest();
        
        Opportunity returnOp = [select HasAOA_records__c from Opportunity where id = :op1.id limit 1];
      //  system.assertEquals(-1, returnOp.HasAOA_records__c);
        
        returnOp = [select HasAOA_records__c from Opportunity where id = :op2.id limit 1];
        //system.assertEquals(-1, returnOp.HasAOA_records__c);
        
        returnOp = [select HasAOA_records__c from Opportunity where id = :op3.id limit 1];
        system.assertEquals(1, returnOp.HasAOA_records__c);
        
        returnOp = [select HasAOA_records__c from Opportunity where id = :op4.id limit 1];
      //  system.assertEquals(null, returnOp.HasAOA_records__c);
    }
}