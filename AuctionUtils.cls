public class AuctionUtils {

    Public static void ValidateOpportunityStageUpdates(List< Auction_Campaign__c > newList, Map<Id, Auction_Campaign__c> oldMap) {
        Set<Id> selectedAuctionIds = new Set<Id>();
        for(Auction_Campaign__c auc : newList) {
            String eventId = (String)auc.get('MLH_Event_ID__c');             
            System.debug('BST =>' +Date.Valueof(auc.Bidding_Start_Time__c));
            System.debug('BET =>' +Date.Valueof(auc.Bidding_End_Time__c));
                      
            if(eventId != null && (eventId.substring(0,2) == 'B-' || eventId.substring(0,2) == 'N-')) {
                if((((auc.Bidding_Start_Time__c!=oldMap.get(auc.Id).Bidding_Start_Time__c) ||
                     (auc.Bidding_End_Time__c!=oldMap.get(auc.Id).Bidding_End_Time__c)) && 
                     (System.Today() >= date.valueof(auc.Bidding_Start_Time__c) && System.Today() <= Date.Valueof(auc.Bidding_End_Time__c) && auc.Active_Auction_Event__c)) || 
                    (auc.Active_Auction_Event__c && auc.Active_Auction_Event__c!=oldMap.get(auc.Id).Active_Auction_Event__c)) 
                {
                    selectedAuctionIds.add(auc.Id);
                }
            }
        }

        if(!selectedAuctionIds.isEmpty()) {
            System.debug('Kick Start Batch =>' +selectedAuctionIds);
            ID jobID = System.enqueueJob(new OpportunityStageUpdateJob(selectedAuctionIds));    
        }        
    }    
}