public with sharing class AccountTriggerHelper {

public void AccountToContactUpdate(Map<Id, Account> newAccMap, Map<Id, Account> oldTaskMap){  
 
 map<Id,Account> accmap = new map<Id,Account>();
  
 for(Account acc: newAccMap.Values()){  
                                                
     if((acc.CRE_Inside_Sales__c != oldTaskMap.get(acc.Id).CRE_Inside_Sales__c) || (acc.CRE_BD_Rep__c != oldTaskMap.get(acc.Id).CRE_BD_Rep__c) ) {                              
            accmap.put(acc.Id, acc);
        }                            
     }
                     
                    List<Contact> Conlist = new List<Contact>();     
                    Conlist = [SELECT Id, Account.Id, CRE_Inside_Sales__c FROM CONTACT WHERE Account.Id IN:accmap.KeySet() AND Account.RecordTypeId!= :Label.Person_Account];   
                    
                    List<Contact> ConUpdate = new List<Contact>();  
                       if(!Conlist.isEmpty()) {
                         for(Contact con: Conlist){
                           if(accmap.ContainsKey(con.Account.Id)){
                            con.CRE_Inside_Sales__c = accmap.get(con.Account.Id).CRE_Inside_Sales__c;
                            con.CRE_BD_Rep__c = accmap.get(con.Account.Id).CRE_BD_Rep__c;                                          
                            }
                            ConUpdate.add(con);
                          }     
                        }  
                        
                        if(!ConUpdate.isEmpty()) { 
                           Update ConUpdate;
                          }  
}
}