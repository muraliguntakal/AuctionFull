@isTest
private class EventRollingControllerTests {

	public static List<Map<String, Object>> triggerParams = new List<Map<String, Object>>{
		new Map<String, Object>{ 'Name' => 'AssetBeforeupdate', 'Status__c' => false }, 
		new Map<String, Object>{ 'Name' => 'UpdateAddress_Opportunity', 'Status__c' => false }, 
		new Map<String, Object>{ 'Name' => 'OpportunityTriggerBefore', 'Status__c' => false }, 
		new Map<String, Object>{ 'Name' => 'Auto_Create_Valuation_Recrod', 'Status__c' => false }, 
		new Map<String, Object>{ 'Name' => 'OpportunitySplitTrigger', 'Status__c' => false }, 
		new Map<String, Object>{ 'Name' => 'OpportunityContactTrigger', 'Status__c' => false },
		new Map<String, Object>{ 'Name' => 'VROAssetDetails', 'Status__c' => false },
		new Map<String, Object>{ 'Name' => 'OpenHouseDate', 'Status__c' => false },
		new Map<String, Object>{ 'Name' => 'InsertUpdateOptyId', 'Status__c' => false },
		new Map<String, Object>{ 'Name' => 'AOATrigger', 'Status__c' => false }
	};

	public static Auction_Campaign__c newPlaceholderCampaign(Integer i){
		Auction_Campaign__c placeholder = new Auction_Campaign__c();
		placeholder.put('Auction_Name__c', 'Placeholder Venue Midwest Auction  '+i);
		placeholder.put('Venue_Name__c', 'Venue '+i);
		placeholder.put('MLH_Event_Id__c', 'O-915');
		placeholder.put('MLH_Venue_Id__c', '1234'+i);
		placeholder.put('Auction_Region__c', 'Midwest');
		placeholder.put('Placeholder_Event__c',true);

		return placeholder;
	}

	public static Auction_Campaign__c newResiCampaign(Integer i){
		Date startDate = (i > 0) ? Date.today().addDays(i * 7) : Date.today().addDays(-8);
		Date endDate = (i > 0) ? startDate.addDays(7) : Date.today().addDays(-1);
		Time venueTime = Time.newInstance(15, 30, 0, 0);

		Auction_Campaign__c resiCampaign = new Auction_Campaign__c();
		resiCampaign.put('Bidding_Start_Time__c', Datetime.newInstance(startDate, venueTime));
		resiCampaign.put('Bidding_End_Time__c', Datetime.newInstance(endDate, venueTime));
		resiCampaign.put('Auction_Name__c', 'Midwest Auction  '+i);
		resiCampaign.put('Venue_Name__c', 'Venue '+i);
		resiCampaign.put('MLH_Event_Id__c', 'O-47 '+i);
		resiCampaign.put('MLH_Venue_Id__c', '1234'+i);
		resiCampaign.put('Auction_Region__c', 'Midwest');

		return resiCampaign;
	}

	public static Auction_Campaign__c newTvCampaign(Integer i){
		Date startDate = Date.today().addDays(i * 7);
		Date endDate = startDate.addDays(7);
		Time venueTime = Time.newInstance(15, 30, 0, 0);

		Auction_Campaign__c tvCampaign = new Auction_Campaign__c();
		tvCampaign.put('Bidding_Start_Time__c', Datetime.newInstance(startDate, venueTime));
		tvCampaign.put('Bidding_End_Time__c', Datetime.newInstance(endDate, venueTime));
		tvCampaign.put('Auction_Name__c', 'TV Midwest Auction '+i);
		tvCampaign.put('Venue_Name__c', 'TV Venue '+i);
		tvCampaign.put('MLH_Event_Id__c', 'TV-50 '+i);
		tvCampaign.put('MLH_Venue_Id__c', '137'+i);
		tvCampaign.put('Auction_Region__c', 'Midwest');

		return tvCampaign;
	}

	@isTest static void validateOnlyResiCampaigns() {

		List<TriggerSettings__c> ts = TestFactory.newInstance(TriggerSettings__c.class, triggerParams);
		insert ts;

		List<Auction_Campaign__c> campaigns = new List<Auction_Campaign__c> ();
		for(Integer i = 1 ; i < 10 ; i++){			

			Auction_Campaign__c resiCampaign = newResiCampaign(i);
			campaigns.add(resiCampaign);

			Auction_Campaign__c tvCampaign = newTvCampaign(i);
			campaigns.add(tvCampaign);			
		}

		insert campaigns;

		Map<String, List<SObject>> queriedCampaigns = EventRollingController.getAuctionCampaigns();
		for(String state : queriedCampaigns.keySet()){
			System.assert(state.length() == 2, 'The campaing map didnt correctly parse the state keys');

			for(SObject stateCampaign : queriedCampaigns.get(state)){
				String eventId = (String)stateCampaign.get('MLH_Event_Id__c');
				System.assert(eventId.contains('O-47'), 'The query pulled tv campaigns, it should only pull campaigns with event ids like 0-47');
			}
		}
	}

	@isTest static void validateActiveEvents() {

		List<TriggerSettings__c> ts = TestFactory.newInstance(TriggerSettings__c.class, triggerParams);
		insert ts;

		Asset__c asset = (Asset__c)TestFactory.newInstance(Asset__c.class, 1)[0];
		asset.put('Property_State__c', 'MI');
		insert asset;

		RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SObjectType = 'Opportunity'];
		String resiRtId = String.valueOf(resiRT.Id);

		//List<Auction_Campaign__c> campaigns = new List<Auction_Campaign__c> ();
		List<Opportunity> opps = new List<Opportunity> ();

		for(Integer i = 1 ; i <= 10 ; i++){			

			Date removalDate = (i == 1 || i == 3 || i ==5 || i == 7 || i == 9) ? Date.today() : null;
			Opportunity opp = (Opportunity)TestFactory.newInstance(Opportunity.class, 1, new Map<String, Object>{
				'Asset__c' => asset.Id, 'StageName' => 'Stage 4. Pre-Acution', 'CloseDate' => Date.today().addDays(30), 'RecordTypeId' => resiRT.Id, 'Removal_Date__c' => removalDate
			})[0];

			opps.add(opp);	
		}

		Auction_Campaign__c endingCampaign = newResiCampaign(0);
		//campaigns.add(endingCampaign);

		insert endingCampaign;
		insert opps;

		List<Auction_Opportunity_Assignment__c> aoas = new List<Auction_Opportunity_Assignment__c> ();
		for(Integer i = 0 ; i < 10 ; i++){
			for(Integer j = 0 ; j < 2 ; j++){
				Boolean mostRecent = (j == 0) ? false : true;				
				Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c();
				aoa.put('Auction_Campaign__c', endingCampaign.Id);
				aoa.put('Assets__c', asset.Id);
				aoa.put('Opportunity__c', opps[i].Id);
				aoa.put('Most_Recent_AOA__c', mostRecent);
				aoas.add(aoa);
			}
		}

		insert aoas;

		EventRollingController.getEventsToRoll();

		Map<String,List<Auction_Opportunity_Assignment__c>> activeAOAs = EventRollingController.getEventsToRoll();
		System.assert(activeAOAs.get('active').size() == 5, 'Query pulled too many auction events the size should be 5 actual list size is '+activeAOAs.size());
	}

	@isTest static void validatePlaceholderEvents(){
		List<TriggerSettings__c> ts = TestFactory.newInstance(TriggerSettings__c.class, triggerParams);
		insert ts;

		Asset__c asset = (Asset__c)TestFactory.newInstance(Asset__c.class, 1)[0];
		insert asset;

		RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SObjectType = 'Opportunity'];
		String resiRtId = String.valueOf(resiRT.Id);

		Auction_Campaign__c campaign = newPlaceholderCampaign(1);
		insert campaign;

		List<Opportunity> opps = new List<Opportunity> ();
		for(Integer i = 1 ; i <= 10 ; i++){			

			Opportunity opp = (Opportunity)TestFactory.newInstance(Opportunity.class, 1, new Map<String, Object>{
				'Asset__c' => asset.Id, 'StageName' => 'Stage 4. Pre-Auction', 'CloseDate' => Date.today().addDays(30),'RecordTypeId' => resiRT.Id
			})[0];

			opps.add(opp);	
		}

		insert opps;

		List<Auction_Opportunity_Assignment__c> aoas = new List<Auction_Opportunity_Assignment__c> ();
		for(Integer i = 0 ; i < 10 ; i++){
			for(Integer j = 0 ; j < 2 ; j++){
				Boolean mostRecent = (j == 0) ? false : true;				
				Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c();
				aoa.put('Auction_Campaign__c', campaign.Id);
				aoa.put('Assets__c', asset.Id);
				aoa.put('Opportunity__c', opps[i].Id);
				aoa.put('Most_Recent_AOA__c', mostRecent);
				aoas.add(aoa);
			}
		}

		insert aoas;

		Map<String,List<Auction_Opportunity_Assignment__c>> placeholderAOAs = EventRollingController.getEventsToRoll();
		System.assert(placeholderAOAs.get('placeholder').size() == 10, 'Query pulled too many auction events the size should be 10 actual list size is '+placeholderAOAs.size());
	}

	@isTest static void validateUnkEvents(){
		List<TriggerSettings__c> ts = TestFactory.newInstance(TriggerSettings__c.class, triggerParams);
		insert ts;

		Asset__c asset = (Asset__c)TestFactory.newInstance(Asset__c.class, 1)[0];
		insert asset;

		RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SObjectType = 'Opportunity'];
		String resiRtId = String.valueOf(resiRT.Id);

		Auction_Campaign__c campaign = newResiCampaign(-1);
		insert campaign;

		List<Opportunity> opps = new List<Opportunity> ();
		for(Integer i = 1 ; i <= 10 ; i++){			

			Opportunity opp = (Opportunity)TestFactory.newInstance(Opportunity.class, 1, new Map<String, Object>{
				'Asset__c' => asset.Id, 'StageName' => 'Stage 4. Pre-Auction', 'CloseDate' => Date.today().addDays(30),'RecordTypeId' => resiRT.Id
			})[0];

			opps.add(opp);	
		}

		insert opps;

		List<Auction_Opportunity_Assignment__c> aoas = new List<Auction_Opportunity_Assignment__c> ();
		for(Integer i = 0 ; i < 10 ; i++){
			for(Integer j = 0 ; j < 2 ; j++){
				Boolean mostRecent = (j == 0) ? false : true;				
				Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c();
				aoa.put('Auction_Campaign__c', campaign.Id);
				aoa.put('Assets__c', asset.Id);
				aoa.put('Opportunity__c', opps[i].Id);
				aoa.put('Most_Recent_AOA__c', mostRecent);
				aoa.put('MLH_Pool_Number__c','UNK');
				aoa.put('Status__c','Removed');
				aoas.add(aoa);
			}
		}

		insert aoas;

		Map<String,List<Auction_Opportunity_Assignment__c>> unkAOAs = EventRollingController.getEventsToRoll();
		System.assert(unkAOAs.get('unk').size() == 10, 'Query pulled too many auction events the size should be 10 actual list size is '+unkAOAs.size());
	}

	@isTest static void validateAOACreation(){
		List<TriggerSettings__c> ts = TestFactory.newInstance(TriggerSettings__c.class, triggerParams);
		insert ts;

		Asset__c asset = (Asset__c)TestFactory.newInstance(Asset__c.class, 1)[0];
		insert asset;

		RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SObjectType = 'Opportunity'];
		String resiRtId = String.valueOf(resiRT.Id);

		Auction_Campaign__c rollToCampaign = newResiCampaign(1);
		insert rollToCampaign;

		List<Opportunity> opps = new List<Opportunity> ();
		for(Integer i = 1 ; i <= 10 ; i++){			

			Date returnDate = (i == 2) ? Date.today().addDays(-5) : Date.today().addDays(30);
			Opportunity opp = (Opportunity)TestFactory.newInstance(Opportunity.class, 1, new Map<String, Object>{
				'Asset__c' => asset.Id, 'StageName' => 'Stage 4. Pre-Auction', 'CloseDate' => Date.today().addDays(30), 'RecordTypeId' => resiRT.Id
			})[0];

			opps.add(opp);	
		}

		insert opps;

		List<Auction_Opportunity_Assignment__c> active_aoas = new List<Auction_Opportunity_Assignment__c> ();
		for(Integer i = 0 ; i < 10 ; i++){
			Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c();
			aoa.put('Auction_Campaign__c', rollToCampaign.Id);
			aoa.put('Assets__c', asset.Id);
			aoa.put('Opportunity__c', opps[i].Id);
			aoa.put('Most_Recent_AOA__c', true);
			aoa.put('User_Created_AOA__c', true);
			active_aoas.add(aoa);
		}

		List<Auction_Opportunity_Assignment__c> unk_aoa = new List<Auction_Opportunity_Assignment__c> ();
		for(Integer i = 0 ; i < 10 ; i++){
			Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c();
			aoa.put('Auction_Campaign__c', rollToCampaign.Id);
			aoa.put('Assets__c', asset.Id);
			aoa.put('Opportunity__c', opps[i].Id);
			aoa.put('Most_Recent_AOA__c', true);
			aoa.put('User_Created_AOA__c', true);
			aoa.put('MLH_Pool_Number__c', 'UNK');
			aoa.put('Status__c', 'Removed');
			unk_aoa.add(aoa);
		}

		EventRollingController.unkAndRollAOAs(active_aoas, unk_aoa);

		List<Auction_Opportunity_Assignment__c> createdAOAs = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id FROM Auction_Opportunity_Assignment__c');
		System.assertEquals(createdAOAs.size(), 20, 'Not all the AOAS were created');
	}
}