trigger UpdateOpportunity on Task (after insert) {

    //ContactId of Asset Consideration in Production/Full Sandbox. Querying contact will be other alternative to get cIds.
    Set<Id> cIds = new Set<Id>{'003d000001Wc8IP','003J000000k8Bg3IAE'};
    List<Contact> assetconsiderationContact = [Select Id from Contact WHERE Email='assetconsideration@auction.com']; 
    for(Contact c : assetconsiderationContact){
        //cIds.add(assetconsiderationContact.Id); 
        cIds.add(c.Id); 
    }

    //Check if Email is Sent to Asset Consideration and check if Email is related to Opportunity.    
    Set<Id> OppIds = new Set<Id>(); 
    for(task t : trigger.new) {
		if(t.WhoId!=null && t.Type!= null && t.WhatId!=null) {
	        if(cIds.contains(t.WhoId) && t.type=='Email'  && String.valueof(t.WhatId).startsWith('006')) {
	            oppIds.add(t.WhatId);            
	        }
		}
    }

    //Get the Opportunities for which Email is to Asset Consideration and Sent_to_Asset_Consideration__c is not yet set.        
    List<Opportunity> selectedOppsList = new List<Opportunity>([SELECT Id,Sent_to_Asset_Consideration__c FROM Opportunity WHERE Id IN :OppIds AND Sent_to_Asset_Consideration__c!=TRUE]);         
    List<Opportunity> updateOppsList = new List<Opportunity>();

    //Set Sent_to_Asset_Consideration__c flag to true for selected Opportunities 
    if(selectedOppsList.size() > 0) {
        for(Opportunity opp : selectedOppsList) {
           opp.Sent_to_Asset_Consideration__c =true;        
           updateOppsList.add(opp);  
        }
    }

    //Update selected Opportunities
    if(updateOppsList.size() > 0)
        Update updateOppsList;    
}