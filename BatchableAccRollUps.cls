global class BatchableAccRollUps  implements Database.Batchable<sObject>, Database.AllowsCallOuts, Database.Stateful {
    global   String  query;
   
    //  ---------------------------------------------------------------------
    //  CONSTRUCTOR
    //  ---------------------------------------------------------------------
    global BatchableAccRollUps () {


      query = 'SELECT Id,Number_of_Contacts__c FROM Account where CreatedDate > 2017-06-07T00:00:00Z';
           
       
     if(Test.isRunningTest()) { 
            query = 'SELECT Id,Number_of_Contacts__c  FROM Account LIMIT 50';
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
        
        Set<Id> AccIds = new Set<Id>();
 
        for (SObject s: scope) {    
            Account acc    = (Account) s;           
            AccIds.add(acc.Id);                
          
        }          

   
       //Count Number of Contacts
     List<Account> countAccs = [SELECT Id,(SELECT Id,Account.Id FROM Contacts LIMIT 5000) FROM Account WHERE Id IN :AccIds AND Account.RecordTypeId!= :Label.Person_Account];

     List<Account> UpdateAccount = new List<Account>();  
     if(!countAccs.isEmpty())   {          
         for(Account acc: countAccs) {                            
            List<Contact> relatedRecords = acc.getSObjects('Contacts');                       
          
            acc.Number_of_Contacts__c = relatedRecords!=null? relatedRecords.size() : 0;
                         
             UpdateAccount.add(acc);          
         }    
     }
     
       if(!UpdateAccount.isEmpty()){ 
           Update UpdateAccount;
        }
 }

   global void finish(Database.BatchableContext bc){       }

}