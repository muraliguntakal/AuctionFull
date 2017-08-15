trigger OpportunityTriggerBeforeUpdate on Opportunity (before update) {
      TriggerSettings__c ts = TriggerSettings__c.getValues('OpportunityTriggerBeforeUpdate');
      if (ts != null && ts.Status__c) {
      
       String user_id = UserInfo.getUserName();
        
        system.debug('User Id---->' +user_id);
        for(Opportunity opp : trigger.new) {            
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);                         
                if(opp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && opp.StageName == 'Stage 5. Auction' && user_id == 'integrationuser@auction.com') {    
                                         
                       opp.StageName  = oldOpp.StageName;          
                                       
                }            
            }           
 }
 }