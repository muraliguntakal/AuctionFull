public class AuctionCampaignUtils {

	public static void validateAuctionCampaignUpdates(List<Auction_Campaign__c> newList, List<Auction_Campaign__c> oldList, Map<Id, Auction_Campaign__c> oldMap){
		if(Trigger.isInsert && Trigger.isBefore){
			for(Auction_Campaign__c auc : newList){
				String eventId = (String)auc.get('MLH_Event_ID__c');
				String venueCode = (String)auc.get('Venue_Number__c');

				if(eventId != null && eventId.substring(0,2) == 'O-' && venueCode != null){
					auc.put('Merge_Auction__c', true);
				}
			}
		}
	}

	public static void scheduleAuctionMerge(List<Auction_Campaign__c> newList){
		Boolean shouldExecute = false;

		if(Trigger.isInsert && Trigger.isAfter){			
			for(Auction_Campaign__c auc : newList){
				Boolean mergeAuction = (Boolean)auc.get('Merge_Auction__c');
				String eventId = (String)auc.get('MLH_Event_ID__c');
				String venueCode = (String)auc.get('Venue_Number__c');

				if(mergeAuction && eventId != null && venueCode != null){
					shouldExecute = true;
					break;
				}
			}
		}

		if(shouldExecute){
			SystemSettings__c ss = null;
	    	Boolean isRunning = false;

	    	if (SystemSettings__c.getAll().containsKey('AuctionCampaignMergeJobId')) {
	    		ss = SystemSettings__c.getAll().get('AuctionCampaignMergeJobId');

	    		if (ss.Value__c != null) {
	    			try {
		    			AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE ID = :ss.Value__c];
		    			isRunning = (job.Status != 'Completed' && job.Status != 'Aborted' && job.Status != 'Failed');
		    		} catch (System.Exception e) {}
	    		}
	  		} else {
	  			ss = new SystemSettings__c(Name = 'AuctionCampaignMergeJobId');
	  			insert ss;
	  		}

	  		if (!isRunning) {
	  			String jobId = System.enqueueJob(new AuctionCampaignMergeJob());

	  			ss.Value__c = jobId;
	  			update ss;
	  		}
		}
	}
}