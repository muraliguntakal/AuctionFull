@isTest
private class Test_Batchable_FlagAccountsRelObj {

        
    static private string account_personAccountRecordTypeId = '012d0000000t1zAAAQ';
    static private string account_businessRecordTypeId = '012d0000000t0jPAAQ';
        
   static testMethod void mainTest() {
   
   
           //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        // Disable the opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityAccountTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false); 
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false); 
        upsert new TriggerSettings__c(name = 'CountAccountTasks', Status__c = false);  
        upsert new TriggerSettings__c(name = 'ActivityTriggers', Status__c = false);
            
        Account account1 = new Account(name = 'test1', recordTypeId = account_businessRecordTypeId);
        insert account1;
        
        Account account2 = new Account(name = 'test2', recordTypeId = account_businessRecordTypeId);
        insert account2;
        Opportunity op2 = new Opportunity(accountId = account2.id, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today()+ 12);
        insert op2;
        
        Account account3 = new Account(name = 'test3', recordTypeId = account_businessRecordTypeId);
        insert account3;
        Account_Intelligence__c ai = new Account_Intelligence__c(account__c = account3.id);
        insert ai;
        
        Account account4 = new Account(lastname = 'test4', recordTypeId = account_personAccountRecordTypeId);
        insert account4;
         
        Account account5 = new Account(name = 'test5', recordTypeId = account_businessRecordTypeId);
        insert account5;         
        Contact contact1 = new contact(lastname = 'contact 5', accountId = account5.id);
        insert contact1;
        
        Test.startTest();
        Batchable_FlagAccountsRelObj batch = new Batchable_FlagAccountsRelObj();
        Id batchId = Database.executeBatch(batch, 2000);
        Test.stopTest();
        
        Account returnAccount = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Account where id = :account1.id];
        system.assertEquals(-1, returnAccount.HasRelatedObjects__c, 'This account has no related records.');
        system.assertNotEquals(null, returnAccount.HasRelatedObjectsVerified__c);
        
        returnAccount = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Account where id = :account2.id];
        system.assertEquals(1, returnAccount.HasRelatedObjects__c, 'This account should have an opportunity.');
        system.assertNotEquals(null, returnAccount.HasRelatedObjectsVerified__c);
        
        returnAccount = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Account where id = :account3.id];
        system.assertEquals(1, returnAccount.HasRelatedObjects__c, 'This account should have an Account Intelligence record.');
        system.assertNotEquals(null, returnAccount.HasRelatedObjectsVerified__c);
        
        returnAccount = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Account where id = :account4.id];
        system.assertEquals(-1, returnAccount.HasRelatedObjects__c, 'This person-account has no related records.');
        system.assertNotEquals(null, returnAccount.HasRelatedObjectsVerified__c);
        
        returnAccount = [select id, HasRelatedObjects__c, HasRelatedObjectsVerified__c from Account where id = :account5.id];
        system.assertEquals(1, returnAccount.HasRelatedObjects__c, 'This account has a contact.');
        system.assertNotEquals(null, returnAccount.HasRelatedObjectsVerified__c);
        
        
    }
}