trigger ContactProfileBefore on Contact_Profile__c (before insert, before update) {
//if(TriggerSettings__c.getValues('ContactProfileBefore').Status__c) {
  TriggerSettings__c ts = TriggerSettings__c.getValues('ContactProfileBefore');
  if (ts != null && ts.Status__c) {
 
  Set<Id> ConId = new Set<Id>();
  
  for(Contact_Profile__c cp: Trigger.new){
     if(Trigger.isinsert){
          if(cp.Contact__c != null){
             ConId.add(cp.Contact__c);
           }
       }      
     if(Trigger.isupdate){
          if(cp.Contact__c != Trigger.oldMap.get(cp.Id).Contact__c && cp.Contact__c != null){
             ConId.add(cp.Contact__c);
           }
       }  
     }
     
     List<Contact> ConList = new List<Contact>();
     ConList = [Select Id, Account.Id from Contact where Id IN: ConId];
    system.debug('ConList'+ConList);
     
     map<Id, Contact> AccountId = new map<Id, Contact>();
     
   for(Contact con: ConList){
          AccountId.put(con.Id, con);
      }
      
    for(Contact_Profile__c cp: Trigger.new){
      if(AccountId.Containskey(cp.Contact__c)){
        cp.Account_of_Contact__c = AccountId.get(cp.Contact__c).Account.Id;
       }   
     } 
 }     
}