@isTest
private class AOASellerCodeValidatorTests {

	@isTest static void validateProgramEnrollmentChangedOnInsert() {
		final Integer BATCH_SIZE = (TestUtils.BATCH_SIZE_OVERRIDE > 0 ? TestUtils.BATCH_SIZE_OVERRIDE : 250);
		List<Map<String, Object>> params = null;

		Account seller = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert seller;

		Contact c = (Contact)TestFactory.newInstance(Contact.class, 1, new Map<String, Object>{ 'AccountId' => seller.Id, 'Email' => 'assetconsideration@auction.com' })[0];
		insert c;

		Program__c program = (Program__c)TestFactory.newInstance(Program__c.class, 1)[0];
		insert program;

		Program_Enrollment__c pe = (Program_Enrollment__c)TestFactory.newInstance(Program_Enrollment__c.class, 1, new Map<String, Object>{ 'Program__c' => program.Id, 'Account__c' => seller.Id, 'Unique_ID__c' => seller.Id + '-' + program.Id, 'Seller_Code__c' =>'TST' })[0];
		insert pe;

		Asset__c asset = (Asset__c)TestFactory.newInstance(Asset__c.class, 1, new Map<String, Object>{ 'Baths__c' => null, 'Bedrooms__c' => null, 'Lot_Size_Sq_Ft__c' => null})[0];
		insert asset;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'AccountId' => seller.Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => asset.Id });
		}
		List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, params);
		insert opps;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Opportunity__c' => opps[i].Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => asset.Id });
		}
		List<Asset_Management__c> ams = TestFactory.newInstance(Asset_Management__c.class, params);
		insert ams;

		List<Auction_Opportunity_Assignment__c> aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id FROM Auction_Opportunity_Assignment__c');
		System.assertEquals(aoas.size(), 0, 'No aoas should be created: '+aoas.size());

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Assets__c' => asset.Id, 'Opportunity__c' => opps[i].Id, 'Asset_Management__c' => ams[i].Id, 'MLH_Seller_Code__c' => 'TST', 'MLH_Event_ID__c' => 'O-915'});
		}

		aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;
		
		for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Program_Enrollment__c FROM Auction_Opportunity_Assignment__c')){
			System.assertEquals((String)aoa.get('Program_Enrollment__c'), pe.Id, 'Program enrollment id should have changed AM: '+(String)aoa.get('Program_Enrollment__c'));
		}

		for(Asset_Management__c am : (List<Asset_Management__c>)database.query('SELECT Id, Program_Enrollment__c FROM Asset_Management__c')){
			System.assertEquals((String)am.get('Program_Enrollment__c'), pe.Id, 'Program enrollment ids do not match on asset management: '+(String)am.get('Program_Enrollment__c'));
		}

		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Program_Enrollment__c FROM Opportunity')){
			System.assertEquals((String)opp.get('Program_Enrollment__c'), pe.Id, 'Program enrollment ids do not match: '+(String)opp.get('Program_Enrollment__c'));
		}

		Account seller2 = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert seller2;

		Program_Enrollment__c pe2 = (Program_Enrollment__c)TestFactory.newInstance(Program_Enrollment__c.class, 1, new Map<String, Object>{ 'Program__c' => program.Id, 'Account__c' => seller2.Id, 'Unique_ID__c' => seller2.Id + '-' + program.Id, 'Seller_Code__c' =>'REO' })[0];
		insert pe2;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Assets__c' => asset.Id, 'Opportunity__c' => opps[i].Id, 'Asset_Management__c' => ams[i].Id, 'MLH_Seller_Code__c' => 'REO', 'MLH_Event_ID__c' => 'O-415'});
		}

		aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Program_Enrollment__c FROM Auction_Opportunity_Assignment__c WHERE MLH_Seller_Code__c = \'REO\'')){
			System.assertEquals((String)aoa.get('Program_Enrollment__c'), pe2.Id, 'Program enrollment id should have changed AM: '+(String)aoa.get('Program_Enrollment__c'));
		}

		for(Asset_Management__c am : (List<Asset_Management__c>)database.query('SELECT Id, Program_Enrollment__c FROM Asset_Management__c')){
			System.assertEquals((String)am.get('Program_Enrollment__c'), pe2.Id, 'Program enrollment id should have changed AM: '+(String)am.get('Program_Enrollment__c'));
		}
		
		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Program_Enrollment__c FROM Opportunity')){
			System.assertEquals((String)opp.get('Program_Enrollment__c'), pe2.Id, 'Program enrollment id should have changed Opp: '+(String)opp.get('Program_Enrollment__c'));
		}
	}

	@isTest static void validateProgramEnrollmentChangedOnUpdate() {
		final Integer BATCH_SIZE = (TestUtils.BATCH_SIZE_OVERRIDE > 0 ? TestUtils.BATCH_SIZE_OVERRIDE : 250);
		List<Map<String, Object>> params = null;

		Account seller = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert seller;

		Contact c = (Contact)TestFactory.newInstance(Contact.class, 1, new Map<String, Object>{ 'AccountId' => seller.Id, 'Email' => 'assetconsideration@auction.com' })[0];
		insert c;

		Program__c program = (Program__c)TestFactory.newInstance(Program__c.class, 1)[0];
		insert program;

		Program_Enrollment__c pe = (Program_Enrollment__c)TestFactory.newInstance(Program_Enrollment__c.class, 1, new Map<String, Object>{ 'Program__c' => program.Id, 'Account__c' => seller.Id, 'Unique_ID__c' => seller.Id + '-' + program.Id, 'Seller_Code__c' =>'TST' })[0];
		insert pe;

		Asset__c asset = (Asset__c)TestFactory.newInstance(Asset__c.class, 1, new Map<String, Object>{ 'Baths__c' => null, 'Bedrooms__c' => null, 'Lot_Size_Sq_Ft__c' => null})[0];
		insert asset;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'AccountId' => seller.Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => asset.Id });
		}
		List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, params);
		insert opps;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Opportunity__c' => opps[i].Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => asset.Id });
		}
		List<Asset_Management__c> ams = TestFactory.newInstance(Asset_Management__c.class, params);
		insert ams;

		List<Auction_Opportunity_Assignment__c> aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id FROM Auction_Opportunity_Assignment__c');
		System.assertEquals(aoas.size(), 0, 'No aoas should be created: '+aoas.size());

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Assets__c' => asset.Id, 'Opportunity__c' => opps[i].Id, 'Asset_Management__c' => ams[i].Id, 'MLH_Seller_Code__c' => 'TST', 'MLH_Event_ID__c' => 'O-915'});
		}

		aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;
		
		for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Program_Enrollment__c FROM Auction_Opportunity_Assignment__c')){
			System.assertEquals((String)aoa.get('Program_Enrollment__c'), pe.Id, 'Program enrollment id should have changed AM: '+(String)aoa.get('Program_Enrollment__c'));
		}

		for(Asset_Management__c am : (List<Asset_Management__c>)database.query('SELECT Id, Program_Enrollment__c FROM Asset_Management__c')){
			System.assertEquals((String)am.get('Program_Enrollment__c'), pe.Id, 'Program enrollment ids do not match on asset management: '+(String)am.get('Program_Enrollment__c'));
		}

		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Program_Enrollment__c FROM Opportunity')){
			System.assertEquals((String)opp.get('Program_Enrollment__c'), pe.Id, 'Program enrollment ids do not match: '+(String)opp.get('Program_Enrollment__c'));
		}

		Account seller2 = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert seller2;

		Program_Enrollment__c pe2 = (Program_Enrollment__c)TestFactory.newInstance(Program_Enrollment__c.class, 1, new Map<String, Object>{ 'Program__c' => program.Id, 'Account__c' => seller2.Id, 'Unique_ID__c' => seller2.Id + '-' + program.Id, 'Seller_Code__c' =>'REO' })[0];
		insert pe2;

		for(Auction_Opportunity_Assignment__c aoa : aoas){
			aoa.put('MLH_Seller_Code__c', 'REO');
		}

		update aoas;

		for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Program_Enrollment__c FROM Auction_Opportunity_Assignment__c')){
			System.assertEquals((String)aoa.get('Program_Enrollment__c'), pe2.Id, 'Program enrollment id should have changed AM: '+(String)aoa.get('Program_Enrollment__c'));
		}

		for(Asset_Management__c am : (List<Asset_Management__c>)database.query('SELECT Id, Program_Enrollment__c FROM Asset_Management__c')){
			System.assertEquals((String)am.get('Program_Enrollment__c'), pe2.Id, 'Program enrollment id should have changed AM: '+(String)am.get('Program_Enrollment__c'));
		}
		
		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Program_Enrollment__c FROM Opportunity')){
			System.assertEquals((String)opp.get('Program_Enrollment__c'), pe2.Id, 'Program enrollment id should have changed Opp: '+(String)opp.get('Program_Enrollment__c'));
		}
	}

}