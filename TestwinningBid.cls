@isTest()
public class TestwinningBid {
static testmethod void validatewinningBid () {

        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();

      Account acc = new Account(Name='Test 1'); 
      insert acc;
        

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Pre-Auction';
        opp.CloseDate = system.today();
            Test.Starttest();
            insert opp;
            Test.Stoptest();
            
       Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c();
       insert aoa;
            
            Bid__c bd = new Bid__c();
            bd.Bid_Amount__c = 10000;
            bd.Winning_Bid__c = true;
            bd.Opportunity__c = opp.Id;
            bd.MLH_Bid_Stage__c = 'Contract Complete';
            bd.Auction_Opportunity_Assignment__c = aoa.Id;
            bd.MLH_Asset_ID__c = '12345';
            bd.Bid_Amount__c  = 1000;
            bd.MLH_Auction_ID__c = '456787';
            bd.MLH_Bidder_ID__c = '123489';
            insert bd;
            
       
       aoa.MLH_Winning_Bidder_ID__c = '123489';
       aoa.MLH_Auction_ID__c = '456787';
       aoa.MLH_Final_Sale_Price__c = 1000;
       aoa.MLH_Property_Id__c = '12345';
       Update aoa;
            

        
        }
     }