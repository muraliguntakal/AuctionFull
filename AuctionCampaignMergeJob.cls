global class AuctionCampaignMergeJob implements Queueable {

	global void execute(QueueableContext bc) {
				
		List<Auction_Campaign__c> auctionsForUpdate = new List<Auction_Campaign__c> ();
		
		//
		Map<String, Auction_Campaign__c> auctionScope = new Map<String, Auction_Campaign__c> ();

		//
		Set<String> campaignIds = new Set<String> ();
		Set<String> eventIds = new Set<String> ();
		Set<String> venueCodes = new Set<String> ();

		//
		String mergeFldsStr = AuctionCampaignMerge.queryFldsStr();
		List<Auction_Campaign__c> scope = (List<Auction_Campaign__c>)database.query('SELECT Id, '+mergeFldsStr+', MLH_Event_ID__c, Venue_Number__c, SF_Integration_ID__c, (SELECT Id, Auction_Campaign__c FROM Auction_Opportunity_Assignments__r) FROM Auction_Campaign__c WHERE Merge_Auction__c = true');
		for(Auction_Campaign__c auc : scope){
			String eventId = (String)auc.get('MLH_Event_ID__c');
			String venueCode = (String)auc.get('Venue_Number__c');

			if(eventId != null && eventId.substring(0,2) == 'O-' && venueCode != null){
				campaignIds.add(auc.Id);

				String uId = eventId+venueCode;
				eventIds.add(eventId);
				venueCodes.add(venueCode);

				auctionScope.put(uId, auc);
			}
		}
		
		Map<String, AuctionCampaignMerge> mergeMap = new Map<String, AuctionCampaignMerge> ();
		List<Auction_Campaign__c> auctionsForDelete = new List<Auction_Campaign__c> ();

		if(!eventIds.isEmpty() && !venueCodes.isEmpty()){

			Map<String, Auction_Campaign__c> duplicateAuctions = getDuplicateAuctions(campaignIds ,eventIds, venueCodes);
			for(String uId : auctionScope.keySet()){
				Auction_Campaign__c campaign = auctionScope.get(uId);
				campaign.put('Merge_Auction__c', false);

				Auction_Campaign__c auctionForUpdate = campaign;

				if(duplicateAuctions.containsKey(uId)){					
					AuctionCampaignMerge auctionMerge = new AuctionCampaignMerge(uId);
					Boolean mergeResult = auctionMerge.mergeAuctions(campaign, duplicateAuctions.get(uId));

					if(mergeResult){
						auctionForUpdate = auctionMerge.mergeCampaign;
						mergeMap.put(auctionForUpdate.Id, auctionMerge);

						auctionsForDelete.add(auctionMerge.deleteCampaign);
					}
				}

				auctionsForUpdate.add(auctionForUpdate);
			}
		}
				
		//delete the duplicate campaigns
		Map<String, Database.DeleteResult> deleteResults = new Map<String, Database.DeleteResult>();
		if(!auctionsForDelete.isEmpty()){
			List<Database.DeleteResult> results = Database.delete(auctionsForDelete, false);
			for(Database.DeleteResult dr : results){
				String id = dr.getId();
				deleteResults.put(id, dr);
			}
		}		

		//update the active auctions with the merged details
		if(!auctionsForUpdate.isEmpty()){

			List<Auction_Opportunity_Assignment__c> aoasForUpdate = new List<Auction_Opportunity_Assignment__c> ();
			List<Auction_Campaign__c> auctionsForUndelete = new List<Auction_Campaign__c> ();
			List<Database.SaveResult> results = Database.update(auctionsForUpdate, false);

			//only reassign aoas and delete old campaigns if update was successful
			for(Database.SaveResult sr : results){
				String aucId = sr.getId();

				if(mergeMap.containsKey(aucId)){	
					AuctionCampaignMerge auctionMerge = mergeMap.get(aucId);

					if(sr.isSuccess()){
						//add aoas for update
						if(auctionMerge.reassignedAoas != null && !auctionMerge.reassignedAoas.isEmpty()){
							aoasForUpdate.addAll(auctionMerge.reassignedAoas);
						}
					}else{
						Auction_Campaign__c deleteCampaign = auctionMerge.deleteCampaign;
						if(deleteCampaign != null && deleteResults.containsKey(deleteCampaign.Id) && deleteResults.get(deleteCampaign.Id).isSuccess()){
							auctionsForUndelete.add(deleteCampaign);
						}
					}
				}
			}

			//update the reassigned aoas
			if(!aoasForUpdate.isEmpty()){
				update aoasForUpdate;
			}

			//undelete auctions where the merged event failed to update
			if(!auctionsForUndelete.isEmpty()){
				Database.undelete(auctionsForUndelete, false);
			}

			//chain next execution
		    if(!Test.isRunningTest()){
	            String jobId = System.enqueueJob(new AuctionCampaignMergeJob());

	            SystemSettings__c ss = SystemSettings__c.getAll().get('AuctionCampaignMergeJobId');
	            ss.Value__c = jobId;
	            update ss;
	        }
		}
	}

	public static Map<String, Auction_Campaign__c> getDuplicateAuctions(Set<String> campaignIds, Set<String> eventIds, Set<String> venueCodes){
		Map<String, Auction_Campaign__c> duplicateAuctions = new Map<String, Auction_Campaign__c> ();
		String mergeFldsStr = AuctionCampaignMerge.queryFldsStr();

		if(!eventIds.isEmpty() && !venueCodes.isEmpty()){
			for(Auction_Campaign__c auc : (List<Auction_Campaign__c>)database.query('SELECT Id,'+mergeFldsStr+', MLH_Event_ID__c, Venue_Number__c, SF_Integration_ID__c, (SELECT Id, Auction_Campaign__c FROM Auction_Opportunity_Assignments__r) FROM Auction_Campaign__c WHERE ID NOT IN : campaignIds AND MLH_Event_ID__c IN : eventIds AND Venue_Number__c IN : venueCodes')){
				String eventId = (String)auc.get('MLH_Event_ID__c');
				String venueCode = (String)auc.get('Venue_Number__c');
				String uId = eventId+venueCode;

				duplicateAuctions.put(uId, auc);
			}
		}

		return duplicateAuctions;
	}
}