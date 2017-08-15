trigger UpdateOffertoAOA on Offer__c (after update) {
//if(TriggerSettings__c.getValues('UpdateOffertoAOA').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('UpdateOffertoAOA');
  if (ts != null && ts.Status__c) {

 map<Id,Offer__c> offrmap = new map<Id,Offer__c>();
  
 for(Offer__c offr: Trigger.new){  
                                                
     if((offr.Last_Call_Disposition__c != Trigger.oldMap.get(offr.Id).Last_Call_Disposition__c) || (offr.Fall_Out_Reason__c != Trigger.oldMap.get(offr.Id).Fall_Out_Reason__c) ||
         (offr.Offer_Disposition__c != Trigger.oldMap.get(offr.Id).Offer_Disposition__c) || (offr.Recapture_Disposition__c != Trigger.oldMap.get(offr.Id).Recapture_Disposition__c)
           || (offr.Created_from_Bid__c != Trigger.oldMap.get(offr.Id).Created_from_Bid__c) || (offr.Bid_Specialist__c != Trigger.oldMap.get(offr.Id).Bid_Specialist__c))
     {                              
             if(offr.Auction_Opportunity_Assignment__c != null || offr.Auction_Opportunity_Assignment__c != ''){                                                   
               offrmap.put(offr.Auction_Opportunity_Assignment__c, offr);    
             }            
        }                            
     }
                     
                     ////Count Number of Offers Created from Bid
     List<Auction_Opportunity_Assignment__c> countBidOffers = [SELECT Id,(SELECT Id FROM Offers__r WHERE Created_from_Bid__c = True) FROM Auction_Opportunity_Assignment__c WHERE Id IN :offrmap.KeySet()];
     Map<Id, Integer> TrueBidsMap = new Map<Id, Integer> ();   
     if(!countBidOffers.isEmpty())   {          
         for(Auction_Opportunity_Assignment__c oaoa: countBidOffers) {                            
            List<Offer__c> relatedRecords = oaoa.getSObjects('Offers__r');                                
            if(relatedRecords!=null) {
              TrueBidsMap.put(oaoa.Id, relatedRecords.size());
            }
            else {
              TrueBidsMap.put(oaoa.Id, 0);   
            }      
         }    
     }
                 
                    List<Auction_Opportunity_Assignment__c> AOAlist = new List<Auction_Opportunity_Assignment__c>();     
                    AOAlist = [SELECT Id,Offer_Disposition__c,Fall_Out_Reason__c  FROM Auction_Opportunity_Assignment__c WHERE Id IN:offrmap.KeySet()];   
                    
                    List<Auction_Opportunity_Assignment__c> AOAUpdate = new List<Auction_Opportunity_Assignment__c>();  
                       if(!AOAlist.isEmpty()) {
                         for(Auction_Opportunity_Assignment__c aoa: AOAlist){
                               if(offrmap.ContainsKey(aoa.Id)){
                                    aoa.Offer_Disposition__c = offrmap.get(aoa.Id).Offer_Disposition__c;    
                                    aoa.Last_Call_Disposition__c = offrmap.get(aoa.Id).Last_Call_Disposition__c;
                                    aoa.Recapture_Disposition__c = offrmap.get(aoa.Id).Recapture_Disposition__c;
                                    aoa.Fall_Out_Reason__c = offrmap.get(aoa.Id).Fall_Out_Reason__c;      
                                    aoa.Bid_Specialist_From_Offer__c = offrmap.get(aoa.Id).Bid_Specialist__c;
                                     if(TrueBidsMap.containsKey(aoa.Id)) {
                                            aoa.Offers_Created_from_Bid__c=  TrueBidsMap.get(aoa.Id);
                                        }
                                      else{
                                            aoa.Offers_Created_from_Bid__c=0;
                                       }                          
                                }
                            AOAUpdate.add(aoa);
                          }     
                        }  
                                                 
                        if(!AOAUpdate.isEmpty()) { 
                           Update AOAUpdate;
                          }  
      }                       
}