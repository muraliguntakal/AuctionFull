//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To Update the Winning BidLookup in Opportunity with Winning Bid
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota on 02/20/2014 */ 
// Modified By                    Modified Date                                    What Changed                                                    Reason

//****************************************************************************************************************************************************************************************** 
public with sharing class WinningBidClass{

  public static void UpdateWinningBid(List<Bid__c> BDLIST,  Map<Id, Bid__c> oldbid, Boolean isInsert){
         
         set<Id> oppIdSet = new set<Id>();         
         for(Bid__c bd:BDLIST) {
             if(bd.Opportunity__c != null && bd.Winning_Bid__c && bd.Opportunity_Record_Type__c != Label.Parent_Opportunity && 
                                                                  bd.Opportunity_Record_Type__c != Label.Opportunity_Record_TypeId_Trustee &&
                                                                  bd.Opportunity_Record_Type__c != Label.Commercial_Opportunity_Rectype_Id) {
                 if(bd.MLH_Bid_Stage__c!=null && bd.MLH_Bid_Stage__c == 'Contract Complete') {   
                     if(isInsert) {
                         oppIdSet.add(bd.Opportunity__c);
                     }
                     else {
                         if(oldbid.get(bd.id).MLH_Bid_Stage__c != 'Contract Complete') {
                             oppIdSet.add(bd.Opportunity__c);                                       
                         }                           
                     }
                 }
             }
         }
                  
         List<Opportunity> opplist = new List<Opportunity>();              
         for(Opportunity opty: [Select Id,StageName,Status__c From Opportunity where Id IN:oppIdSet]) {                                               
             oppList.add(new Opportunity(Id=Opty.Id,StageName = 'Stage 6. Closing',Status__c = 'Pending Seller Contract'));                                                                    
         }                   
         Database.Update(oppList,false);                                             
   }
   
   
   public static void BidRollUp(List<Bid__c> newbidlist,  List<Bid__c> oldbidlist, Boolean isDelete) {
  
      Set<Id> ConId = new Set<Id>();
      Set<Id> BidId = new Set<Id>();
            
      if( trigger.isDelete ) {
             for(Bid__c oldval: oldbidlist)
            {
                if(oldval.Buyer_Name__c!=null)
                 {
                    ConId.add(oldval.Buyer_Name__c);
                    BidId.add(oldval.Id);
                 }   
            }
        }
        else
        {
            for(Bid__c newval: newbidlist)
            {
                ConId.add(newval.Buyer_Name__c);
                BidId.add(newval.Id);
            }
        }
       
        List<Contact> winningBids = [SELECT Id,(SELECT Id FROM  Bids__r where Winning_Bid__c = true) FROM Contact WHERE Id IN :ConId];
        Map<Id, Integer> TrueBidsMap = new Map<Id, Integer> ();            
        for(Contact con: winningBids)   {                
                List<Bid__c> relatedRecords = con.getSObjects('Bids__r');
                if(relatedRecords!=null){
                    TrueBidsMap.put(con.Id, relatedRecords.size());
                }
                else{
                      TrueBidsMap.put(con.Id, 0);          
                }               
        }
         
        //Commercial Bids by Contact
        List<Contact> CommercialBids = [SELECT Id,(SELECT Id FROM  Bids__r where AOA_Product_Type__c = 'Commercial' and MLH_Bidder_ID__c >= '1') FROM Contact WHERE Id IN :ConId];
        Map<Id, Integer> CommercialBidsMap = new Map<Id, Integer> ();            
        for(Contact con: CommercialBids)   {                
                List<Bid__c> relatedRecords = con.getSObjects('Bids__r');
                if(relatedRecords!=null){
                    CommercialBidsMap.put(con.Id, relatedRecords.size());
                    }
                 else {
                        CommercialBidsMap.put(con.Id, 0);       
                      }                      
        }

        //Commercial Bids Won by Contact
        List<Contact> CommercialBidsWon = [SELECT Id,(SELECT Id FROM  Bids__r WHERE Winning_Bid__c=TRUE AND AOA_Product_Type__c = 'Commercial' and MLH_Bidder_ID__c >= '1') FROM Contact WHERE Id IN :ConId];
        Map<Id, Integer> CommercialBidsWonMap = new Map<Id, Integer> ();            
        for(Contact con: CommercialBidsWon)   {                
            List<Bid__c> relatedRecords = con.getSObjects('Bids__r');
            if(relatedRecords!=null){
                CommercialBidsWonMap.put(con.Id, relatedRecords.size());
            }
            else {
                CommercialBidsWonMap.put(con.Id, 0);       
            }                      
        }

        
        List<Contact> countBids = [SELECT Id,of_Bids__c,of_Winning_Bids__c,Number_Of_Commercial_Bids__c,Of_Commercial_Bids_Won__c,(SELECT Id FROM  Bids__r WHERE MLH_Bidder_ID__c >= '1') FROM Contact WHERE Id IN :ConId];
        
        for(Contact con: countBids)   {                
                    List<Bid__c> relatedRecords = con.getSObjects('Bids__r');
                    if(relatedRecords!=null) {
                          con.of_Bids__c = relatedRecords.size();
                          if(TrueBidsMap.containsKey(con.Id)) {
                              con.of_Winning_Bids__c =  TrueBidsMap.get(con.Id);
                          }
                          if(CommercialBidsMap.containsKey(con.Id)) {
                              con.Number_Of_Commercial_Bids__c =  CommercialBidsMap.get(con.Id);
                          }
                          if(CommercialBidsWonMap.containsKey(con.Id)) {
                              con.Of_Commercial_Bids_Won__c =  CommercialBidsWonMap.get(con.Id);
                          }                                             
                    }
                    else {
                           con.of_Bids__c = 0;                 
                           con.of_Winning_Bids__c =  0;
                           con.Number_Of_Commercial_Bids__c = 0;
                           con.Of_Commercial_Bids_Won__c = 0;   
                    }                                     
        }

        if(!countBids.IsEmpty())
        {
          update countBids;
        } 
         

    }


 public static void CreateContractingRoles(Map<Id, Bid__c> NewBidMap, Map<Id, Bid__c> OldBidMap){
         
         List<Contracting_Role__c> crlist = new List<Contracting_Role__c>();
         List<Bid__c> bdlist = new List<Bid__c>();
         
         for(Bid__c bds: NewBidMap.Values()) {
         
            If ((OldBidMap.get(bds.Id).OwnerId != NewBidMap.get(bds.Id).OwnerId) || (OldBidMap.get(bds.Id).MLH_Bid_Stage__c != NewBidMap.get(bds.Id).MLH_Bid_Stage__c && bds.MLH_Bid_Stage__c == 'Contract Complete')) 
            {                            
               Contracting_Role__c cr = new Contracting_Role__c(Bid__c=bds.Id, User__c=bds.OwnerId, MLH_Bid_Stage__c=bds.MLH_Bid_Stage__c); 
               crlist.add(cr);               
            }  
         }  
        Insert crlist;                 
  }
                        
}