public class AssignDGR {
    //Apex properties or variables

    public Id DGROwner {get; set;}
    public Id CampaignId { get; set; }
    public Campaign cap { get; set; }

    //constructor to get the Campaign record
    public AssignDGR(ApexPages.StandardController controller) {
     cap =  (Campaign) controller.getRecord();
     CampaignId = cap.Id;
     DGROwner = cap.DGR_Assigned_Rep__c;
    }

    //Method that can is called from the Visual Force page action attribute
    public PageReference DGRAssignment() {

      List<CampaignMember>  CampaignMemberList = new List<CampaignMember>();
      CampaignMemberList = [Select Id,ContactId,LeadId,Type from CampaignMember where CampaignId =: CampaignId];
          
      Set<Id> ConIds = new Set<Id>();
      Set<Id> LedIds = new Set<Id>();
        if(!CampaignMemberList.isEmpty()){  
              for(CampaignMember Camps: CampaignMemberList){
                  if(Camps.Type == 'Contact'){
                      ConIds.add(Camps.ContactId);
                  }
                  else if(Camps.Type == 'Lead'){
                      LedIds.add(Camps.LeadId);
                  }    
              }
          }  
   
      List<Contact> consList = new List<Contact>([Select Id,OwnerId from Contact where Id IN: ConIds]);
      List<Lead> ledsList = new List<Lead>([Select Id,OwnerId from Lead where Id IN: LedIds]);
      
 /*   if(!consList.isEmpty()){
      for(Contact Cons: consList){
          Cons.OwnerId = DGROwner;
        }
      }  
        
     if(!ledsList.isEmpty()){
      for(Lead Leds: ledsList){
          Leds.OwnerId = DGROwner;
        }
      }  */
      
      
      if(!consList.isEmpty()){
         update consList;
      }
      
      if(!ledsList.isEmpty()){
         update ledsList;
      }
        PageReference pageRef = new PageReference('/'+CampaignId);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the Campaign page
    }
}