@isTest(SeeAllData=true)
public class TestOpportunityUpdate {
static testmethod void OpportunityUpdate () {

 User u3 = [SELECT Id FROM User WHERE UserName='integrationuser@auction.com'];

   System.runAs(u3) {
         
        Opportunity Childopp = new Opportunity();
        Childopp.Name = 'Test Opportunity';
        Childopp.StageName = Label.Opportunity_Stage3;
        Childopp.CloseDate = system.today();
        Childopp.RecordTypeId = '012d0000000t0iC';       
        insert Childopp;     
 
        TriggerHelperClass.ResetAlreadyfired();  
        
        Childopp.StageName = 'Stage 5. Auction';
        update Childopp;
    }    
  }
}