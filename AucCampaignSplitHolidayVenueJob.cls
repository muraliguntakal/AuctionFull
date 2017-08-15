public class AucCampaignSplitHolidayVenueJob implements Queueable{

	public void execute(QueueableContext bc) {

/*
		List<Auction_Campaign__c> auctionsForUpsert = new List<Auction_Campaign__c> ();
		List<Auction_Campaign__c> scope = (List<Auction_Campaign__c>)database.query('SELECT Id, CreatedDate, Auction_Name__c, Auction_Region_Resi__c, Auction_State__c, Bidding_End_Time__c, Bidding_Start_Time__c, MLH_Event_Id__c, MLH_Auction_Id__c, MLH_Venue_Id__c, Open_House_1_Date__c, Open_House_2_Date__c, Product_Type__c, SF_Calendar_Event_ID__c, Split_Holiday_Venue__c, Venue_Group__c, Venue_Name__c, Venue_Number__c FROM Auction_Campaign__c WHERE Split_Holiday_Venue__c = true');

		if(!scope.isEmpty()){
			Set<String> eventIds = new Set<String> ();
			Set<String> venueNames = new Set<String> ();
			Integer dateRange = 0;
			for(Auction_Campaign__c venue : scope){
				String eventId = (String)venue.get('MLH_Event_Id__c');
				String venueName = (String)venue.get('Venue_Name__c');
				Datetime createdDate = (Datetime)venue.get('CreatedDate');

				if(eventId != null && venueName != null){
					eventIds.add(eventId);
					venueNames.add(venueName);
				}

				if(createdDate.date().daysBetween(Date.today()) > dateRange){
					dateRange = createdDate.date().daysBetween(Date.today());
				}
			}

			if(!eventIds.isEmpty() && !venueNames.isEmpty()){
				Map<String, List<Auction_Campaign__c>> campaignMap = searchVenuesForMatch(eventIds, venueNames, dateRange);

				Boolean splitVenue = true;
				for(Auction_Campaign__c venue : scope){

					venue.put('Split_Holiday_Venue__c', false);
					String eventId = (String)venue.get('MLH_Event_Id__c');
					String venueName = (String)venue.get('Venue_Name__c');

					if(!campaignMap.containsKey(venueName+'-'+eventId)){
						splitVenue = false;
					}else{
						for(Auction_Campaign__c matchedVenue : campaignMap.get(venueName+'-'+eventId)){
							Datetime bidStart = (Datetime)venue.get('Bidding_Start_Time__c');
							Datetime matchedBidStart = (Datetime)matchedVenue.get('Bidding_Start_Time__c');

							if(matchedBidStart != null && Math.abs(bidStart.date().daysBetween(matchedBidStart.date())) > 4){
								splitVenue = false;
								break;
							}
						}						
					}

					if(splitVenue){
						Auction_Campaign__c newAuction = cloneHolidayVenue(venue);
						auctionsForUpsert.add(newAuction);
					}
					
					auctionsForUpsert.add(venue);
				}
			}

			if(!auctionsForUpsert.isEmpty()){
				List<Database.UpsertResult> results = database.upsert(auctionsForUpsert, Auction_Campaign__c.Fields.SF_Calendar_Event_ID__c, false);
				for(Database.UpsertResult sr : results){
					if(!sr.isSuccess()){
						for(Database.Error err : sr.getErrors()){
							System.debug('****Upsert Error****  '+err);
						}
					}
				}
			}

			if(!Test.isRunningTest()){
				String jobId = System.enqueueJob(new AucCampaignSplitHolidayVenueJob());

				SystemSettings__c ss = SystemSettings__c.getAll().get('SplitHolidayVenueJob');
				ss.Value__c = jobId;
				update ss;
			}
		}
	}

	public Map<String, List<Auction_Campaign__c>> searchVenuesForMatch(Set<String> eventIds, Set<String> venueNames, Integer dateRange){

		Map<String, List<Auction_Campaign__c>> campaignMap = new Map<String, List<Auction_Campaign__c>> ();

		for(Auction_Campaign__c venue : (List<Auction_Campaign__c>)database.query('SELECT Id, Venue_Group__c, MLH_Event_Id__c, Venue_Name__c, Bidding_End_Time__c, Bidding_Start_Time__c FROM Auction_Campaign__c WHERE MLH_Event_Id__c IN :eventIds AND Venue_Name__c IN :venueNames AND CreatedDate = Last_N_Days:'+String.valueOf(dateRange+1))){
			String venueName = (String)venue.get('Venue_Name__c');
			String eventId = (String)venue.get('MLH_Event_Id__c');
			
			if(!campaignMap.containsKey(venueName+'-'+eventId)){
				campaignMap.put(venueName+'-'+eventId, new List<Auction_Campaign__c>());
			}

			List<Auction_Campaign__c> venues = campaignMap.get(venueName+'-'+eventId);
			venues.add(venue);
			campaignMap.put(venueName+'-'+eventId, venues);
		}

		return campaignMap;
	}

	public Auction_Campaign__c cloneHolidayVenue(Auction_Campaign__c venue){
		String venueGroup = (String)venue.get('Venue_Group__c') == 'A' ? 'B' : 'A';
		Datetime bidStart = (Datetime)venue.get('Bidding_Start_Time__c');
        String venueCode = (String)venue.get('Venue_Number__c');
        String eventId = (String)venue.get('MLH_Event_Id__c');        
        String newVenueId = (String)venue.get('MLH_Venue_Id__c') != null ? (String)venue.get('MLH_Venue_Id__c')+'-'+venueGroup : null;

		Auction_Campaign__c clonedVenue = venue.clone(false);
		clonedVenue.put('Venue_Group__c', venueGroup);		
		clonedVenue.put('SF_Calendar_Event_ID__c', eventId+'-'+venueCode+'-'+String.valueOf(bidStart.date())+'-'+venueGroup);
		clonedVenue.put('MLH_Venue_Id__c', newVenueId);
		clonedVenue.put('Is_Holiday__c', true);

		return clonedVenue;
	}
*/
	}
}