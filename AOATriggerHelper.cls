//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To uncheck the most recent auction flag on previous auction, to update the most recent Auction on Opportunity, to create open house records when Auction is associated to AOA
//  --------------------------------------------------------------------
//* Author : Ganesh Vinnakota Created  on 02/12/14 *//
// Test Class : TestMostResentOpportunityAuction
// Modified By                    Modified Date                              What Changed                                          Reason
// Murali Guntakal                   4/11/2014                               Determining Winning Bid From AOA ID                   Add New Modification as per Hammad's Email - REF-0001 //
//******************************************************************************************************************************************************************************************/ 
public with sharing class AOATriggerHelper {

  public void CheckLatestAuctionOppFlag(List<Auction_Opportunity_Assignment__c> aoaList, Set<Id> CurrentaoaId) {
    Set<Id> oppIds = new Set<Id>();

    for (Auction_Opportunity_Assignment__c aoa : aoaList) {
      if (aoa.Opportunity__c != null && !oppIds.contains(aoa.Opportunity__c)) {
        oppIds.add(aoa.Opportunity__c);
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. 
     */
    if (!oppIds.isEmpty()) {
      List<Auction_Opportunity_Assignment__c> aoas = 
        [SELECT Id, MLH_Product_Type__c
         FROM Auction_Opportunity_Assignment__c
         WHERE Opportunity__c IN :oppIds
         AND Id NOT IN :CurrentaoaId
         AND Most_Recent_AOA__c = true
         ORDER BY CreatedDate DESC];

      List<Auction_Opportunity_Assignment__c> aoaToUpdate = new List<Auction_Opportunity_Assignment__c>();
      for (Auction_Opportunity_Assignment__c aoa : aoas) {
        if (aoa.MLH_Product_Type__c != 'Trustee' && aoa.MLH_Product_Type__c != 'FCL Marketing') {
          aoa.Most_Recent_AOA__c = false;
          aoaToUpdate.add(aoa);
        }
      }

      if (!aoaToUpdate.isEmpty()) {
        update aoaToUpdate;
      }
    }

    /**
     * Author: Luke Martell
     * Date: 4/18/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *
      Set<Id> oppIds = new Set<Id>();
      Set<Id> aoaIds = new Set<Id>();
  
      for(Auction_Opportunity_Assignment__c aoaj : aoaList) {
          aoaIds .add(aoaj.Id);
          if(aoaj.Opportunity__c!=null)
          oppIds.add(aoaj.Opportunity__c); 
      }

      //Get all the AuctionsOppJuntion records connected to Opportunity with Latest AOA set as TRUE 
      List<Auction_Opportunity_Assignment__c > newaoaList = new List<Auction_Opportunity_Assignment__c >([SELECT Id,MLH_Product_Type__c ,Opportunity__c 
                                                                                                          FROM Auction_Opportunity_Assignment__c 
                                                                                                          WHERE Opportunity__c IN :OppIds AND Opportunity__c!=null AND Most_Recent_AOA__c=true AND Id NOT IN :CurrentaoaId 
                                                                                                          ORDER BY CreatedDate DESC]);

      List<Auction_Opportunity_Assignment__c > oldaoa = new List<Auction_Opportunity_Assignment__c > ();
      for(Auction_Opportunity_Assignment__c aoa : newaoaList) { 
              if(aoa.MLH_Product_Type__c != 'Trustee' && aoa.MLH_Product_Type__c != 'FCL Marketing')
                {
                      aoa.Most_Recent_AOA__c=false;
                      oldaoa.add(aoa); 
                }      
      }

      if(oldaoa.size() > 0)
      Update oldaoa;
      */
  }

  public void updateMostRecentAuctionClass(List<Auction_Opportunity_Assignment__c> aoaList) {
    Set<Id> oppIds = new Set<Id>();

    for (Auction_Opportunity_Assignment__c aoa : aoaList) {
      if (aoa.Opportunity__c != null && !oppIds.contains(aoa.Opportunity__c)) {
        oppIds.add(aoa.Opportunity__c);
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. 
     */
    if (!oppIds.isEmpty()) {
      List<Opportunity> opps = 
        [SELECT Id, RecordTypeId, Most_Recent_Auction__c, Next_Most_Recent_Auction__c,
          (SELECT Id, Auction_Campaign__c, MLH_Seller_Code__c, MLH_Outsourcer_Code__c 
           FROM Auction_Opportunity_Assignments__r
           WHERE Auction_Campaign__c != null
           ORDER BY CreatedDate DESC 
           LIMIT 2)
         FROM Opportunity
         WHERE Id IN :oppIds
         AND RecordTypeId != :Label.Opportunity_Record_TypeId_Trustee];

      List<Opportunity> oppsToUpdate = new List<Opportunity>();

      // Eliminated loop structure by statically pulling AOA details from the child records if they are present
      for (Opportunity opp : opps) {
        if (opp.Auction_Opportunity_Assignments__r != null && !opp.Auction_Opportunity_Assignments__r.isEmpty()) {
          Auction_Opportunity_Assignment__c aoa = opp.Auction_Opportunity_Assignments__r[0];

          opp.Most_Recent_Auction__c = aoa.Auction_Campaign__c;
          opp.Auction_Opportunity_Assignment__c = aoa.Id;
          opp.MLH_Seller_Code__c = aoa.MLH_Seller_Code__c;
          opp.Outsourcer__c = aoa.MLH_Outsourcer_Code__c;
          opp.Winning_BidLookup__c = null;
          opp.Winning_Bid_Amount__c = null;
          opp.Winning_Bid_AOA__c = null;
          opp.Winning_Bidder_Email__c = null;
          opp.Winning_Bidder_First_Name__c = null;
          opp.Winning_Bidder_Last_Name__c = null;

          if (opp.Auction_Opportunity_Assignments__r.size() > 1) {
            opp.Next_Most_Recent_Auction__c = opp.Auction_Opportunity_Assignments__r[1].Auction_Campaign__c;
          }
          oppsToUpdate.add(opp);
        }
      }

      if (!oppsToUpdate.isEmpty()) {
        update oppsToUpdate;
      }
    }


    /**
     * Author: Luke Martell
     * Date: 4/18/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *
      Set<Id> setoppId = new Set<Id>();   
      List<Opportunity> mostrecentaoas = new List<Opportunity>(); 
          
      for (Auction_Opportunity_Assignment__c  childObj: aoaList) {
          if(childObj.Opportunity__c!=null){
              setoppId.add(childObj.Opportunity__c);
          }
      }                                               

      mostrecentaoas= [SELECT Id,RecordTypeId,Most_Recent_Auction__c,Next_Most_Recent_Auction__c,(SELECT Id, Opportunity__c, Auction_Campaign__c,Most_Recent_AOA__c,MLH_Seller_Code__c,MLH_Outsourcer_Code__c
                                                                                     FROM Auction_Opportunity_Assignments__r 
                                                                                     WHERE Opportunity__c!=null AND Auction_Campaign__c!=null 
                                                                                     ORDER BY  CreatedDate DESC LIMIT 2)
                       FROM Opportunity where Id in: setoppId];       
      if(!mostrecentaoas.isEmpty()) {
          for (Opportunity opp : mostrecentaoas) {
             if(opp.RecordTypeId != Label.Opportunity_Record_TypeId_Trustee){
              if(opp.Auction_Opportunity_Assignments__r !=null && opp.Auction_Opportunity_Assignments__r.size()!=0){
                  for (Auction_Opportunity_Assignment__c  aoa : opp.Auction_Opportunity_Assignments__r) {
                      if(aoa.Most_Recent_AOA__c==true){
                          opp.Most_Recent_Auction__c = aoa.Auction_Campaign__c;
                          opp.Auction_Opportunity_Assignment__c = aoa.Id;
                          opp.MLH_Seller_Code__c = aoa.MLH_Seller_Code__c;
                          opp.Outsourcer__c = aoa.MLH_Outsourcer_Code__c;
                          opp.Winning_BidLookup__c = null;
                          opp.Winning_Bid_Amount__c = null;
                          opp.Winning_Bid_AOA__c = null;
                          opp.Winning_Bidder_Email__c = null;
                          opp.Winning_Bidder_First_Name__c = null;
                          opp.Winning_Bidder_Last_Name__c = null;
                        }  
                      else {
                          opp.Next_Most_Recent_Auction__c = aoa.Auction_Campaign__c;
                        }   
                  }
              }
            } 
          }
          update mostrecentaoas;
      }
      */
  }     

  // Most Recent AOA on Asset
  public void MostRecentAOAonAsset(List<Auction_Opportunity_Assignment__c> aoaList) {   
    Set<String> gpids = new Set<String>();

    for (Auction_Opportunity_Assignment__c aoa : aoaList) {
      if (aoa.MLH_Global_Property_Id__c != null && !aoa.User_Created_AOA__c && !gpids.contains(aoa.MLH_Global_Property_Id__c)) {
        gpids.add(aoa.MLH_Global_Property_Id__c);
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. 
     */
    if (!gpids.isEmpty()) {
      List<Asset__c> assets = 
        [SELECT Id, 
          (SELECT Id 
           FROM Auction_Opportunity_Assignments__r
           WHERE MLH_Global_Property_Id__c != null
           AND User_Created_AOA__c = false
           ORDER BY CreatedDate DESC
           LIMIT 2)
         FROM Asset__c
         WHERE MLH_Global_Property_ID__c IN :gpids];

      List<Asset__c> assetsToUpdate = new List<Asset__c>(); 

      for (Asset__c asset : assets) {
        if (asset.Auction_Opportunity_Assignments__r != null && !asset.Auction_Opportunity_Assignments__r.isEmpty()) {
          asset.Most_Recent_AOA__c = asset.Auction_Opportunity_Assignments__r[0].Id;

          if (asset.Auction_Opportunity_Assignments__r.size() > 1) {
            asset.Next_Most_Recent_AOA__c = asset.Auction_Opportunity_Assignments__r[1].Id;
          }
          assetsToUpdate.add(asset);
        }
      }

      if (!assetsToUpdate.isEmpty()) {
        update assetsToUpdate;
      }
    }

    /**
     * Author: Luke Martell
     * Date: 4/18/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *                 
      Set<string> setglobalId = new Set<string>();   
          
      for (Auction_Opportunity_Assignment__c  childObjt: aoaList) {
          if(childObjt.MLH_Global_Property_Id__c!=null && childObjt.User_Created_AOA__c == False){
              setglobalId.add(childObjt.MLH_Global_Property_Id__c);
          }
      }                                               

      List<Asset__c> recentaoas = new List<Asset__c>(); 
      recentaoas= [SELECT Id,(SELECT Id FROM Auction_Opportunity_Assignments__r WHERE MLH_Global_Property_ID__c !=null AND User_Created_AOA__c = False ORDER BY CreatedDate DESC LIMIT 2) FROM Asset__c where MLH_Global_Property_ID__c in: setglobalId];       
      
      List<Asset__c> UpdateAsset = new List<Asset__c>(); 
      
      if(!recentaoas.isEmpty()) {
          for (Asset__c asst : recentaoas) {             
                       
              List<Auction_Opportunity_Assignment__c> relatedRecords = asst.getSObjects('Auction_Opportunity_Assignments__r');              
              if(relatedRecords.size()!=0){
                      if(relatedRecords[0] != null){
                        asst.Most_Recent_AOA__c = relatedRecords[0].Id;
                       }
                }
              if(relatedRecords.size() > 1){       
                      if(relatedRecords[1] != null){  
                        asst.Next_Most_Recent_AOA__c = relatedRecords[1].Id;       
                       }  
               }                           
            UpdateAsset.add(asst);       
          }
           if(!UpdateAsset.isEmpty())
               update UpdateAsset;
      }
      */
  }

  public void CreatOpenHouses(Map<Id,Auction_Opportunity_Assignment__c> NewMapAOA, Map<Id,Auction_Opportunity_Assignment__c> OldMapAOA, Boolean isInsert, Boolean isUpdate) {
    Set<Id> oppIds = new Set<Id>();

    for (Auction_Opportunity_Assignment__c aoa : NewMapAOA.values()) {
      if (aoa.Opportunity__c != null && !oppIds.contains(aoa.Opportunity__c) && (aoa.Line_of_Business__c  == 'Commercial' || (aoa.Line_of_Business__c == 'Residential' && aoa.MLH_Product_Type__c == 'Short Sale'))) {
        oppIds.add(aoa.Opportunity__c);
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. 
     */
    if (!oppIds.isEmpty()) {
      List<Open_House__c> openHousesToCreate = new List<Open_House__c>();

      Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Id FROM Open_Houses__r) FROM Opportunity WHERE Id IN :oppIds]);

      for (Auction_Opportunity_Assignment__c aoa : NewMapAOA.values()) {
        if (oppIds.contains(aoa.Opportunity__c)) {
          List<Open_House__c> openHouses = oppMap.get(aoa.Opportunity__c).Open_Houses__r;

          if (openHouses == null || openHouses.isEmpty()) {
            if ((isInsert && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_1_Date__c != null) || (isUpdate && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_1_Date__c != null && OldMapAOA.get(aoa.Id).Auction_Campaign__c == null)) {
              openHousesToCreate.add(new Open_House__c(Auction_Opportunity_Assignment__c = aoa.Id, Open_House_Date__c = aoa.Auction_Open_House_1_Date__c, Open_House_Start_Time__c = '01:00,PM', Open_House_End_Time__c = '04:00,PM', Open_House_Unique_key__c = aoa.Opportunity__c + '1'));
            }
            if ((isInsert && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_2_Date__c != null) || (isUpdate && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_2_Date__c != null && OldMapAOA.get(aoa.Id).Auction_Campaign__c == null)) {
              openHousesToCreate.add(new Open_House__c(Auction_Opportunity_Assignment__c = aoa.Id, Open_House_Date__c = aoa.Auction_Open_House_2_Date__c, Open_House_Start_Time__c = '01:00,PM', Open_House_End_Time__c = '04:00,PM', Open_House_Unique_key__c = aoa.Opportunity__c + '2'));
            }
            if ((isInsert && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_3_Date__c != null) || (isUpdate && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_3_Date__c != null && OldMapAOA.get(aoa.Id).Auction_Campaign__c == null)) {
              openHousesToCreate.add(new Open_House__c(Auction_Opportunity_Assignment__c = aoa.Id, Open_House_Date__c = aoa.Auction_Open_House_3_Date__c, Open_House_Start_Time__c = '01:00,PM', Open_House_End_Time__c = '04:00,PM', Open_House_Unique_key__c = aoa.Opportunity__c + '3'));
            }
          }
        }
      }

      if (!openHousesToCreate.isEmpty()) {
        insert openHousesToCreate;
      }
    }

    /**
     * Author: Luke Martell
     * Date: 4/18/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *  
         Set<Id> oppIds = new Set<Id>();
      
         for(Auction_Opportunity_Assignment__c aoa:NewMapAOA.values()){
              oppIds.add(aoa.Opportunity__c);
         }
              
          List<Open_House__c> OpenHouse = new List<Open_House__c>();
          OpenHouse = [SELECT Id, Opportunity__c  FROM Open_House__c WHERE Opportunity__c!=null AND Opportunity__c IN: oppIds];
          
          
          Set<Id> OppIdSet = new Set<Id>();
          
          for(Open_House__c openHo: OpenHouse ) {            
              OppIdSet.add(openHo.Opportunity__c);
          }
                                                                                        
        List<Open_House__c> ohlist = new List<Open_House__c>();
        for(Auction_Opportunity_Assignment__c aoa:NewMapAOA.values()) {
            if(!OppIdSet.contains(aoa.Opportunity__c)) {
                    if((isInsert && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_1_Date__c != null) || (isUpdate && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_1_Date__c != null && OldMapAOA.get(aoa.id).Auction_Campaign__c ==null)){
                       Open_House__c oh = new Open_House__c(Auction_Opportunity_Assignment__c=aoa.Id,Open_House_Date__c=aoa.Auction_Open_House_1_Date__c,Open_House_Start_Time__c='01:00,PM',Open_House_End_Time__c='04:00,PM',Open_House_Unique_key__c=aoa.Opportunity__c+'1');
                       ohlist.add(oh);
                    }      
                    if((isInsert && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_2_Date__c != null) || (isUpdate && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_2_Date__c != null && OldMapAOA.get(aoa.id).Auction_Campaign__c ==null)){
                       Open_House__c oh = new Open_House__c(Auction_Opportunity_Assignment__c=aoa.Id,Open_House_Date__c=aoa.Auction_Open_House_2_Date__c,Open_House_Start_Time__c='01:00,PM',Open_House_End_Time__c='04:00,PM',Open_House_Unique_key__c=aoa.Opportunity__c+'2');
                       ohlist.add(oh);
                    }  
                    if((isInsert && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_3_Date__c != null) || (isUpdate && aoa.Auction_Campaign__c != null && aoa.Auction_Open_House_3_Date__c != null && OldMapAOA.get(aoa.id).Auction_Campaign__c ==null)){
                       Open_House__c oh = new Open_House__c(Auction_Opportunity_Assignment__c=aoa.Id,Open_House_Date__c=aoa.Auction_Open_House_3_Date__c,Open_House_Start_Time__c='01:00,PM',Open_House_End_Time__c='04:00,PM',Open_House_Unique_key__c=aoa.Opportunity__c+'3');
                       ohlist.add(oh);
                    }
                    OppIdSet.add(aoa.Opportunity__c);  
             }              
        }
          Insert ohlist;  
    */
  }  
    
  // Count AOAs     
  public void CountAuctionOpptyAssignment(Map<Id,Auction_Opportunity_Assignment__c> NewMapAOA, Map<Id,Auction_Opportunity_Assignment__c> OldMapAOA, Boolean isInsert, Boolean isUpdate) { 
    Map<Id, Auction_Opportunity_Assignment__c> includeExtraFields = new Map<Id, Auction_Opportunity_Assignment__c>();
    Set<Id> oppIds = new Set<Id>();

    // Eliminated duplicate logic checking by pushing conditionals farther up the logic pipeline
    for (Auction_Opportunity_Assignment__c aoa : NewMapAOA.values()) {
      if (aoa.Opportunity__c != null && aoa.Status__c != null && (aoa.Line_of_Business__c == 'Commercial' || (aoa.Line_of_Business__c == 'Residential' && aoa.MLH_Product_Type__c == 'Short Sale'))) {
        if (isInsert || (isUpdate && ((aoa.Status__c != OldMapAOA.get(aoa.Id).Status__c) || (aoa.Opportunity__c != OldMapAOA.get(aoa.Id).Opportunity__c)))) {
          if (aoa.MLH_File_Received_Date__c != null || aoa.Seller_Name__c != null) {
            includeExtraFields.put(aoa.Opportunity__c, aoa);
          }
          if (isUpdate && aoa.Opportunity__c != OldMapAOA.get(aoa.Id).Opportunity__c) {
            oppIds.add(OldMapAOA.get(aoa.Id).Opportunity__c);
          }
          oppIds.add(aoa.Opportunity__c);
        }
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. 
     */
    if (!oppIds.isEmpty()) {
      List<Opportunity> opps = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r WHERE Run_Count__c = 1) FROM Opportunity WHERE Id IN :oppIds];
      
      for (Opportunity opp : opps) {
        opp.Run_Number__c = (opp.Auction_Opportunity_Assignments__r != null ? opp.Auction_Opportunity_Assignments__r.size() : 0);

        if (includeExtraFields.containsKey(opp.Id)) {
          opp.MLH_File_Received_Date__c = includeExtraFields.get(opp.Id).MLH_File_Received_Date__c;
          opp.MLH_Seller_Name__c = includeExtraFields.get(opp.Id).Seller_Name__c;
        }
      }
      update opps;
    }
    

    /**
     * Author: Luke Martell
     * Date: 4/18/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *  
    //Limit the size of list by using Sets which do not contain duplicate elements
    set<id> OpportunityIds = new set<Id>();
    map<Id,Auction_Opportunity_Assignment__c> aoamap1 = new map<Id,Auction_Opportunity_Assignment__c>();  
    //Commented below code as per requirements from  4/21/2014 Meeting with Dalisa, Hammad & Sally; Run_Count__c will be used in aggregate from now on.
    //Set<String> validStatusforRunCount = new Set<String> {'Auction','Sold', 'Not Sold', 'Removed'} ; 

    //When adding AOA or updating existing AOA, calcute Opportunity Run Number 
    if(isInsert || isUpdate) {
        for(Auction_Opportunity_Assignment__c a : NewMapAOA.values()) {      
            if(a.Opportunity__c!=null && a.Status__c!=null && a.Line_of_Business__c != 'Residential') {
                if(isupdate)  
                { 
                  if(a.MLH_File_Received_Date__c!=null || a.Seller_Name__c!=null) {
                        aoamap1.put(a.Opportunity__c,a);
                        OpportunityIds.add(a.Opportunity__c);
                    }
                    if(a.Status__c!=OldMapAOA.get(a.Id).Status__c) {
                        OpportunityIds.add(a.Opportunity__c);
                    } 
                }
                else 
                {
                      if(a.MLH_File_Received_Date__c!=null || a.Seller_Name__c!=null) {
                        aoamap1.put(a.Opportunity__c,a);
                    }
                     OpportunityIds.add(a.Opportunity__c);
                }  
            }    
        }
    }
          
    List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
   
    List<Opportunity> oppList =  new List<Opportunity>([SELECT Id,(SELECT Id FROM Auction_Opportunity_Assignments__r WHERE Run_Count__c=1) 
                                                        FROM Opportunity WHERE Id IN :OpportunityIds]);
    
    for(Opportunity o : oppList) {
        Integer RunNumber = o.Auction_Opportunity_Assignments__r.size();
        o.Run_Number__c = RunNumber;
         if(aoamap1.ContainsKey(o.Id)){
              o.MLH_File_Received_Date__c = aoamap1.get(o.Id).MLH_File_Received_Date__c;
              o.MLH_Seller_Name__c = aoamap1.get(o.Id).Seller_Name__c;
          }
        OpportunitiesToUpdate.add(o);
    }

    Update OpportunitiesToUpdate;
    */
  }

  //*********************Trustee Opportunity Update*********************
  public void TrusteeOpportunityUpdate(Map<Id,Auction_Opportunity_Assignment__c> NewMapAOA) {
    Map<Id, Auction_Opportunity_Assignment__c> oppAoaMap = new Map<Id, Auction_Opportunity_Assignment__c>();

    // Eliminated the need for 2 data structures to track the acceptable records
    for (Auction_Opportunity_Assignment__c aoa : NewMapAOA.values()) {
      if (aoa.Opportunity__c != null && (aoa.MLH_Product_Type__c == 'Trustee' || aoa.MLH_Product_Type__c == 'FCL Marketing')) {
        oppAoaMap.put(aoa.Opportunity__c, aoa);
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. 
     */
    if (!oppAoaMap.isEmpty()) {
      List<Opportunity> opps = 
        [SELECT Id, Asset__c, RecordTypeId, Loan_Number__c, MLH_Seller_Code__c, Auction_Status__c, 
                MLH_Bid_Start_Date__c, First_Last_Name_Homeowner__c, MLH_Venue_ID__c, Outsourcer_Code__c
         FROM Opportunity
         WHERE Id IN :oppAoaMap.keySet()];

      for (Opportunity opp : opps) {
        opp.Loan_Number__c = oppAoaMap.get(opp.Id).MLH_Loan_Number__c;
        opp.Auction_Status__c = oppAoaMap.get(opp.Id).Status__c;
        opp.MLH_Bid_Start_Date__c = oppAoaMap.get(opp.Id).Property_Auction_Date__c;
        opp.First_Last_Name_Homeowner__c = oppAoaMap.get(opp.Id).Trustor__c;
        opp.MLH_Venue_ID__c = oppAoaMap.get(opp.Id).MLH_Venue_ID__c;
        opp.Outsourcer_Code__c = oppAoaMap.get(opp.Id).MLH_Outsourcer_Code__c;
        
        if (oppAoaMap.get(opp.Id).MLH_Seller_Code__c != null) {
          opp.MLH_Seller_Code__c = oppAoaMap.get(opp.Id).MLH_Seller_Code__c;
        }
        if (oppAoaMap.get(opp.Id).MLH_Pool_Number__c != null) {
          opp.MLH_Pool_Number__c = oppAoaMap.get(opp.Id).MLH_Pool_Number__c.left(3);
        }
      }
      update opps;

      // Call Create Trustee Valuation method
      //OpportunityTriggerHelper oct = new OpportunityTriggerHelper();
      //oct.Create_Trustee_Valuation(opps); 
    }

    /**
     * Author: Luke Martell
     * Date: 5/4/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *  
    Set<Id> OppId = new Set<Id>(); 
    map<Id,Auction_Opportunity_Assignment__c> aoamap = new map<Id,Auction_Opportunity_Assignment__c>();   
    
        for(Auction_Opportunity_Assignment__c aoa : NewMapAOA.values())
         {      
           if(aoa.Opportunity__c!=null && (aoa.MLH_Product_Type__c == 'Trustee' || aoa.MLH_Product_Type__c == 'FCL Marketing'))
             {
              OppId.add(aoa.Opportunity__c);
              aoamap.put(aoa.Opportunity__c,aoa);
              
             }
          }
          
        List<Opportunity> TrusteeOppUpdate = new List<Opportunity>();
        List<Opportunity> oppList =  new List<Opportunity>([SELECT Id,Asset__c,RecordTypeId,Loan_Number__c,MLH_Seller_Code__c,Auction_Status__c,MLH_Bid_Start_Date__c,First_Last_Name_Homeowner__c,
                                                            MLH_Venue_ID__c,Outsourcer_Code__c FROM Opportunity WHERE Id IN :OppId]);
         
        for(Opportunity opp: oppList)
        {
            opp.Loan_Number__c = aoamap.get(opp.Id).MLH_Loan_Number__c;
             
            opp.Auction_Status__c = aoamap.get(opp.Id).Status__c;
            opp.MLH_Bid_Start_Date__c = aoamap.get(opp.Id).Property_Auction_Date__c;
            opp.First_Last_Name_Homeowner__c = aoamap.get(opp.Id).Trustor__c;    
            opp.MLH_Venue_ID__c = aoamap.get(opp.Id).MLH_Venue_ID__c;    
            opp.Outsourcer_Code__c = aoamap.get(opp.Id).MLH_Outsourcer_Code__c;  
        if(aoamap.get(opp.Id).MLH_Seller_Code__c!=null){
            opp.MLH_Seller_Code__c = aoamap.get(opp.Id).MLH_Seller_Code__c;
        }
        else if(aoamap.get(opp.Id).MLH_Pool_Number__c!=null){
            opp.MLH_Pool_Number__c = aoamap.get(opp.Id).MLH_Pool_Number__c.SubString(0,3);
        }
            TrusteeOppUpdate.add(opp);
                    
        }  
       if(!TrusteeOppUpdate.isEmpty()){
          update TrusteeOppUpdate; 
        }
        
          //Create Trustee Valuation  
          OpportunityTriggerHelper oct = new OpportunityTriggerHelper();
          oct.Create_Trustee_Valuation(oppList);  
    */
  }            
              
  // Update Photo order Flag when AOA Status is updated     
  public void UncheckPhotoOrder(Map<Id,Auction_Opportunity_Assignment__c> NewMapAOA, Map<Id,Auction_Opportunity_Assignment__c> OldMapAOA) {     
    Map<Id, Auction_Opportunity_Assignment__c> oppAoaMap = new Map<Id, Auction_Opportunity_Assignment__c>();

    // Eliminated an unncessary check for "Auction" status 
    for (Auction_Opportunity_Assignment__c aoa : NewMapAOA.values()) {
      if (aoa.Opportunity__c != null && aoa.Status__c != null && (aoa.MLH_Product_Type__c == 'Trustee' || aoa.MLH_Product_Type__c == 'FCL Marketing') && aoa.Status__c != OldMapAOA.get(aoa.Id).Status__c) {
        oppAoaMap.put(aoa.Opportunity__c, aoa);
      }
    }

    /**
     * Eliminated a query call unless there was an opportunity put onto the map. Removed the hardcoded ID from the query and 
     * put in the name so it's more readable.
     */
    if (!oppAoaMap.isEmpty()) {
      Map<Id, BPO__c> bposToUpdate = new Map<Id, BPO__c>();
      Set<Id> valuationIds = new Set<Id>();

      List<Opportunity> opps = 
        [SELECT Id, Most_Recent_Valuation__c
         FROM Opportunity
         WHERE Id IN :oppAoaMap.keySet()
         AND RecordType.Name = 'Trustee'
         AND Most_Recent_Valuation__c != null];

      for (Opportunity opp : opps) {
        valuationIds.add(opp.Most_Recent_Valuation__c);
      }

      // Eliminated one query by making a more generic query and pushed the business logic into the code below
      List<BPO__c> bpos = 
        [SELECT Id, Place_Photo_Order__c, Order_Status__c, Order_Placement_Date__c, Auction_Status__c
         FROM BPO__c
         WHERE Valuation__c IN :valuationIds
         AND (Auction_Status__c != 'Completed' OR Order_Placement_Date__c = null)
         ORDER BY CreatedDate DESC];

      for (BPO__c bpo : bpos) {
        if (!bposToUpdate.containsKey(bpo.Valuation__c)) {
          if (bpo.Auction_Status__c != 'Auction') {
            bpo.Place_Photo_Order__c = false;
            bposToUpdate.put(bpo.Valuation__c, bpo);
          } else if (bpo.Order_Placement_Date__c == null) {
            bpo.Place_Photo_Order__c = true;
            bposToUpdate.put(bpo.Valuation__c, bpo);
          }
        }
      }

      if (!bposToUpdate.isEmpty()) {
        update bposToUpdate.values();
      }
    }

    /**
     * Author: Luke Martell
     * Date: 5/4/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     *  
    Set<Id> OppId = new Set<Id>();    
    for(Auction_Opportunity_Assignment__c aoa : NewMapAOA.values()){      
       if(aoa.Opportunity__c!=null && (aoa.MLH_Product_Type__c == 'Trustee' || aoa.MLH_Product_Type__c == 'FCL Marketing') && aoa.Status__c != OldMapAOA.get(aoa.Id).Status__c && aoa.Status__c != ''){
            if(aoa.Status__c != 'Auction'){
              OppId.add(aoa.Opportunity__c);
              }
            else if( aoa.Status__c == 'Auction'){
                 OppId.add(aoa.Opportunity__c);
              } 
         }             
     }             
    List<Opportunity> oppList =  new List<Opportunity>([SELECT Id,RecordTypeId,Most_Recent_Valuation__c FROM Opportunity WHERE Id IN :OppId]);           
     Set<Id> valId = new Set<Id>();
     for(Opportunity opty: oppList){
                   if(opty.RecordTypeId == '012d0000000Swzi' && opty.Most_Recent_Valuation__c != null){
                       valId.add(opty.Most_Recent_Valuation__c);
                   }            
   }        
        
   List<BPO__C> Photolist = new List<BPO__C>();
   
   Set<Id> LatestValIds = new Set<Id>();
   list<BPO__C> VROList = [Select Id,Place_Photo_Order__c,Valuation__c,Order_Status__c,Order_placement_date__c,Auction_Status__c from BPO__c where Valuation__c IN:valId  AND Valuation__c != null AND Order_Status__c != 'Completed' ORDER BY CreatedDate DESC];
   
   for(BPO__C vro: VROList){ 
       if(!LatestValIds.contains(vro.Valuation__c)){
           if(vro.Auction_Status__c != 'Auction'){
               vro.Place_Photo_Order__c = False;
               Photolist.add(vro);
               LatestValIds.add(vro.Valuation__c);     
            }   
       }        
   }           
         
   Set<Id> LatestValIds1 = new Set<Id>();
   list<BPO__C> VROList1 = [Select Id,Place_Photo_Order__c,Valuation__c,Order_Status__c,Order_placement_date__c,Auction_Status__c from BPO__c where Valuation__c IN:valId  AND Valuation__c != null AND Order_placement_date__c = null ORDER BY CreatedDate DESC];
   
   for(BPO__C vro: VROList1){ 
       if(!LatestValIds1.contains(vro.Valuation__c)){
            if(vro.Auction_Status__c == 'Auction'){
               vro.Place_Photo_Order__c = True;
               Photolist.add(vro);
               LatestValIds1.add(vro.Valuation__c);     
       }    }    
   }           
   if(!Photolist.isEmpty())
     update Photolist;   
   */        
  }
   
  public void UpdatebidfromAOA(Map<Id,Auction_Opportunity_Assignment__c> newMap, Map<Id,Auction_Opportunity_Assignment__c> oldMap) {
    
    Set<Id> aoaIds = new Set<Id>();    
        
    for(Auction_Opportunity_Assignment__c  aoa: newMap.values()){
      aoaIds.add(aoa.Id);                
    }
       
    if(!aoaIds.isEmpty()){
      List<Bid__c> winningBids = [SELECT Id, OwnerId,Winning_Bid__c,Auction_Opportunity_Assignment__c,MLH_Bid_Stage__c FROM Bid__c
                      WHERE Auction_Opportunity_Assignment__c IN: aoaIds AND Winning_Bid__c = True];
    

      if(!winningBids.isEmpty()){
        List<Bid__c> updateBids = new List<Bid__c>();
        for(Bid__c bid : winningBids){
          String status = newMap.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c;
          String oldStatus = (!Trigger.isInsert) ? oldMap.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c : null;
          String stage = newMap.get(bid.Auction_Opportunity_Assignment__c).Stage__c;
          String oldStage = (!Trigger.isInsert) ? oldMap.get(bid.Auction_Opportunity_Assignment__c).Stage__c : null;

          if(status != oldStatus && status == 'Escrow In Progress'){
            bid.OwnerId = '005d0000002jB6P'; 
            updateBids.add(bid);
          }

          if(stage != oldStage && stage != null){
            bid.MLH_Bid_Stage__c = stage;
            updateBids.add(bid);
          }
        }
        
        if(!updateBids.isEmpty()){
          update updateBids; 
        }
      }
    }



    /**
     * Author: Kilian Davis
     * Date: 6/24/2015
     * Comments:
     * Modified to be more efficient with the use of SOQL query and DML executions.
     
     Set<Id> AOAId = new Set<Id>();    
     List<Bid__c> WinningbidList = new List<Bid__c>();
        
    for(Auction_Opportunity_Assignment__c  aoa: NewMapAOA.values()) {
            AOAId.add(aoa.Id);                
        }
       
     WinningbidList = [SELECT Id, OwnerId,Winning_Bid__c,Auction_Opportunity_Assignment__c,MLH_Bid_Stage__c FROM Bid__c
                      WHERE Auction_Opportunity_Assignment__c IN: AOAId AND Winning_Bid__c = True];

    List<Bid__c> UpdateBidList = new List<Bid__c>();
    for (Bid__c bid : WinningbidList) {    
            If((OldMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c) != (NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c) &&
               (NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c) == 'Escrow In Progress'){
                    bid.OwnerId = '005d0000002jB6P'; 
             }               
            If((OldMapAOA.get(bid.Auction_Opportunity_Assignment__c).Stage__c) != (NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Stage__c) &&
               (NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Stage__c) != null){
                    bid.MLH_Bid_Stage__c = (NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Stage__c);
             }
       UpdateBidList.add(bid);      
      }
      
      
      if(!UpdateBidList.isEmpty())
         update UpdateBidList; 
    */
  }     


      
    ////Find Winning Bid    
    public void Findwinningbid(Map<Id,Auction_Opportunity_Assignment__c> NewMapAOA) {
         
        Set<Id> AOAId = new Set<Id>();    
        Set<String> WinningBidRecords = new Set<String>();  
            
        for(Auction_Opportunity_Assignment__c  aoa: NewMapAOA.values()) {
            //Commented the condition to allow uncheck all Bids when AOA Aution Day Status is set to Fall Out
            //if(aoa.Most_Recent_AOA__c == true && aoa.MLH_Winning_Bidder_ID__c!=null  && aoa.MLH_Winning_Bidder_ID__c!= '-1' && aoa.MLH_Auction_ID__c!=null && aoa.MLH_Auction_ID__c!= '-1' && aoa.MLH_Property_Id__c!=null) {
                AOAId.add(aoa.Id);                
            //}
            if(aoa.MLH_Winning_Bidder_ID__c!=null  && aoa.MLH_Winning_Bidder_ID__c!= '-1' && aoa.MLH_Auction_ID__c!=null && aoa.MLH_Auction_ID__c!= '-1' && aoa.MLH_Final_Sale_Price__c!=null && aoa.MLH_Final_Sale_Price__c > 0 && aoa.MLH_Property_Id__c!=null 
               && !CONSTANTS.aoaFalloutStatuses.Contains(aoa.Auction_Day_Status__c)) {
                WinningBidRecords.add(aoa.MLH_Winning_Bidder_ID__c+aoa.MLH_Auction_ID__c+aoa.MLH_Property_Id__c+String.valueof(aoa.MLH_Final_Sale_Price__c));
                system.debug(' Winning Bids : ' +WinningBidRecords);
            }
        }                                               

        List<Bid__c> bidList = new List<Bid__c>();
        Map<Id,Bid__c> updatebidList = new Map<Id,Bid__c>();
        List<Opportunity> OppList = new List<Opportunity>();
   
        bidList = [SELECT Id, MLH_Bidder_ID__c,MLH_Asset_ID__c,MLH_Team__c,MLH_Auction_ID__c,Bid_Amount__c,Winning_Bid__c,Opportunity__c,Auction_Opportunity_Assignment__c,Bid_Registration_Email__c,Bid_Registration_First_Name__c,Bid_Registration_Last_Name__c 
                   FROM Bid__c
                   WHERE Auction_Opportunity_Assignment__c IN: AOAId AND MLH_Bidder_ID__c!=null AND 
                         MLH_Bidder_ID__c!='1' AND MLH_Auction_ID__c!=null AND MLH_Asset_ID__c!=null 
                         AND Bid_Amount__c > 0
                   ORDER BY Auction_Opportunity_Assignment__c,LastModifiedDate DESC];
        system.debug(' SELECT Bids : ' +bidList);
        Set<Id> UpdateWinningOppIds     = new Set<Id>(); 
        Set<Id> RemovedWinningBidIds    = new Set<Id>();
        Set<String> trueWinningBidKey   = new Set<String>();
        if(!bidList.isEmpty()) {
            for (Bid__c bid : bidList) {                  
                if(WinningBidRecords.contains(bid.MLH_Bidder_ID__c+bid.MLH_Auction_ID__c+bid.MLH_Asset_ID__c+String.valueof(bid.Bid_Amount__c))
                   && !CONSTANTS.aoaFalloutStatuses.Contains(NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c)) {
                    bid.Winning_Bid__c = true;
                    bid.True_Winning_bid__c=true;
                    if(NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).MLH_Team__c!=null)  {
                        bid.MLH_Team__c = NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).MLH_Team__c; 
                    }
                    trueWinningBidKey.add(bid.Auction_Opportunity_Assignment__c);
                    updatebidList.put(bid.Id,bid);

                    if(bid.Opportunity__c!=null && !UpdateWinningOppIds.contains(bid.Opportunity__c)) {
                       // #00410648 - 2-9-2014 Murali Guntakal
                       Opportunity opp = new Opportunity();
                       opp.Id=bid.Opportunity__c;
                       opp.Winning_BidLookup__c=bid.Id;
                       opp.Winning_Bid_Amount__c=bid.Bid_Amount__c;
                       if(bid.Opportunity_Record_Type__c == Label.Commercial_Opportunity_Rectype_Id) {
                           opp.StageName='Stage 6. Closing';
                           if(NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c != null && NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c == 'Contract Complete') {
                               opp.StageName='Closed Won';
                           }
                       }
                       opp.Winning_Bidder_Email__c=bid.Bid_Registration_Email__c;
                       opp.Winning_Bidder_First_Name__c=bid.Bid_Registration_First_Name__c;
                       opp.Winning_Bidder_Last_Name__c=bid.Bid_Registration_Last_Name__c;
                       opp.Winning_Bid_AOA__c = bid.Auction_Opportunity_Assignment__c;
                       OppList.add(opp);
                       // #00410648
                       UpdateWinningOppIds.add(bid.Opportunity__c);
                    }   
                }
            }                    

            for (Bid__c bid : bidList) {                                        
                 System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+OppList);
                  if((trueWinningBidKey.contains(bid.Auction_Opportunity_Assignment__c)
                       && !WinningBidRecords.contains(bid.MLH_Bidder_ID__c+bid.MLH_Auction_ID__c+bid.MLH_Asset_ID__c+String.valueof(bid.Bid_Amount__c))) 
                       || CONSTANTS.aoaFalloutStatuses.Contains(NewMapAOA.get(bid.Auction_Opportunity_Assignment__c).Auction_Day_Status__c)) {
                       bid.Winning_Bid__c = false;
             bid.True_Winning_bid__c=false;
                       RemovedWinningBidIds.add(bid.Id);
                       updatebidList.put(bid.Id,bid);
                     
                       if(bid.Opportunity__c!=null && !UpdateWinningOppIds.contains(bid.Opportunity__c)) {
                           Opportunity opp = new Opportunity();
                           opp.Id=bid.Opportunity__c;
                           opp.Winning_BidLookup__c=null;
                           opp.Winning_Bid_Amount__c=null;
                           opp.Winning_Bidder_Email__c=null;
                           opp.Winning_Bidder_First_Name__c=null;
                           opp.Winning_Bidder_Last_Name__c=null;
                           opp.Winning_Bid_AOA__c = null;
                       	   if(bid.Opportunity_Record_Type__c == Label.Commercial_Opportunity_Rectype_Id) {
                           	   opp.StageName='Stage 6. Closing';
                       	   }	                                   
                           OppList.add(opp);
                           System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+OppList);                                                  
                           UpdateWinningOppIds.add(bid.Opportunity__c);
                       }
                  }
             }                
        }           

         if(!RemovedWinningBidIds.isEmpty()) {
             List<CallRecord__c> omittedCallRecords = new List<CallRecord__c> ([SELECT Id, CallDisposition__c FROM CallRecord__c WHERE Bid__c IN :RemovedWinningBidIds AND CallDisposition__c = :CONSTANTS.NEED_FOLLOWUP_DISPOISTION]);

             for(CallRecord__c cr : omittedCallRecords) {
                cr.CallDisposition__c = CONSTANTS.OMITTED_DISPOISTION;
             }
             Update omittedCallRecords;              
         }
         if(!updatebidList.isEmpty())   
            update updatebidList.values();
        
         if(!oppList.isEmpty())
            Update oppList;
 }   
      
}