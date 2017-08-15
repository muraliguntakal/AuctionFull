trigger LeadTrigger on Lead (before insert,after update) {
   // if(TriggerSettings__c.getValues('LeadConversionTrigger').Status__c){
      TriggerSettings__c ts = TriggerSettings__c.getValues('LeadConversionTrigger');
      if (ts != null && ts.Status__c) {

       if (!LeadTriggerHelperClass.hasAlreadyfired()) {        

            LeadConversionTrigger lct = new LeadConversionTrigger();
   
            if(Trigger.isInsert && Trigger.isBefore) {
                lct.getAuctionDetails(Trigger.new);
            }         
            if(Trigger.isUpdate && Trigger.isAfter)
                lct.CreateConversionInfo(trigger.new,Trigger.isBefore);        
        }
        LeadTriggerHelperClass.setAlreadyfired();       
    }
}