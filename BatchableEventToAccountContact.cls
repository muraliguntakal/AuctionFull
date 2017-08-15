global class BatchableEventToAccountContact  implements Database.Batchable<sObject>, Database.AllowsCallOuts, Database.Stateful {
    global   String  query;
   
    //  ---------------------------------------------------------------------
    //  CONSTRUCTOR
    //  ---------------------------------------------------------------------
    global BatchableEventToAccountContact () {
       String sysdatetime = String.valueOfGmt(System.now().addHours(-32)).replace(' ','T')+'.000Z'; 
       system.debug('Date = ' +sysdatetime);
       if(TriggerSettings__c.getValues('ProcessTodaysEventToAccCon').Status__c) {
           query = 'SELECT Id,WhoId,WhatId,ActivityDateTime,Owner.Name FROM Event WHERE  LastModifiedDate >= '+sysdatetime;
       }
       else {
           query = 'SELECT Id,WhoId,WhatId,ActivityDateTime,Owner.Name FROM Event';    
       }
        
       system.debug('Query = ' +query);       
       
     if(Test.isRunningTest()) { 
            query = 'SELECT Id,WhoId,WhatId,ActivityDateTime,Owner.Name FROM Event LIMIT 200';
        }  
             
    }
    
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: start
    //  ---------------------------------------------------------------------
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: execute 
    //  ---------------------------------------------------------------------
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
    
    Set<Id> contactIds = new Set<Id>();
    Set<Id> AccountIds = new Set<Id>();

    
          for (SObject s: scope) {    
              Event e = (Event) s; 
                  if (e.WhoId != null) {
                    String objPrefix = String.valueOf(e.WhoId).left(3);    
                    if (objPrefix == '003') {
                      contactIds.add(e.WhoId);
                    } 
                  }                 
                  if (e.WhatId != null) {
                    String objPrefixwhat = String.valueOf(e.WhatId).left(3);            
                    if (objPrefixwhat == '001') {
                      AccountIds.add(e.WhatId);}
                  }
             }
      
       

    //Update Contact with Latest Event information
    if (!contactIds.isEmpty()) {
          List<Contact> contactList = [SELECT Id,(SELECT Id,ActivityDateTime,Owner.Name FROM Events WHERE ActivityDateTime < :System.Now() ORDER BY EndDateTime DESC LIMIT 1) FROM Contact WHERE Id IN :contactIds];
    
          for (Contact c : contactList) {
                if (c.Events != null && !c.Events.isEmpty()) {                   
                    DateTime dte = c.Events[0].ActivityDateTime;
                    Date coverteddate = dte.date();                      
                    c.Date_of_Last_Meeting_Activity__c = coverteddate;                    
                    c.Last_Meeting_Activity_Assigned_To__c = c.Events[0].Owner.Name;  
                } else {                        
                    c.Date_of_Last_Meeting_Activity__c = null;
                    c.Last_Meeting_Activity_Assigned_To__c = null;          
                }
          }
          update contactList;
    }
  
  
  /*  
    //Update Account with Latest Event information
     if (!AccountIds.isEmpty()) {
              List<Account> AccountList = [SELECT Id, (SELECT Id,ActivityDateTime,Owner.Name FROM Events WHERE ActivityDateTime < :System.Now() ORDER BY EndDateTime DESC LIMIT 1) FROM Account WHERE Id IN :AccountIds];
        
              for (Account a : AccountList) {
                    if (a.Events != null && !a.Events.isEmpty()) {
                    
                       DateTime dt = a.Events[0].ActivityDateTime;
                       Date onlydate = dt.date();
                      a.Date_of_Last_Meeting_Activity__c = onlydate;  
                      a.Last_Meeting_Activity_Assigned_To__c = a.Events[0].Owner.Name;  
                    } else {
                     a.Date_of_Last_Meeting_Activity__c = null;
                     a.Last_Meeting_Activity_Assigned_To__c = null;          
                    }
              }
              update AccountList;
     }  */
     
  }

   global void finish(Database.BatchableContext bc){       }

}