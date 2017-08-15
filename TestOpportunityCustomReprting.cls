@isTest()
public class TestOpportunityCustomReprting{
static testmethod void validateOpportunityTriggerHelper() {

TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();

      Account acc = new Account(Name='Test 1'); 
      insert acc;  
       
        Auction_Campaign__c au = new Auction_Campaign__c();
        au.Auction_Name__c = 'Auc-0000001';
        au.Open_House_1_Date__c = date.parse('1/2/2014');
        au.Open_House_2_Date__c = date.parse('1/16/2014');
        au.Open_House_3_Date__c = date.parse('1/25/2014');
        insert au;
                          
        Opportunity Parentopp = new Opportunity();
        Parentopp.Name = 'Test Parent Opportunity';
        Parentopp.AccountId = acc.Id;
        Parentopp.StageName = Label.Opportunity_Stage3;
        Parentopp.CloseDate = system.today();     
        Parentopp.RecordTypeId = '012d0000000T0yk';
        insert Parentopp;
        
        Opportunity Childopp = new Opportunity();
        Childopp.Name = 'Test Opportunity';
        Childopp.AccountId = acc.Id;
        Childopp.StageName = Label.Opportunity_Stage3;
        Childopp.CloseDate = system.today();
        Childopp.Parent_Opportunity__c = Parentopp.Id;
        Childopp.RecordTypeId = '012d0000000t0iC';       
        insert Childopp;  
        
        Custom_Reporting__c custopp = new Custom_Reporting__c();
        custopp.Opportunity__c = Childopp.Id; 
         insert custopp;
                
        Parentopp.Sourced_by_Broker_Channel_Rep__c = true;
        update Parentopp;  
        
}

}