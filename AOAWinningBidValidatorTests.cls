@isTest
private class AOAWinningBidValidatorTests {
	
	public static final Integer BATCH_SIZE = 20;

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
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Baths__c' => null, 'Bedrooms__c' => null, 'Lot_Size_Sq_Ft__c' => null, 'MLH_Global_Property_ID__c' => 'PROPID12345'+i});
		}
		List<Asset__c> assets = TestFactory.newInstance(Asset__c.class, params);
		insert assets;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'AccountId' => seller.Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => assets[i].Id });
		}
		List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, params);
		insert opps;

		List<Auction_Campaign__c> campaigns = new List<Auction_Campaign__c> ();
		for(Integer i = 0; i < BATCH_SIZE; i++){

			Auction_Campaign__c camp = new Auction_Campaign__c ();
			camp.put('Auction_Name__c', 'Midwest Auction  '+i);
			camp.put('Venue_Name__c', 'Venue '+i);
			camp.put('MLH_Event_Id__c', 'O-47 '+i);
			camp.put('MLH_Venue_Id__c', '1234'+i);
			camp.put('Auction_Region__c', 'Midwest');
			campaigns.add(camp);
		}

		insert campaigns;

		params = new List<Map<String, Object>>();

		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{'Opportunity__c' => opps[i].Id, 'MLH_Product_Type__c' => 'REO', 'Auction_Campaign__c' => campaigns[i].Id, 'MLH_Auction_ID__c' => 'AUC123'+i, 'MLH_Property_Id__c' => 'PROPID12345'+i, 'Auction_Day_Status__c' => 'Contract In Progress'});
		}

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		params = new List<Map<String, Object>>();

		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{'Opportunity__c' => opps[i].Id, 'MLH_Bidder_ID__c' => 'abc123'+i, 'MLH_Asset_ID__c' => 'PROPID12345'+i, 'Bid_Amount__c' => 100000+i, 'MLH_Auction_ID__c' => 'AUC123'+i, 'Opportunity__c' => opps[i].Id, 'Auction_Opportunity_Assignment__c' => aoas[i].Id});
		}

		List<Bid__c> originalBids = TestFactory.newInstance(Bid__c.class, params);
		insert originalBids;

		params = new List<Map<String, Object>>();

		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{'Opportunity__c' => opps[i].Id, 'MLH_Bidder_ID__c' => 'xyz123'+i, 'MLH_Asset_ID__c' => 'PROPID12345'+i, 'Bid_Amount__c' => 120000+i, 'MLH_Auction_ID__c' => 'AUC123'+i, 'Opportunity__c' => opps[i].Id, 'Auction_Opportunity_Assignment__c' => aoas[i].Id});
		}

		List<Bid__c> secondaryBids = TestFactory.newInstance(Bid__c.class, params);
		insert secondaryBids;
	}
	
	@isTest static void validateBidLookupUpdated() {
		List<Auction_Opportunity_Assignment__c> aoasForUpdate = new List<Auction_Opportunity_Assignment__c> ();

		for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, MLH_Bidder_ID__c, MLH_Asset_ID__c, MLH_Auction_ID__c, Bid_Amount__c, Opportunity__c, Auction_Opportunity_Assignment__c FROM Bid__c WHERE MLH_Bidder_ID__c LIKE \'abc123%\'')){
			String aoaId = (String)bid.get('Auction_Opportunity_Assignment__c');
			String winningBidderId = (String)bid.get('MLH_Bidder_ID__c');
			Decimal winningBidAmount = (Decimal)bid.get('Bid_Amount__c');

			Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c(Id = aoaId);
			aoa.put('MLH_Winning_Bidder_ID__c', winningBidderId);
			aoa.put('MLH_Final_Sale_Price__c', winningBidAmount);
			aoasForUpdate.add(aoa);
		}

		Test.startTest();
			update aoasForUpdate;
		Test.stopTest();

		Map<String, Opportunity> opps = new Map<String, Opportunity> ();
		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Winning_BidLookup__c FROM Opportunity')){
			opps.put((String)opp.get('Id'), opp);
		}

		for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, Opportunity__c, Winning_Bid__c, True_Winning_Bid__c FROM Bid__c WHERE MLH_Bidder_ID__c LIKE \'abc123%\'')){
			Opportunity opp = opps.get((String)bid.get('Opportunity__c'));

			System.assertEquals((Boolean)bid.get('Winning_Bid__c'), true);
			System.assertEquals((Boolean)bid.get('True_Winning_Bid__c'), true);
			System.assertEquals((String)opp.get('Winning_BidLookup__c'), bid.Id);
		}
	}

	@isTest static void validateWinningBidsRemoved() {
		List<Auction_Opportunity_Assignment__c> aoasForUpdate = new List<Auction_Opportunity_Assignment__c> ();

		for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, MLH_Bidder_ID__c, MLH_Asset_ID__c, MLH_Auction_ID__c, Bid_Amount__c, Opportunity__c, Auction_Opportunity_Assignment__c FROM Bid__c WHERE MLH_Bidder_ID__c LIKE \'abc123%\'')){
			String aoaId = (String)bid.get('Auction_Opportunity_Assignment__c');
			String winningBidderId = (String)bid.get('MLH_Bidder_ID__c');
			Decimal winningBidAmount = (Decimal)bid.get('Bid_Amount__c');

			Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c(Id = aoaId);
			aoa.put('MLH_Winning_Bidder_ID__c', winningBidderId);
			aoa.put('MLH_Final_Sale_Price__c', winningBidAmount);
			aoasForUpdate.add(aoa);
		}
		
		update aoasForUpdate;

		//set the secondary bids to winning bids
		AOAUtils.bidUpdatesComplete = false;
		aoasForUpdate = new List<Auction_Opportunity_Assignment__c> ();

		for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, MLH_Bidder_ID__c, MLH_Asset_ID__c, MLH_Auction_ID__c, Bid_Amount__c, Opportunity__c, Auction_Opportunity_Assignment__c FROM Bid__c WHERE MLH_Bidder_ID__c LIKE \'xyz123%\'')){
			String aoaId = (String)bid.get('Auction_Opportunity_Assignment__c');
			String winningBidderId = (String)bid.get('MLH_Bidder_ID__c');
			Decimal winningBidAmount = (Decimal)bid.get('Bid_Amount__c');

			Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c(Id = aoaId);
			aoa.put('MLH_Winning_Bidder_ID__c', winningBidderId);
			aoa.put('MLH_Final_Sale_Price__c', winningBidAmount);
			aoasForUpdate.add(aoa);
		}

		Test.startTest();
			update aoasForUpdate;
		Test.stopTest();

		Map<String, Opportunity> opps = new Map<String, Opportunity> ();
		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Winning_BidLookup__c FROM Opportunity')){
			opps.put((String)opp.get('Id'), opp);
		}

		for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, Opportunity__c, Winning_Bid__c, True_Winning_Bid__c FROM Bid__c WHERE MLH_Bidder_ID__c LIKE \'xyz123%\'')){
			Opportunity opp = opps.get((String)bid.get('Opportunity__c'));

			System.assertEquals((Boolean)bid.get('Winning_Bid__c'), true);
			System.assertEquals((Boolean)bid.get('True_Winning_Bid__c'), true);
			System.assertEquals((String)opp.get('Winning_BidLookup__c'), bid.Id);
		}	

		for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, Opportunity__c, Winning_Bid__c, True_Winning_Bid__c FROM Bid__c WHERE MLH_Bidder_ID__c LIKE \'abc123%\'')){
			System.assertEquals((Boolean)bid.get('Winning_Bid__c'), false);
			System.assertEquals((Boolean)bid.get('True_Winning_Bid__c'), false);
		}	
	}
}