@isTest()
public class TestOpportunityTriggerHelper {
static testmethod void validateOpportunityTriggerHelper() {

TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();

      Account acc = new Account(Name='Test 1'); 
      insert acc;


       Asset__c As1 = new Asset__c( MLH_Global_Property_ID__c='144123' ,Property_Street__c='1 Technology Dr',Property_City__c='Irvine' ,Property_State__c='CA',Property_Zip_Postal_Code__c='92612');
       insert As1;      
       
        Auction_Campaign__c au = new Auction_Campaign__c();
        au.Auction_Name__c = 'Auc-0000001';
        au.Open_House_1_Date__c = date.parse('1/2/2014');
        au.Open_House_2_Date__c = date.parse('1/16/2014');
        au.Open_House_3_Date__c = date.parse('1/25/2014');
        insert au;
            
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = Label.Opportunity_Stage3;
        opp.CloseDate = system.today();
        opp.Property_Street__c = '12 Technology Dr';
        opp.Property_Zip_Postal_Code__c = '92610';
        opp.Initial_Auction__c = au.Id;
        opp.Created_From_Lead__c = 1;
        opp.RecordTypeId = '012d0000000t0iC';       
        insert opp;     
               
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
        Childopp.Property_Street__c = '1 Technology Dr';
        Childopp.Property_Zip_Postal_Code__c = '92612';
        Childopp.Parent_Opportunity__c = Parentopp.Id;
        Childopp.Created_From_Lead__c = 1;
        Childopp.RecordTypeId = '012d0000000t0iC';       
        insert Childopp;     
 
        TriggerHelperClass.ResetAlreadyfired();  
        
        Childopp.StageName = Label.Opportunity_Stage6;
        update Childopp;

  
        
}

}