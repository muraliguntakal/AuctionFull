public class AucCampaignHolidayValidator {

	public List<Auction_Campaign__c> holidayAuctions;
	public Set<Date> holidays;	

	public AucCampaignHolidayValidator() {
		holidayAuctions = new List<Auction_Campaign__c> ();
		List<Holiday_Calendar__c> cal = Holiday_Calendar__c.getall().values();		

		for(Holiday_Calendar__c holiday : cal){
			holidays.add((Date)holiday.get('Date__c'));
		}
	}

	public void preValidate(Auction_Campaign__c venue){
		Datetime startDate = (Datetime)venue.get('Bidding_Start_Time__c');
		Datetime endDate = (Datetime)venue.get('Bidding_End_Time__c');
		String venueGroup = (String)venue.get('Venue_Group__c');
		String uniqueId = (String)venue.get('SF_Calendar_Event_ID__c');

		if(startDate != null && endDate != null && (venueGroup == 'A' || venueGroup == 'B') && uniqueId != null){
			for(Date holiday : holidays){
				if(holiday <= endDate.date() && holiday >= startDate){
					holidayAuctions.add(venue);

					break;
				}
			}
		}
	}

	//set to queueable job
	public void validate(List<Auction_Campaign__c> venuesForInsert){
		
		if(!holidayAuctions.isEmpty()){
			Map<String, Auction_Campaign__c> campaignMap = new Map<String, Auction_Campaign__c> ();

			for(Auction_Campaign__c ac : holidayAuctions){
				Datetime bidStart = (Datetime)ac.get('Bidding_Start_Time__c');
				String venueCode = (String)ac.get('Venue_Number__c');
				String eventId = (String)ac.get('MLH_Event_Id__c');
				String newVenueGroup = ((String)ac.get('Venue_Group__c') == 'A') ? 'B' : 'A';
				String newUnqiueId = eventId+'-'+venueCode+'-'+String.valueOf(bidStart.date())+'-'+newVenueGroup;				

				//clone the auction campaign
				Auction_Campaign__c dupeAuction = ac.clone(false);
				dupeAuction.put('Venue_Group__c', newVenueGroup);
				dupeAuction.put('SF_Calendar_Event_ID__c', newUnqiueId);	

				if(!campaignMap.containsKey(newUnqiueId)){
					campaignMap.put(newUnqiueId, dupeAuction);
				}
			}

			//validate existing campaigns do not exist before inserting
			Set<String> aucIds = campaignMap.keySet();
			for(Auction_Campaign__c venue : (List<Auction_Campaign__c>)database.query('SELECT Id FROM Auction_Campaign__c WHERE SF_Calendar_Event_ID__c IN : aucIds')){
				String aucId = (String)venue.get('SF_Calendar_Event_ID__c');
				campaignMap.remove(aucId);
			}

			if(!campaignMap.isEmpty()){
				venuesForInsert.addAll(campaignMap.values());
			}
		}		
	}
}