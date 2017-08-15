trigger AuctionCampaignTrigger on Auction_Campaign__c (before insert, after insert) {
	AuctionCampaignUtils.validateAuctionCampaignUpdates(Trigger.new, Trigger.old, Trigger.oldMap);
	AuctionCampaignUtils.scheduleAuctionMerge(Trigger.new);
}