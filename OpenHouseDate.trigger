//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To update/create open House records when Auction is updated with Open House dates
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota Created  on 02/12/14 */
// Test Class : TestOpenHouse
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  

trigger OpenHouseDate on Auction_Campaign__c (after Update) {
 //if(TriggerSettings__c.getValues('OpenHouseDate').Status__c) {   
  TriggerSettings__c ts = TriggerSettings__c.getValues('OpenHouseDate');
    if (ts != null && ts.Status__c) {
                
    ////Create Open House when the Open House date is entered for the first time in Auction
    List<Open_House__c> newOpenHouses= new List<Open_House__c>();
    Set<Id> updatedAuctionIds = new Set<Id>();
    Map<String,Open_House__c> aoaOpenHouseMap= new Map<String,Open_House__c>();
    Map<Id,Auction_Campaign__c> changedAuctionMap = new  Map<Id,Auction_Campaign__c>();
    Set<Id> OppIdSet = new Set<Id>();
    
    for(Auction_Campaign__c au:Trigger.new) {
        if(au.Open_House_1_Date__c!=Trigger.oldMap.get(au.Id).Open_House_1_Date__c || au.Open_House_2_Date__c!=Trigger.oldMap.get(au.Id).Open_House_2_Date__c || au.Open_House_3_Date__c!=Trigger.oldMap.get(au.Id).Open_House_3_Date__c) {
            changedAuctionMap.put(au.Id,au);
            updatedAuctionIds.add(au.Id); 
        }
    }             
    Map<Id,Auction_Opportunity_Assignment__c> aoaMap = new Map<Id,Auction_Opportunity_Assignment__c>([SELECT Id,Name,Opportunity__c,Auction_Campaign__c,Auction_Campaign__r.Open_House_1_Date__c, Auction_Campaign__r.Open_House_2_Date__c,Auction_Campaign__r.Open_House_3_Date__c
                                                       FROM Auction_Opportunity_Assignment__c 
                                                       WHERE Auction_Campaign__c IN : updatedAuctionIds 
                                                       ORDER BY Auction_Campaign__c]);

    for( Open_House__c oh :  [SELECT Id,Opportunity__c,Auction_Opportunity_Assignment__c,Open_House_Unique_key__c,Open_House_Date__c,Open_House_Start_Time__c,Open_House_End_Time__c 
                                                                  FROM Open_House__c 
                                                                  WHERE  Auction_Opportunity_Assignment__c IN :aoaMap.KeySet()]) {
        aoaOpenHouseMap.put(oh.Open_House_Unique_key__c,oh);
        OppIdSet.add(oh.Opportunity__c);                                                                                
    }

            
    for(Auction_Opportunity_Assignment__c aoa: aoaMap.values()) {
        // Create/update Open House 1    
     /*   if(aoaOpenHouseMap.containsKey(String.valueof(aoa.Id)+'1')) {                                   
            if(Trigger.oldMap.get(aoa.Auction_Campaign__c).Open_House_1_Date__c != Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_1_Date__c) {                              
                Open_House__c oh = new Open_House__c(Id=aoaOpenHouseMap.get(String.valueof(aoa.Id)+'1').Id,Open_House_Date__c=Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_1_Date__c);                
                newOpenHouses.add(oh);
            }
        }    */
          if(Trigger.oldMap.get(aoa.Auction_Campaign__c).Open_House_1_Date__c != Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_1_Date__c && !OppIdSet.contains(aoa.Opportunity__c)) {  
                          
               Open_House__c oh = new Open_House__c(Auction_Opportunity_Assignment__c=aoa.Id,Open_House_Date__c=aoa.Auction_Campaign__r.Open_House_1_Date__c,Open_House_Start_Time__c='01:00,PM',Open_House_End_Time__c='04:00,PM',Open_House_Unique_key__c=aoa.Opportunity__c+'1');
               newOpenHouses.add(oh);
             
        }  

        // Create/update Open House 2    
      /*  if(aoaOpenHouseMap.containsKey(String.valueof(aoa.Id)+'2')) {                                   
            if(Trigger.oldMap.get(aoa.Auction_Campaign__c).Open_House_2_Date__c != Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_2_Date__c) {                              
                Open_House__c oh = new Open_House__c(Id = aoaOpenHouseMap.get(String.valueof(aoa.Id)+'2').Id,Open_House_Date__c=Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_2_Date__c);                
                newOpenHouses.add(oh);
            }
        }  */  
          if(Trigger.oldMap.get(aoa.Auction_Campaign__c).Open_House_2_Date__c != Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_2_Date__c && !OppIdSet.contains(aoa.Opportunity__c)) {                  
               Open_House__c oh = new Open_House__c(Auction_Opportunity_Assignment__c=aoa.Id,Open_House_Date__c=aoa.Auction_Campaign__r.Open_House_2_Date__c,Open_House_Start_Time__c='01:00,PM',Open_House_End_Time__c='04:00,PM',Open_House_Unique_key__c=aoa.Opportunity__c+'2');
               newOpenHouses.add(oh);
        }  

        // Create/update Open House 3    
       /* if(aoaOpenHouseMap.containsKey(String.valueof(aoa.Id)+'3')) {                                   
            if(Trigger.oldMap.get(aoa.Auction_Campaign__c).Open_House_3_Date__c != Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_3_Date__c) {                              
                Open_House__c oh = new Open_House__c(Id = aoaOpenHouseMap.get(String.valueof(aoa.Id)+'3').Id,Open_House_Date__c=Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_3_Date__c);                
                newOpenHouses.add(oh);
            }
        }  */
          if(Trigger.oldMap.get(aoa.Auction_Campaign__c).Open_House_3_Date__c != Trigger.newMap.get(aoa.Auction_Campaign__c).Open_House_3_Date__c && !OppIdSet.contains(aoa.Opportunity__c)) {                  
               Open_House__c oh = new Open_House__c(Auction_Opportunity_Assignment__c=aoa.Id,Open_House_Date__c=aoa.Auction_Campaign__r.Open_House_3_Date__c,Open_House_Start_Time__c='01:00,PM',Open_House_End_Time__c='04:00,PM',Open_House_Unique_key__c=aoa.Opportunity__c+'3');
               newOpenHouses.add(oh);
        }  
        
         OppIdSet.add(aoa.Opportunity__c);  
    }
    
   
    Upsert newOpenHouses;                                          
  }
}