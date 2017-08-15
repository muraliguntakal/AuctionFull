@isTest
private class AOAMostRecentUpdatesJobTests {

	public static final Integer PARENT_BATCH_SIZE = 10;
	public static final Integer CHILD_BATCH_SIZE = 2;

	@testSetup static void setup() {
		
		List<Map<String, Object>> params = null;

		Account seller = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert seller;

		Contact c = (Contact)TestFactory.newInstance(Contact.class, 1, new Map<String, Object>{ 'AccountId' => seller.Id, 'Email' => 'assetconsideration@auction.com' })[0];
		insert c;

		Program__c program = (Program__c)TestFactory.newInstance(Program__c.class, 1)[0];
		insert program;

		Program_Enrollment__c pe = (Program_Enrollment__c)TestFactory.newInstance(Program_Enrollment__c.class, 1, new Map<String, Object>{ 'Program__c' => program.Id, 'Account__c' => seller.Id, 'Unique_ID__c' => seller.Id + '-' + program.Id, 'Seller_Code__c' =>'TST' })[0];
		insert pe;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < PARENT_BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Baths__c' => null, 'Bedrooms__c' => null, 'Lot_Size_Sq_Ft__c' => null, 'MLH_Global_Property_ID__c' => 'PROPID12345'+i});
		}
		List<Asset__c> assets = TestFactory.newInstance(Asset__c.class, params);
		insert assets;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < PARENT_BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'AccountId' => seller.Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => assets[i].Id });
		}
		List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, params);
		insert opps;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < PARENT_BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Opportunity__c' => opps[i].Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => assets[i].Id, 'Tracking_ID__c' => opps[i].Id });
		}
		List<Asset_Management__c> ams = TestFactory.newInstance(Asset_Management__c.class, params);
		insert ams;		
	}
	
	@isTest static void validateMostRecentOnInsert() {
		List<Map<String, Object>> params = null;

		List<Asset_Management__c> ams = (List<Asset_Management__c>)database.query('SELECT Id, Opportunity__c, Asset__c, Asset__r.MLH_Global_Property_ID__c FROM Asset_Management__c');		

		List<Auction_Campaign__c> campaigns = new List<Auction_Campaign__c> ();

		Auction_Campaign__c oldCampaign = new Auction_Campaign__c ();
		oldCampaign.put('Auction_Name__c', 'Midwest Auction old');
		oldCampaign.put('Venue_Name__c', 'Venue Old');
		oldCampaign.put('MLH_Event_Id__c', 'O-999');
		oldCampaign.put('MLH_Venue_Id__c', '1234Old');
		oldCampaign.put('Auction_Region__c', 'Midwest');
		campaigns.add(oldCampaign);

		for(Integer i = 0; i < CHILD_BATCH_SIZE; i++){

			Auction_Campaign__c c = new Auction_Campaign__c ();
			c.put('Auction_Name__c', 'Midwest Auction  '+i);
			c.put('Venue_Name__c', 'Venue '+i);
			c.put('MLH_Event_Id__c', 'O-47 '+i);
			c.put('MLH_Venue_Id__c', '1234'+i);
			c.put('Auction_Region__c', 'Midwest');
			campaigns.add(c);
		}

		insert campaigns;

		params = new List<Map<String, Object>>();

		for(Asset_Management__c am : ams){			
			params.add(new Map<String, Object>{'Opportunity__c' => (String)am.get('Opportunity__c'), 'Asset_Management__c' => am.Id, 'MLH_Product_Type__c' => 'REO', 'Auction_Campaign__c' => oldCampaign.Id, 'Most_Recent_AOA__c' => true, 'MLH_Global_Property_Id__c' => am.Asset__r.MLH_Global_Property_ID__c});
		}

		List<Auction_Opportunity_Assignment__c> oldAoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert oldAoas;

		params = new List<Map<String, Object>>();

		for(Asset_Management__c am : ams){
			for (Integer i = 0; i < CHILD_BATCH_SIZE; i++) {
				String productType = ( i < CHILD_BATCH_SIZE/2 ) ? 'REO' : 'Trustee';
				String oppId = ( i < CHILD_BATCH_SIZE/2 ) ? (String)am.get('Opportunity__c') : null;

				params.add(new Map<String, Object>{'Opportunity__c' => oppId, 'Asset_Management__c' => am.Id, 'MLH_Product_Type__c' => productType, 'Auction_Campaign__c' => campaigns[i].Id, 'MLH_Global_Property_Id__c' => am.Asset__r.MLH_Global_Property_ID__c});
			}
		}

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		
		Test.startTest();
			insert aoas;
		Test.stopTest();
		
		List<Opportunity> opps = (List<Opportunity>)database.query('SELECT Id, Auction_Opportunity_Assignment__c, Most_Recent_Auction__c, Next_Most_Recent_Auction__c, Asset__c, Asset__r.Most_Recent_AOA__c, Asset__r.Next_Most_Recent_AOA__c, (SELECT Id, Most_Recent_AOA__c, Auction_Campaign__c, CreatedDate, Assets__c FROM Auction_Opportunity_Assignments__r ORDER BY CreatedDate LIMIT 2) FROM Opportunity');

		for(Opportunity opp : opps){
			String oppId = (String)opp.get('Id');
			String assetId = (String)opp.get('Asset__c');
			List<Auction_Opportunity_Assignment__c> oppAoas = opp.Auction_Opportunity_Assignments__r;
			System.debug('############   '+oppAoas);

			//System.assertEquals((Boolean)oppAoas[0].get('Most_Recent_AOA__c'), true, 'Most recent aoa flag was not set correctly');
			//System.assertEquals((String)opp.get('Most_Recent_Auction__c'), (String)oppAoas[0].get('Auction_Campaign__c'), 'The most recent auction Id was not set on the Opp correctly '+(String)opp.get('Most_Recent_Auction__c'));
			//System.assertEquals((String)opp.get('Next_Most_Recent_Auction__c'), (String)oppAoas[1].get('Auction_Campaign__c'), 'The next most recent auction Id was not set on the Opp correctly '+(String)opp.get('Next_Most_Recent_Auction__c'));
			//System.assertEquals((String)opp.get('Auction_Opportunity_Assignment__c'), (String)oppAoas[0].get('Id'), 'The most recent aoa Id was not set on the Opp correctly '+(String)opp.get('Auction_Opportunity_Assignment__c'));
			//System.assertEquals(opp.Asset__r.Most_Recent_AOA__c, (String)oppAoas[0].get('Id'), 'The most recent AOA Id was not set on the Asset correctly '+opp.Asset__r.Most_Recent_AOA__c);
			//System.assertEquals(opp.Asset__r.Next_Most_Recent_AOA__c, (String)oppAoas[1].get('Id'), 'The next most recent AOA Id was not set on the Asset correctly '+opp.Asset__r.Next_Most_Recent_AOA__c);

			for(Auction_Opportunity_Assignment__c aoa : oppAoas){
				System.assertEquals((String)aoa.get('Assets__c'), assetId, 'The asset Id was not set on the AOA '+(String)aoa.get('Assets__c'));
			}
		}
	}

	@isTest static void validateMostRecentOnDeleteStatus() {
		List<Map<String, Object>> params = null;

		List<Asset_Management__c> ams = (List<Asset_Management__c>)database.query('SELECT Id, Opportunity__c, Asset__c, Asset__r.MLH_Global_Property_ID__c FROM Asset_Management__c');		
		List<Auction_Campaign__c> campaigns = new List<Auction_Campaign__c> ();

		for(Integer i = 0; i < CHILD_BATCH_SIZE; i++){

			Auction_Campaign__c c = new Auction_Campaign__c ();
			c.put('Auction_Name__c', 'Midwest Auction  '+i);
			c.put('Venue_Name__c', 'Venue '+i);
			c.put('MLH_Event_Id__c', 'O-47 '+i);
			c.put('MLH_Venue_Id__c', '1234'+i);
			c.put('Auction_Region__c', 'Midwest');

			campaigns.add(c);
		}

		insert campaigns;

		params = new List<Map<String, Object>>();

		for(Asset_Management__c am : ams){
			for (Integer i = 0; i < CHILD_BATCH_SIZE; i++) {
				String productType = ( i < CHILD_BATCH_SIZE/2 ) ? 'REO' : 'Trustee';
				String oppId = ( i < CHILD_BATCH_SIZE/2 ) ? (String)am.get('Opportunity__c') : null;

				params.add(new Map<String, Object>{'Opportunity__c' => oppId, 'Asset_Management__c' => am.Id, 'MLH_Product_Type__c' => productType, 'Auction_Campaign__c' => campaigns[i].Id, 'MLH_Global_Property_Id__c' => am.Asset__r.MLH_Global_Property_ID__c});
			}
		}

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		Map<String, List<Auction_Opportunity_Assignment__c>> oppsToAoas = MapUtils.groupByString(aoas, 'Opportunity__c');
		List<Auction_Opportunity_Assignment__c> deletedAoas = new List<Auction_Opportunity_Assignment__c> ();

		for(String oppId : oppsToAoas.keySet()){
			List<Auction_Opportunity_Assignment__c> oppAoas = oppsToAoas.get(oppId);
			oppAoas[0].Status__c = 'Deleted';
			deletedAoas.add(oppAoas[0]);
		}

		Test.startTest();
			update deletedAoas;
		Test.stopTest();
	}

	@isTest static void validateCreateForTrustee() {
		List<Map<String, Object>> params = null;

		Auction_Campaign__c c = new Auction_Campaign__c ();
		c.put('Auction_Name__c', 'Midwest Auction');
		c.put('Venue_Name__c', 'Venue5');
		c.put('MLH_Event_Id__c', 'O-475');
		c.put('MLH_Venue_Id__c', '12345');
		c.put('Auction_Region__c', 'Midwest');
		
		insert c;

		params = new List<Map<String, Object>>();

		Asset__c a = [SELECT Id, MLH_Global_Property_ID__c FROM Asset__c LIMIT 1];

		List<Auction_Opportunity_Assignment__c> oldAoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert oldAoas;

		params = new List<Map<String, Object>>();
		params.add(new Map<String, Object>{'Seller_Name__c' => 'Test Seller', 'MLH_Product_Type__c' => 'Trustee', 'Auction_Campaign__c' => c.Id, 'MLH_Global_Property_Id__c' => a.MLH_Global_Property_ID__c});

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		
		Test.startTest();
			insert aoas;
		Test.stopTest();
		
		Auction_Opportunity_Assignment__c uAoa = [SELECT ID, Opportunity__c, Assets__c FROM Auction_Opportunity_Assignment__c WHERE ID = :aoas[0].Id];
		System.assert(uAoa.Opportunity__c != NULL);
		System.assert(uAoa.Assets__c == a.Id);
	}
	
	@isTest static void validateCreateForREO() {
		List<Map<String, Object>> params = null;

		Auction_Campaign__c c = new Auction_Campaign__c ();
		c.put('Auction_Name__c', 'Midwest Auction');
		c.put('Venue_Name__c', 'Venue5');
		c.put('MLH_Event_Id__c', 'O-475');
		c.put('MLH_Venue_Id__c', '12345');
		c.put('Auction_Region__c', 'Midwest');
		
		insert c;

		params = new List<Map<String, Object>>();

		Asset__c a = [SELECT Id, MLH_Global_Property_ID__c FROM Asset__c LIMIT 1];

		List<Auction_Opportunity_Assignment__c> oldAoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert oldAoas;

		params = new List<Map<String, Object>>();
		params.add(new Map<String, Object>{'Seller_Name__c' => 'BAC Dual Path', 'MLH_Product_Type__c' => 'REO', 'Auction_Campaign__c' => c.Id, 'MLH_Global_Property_Id__c' => a.MLH_Global_Property_ID__c});

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		
		Test.startTest();
			insert aoas;
		Test.stopTest();
		
		Auction_Opportunity_Assignment__c uAoa = [SELECT ID, Opportunity__c, Assets__c FROM Auction_Opportunity_Assignment__c WHERE ID = :aoas[0].Id];
		System.assert(uAoa.Opportunity__c != NULL);
		System.assert(uAoa.Assets__c == a.Id);
	}

	@isTest static void validateDONTCreateForCWCOT() {
		List<Map<String, Object>> params = null;

		Auction_Campaign__c c = new Auction_Campaign__c ();
		c.put('Auction_Name__c', 'Midwest Auction');
		c.put('Venue_Name__c', 'Venue5');
		c.put('MLH_Event_Id__c', 'O-475');
		c.put('MLH_Venue_Id__c', '12345');
		c.put('Auction_Region__c', 'Midwest');
		
		insert c;

		params = new List<Map<String, Object>>();

		Asset__c a = [SELECT Id, MLH_Global_Property_ID__c FROM Asset__c LIMIT 1];

		List<Auction_Opportunity_Assignment__c> oldAoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert oldAoas;

		params = new List<Map<String, Object>>();
		params.add(new Map<String, Object>{'Seller_Name__c' => 'WElls CWCOT - Vacant', 'MLH_Product_Type__c' => 'REO', 'Auction_Campaign__c' => c.Id, 'MLH_Global_Property_Id__c' => a.MLH_Global_Property_ID__c});

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		
		Test.startTest();
			insert aoas;
		Test.stopTest();
		
		Auction_Opportunity_Assignment__c uAoa = [SELECT ID, Opportunity__c, Assets__c FROM Auction_Opportunity_Assignment__c WHERE ID = :aoas[0].Id];
		System.assert(uAoa.Opportunity__c == NULL);
		System.assert(uAoa.Assets__c != a.Id);
	}	
}