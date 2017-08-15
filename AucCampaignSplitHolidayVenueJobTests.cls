@isTest
private class AucCampaignSplitHolidayVenueJobTests {
/*
	@isTest static void validateHolidaySplit() {
		Integer BATCH_SIZE = 20;

		SystemSettings__c ss = new SystemSettings__c(Name = 'SplitHolidayVenueJob');
		ss.put('Value__c', 'Some Value');
		insert ss;

		Datetime startDate = Datetime.newInstanceGmt(Date.today().year(), 12, 21, 0, 0, 0);
		Datetime endDate = Datetime.newInstanceGmt(Date.today().year(), 12, 26, 0, 0, 0);
		Date xmas = Date.newInstance(Date.today().year(), 12, 25);

		Holiday_Calendar__c christmas = new Holiday_Calendar__c(Name = 'Christmas');
		christmas.put('Date__c', xmas);
		insert christmas;		

		List<Map<String, Object>> params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(
				new Map<String, Object>{ 
					'MLH_Event_ID__c' => 'O-88'+i, 'Bidding_Start_Time__c' => startDate, 'Bidding_End_Time__c' => endDate,
					'Venue_Name__c' => 'Test Holiday Venue '+i, 'Venue_Number__c' => 'AA', 'MLH_Venue_ID__c' => '123'+i
				}
			);
		}
		List<Auction_Campaign__c> campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);

		Test.startTest();
			insert campaigns;
		Test.stopTest();

		campaigns = database.query('SELECT ID FROM Auction_Campaign__c');
		System.assertEquals(campaigns.size(), BATCH_SIZE*2);

		campaigns = database.query('SELECT ID FROM Auction_Campaign__c WHERE Is_Holiday__c = TRUE');
		System.assertEquals(campaigns.size(), BATCH_SIZE);

		campaigns = database.query('SELECT ID FROM Auction_Campaign__c WHERE Split_Holiday_Venue__c = TRUE');
		System.assert(campaigns == null || campaigns.size() == 0);
	}
	*/
}