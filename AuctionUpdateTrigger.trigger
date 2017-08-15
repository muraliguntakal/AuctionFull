trigger AuctionUpdateTrigger on Auction_Campaign__c (after update) {
    if(Trigger.isUpdate) {
        TriggerSettings__c ts = TriggerSettings__c.getValues('ValidateOpportunityStageUpdates');
        if(ts.Status__c) {
            AuctionUtils.ValidateOpportunityStageUpdates(Trigger.new, Trigger.oldMap);
        }
    }
}