@isTest
private class AuctionCampaignMergeJobTests {

	public static final Integer BATCH_SIZE = 10;

	@testSetup static void setup() {

		List<Map<String, Object>> params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			String venueid = (i < BATCH_SIZE/2) ? '12345'+i : null;
			String auctionid = (i < BATCH_SIZE/2) ? 'auc12345'+i : null;
			String sfCalId = (i >= BATCH_SIZE/2) ? 'O-55'+i+'TT' : null;

			params.add(new Map<String, Object>{'SF_Integration_ID__c' => sfCalId, 'MLH_Event_Id__c' => 'O-55'+i, 'Venue_Number__c' => 'TT', 'MLH_Venue_Id__c' => venueid, 'MLH_Auction_ID2__c' => auctionid, 'Bidding_Start_Time__c' => Date.today().addDays(i), 'Bidding_End_Time__c' => Date.today().addDays(i+3)});
		}
		List<Auction_Campaign__c> campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);
		insert campaigns;

		params = new List<Map<String, Object>>();
		for(Auction_Campaign__c auc : campaigns){
			for(Integer i = 0; i < 2; i++){
				params.add(new Map<String, Object>{'Auction_Campaign__c' => auc.Id});
			}
		}
		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;
	}
	
	@isTest static void validateNewIntegrationEventMerge() {

		List<Map<String, Object>> params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE/2; i++) {
			String sfCalId = 'O-55'+i+'TT';
			params.add(new Map<String, Object>{'SF_Integration_ID__c' => sfCalId, 'MLH_Event_Id__c' => 'O-55'+i, 'Venue_Number__c' => 'TT','Bidding_Start_Time__c' => Date.today().addDays(i), 'Bidding_End_Time__c' => Date.today().addDays(i+3)});	
		}
		List<Auction_Campaign__c> campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);

		Test.startTest();
			insert campaigns;
		Test.stopTest();

		campaigns = (List<Auction_Campaign__c>)database.query('SELECT Id, SF_Integration_ID__c, MLH_Venue_Id__c, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Auction_Campaign__c');
		System.assertEquals(campaigns.size(), BATCH_SIZE, 'The job should have merged the new events resulting in '+String.valueOf(BATCH_SIZE)+' Auction campaigns');

		for(Auction_Campaign__c auc : campaigns){
			System.assert(auc.get('SF_Integration_ID__c') != null, 'The integration id should be populated for all campaigns');
			System.assertEquals(auc.Auction_Opportunity_Assignments__r.size(), 2, 'Each campagin should have 2 aoas');
		}
	}

	@isTest static void validateNewMlhEventMerge() {

		List<Map<String, Object>> params = new List<Map<String, Object>>();
		for (Integer i = BATCH_SIZE/2; i < BATCH_SIZE; i++) {
			String sfCalId = 'O-55'+i+'TT';
			params.add(new Map<String, Object>{'MLH_Venue_Id__c' => '12345'+i, 'MLH_Auction_ID2__c' => 'auc12345'+i, 'MLH_Event_Id__c' => 'O-55'+i, 'Venue_Number__c' => 'TT','Bidding_Start_Time__c' => Date.today().addDays(i), 'Bidding_End_Time__c' => Date.today().addDays(i+3)});	
		}
		List<Auction_Campaign__c> campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);

		Test.startTest();
			insert campaigns;
		Test.stopTest();

		campaigns = (List<Auction_Campaign__c>)database.query('SELECT Id, SF_Integration_ID__c, MLH_Venue_Id__c, MLH_Auction_ID2__c, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Auction_Campaign__c');
		System.assertEquals(campaigns.size(), BATCH_SIZE, 'The job should have merged the new events resulting in '+String.valueOf(BATCH_SIZE)+' Auction campaigns');

		for(Auction_Campaign__c auc : campaigns){			
			System.assert(auc.get('MLH_Venue_Id__c') != null, 'The mlh venue id should be populated for all campaigns');
			System.assert(auc.get('MLH_Auction_ID2__c') != null, 'The mlh auction id should be populated for all campaigns');
			System.assertEquals(auc.Auction_Opportunity_Assignments__r.size(), 2, 'Each campagin should have 2 aoas');
		}
	}

	@isTest static void validateInsertWithNonResiEventsInsert(){
		List<Map<String, Object>> params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			String venueid = (i >= BATCH_SIZE/2) ? 'comm12345'+i : null;
			String auctionid = (i >= BATCH_SIZE/2) ? 'comm12345'+i : null;
			String eventId = (i >= BATCH_SIZE/2) ? 'B-55'+i : 'O-55'+i;
			String sfCalId = (i < BATCH_SIZE/2) ? 'O-55'+i+'TT' : null;

			params.add(new Map<String, Object>{'SF_Integration_ID__c' => sfCalId, 'MLH_Event_Id__c' => eventId, 'Venue_Number__c' => 'TT', 'MLH_Venue_Id__c' => venueid, 'MLH_Auction_ID2__c' => auctionid, 'Bidding_Start_Time__c' => Date.today().addDays(i), 'Bidding_End_Time__c' => Date.today().addDays(i+3)});
		}		
		List<Auction_Campaign__c> campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);

		Test.startTest();
			insert campaigns;
		Test.stopTest();

		campaigns = (List<Auction_Campaign__c>)database.query('SELECT Id, SF_Integration_ID__c, MLH_Venue_Id__c, MLH_Auction_ID2__c, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Auction_Campaign__c');
		System.assertEquals(campaigns.size(), (BATCH_SIZE+(BATCH_SIZE/2)), 'The job should have merged the new events resulting in and allowed the insertion of the commercial events');

		campaigns = (List<Auction_Campaign__c>)database.query('SELECT Id FROM Auction_Campaign__c WHERE MLH_Event_Id__c LIKE \'B-%\'');
		System.assertEquals(campaigns.size(), (BATCH_SIZE/2), 'the commercial campaign count should be half the batch size');
	}
}