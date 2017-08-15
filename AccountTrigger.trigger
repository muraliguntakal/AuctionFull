trigger AccountTrigger on Account (After Insert, After Update, Before Insert, Before Update) {
//if(TriggerSettings__c.getValues('AccountTrigger').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('AccountTrigger');
  if (ts != null && ts.Status__c) {

if (!AccountTriggerHelperClass.hasAlreadyfired()) {

    AccountTriggerHelper AccTr = new AccountTriggerHelper(); 

   if(Trigger.isupdate && Trigger.isafter) {
            AccTr.AccountToContactUpdate(Trigger.NewMap, Trigger.OldMap);
      }  
    //************************************* Set Trigger lock to TRUE   ***************************************************//
    AccountTriggerHelperClass.setAlreadyfired();              

  } 
  
     AccountBeforeTriggerHelper AccBeTr = new AccountBeforeTriggerHelper(); 
      
     if((Trigger.isinsert || Trigger.isupdate) && Trigger.isbefore) {
            AccBeTr.legoTeamName(Trigger.new, Trigger.NewMap, Trigger.OldMap, Trigger.isInsert, Trigger.isUpdate);
      } 
 }    
}