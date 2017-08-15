trigger OpportunitySplitTrigger on OpportunitySplit (before insert, before update) {
//if(TriggerSettings__c.getValues('OpportunitySplitTrigger').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('OpportunitySplitTrigger');
  if (ts != null && ts.Status__c) {

    
        for (OpportunitySplit oppsp: Trigger.New) {    
            oppsp.Opportunity_Name__c = oppsp.OpportunityId;               
        }    
  } 
 }