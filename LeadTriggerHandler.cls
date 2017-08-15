public with sharing class LeadTriggerHandler {
 
    public void AddLeadsToCampaign(List<Lead> leadList) {
       List<CampaignMember> CampaignMembersCRE = new List<CampaignMember>();    
       for (Lead ld : leadList) {
           if(ld.Lead_Source_Filename__c != null) { 
		   	   if(ld.Lead_Source_Filename__c.length() <=38) { 	
	               if(SystemSettings__c.getValues(ld.Lead_Source_Filename__c)!=null) {
	                  CampaignMember cm = new CampaignMember(CampaignId = SystemSettings__c.getValues(ld.Lead_Source_Filename__c).Value__c, 
	                                                         LeadId=ld.Id
	                                                        );
	                  CampaignMembersCRE.add(cm); 
	               }
		   	   }	
           }
       } 
       Insert CampaignMembersCRE;
    } 
   
    @future
    public static void setLeadDMLOptions(Set<Id> leadSet)
    {
       List<Lead> LeadList = new List<Lead>([SELECT Id,IsConverted,CreatedById FROM Lead WHERE Id IN :leadSet]);  
       List<Lead> Leads = new List<Lead>(); 
       for (Lead ld : LeadList) {        
          if(!ld.IsConverted && CONSTANTS.apiUsers.contains(ld.CreatedById)) { 
           Database.DMLOptions dmo = new Database.DMLOptions();
           dmo.assignmentRuleHeader.useDefaultRule = true;
           dmo.EmailHeader.triggerAutoResponseEmail  = true;
           dmo.EmailHeader.triggerUserEmail  = true;
           ld.setOptions(dmo);                         
           Leads.add(ld); 
          }
       }
       if(Leads.size() > 0) 
           database.Update(Leads);
    }
}