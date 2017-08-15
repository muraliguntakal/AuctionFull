trigger CreateBidContact on Bidder_Registration__c (before insert, after insert, before update, after update, after delete) {
    //if(TriggerSettings__c.getValues('CreateBidContact').Status__c) {
      TriggerSettings__c ts = TriggerSettings__c.getValues('CreateBidContact');
      if (ts != null && ts.Status__c) {

        BidRegistrationTriggerHelper brh= new BidRegistrationTriggerHelper();

        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
            brh.UpsertBidderRegContact(Trigger.New);
        }

        if(Trigger.isInsert && Trigger.isAfter) {
            brh.CreateNewCaseforNewContact(Trigger.New);
        }        

        if((Trigger.isinsert || Trigger.isupdate || Trigger.isdelete) && Trigger.isafter) {
            brh.BidRegistrationRollUp(trigger.new, trigger.old, trigger.isdelete);
        }   

        if(Trigger.isUpdate && Trigger.isafter) {  
            brh.BidUpdateContactPhone(trigger.new, trigger.oldMap);
        } 
    }   
}