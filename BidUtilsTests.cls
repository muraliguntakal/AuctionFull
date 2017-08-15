@isTest
private class BidUtilsTests {
	
	private static final Integer NUM_OF_ASSETS = 2;

	@testSetup static void init() {
		List<Map<String, Object>> params = null;

		Account acct = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert acct;

		Contact c = (Contact)TestFactory.newInstance(Contact.class, 1, new Map<String, Object>{ 'AccountId' => acct.Id, 'Email' => 'fakebuyer123@auction.com' })[0];
		insert c;

		List<Asset__c> assets = TestFactory.newInstance(Asset__c.class, NUM_OF_ASSETS);
		insert assets;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < NUM_OF_ASSETS; i++) {
			params.add(new Map<String, Object>{ 'Assets__c' => assets[i].Id });
		}
		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		insert new TriggerSettings__c(Name = 'BidTrigger', Status__c = true);
	}

	@isTest static void validateContactIdAddedOnInsertWithWB() {
		Asset__c a = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => a.Id, 'Auction_Opportunity_Assignment__c' => a.Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Created_From_Rest_API__c' => true, 'Buyer_Name__c' => c.Id })[0];
		insert b;

		Asset__c ua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertNotEquals(null, ua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should not be empty.');
	}

	@isTest static void validateContactIdAddedOnInsertWithTWB() {
		Asset__c a = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => a.Id, 'Auction_Opportunity_Assignment__c' => a.Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Created_From_Rest_API__c' => false, 'True_Winning_Bid__c' => true, 'Buyer_Name__c' => c.Id })[0];
		insert b;

		Asset__c ua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertNotEquals(null, ua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should not be empty.');
	}
	
	@isTest static void validateContactIdRemovedWhenOfferDeleted() {
		Asset__c a = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => a.Id, 'Auction_Opportunity_Assignment__c' => a.Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Created_From_Rest_API__c' => true, 'Buyer_Name__c' => c.Id })[0];
		insert b;

		delete b;

		Asset__c ua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertEquals(null, ua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should be empty.');
	}

	@isTest static void validateContactIdUpdatedOnUpdateOfWinningBid() {
		Asset__c a = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => a.Id, 'Auction_Opportunity_Assignment__c' => a.Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Buyer_Name__c' => c.Id })[0];
		insert b;

		Asset__c ua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertEquals(null, ua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should be empty.');		

		b.Created_From_Rest_API__c = true;
		update b;

		Asset__c uua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertNotEquals(null, uua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should not be empty.');
	}

	@isTest static void validateContactIdUpdatedOnUpdateOfTrueWinningBid() {
		Asset__c a = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => a.Id, 'Auction_Opportunity_Assignment__c' => a.Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Buyer_Name__c' => c.Id })[0];
		insert b;

		Asset__c ua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertEquals(null, ua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should be empty.');		

		b.True_Winning_Bid__c = true;
		update b;

		Asset__c uua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertNotEquals(null, uua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should not be empty.');
	}
	
	@isTest static void validateBothContactIdsAddedOnUpdateOfCustomAsset() {
		List<Asset__c> assets = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c ORDER BY Id];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => assets[0].Id, 'Auction_Opportunity_Assignment__c' => assets[0].Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Created_From_Rest_API__c' => true, 'Buyer_Name__c' => c.Id })[0];
		insert b;

		b.Assets__c = assets[1].Id;
		update b;

		List<Asset__c> uassets = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c ORDER BY Id];
		System.assertEquals(null, uassets[0].Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should be empty');
		System.assertNotEquals(null, uassets[1].Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should not be empty.');
	}

	@isTest static void validateContactIdUpdatedOnUpdateOfBuyer() {
		Asset__c a = [SELECT Id, (SELECT Id FROM Auction_Opportunity_Assignments__r) FROM Asset__c LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];

		Bid__c b = (Bid__c)TestFactory.newInstance(Bid__c.class, 1, new Map<String, Object>{ 'Assets__c' => a.Id, 'Auction_Opportunity_Assignment__c' => a.Auction_Opportunity_Assignments__r[0].Id, 'Bid_Amount__c' => 100000, 'Created_From_Rest_API__c' => true })[0];
		insert b;

		Asset__c ua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertEquals(null, ua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should be empty.');		

		b.Buyer_Name__c = c.Id;
		update b;

		Asset__c uua = [SELECT Id, Winning_Bidder_Contact_IDs__c FROM Asset__c WHERE Id = :a.Id];
		System.assertNotEquals(null, uua.Winning_Bidder_Contact_IDs__c, 'The Winning Bidder Contact IDs field should not be empty.');
	}
}