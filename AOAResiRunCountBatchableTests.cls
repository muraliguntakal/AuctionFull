@isTest
private class AOAResiRunCountBatchableTests {
	
	@isTest static void validateRunCount() {
		List<Map<String, Object>> params = null;
		RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SobjectType = 'Opportunity'];

		Account seller = new Account();
		seller.put('Prefix__c','BAC');
		seller.put('Name','Test Apex Account');
		insert seller;

		Program__c reo = new Program__c ();
		reo.put('Product_Type__c', 'REO');
		reo.put('Active__c', true);
		insert reo;

		Program_Enrollment__c pe = new Program_Enrollment__c ();
		pe.put('Account__c', seller.Id);
		pe.put('Program__c', reo.Id);
		pe.put('Seller_Code__c', 'BAJ');

		insert pe;

		Opportunity opp = new Opportunity ();
		opp.put('Name', 'Test Opp Apex');
		opp.put('RecordTypeId', resiRT.Id);
		opp.put('AccountId', seller.Id);
		opp.put('CloseDate', Date.today());
		opp.put('StageName', 'Stage 4. Pre-Auction');

		insert opp;

		Auction_Campaign__c placeholder = new Auction_Campaign__c ();
		placeholder.put('Placeholder_Event__c', true);
		placeholder.put('MLH_Event_ID__c', 'O-915');
		placeholder.put('MLH_Venue_Id__c', 'O915');
		insert placeholder;

		Datetime nowTime = Datetime.now();
		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < 2; i++) {
			params.add(new Map<String, Object>{'Placeholder_Event__c' => false, 'MLH_Event_ID__c' => 'O-49'+i, 'Bidding_End_Time__c' => nowTime, 'MLH_Venue_Id__c' => 'active'+i});
		}
		List<Auction_Campaign__c> active_campaigns = TestFactory.newInstance(Auction_Campaign__c.class, params);
		insert active_campaigns;

		//placeholder aoa
		Auction_Opportunity_Assignment__c placeholder_aoa = new Auction_Opportunity_Assignment__c ();
		placeholder_aoa.put('MLH_Product_Type__c', 'REO');
		placeholder_aoa.put('Opportunity__c', opp.Id);
		placeholder_aoa.put('Auction_Campaign__c', placeholder.Id);

		insert placeholder_aoa;

		//active aoas
		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < 2; i++) {
			params.add(new Map<String, Object>{'MLH_Product_Type__c' => 'REO', 'Opportunity__c' => opp.Id, 'Auction_Campaign__c' => active_campaigns[i].Id, 'MLH_Auction_ID__c' => '12345'+i});
		}
		List<Auction_Opportunity_Assignment__c> active_aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert active_aoas;

		//dupe active aoas
		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < 2; i++) {
			params.add(new Map<String, Object>{'MLH_Product_Type__c' => 'REO', 'Opportunity__c' => opp.Id, 'Auction_Campaign__c' => active_campaigns[i].Id});
		}
		List<Auction_Opportunity_Assignment__c> dupe_aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert dupe_aoas;

		//unk aoa
		Auction_Opportunity_Assignment__c unk_aoa = new Auction_Opportunity_Assignment__c ();
		unk_aoa.put('MLH_Product_Type__c', 'REO');
		unk_aoa.put('Opportunity__c', opp.Id);
		unk_aoa.put('MLH_Pool_Number__c', 'UNK');		

		insert unk_aoa;

		List<Auction_Opportunity_Assignment__c> aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id FROM Auction_Opportunity_Assignment__c');
		System.assertEquals(aoas.size(),6, 'Starting aoa count should be 6');

		Test.startTest();
			AOAResiRunCountBatchable arcb = new AOAResiRunCountBatchable(Datetime.now(), Datetime.now() - 1);
			Database.executeBatch(arcb);

			String jobId = System.schedule('AOAResiRunCountSchedulable', '0 0 0 3 9 ? 2020', new AOAResiRunCountSchedulable());		

		Test.stopTest();

		opp = (Opportunity)database.query('SELECT Id, Run_Number__c FROM Opportunity');
		System.assertEquals((Decimal)opp.get('Run_Number__c'), 2, 'Run count should be decremented when and event is UNKd');

		aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id FROM Auction_Opportunity_Assignment__c');
		System.assertEquals(aoas.size(),4, '2 aoas should have been removed and 4 should only remain '+aoas.size());
	}
}