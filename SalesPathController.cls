public with sharing class SalesPathController {
     
  public Opportunity  Oppty {get;set;}
   
      public SalesPathController(ApexPages.StandardController Controller) {   
         getOpportunity();                   
      }
  
    public Opportunity getOpportunity() {   
    
    System.Debug('Opp Id-->' +ApexPages.currentPage().getParameters().get('id'));
           
    Oppty = [select Id,Owner.Name,
            stageName,
            LeadSource,
            Type_of_Sale__c,
            Auction_End_Date__c,
            amount,
            closedate,
            GMV__c,
            Most_Recent_Auction__c,
            Lead_Development_Rep__c,
            Analyst__c,
            Broker_Channel_Rep__c,
            CRE_or_Notes__c,
            CRE_Category_O__c,
            CRE_Sub_Category_O__c,
            Brokered_By__c,
            Broker_Agent__c,
            Sourced_by_Broker__c,
            Referring_Broker_Name__c,
            Seller__c,
            Broker_Promo__c,
            Property_Street__c,
            Property_City__c,
            Property_State__c,
            Property_Zip_Postal_Code__c,
            Property_Country__c,
            Property_Type__c,
            Seller_Requested_Reserve__c,
            Property_Reserve_Price__c,
            Winning_Bid_Amount__c,
            Broker_Ranking__c,
            Highest_Bid__c,
            Broker_Ranking_Notes__c,
            Reason_Won_Lost__c,
            Prev_Current_Stage__c,
            Reason_Won_Lost_Comments__c from Opportunity where id = :ApexPages.currentPage().getParameters().get('id')];   
            
           return Oppty;     
                               
  }

  public PageReference dosave() {
    try{
        update Oppty;
       }
    catch(DmlException ex){
        ApexPages.addMessages(ex);
       }
    return null;
  }
     

}