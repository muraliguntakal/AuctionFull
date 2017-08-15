trigger CountContactTasks on Task(after insert, after update, after delete) {
  //if(TriggerSettings__c.getValues('CountContactTasks').Status__c){
    TriggerSettings__c ts = TriggerSettings__c.getValues('CountContactTasks');
    if (ts != null && ts.Status__c) {


  Set<Id> ConId = new Set<Id>();
  Set<Id> AccId = new Set<Id>();
  Set<Id> leadIds = new Set<Id>();
  
  if(trigger.isDelete || trigger.isUpdate)
    {
        for(Task oldval: trigger.old)
        {
           if (oldval.WhoId != null) {
                String objPrefix = String.valueOf(oldval.WhoId).left(3);
                if (objPrefix == '003') {
                  ConId.add(oldval.WhoId);
                }else if (objPrefix == '00Q') {
                  leadIds.add(oldval.WhoId);
                }
            }      
            if (oldval.WhatId != null) {
                String objPrefixwhat = String.valueOf(oldval.WhatId).left(3);                
                if (objPrefixwhat == '001') {
                  AccId.add(oldval.WhatId);
                }
             }   
       }   
    }   
  if(trigger.isInsert || trigger.isUpdate)
    {
        for(Task newval: Trigger.new)
        {   
            if (newval.WhoId != null) {
                String objPrefix = String.valueOf(newval.WhoId).left(3);
                if (objPrefix == '003') {
                  ConId.add(newval.WhoId);
                }else if (objPrefix == '00Q') {
                  leadIds.add(newval.WhoId);
                }
            }     
            if (newval.WhatId != null) {
                String objPrefixwhat = String.valueOf(newval.WhatId).left(3);                
                if (objPrefixwhat == '001') {
                  AccId.add(newval.WhatId);
                }
             }   
        }    
    }
    
    //Activity Count for Contact
    if (!ConId.isEmpty()) {
        List<Contact> countTask = [SELECT Id,(SELECT Id FROM  Tasks) FROM Contact WHERE Id IN :ConId];    
        for(Contact con: countTask)
        {
            List<Task> relatedRecords = con.getSObjects('Tasks');
            if(relatedRecords!=null)
            con.of_Activities__c= relatedRecords.size();
            else
            con.of_Activities__c= 0;
        } 
       update countTask;
     } 
     
    //Activity Count for Lead  
    if (!leadIds.isEmpty()) {
        List<Lead> LeadTask = [SELECT Id,(SELECT Id FROM  Tasks) FROM Lead WHERE Id IN :leadIds];    
        for(Lead Ld: LeadTask)
        {
            List<Task> relatedRecords = Ld.getSObjects('Tasks');
            if(relatedRecords!=null)
            Ld.Number_of_Activities__c= relatedRecords.size();
            else
            Ld.Number_of_Activities__c= 0;
        }
            update LeadTask;
     }       
     
    //Activity Count for Account 
    if (!AccId.isEmpty()) {
        List<Account> AccountTask = [SELECT Id,(SELECT Id FROM  Tasks) FROM Account WHERE Id IN :AccId];       
        for(Account Acc: AccountTask)
        {
            List<Task> relatedRecords = Acc.getSObjects('Tasks');
            if(relatedRecords!=null)
            Acc.of_Activities__c= relatedRecords.size();
            else
            Acc.of_Activities__c= 0;
        } 
           update AccountTask;
     }
  
  }   
}