public with sharing class ContactCampController {
     
  public List<CampaignMember> con {get;set;}
  
      public ContactCampController (ApexPages.StandardController controller) {
         getCampaignMember();                   
      }
  
    public Void getCampaignMember() {          
      con = [select Id, FirstName, LastName, ContactId, CampaignId, Status from CampaignMember where ContactId = :ApexPages.currentPage().getParameters().get('id') limit 1000];                    
  }   
}