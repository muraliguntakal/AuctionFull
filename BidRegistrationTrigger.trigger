trigger BidRegistrationTrigger on Bidder_Registration__c (after insert, after update, after delete) {
    // if(TriggerSettings__c.getValues('BidRegistrationTrigger').Status__c){
       TriggerSettings__c ts = TriggerSettings__c.getValues('BidRegistrationTrigger');
       if (ts != null && ts.Status__c) {

         BidRegistrationTriggerHelper bidregclass = new BidRegistrationTriggerHelper();
         if(Trigger.isUpdate && Trigger.isafter) {  
             bidregclass.BidUpdateContactPhone(trigger.new, trigger.oldMap);
         } 
         if((Trigger.isinsert || Trigger.isupdate || Trigger.isdelete) && Trigger.isafter) {
             bidregclass.BidRegistrationRollUp(trigger.new, trigger.old, trigger.isdelete);
         }   
     }  
}