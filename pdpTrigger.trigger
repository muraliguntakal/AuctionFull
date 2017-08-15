trigger pdpTrigger on PDP__c (before Insert, after Insert) {
  TriggerSettings__c ts = TriggerSettings__c.getValues('pdpTrigger');
    if (ts != null && ts.Status__c) {

    pdpTriggerHelper pdpHelper = new pdpTriggerHelper();
    
    if(Trigger.isinsert && Trigger.isbefore) {
            pdpHelper.linkRelatedRecords(Trigger.new);
    }
     if(Trigger.isinsert && Trigger.isafter) {
            pdpHelper.AssociateCrePDPContacttoCampaign(Trigger.new);   
    }     
  }  
}