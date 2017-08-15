public with sharing class AccountBeforeTriggerHelper {

/////////////////////// lego Team name based on User
public void legoTeamName(List<Account> newAccList, Map<Id, Account> NewAccMap, Map<Id, Account> oldAccMap, Boolean isInsert, Boolean isUpdate){  
 
  Set<Id> UserIds = new Set<Id>();  
  if(isInsert) { 
     for(Account acc: newAccList){                                                      
         if(acc.OwnerId != null) {                              
              UserIds.add(acc.OwnerId);
            }                            
         }
    }     
    else if(isUpdate){
       for(Account acc: NewAccMap.Values()){                                                      
         if(acc.OwnerId != null && acc.OwnerId != oldAccMap.get(acc.Id).OwnerId ) {                              
              UserIds.add(acc.OwnerId);
            }                            
         }
    }  

    Map<Id, User> UserMap = new Map<Id, User>([select Id,Lego_Team_Id__c from User where id in :UserIds] );

    for (Account acc: newAccList) {
        User urs = UserMap.get(acc.OwnerId);
        
        if (urs != null) {
            acc.Lego_team__c = urs.Lego_Team_Id__c;
        }
    }                      
}
}