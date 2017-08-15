trigger ContactTriggerAfter on Contact (after insert, after update) {
//if(TriggerSettings__c.getValues('ContactTriggerAfter').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('ContactTriggerAfter');
  if (ts != null && ts.Status__c) {

if (!ContactTriggerHelperClass.hasconAlreadyfired()) {

    List<Id> ConIds = new List<Id>();

    for (Contact con: Trigger.new) {
       
        if(Trigger.isUpdate){ 
             Map<ID,Contact> oldMap =    new Map<ID,Contact>(Trigger.old);
             if((con.VIP_Client_Rep__c != oldMap.get(con.Id).VIP_Client_Rep__c) || (con.CRE_VIP_Client_Rep__c != oldMap.get(con.Id).CRE_VIP_Client_Rep__c)) {
                   ConIds.add(con.Id);
               }
         }    
         
         if(Trigger.isInsert){
             ConIds.add(con.Id);
         } 
    }


    if (ConIds.size() > 0) {
        ContactTriggerHelper.ContactToAccountUpdate(ConIds);
    }

    //ContactTriggerHelper.UpdateMasterContact(trigger.newMap.keyset());

    //************************************* Set Trigger lock to TRUE   ***************************************************//

    ContactTriggerHelperClass.setconAlreadyfired();              
              
      
  } 
 }    
}