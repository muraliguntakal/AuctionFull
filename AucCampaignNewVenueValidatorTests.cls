@isTest
private class AucCampaignNewVenueValidatorTests {
/*	
	@isTest static void validateBeforeInsertFieldsSet() {
		Integer BATCH_SIZE = 20;

		Date startOfWeek = Date.today().toStartofWeek();
		Datetime startVenueA = Datetime.newInstanceGmt(startOfWeek.year(), startOfWeek.month(), startOfWeek.day(), 0, 0, 0);
		Datetime startVenueB = Datetime.newInstanceGmt(startOfWeek.year(), startOfWeek.month(), startOfWeek.day()+5, 0, 0, 0);

		List<Map<String, Object>> params = new List<Map<String, Object>>();

		//A venues
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(
				new Map<String, Object>{ 
					'MLH_Event_ID__c' => 'O-88'+i, 'Bidding_Start_Time__c' => startVenueA, 'Bidding_End_Time__c' => startVenueA.addDays(3),
					'Venue_Name__c' => 'Test Venue '+i, 'Venue_Number__c' => 'AA', 'MLH_Venue_ID__c' => '123A'+i
				}
			);
		}

		//B venues
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(
				new Map<String, Object>{ 
					'MLH_Event_ID__c' => 'O-88'+i, 'Bidding_Start_Time__c' => startVenueB, 'Bidding_End_Time__c' => startVenueB.addDays(3),
					'Venue_Name__c' => 'Test Venue '+i, 'Venue_Number__c' => 'AA', 'MLH_Venue_ID__c' => '123B'+i
				}
			);
		}

		List<Auction_Campaign__c> campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);
		insert campaigns;

		campaigns = (List<Auction_Campaign__c>)database.query('SELECT Id, Venue_Group__c, SF_Calendar_Event_ID__c FROM Auction_Campaign__c');

		Map<String, List<Auction_Campaign__c>> groupedByVenueGroup = MapUtils.groupByString(campaigns,'Venue_Group__c');
		System.assertEquals(groupedByVenueGroup.get('A').size(), BATCH_SIZE);
		System.assertEquals(groupedByVenueGroup.get('B').size(), BATCH_SIZE);

		for(Auction_Campaign__c venue : campaigns){
			System.assert((String)venue.get('SF_Calendar_Event_ID__c') != null);
		}
	}
*/	
}