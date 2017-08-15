trigger VaultRollUp on Vault__c(after update, after delete) {
   // if(TriggerSettings__c.getValues('VaultRollUp').Status__c) {
      TriggerSettings__c ts = TriggerSettings__c.getValues('VaultRollUp');
      if (ts != null && ts.Status__c) {

      Set<Id> ConId = new Set<Id>();
      Set<Id> VaultId = new Set<Id>();
            
      if(trigger.isDelete) {
             for(Vault__c oldval: trigger.old) {
                if(oldval.Contact__c!=null) {
                    ConId.add(oldval.Contact__c);
                    VaultId.add(oldval.Id);
                }  
            }
        }
        else
        {
            for(Vault__c newval: Trigger.new)
            {
                if(newval.Contact__c!=trigger.oldMap.get(newval.Id).Contact__c) {
                    ConId.add(trigger.oldMap.get(newval.Id).Contact__c);
                    VaultId.add(newval.Id);
                }
            }
        }
    
     ////Count Number of Completed Vaults for each Contact
     Set<String> contactedValuts = new Set<String> {'B.) Attempting Contact','C.) Invalid Data','D.) Contact made','E.) Complete','F.) Sell Opportunity Created','G.) Task for BD Created','H.) Duplicate'};

     List<Contact> countContVaults = [SELECT Id,(SELECT Id,Vault_Call_Status__c FROM Vault__r WHERE Vault_Call_Status__c IN :contactedValuts)FROM Contact WHERE Id IN :ConId];
     Map<Id, Integer> ContactedVaultsCountMap = new Map<Id, Integer> ();
     if(!countContVaults.isEmpty())   {          
         for(Contact con: countContVaults) {                            
            List<Vault__c> relatedRecords1 = con.getSObjects('Vault__r');                       
            if(relatedRecords1!=null) {
                ContactedVaultsCountMap.put(con.Id,relatedRecords1.size());  
            }
            else {
                ContactedVaultsCountMap.put(con.Id,0);  
            }       
         }    
     }

     ////Count Number of Completed Vaults for each Contact
     Set<String> completedValuts = new Set<String> {'C.) Invalid Data','D.) Contact made','E.) Complete','F.) Sell Opportunity Created','G.) Task for BD Created','H.) Duplicate'};

     List<Contact> countCompVaults = [SELECT Id,(SELECT Id,Vault_Call_Status__c FROM Vault__r WHERE Vault_Call_Status__c IN :completedValuts)FROM Contact WHERE Id IN :ConId];
     Map<Id, Integer> CompleteVaultsCountMap = new Map<Id, Integer> ();
     if(!countCompVaults.isEmpty())   {          
         for(Contact con: countCompVaults) {                            
            List<Vault__c> relatedRecords1 = con.getSObjects('Vault__r');                       
            if(relatedRecords1!=null) {
                CompleteVaultsCountMap.put(con.Id,relatedRecords1.size());  
            }
            else {
                CompleteVaultsCountMap.put(con.Id,0);  
            }           
         }    
     }

     // Murali Guntakal - 10/7/2014 - Vault
     // Count Number of Completed Vaults for each Contact
     Set<String> PriorityLevels = new Set<String> {'1. Will be getting registered','2. Interested','2. Interested w/ guidance','3. Not Interested','3. Not Interested w/ guidance'};
     
     List<Contact> countPreAuctionVaults = [SELECT Id,(SELECT Id,Priority_Level__c FROM Vault__r WHERE Priority_Level__c IN :PriorityLevels) FROM Contact WHERE Id IN :ConId];
     Map<Id, Integer> PreAuctionCountMap = new Map<Id, Integer> ();
     if(!countPreAuctionVaults.isEmpty())   {          
         for(Contact con: countPreAuctionVaults) {                            
            List<Vault__c> relatedRecords1 = con.getSObjects('Vault__r');                       
            if(relatedRecords1!=null) {
                PreAuctionCountMap.put(con.Id,relatedRecords1.size());  
            }
            else {
                PreAuctionCountMap.put(con.Id,0);  
            }           
         }    
     }
     // 

     //// Count Total Number of Vaults for each Contact.
     List<Contact> contactVaultsMetrics = [SELECT Id,of_Vaults_Contacted__c,Number_Of_Completed_Vaults__c,Vault_Entries__c,of_Completed_Pre_Auction_Vaults__c,Max_Vault_LOI__c,First_Vault_LOI__c,First_Vault_Event_Date__c,First_visit_Pre_auction_Post_auction__c,Most_Recent_Pre_auction_Post_auction__c,
                                                 (SELECT Id,Vault_Call_Status__c,Level_of_Interest__c,Auction_End_Date_F__c,Event_Date__c,Pre_Auction_Post_Auction__c,CreatedDate FROM Vault__r ORDER BY CreatedDate) 
                                           FROM Contact WHERE Id IN :ConId];    

     if(!contactVaultsMetrics.isEmpty())  {             
        for(Contact con: contactVaultsMetrics)   {                
            List<Vault__c> relatedRecords = con.getSObjects('Vault__r');
            system.debug('All Vaults = ' +relatedRecords);  
            if(relatedRecords!=null) {
               con.Vault_Entries__c = relatedRecords.size();
               integer  counter = 0;
               integer MaxVaultLOI = 0;
               for(vault__c v : relatedRecords) {
                   counter = counter + 1;     
                   if(counter==1 && con.First_Vault_LOI__c==null) {
                       con.First_Vault_LOI__c = v.Level_of_Interest__c;                       
                   }    
                   
                   if(v.Level_Of_Interest__c > MaxVaultLOI)
                      MaxVaultLOI = integer.valueof(v.Level_of_Interest__c);
                   con.Max_Vault_LOI__c = MaxVaultLOI;
                   
                   system.debug('Created Date Value :' +String.valueof(v.CreatedDate.Date()));   
                   if(counter==1 && String.valueof(v.CreatedDate.Date()) >= '2014-05-01') {
                       con.First_Vault_Event_Date__c = v.Auction_End_Date_F__c;
                   }    

                   if(counter==1 && con.First_visit_Pre_auction_Post_auction__c == null)
                       con.First_visit_Pre_auction_Post_auction__c = v.Pre_Auction_Post_Auction__c;     

                   if(counter == relatedRecords.size()) { 
                       con.Most_Recent_Pre_auction_Post_auction__c = v.Pre_Auction_Post_Auction__c;
                   }
                       
               }  

               if(CompleteVaultsCountMap.containsKey(con.Id)) {
                   con.Number_Of_Completed_Vaults__c =  CompleteVaultsCountMap.get(con.Id);
               }
               else {
                   con.Number_Of_Completed_Vaults__c =  0;
               }
               //Murali Guntakal - 10/8/2014 - Start
               if(ContactedVaultsCountMap.containsKey(con.Id)) {
                   con.of_Vaults_Contacted__c =  ContactedVaultsCountMap.get(con.Id);
               }
               else {
                   con.of_Vaults_Contacted__c =  0;
               }                             
               //

               // Murali Guntakal - 10/7/2014 - Vault
               if(PreAuctionCountMap.ContainsKey(con.Id)) {
                   con.of_Completed_Pre_Auction_Vaults__c = PreAuctionCountMap.get(con.Id);
               }
               else {
                   con.of_Completed_Pre_Auction_Vaults__c = 0;             
               }
               //   
            }
            else {
                con.Vault_Entries__c=0;
                con.of_Vaults_Contacted__c = 0;
                con.Number_Of_Completed_Vaults__c = 0;
                con.of_Completed_Pre_Auction_Vaults__c = 0;
                con.Max_Vault_LOI__c = null;
                con.First_Vault_LOI__c = null;
                con.First_Vault_Event_Date__c = null;
                con.First_Vault_Event_Date__c = null;
                con.First_visit_Pre_auction_Post_auction__c = null;
                con.Most_Recent_Pre_auction_Post_auction__c = null;                
            }
        }
     }    
     Update contactVaultsMetrics;

   }                              
}