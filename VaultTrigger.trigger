trigger VaultTrigger on Vault__c (After Insert, After Update) {
//if(TriggerSettings__c.getValues('VaultTrigger').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('VaultTrigger');
  if (ts != null && ts.Status__c) {

   VaultTriggerHelper valthelper = new VaultTriggerHelper();

         if((Trigger.isinsert || Trigger.isupdate) && Trigger.isafter) {
            valthelper.CreateActivityCallLog(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);   
         }      
 }
}