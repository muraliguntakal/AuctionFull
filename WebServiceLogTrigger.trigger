trigger WebServiceLogTrigger on Webservice_Log__c (after insert) {
   // if(TriggerSettings__c.getValues('WebServiceLogTrigger').Status__c) { 
      TriggerSettings__c ts = TriggerSettings__c.getValues('WebServiceLogTrigger');
      if (ts != null && ts.Status__c) {

        Set<Id> IdsSet = new Set<Id>(); 
        List<String> allIdsList = new List<String>();
        system.debug('WebService Log :' +trigger.new);
        for(Webservice_Log__c wsl : trigger.new) {
            if(wsl.Status__c=='Failed') {
                List<String> IdsList = new List<String>();
                String IdsCommas = wsl.whatIds__c.substring(1, wsl.whatIds__c.length()-1);                 
                IdsList = IdsCommas.split(',');
                for(String s : IdsList) {
                    s=s.trim();
                    IdsSet.add(Id.valueOf(s));
                }
            }
        }    
    
        Map<Id,CallRecord__c> oldCallRecords = new Map<Id,CallRecord__c>([SELECT Id,Bid__c,Calldisposition__c,Call_Status__c,Contact__c,CreatedById,CreatedDate,Created_By_Batch__c,Failed__c,FollowupTime__c,Notes__c,Opportunity__c,OwnerId,Winning_Bid_Call__c 
                                                                          FROM CallRecord__c
                                                                          WHERE Id IN :IdsSet AND Calldisposition__c!='Completed Information']);  
    
        system.debug('Ids Set  : ' +oldCallRecords);
            
        if(!oldCallRecords.isEmpty()) {
            List<CallRecord__c> newCallRecords = oldCallRecords.values().deepClone(); 
            for(CallRecord__c cr : newCallRecords) {
                cr.Created_By_Batch__c = true;
                cr.Retry__c=true;               
            }
            Boolean success = true; 
            try {
                Insert newCallRecords;        
            } catch(DmlException e) {
                success=false;
                System.debug('The following exception has occurred: ' + e.getMessage());
            }      
            
            for(CallRecord__c  cr : oldCallRecords.values()) {
                cr.Failed__c = true; 
            }
            Update oldCallRecords.values();         

        }
    }
}