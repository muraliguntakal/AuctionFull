public with sharing class ContactTriggerHelper{

@future(callout = false) 
public static void ContactToAccountUpdate(List<Id> ConIDS) {  

   List<Contact> Newcontacts = [select Id,AccountId,VIP_Client_Rep__c,CRE_VIP_Client_Rep__c from Contact where Id IN: ConIDS];

    Map<Id, Contact> accIdmap = new Map<Id, Contact>();
    
    for(Contact con: Newcontacts){      
                   accIdmap.Put(con.AccountId, con);                             
    }             
                

    List<Account> acclist = new List<Account>();     
    acclist = [SELECT Id, CRE_VIP__c, Resi_VIP__c,(SELECT Id, VIP_Client_Rep__c,CRE_VIP_Client_Rep__c from Contacts) FROM ACCOUNT WHERE Id IN:accIdmap.KeySet()];   
  
    List<Account> AccUpdate = new List<Account>();  
       if(!acclist.isEmpty()) {                  
           for(Account acc: acclist){
                       integer Resi_VIP= 0;
                       integer CRE_VIP= 0;
                    if(acc.Contacts !=null && acc.Contacts.size()!=0){
                        for(Contact conr : acc.Contacts) {              
                             if(conr.VIP_Client_Rep__c != null){                                            
                                Resi_VIP += 1; 
                               }
                             if(conr.CRE_VIP_Client_Rep__c != null){
                                CRE_VIP += 1; 
                               }                                       
                         }        
                      } 
                      acc.Resi_VIP__c= Resi_VIP>0?true:false;
                      acc.CRE_VIP__c= CRE_VIP>0?true:false;
                       
                      AccUpdate.add(acc);                            
           }     
       }  
    
    if(!AccUpdate.isEmpty()) { 
      Update AccUpdate;
      }  
 
}

 // Update from Account TO Contact when Contact is created
 
 public void ContactUpdateBeforeInsert(List<Contact> newConlist) {  

    Set<Id> accIdSet = new Set<Id>();
    
    for(Contact con: newConlist) {   
        if(con.AccountId != null) {
           accIdSet.add(con.AccountId);
        } 
    }                             
                    
    List<Account> accnlist = new List<Account>();     
    accnlist = [SELECT Id,CRE_Inside_Sales__c,Rockwood_Advisor__c,CRE_BD_Rep__c,Assigned_Acquisition_Rep__c                                    
                                                  FROM ACCOUNT WHERE Id IN:accIdSet];  
                                                  
      map<Id, Account> Accomap = new map<Id, Account>();
                                                     
       if(!accnlist.isEmpty()) {                  
           for(Account acco: accnlist){ 
              if(accIdSet.Contains(acco.Id)){             
                Accomap.put(acco.Id, acco); 
               }      
            }                          
         }

        System.debug(' Accomap ' +Accomap);
       
       for(Contact con: newConlist){  
       System.debug(' ConAcc ' + con); 
        if(Accomap.ContainsKey(con.AccountId)){
        System.debug(' Accomap2 ' +Accomap);
           con.CRE_Inside_Sales__c = Accomap.get(con.AccountId).CRE_Inside_Sales__c;
           con.CRE_BD_Rep__c = Accomap.get(con.AccountId).CRE_BD_Rep__c;
           con.Rockwood_Advisor__c = Accomap.get(con.AccountId).Rockwood_Advisor__c;
           con.Assigned_Acquisition_Rep__c = Accomap.get(con.AccountId).Assigned_Acquisition_Rep__c;                        
        } 
       } 
   
 } 
 
     public static Set<Id> getMasterContacts (Set<Id> contactIds) {
        List<Contact> ContactList = new List<Contact>([SELECT Id,MasterContactID__c FROM Contact WHERE Id IN : contactIds AND Master_Contact__c!=null]);
        for(Contact c : ContactList) {            
            if(!contactIds.contains(c.MasterContactID__c)) {
                contactIds.add(c.MasterContactID__c);
            }
        }
        return contactIds;
     }

    public static void UpdateMasterContact (Set<Id> contactIds) {
        AggregateResult[] masterContacts = [SELECT MasterContactID__c, 
                                                   SUM(of_Opportunities__c), 
                                                   SUM(Vault_Entries__c), 
                                                   SUM(of_Bids__c), 
                                                   SUM(of_Commercial_Opportunities__c),
                                                   SUM(of_Winning_Bids__c),
                                                   SUM(Total_Winning_Bid_Amount__c)
                                            FROM Contact 
                                            WHERE Id IN : contactIds
                                            GROUP BY MasterContactID__c];

        List<Contact> masterContactList = new List<Contact>(); 
        Set<Id> conIds = new set<Id>();      
        for (AggregateResult ar : masterContacts)  {
            String cId = String.Valueof(ar.get('MasterContactID__c'));
            integer TotalOpps = integer.valueof(ar.get('expr0'));
            integer TotalVals = integer.valueof(ar.get('expr1'));
            integer TotalBids = integer.valueof(ar.get('expr2'));
            integer TotalCommOppsSeller = integer.valueof(ar.get('expr3'));
            integer TotalWinningBids = integer.valueof(ar.get('expr4'));
            double  TotalWinningBidAmt = double.valueof(ar.get('expr5'));
            
            system.debug('Contact IDs => '+contactIds);
            system.debug('Contact Id =? '+cId+ ' Total Opps => '+TotalOpps+ ' Vals => '+TotalVals+ ' Total Bids => '+TotalBids+' Seller Ops => '+TotalCommOppsSeller+ ' Bids =>'+TotalWinningBids);    

            if(cId!=null && !conIds.contains(cId)) {
                masterContactList.add(new Contact(Id = Id.Valueof(cId),
                                                  Opportunities_Master__c = TotalOpps, 
                                                  Vaults_Master__c = TotalVals, 
                                                  Bids_Master__c = TotalBids,
                                                  Commercial_Opps_Seller_Master__c = TotalCommOppsSeller,
                                                  Winning_Bids_Master__c = TotalWinningBids,
                                                  Total_Winning_Bid_Amount_Master__c = TotalWinningBidAmt
                                                  ));
                conIds.add(cId);
            }
        }

        Database.Update(masterContactList,false);
    }

}