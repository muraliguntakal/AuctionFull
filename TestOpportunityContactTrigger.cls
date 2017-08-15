@isTest(SeeAllData=true)
public class TestOpportunityContactTrigger 
{

     public static testMethod void OpportunityContactTrigger()
     {
        Account acct = new Account(Name='Test 1'); 
        insert acct;
       
          Contact con1 = TestDataProvider.NewContact();
          con1.AccountId = acct.Id;
          con1.Email='testsfdc@auction.com';
          Insert con1;

          Contact con2= TestDataProvider.NewContact();
          con2.AccountId = acct.Id;
          con2.Email='assetconsideration@auction.com';
          Insert con2;
          
          
          Contact con3= TestDataProvider.NewContact();
          con2.AccountId = acct.Id;
          con2.Email='assetconsideration@auction.com';
          Insert con3;
          
          Contact con4= TestDataProvider.NewContact();
          con2.AccountId = acct.Id;
          con2.Email='assetconsideration@auction.com';
          Insert con4;
        
        //Parent Opportunity        
        Opportunity oppParent = new Opportunity();
        oppParent.Name = 'Opportunity Parent';
        oppParent.StageName = Label.Opportunity_Stage2;
        oppParent.CloseDate = system.today();
        oppParent.Broker_Agent__c = con1.Id;
        oppParent.Seller__c = con2.Id;
        oppParent.Referring_Broker_Name__c = con3.Id;
        oppParent.RecordTypeId = Label.Parent_Opportunity;  
        insert oppParent;
        
        TriggerHelperClass.ResetAlreadyfired();   
 
        oppParent.Seller__c = con4.Id;
        update oppParent;
      
        
        
        
        
        
   }
}