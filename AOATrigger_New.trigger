trigger AOATrigger_New on Auction_Opportunity_Assignment__c (before insert, after insert, before update, after update) {

	AOAUtils.validateAoaUpdates(Trigger.new, Trigger.oldMap);
	AOAUtils.validateOpportunityUpdates(Trigger.new, Trigger.oldMap);
	AOAUtils.validateMostRecentAOAUpdates(Trigger.new, Trigger.oldMap);
	AOAUtils.validateBidUpdates(Trigger.new, Trigger.oldMap);
	AOAUtils.validateBpoUpdates(Trigger.new, Trigger.oldMap);	
	AOAUtils.validateAOASellerCode(Trigger.new, Trigger.oldMap);
}