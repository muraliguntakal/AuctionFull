trigger ContactTrigger on Contact (before insert, before update) {
//if(TriggerSettings__c.getValues('ContactTrigger').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('ContactTrigger');
  if (ts != null && ts.Status__c) {


    for(Contact c : trigger.new) {
        if(c.VIP_Client_Rep_SFID__c!=null) {
            c.VIP_Assigned__c = c.VIP_Client_Rep_SFID__c;
        }
    }  
    
    ContactTriggerHelper ConTr = new ContactTriggerHelper(); 
         if(Trigger.isInsert && Trigger.isbefore){ 
           ConTr.ContactUpdateBeforeInsert(Trigger.New);
         }
 }     
}