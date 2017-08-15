trigger VaultActivityTriggers on Task (After Update) {
  //if(TriggerSettings__c.getValues('VaultActivityTriggers').Status__c){
    TriggerSettings__c ts = TriggerSettings__c.getValues('VaultActivityTriggers');
    if (ts != null && ts.Status__c) {

 
       Set<Id> isrContactIds = new Set<Id>();
       Set<Id> cmContactIds = new Set<Id>();
       Set<Id> contactIds   = new Set<Id>();
       
       for(Task t : trigger.new) {
          system.debug('Current Task: ' +t);
          if((t.WhatId)!=null && t.Assigned_User_Role__c!=null) { 
              if(t.Status == 'Completed' && String.Valueof(t.WhatId).startsWith('a1P') && (t.Assigned_User_Role__c=='Commercial: Inside Sales Rep' || t.Assigned_User_Role__c=='Commercial - Operations - Client Manager')) {
                  ContactIds.add(t.WhatId);
              }

              if(t.Status == 'Completed' && String.Valueof(t.WhatId).startsWith('a1P') && t.Assigned_User_Role__c=='Commercial: Inside Sales Rep') {
                  isrContactIds.add(t.WhatId);                   
              }

              if(t.Status == 'Completed' && String.Valueof(t.WhatId).startsWith('a1P') && t.Assigned_User_Role__c=='Commercial - Operations - Client Manager') {
                  cmContactIds.add(t.WhatId);                   
              }
          }
       }
       
       List<Vault__c> vaultContacts = new List<Vault__c>([SELECT Id, CM_Vault_Activity__c, ISR_Vault_Activity__c FROM Vault__c 
                                                          WHERE
                                                          Id IN :contactIds]);
       
       for(Vault__c v :  vaultContacts) {
           if(isrContactIds.contains(v.Id))
               v.ISR_Vault_Activity__c = '1';
           if(cmContactIds.contains(v.Id))
               v.CM_Vault_Activity__c = '1';                             
       }       
       Update vaultContacts; 
    }
}