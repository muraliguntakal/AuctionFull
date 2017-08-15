@isTest
private class AOAUpdateBPOValidatorTests {
	
	public static final Integer BATCH_SIZE = 20;
	
	@testSetup static void setup() {

		RecordType trusteeRT = [SELECT Id FROM RecordType WHERE Name = 'Trustee' AND SobjectType = 'Opportunity' Limit 1];
		
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
			params.add(new Map<String, Object>{ 'AccountId' => seller.Id, 'Program_Enrollment__c' => pe.Id, 'Asset__c' => assets[i].Id, 'RecordTypeId' => trusteeRT.Id});
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
			params.add(new Map<String, Object>{'Opportunity__c' => opps[i].Id, 'MLH_Product_Type__c' => 'Trustee', 'Auction_Campaign__c' => campaigns[i].Id, 'Status__c' => 'Not Sold'});
		}

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		params = new List<Map<String, Object>>();

		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{'Opportunity__c' => opps[i].Id, 'Asset__c' => assets[0].Id, 'Valuation_Type__c' => 'Photo'});
		}

		List<Valuation__c> valuations = TestFactory.newInstance(Valuation__c.class, params);
		insert valuations;

		for (Integer i = 0; i < BATCH_SIZE; i++) {
			opps[i].put('Most_Recent_Valuation__c', valuations[i].Id);
		}

		update opps;

		params = new List<Map<String, Object>>();

		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{'Valuation__c' => valuations[i].Id});
		}

		List<BPO__c> bpos = TestFactory.newInstance(BPO__c.class, params);
		insert bpos;
	}
	
	@isTest static void validateBpoChecked() {
		List<Auction_Opportunity_Assignment__c> aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Status__c FROM Auction_Opportunity_Assignment__c');
		
		for(Auction_Opportunity_Assignment__c aoa : aoas){
			aoa.put('Status__c', 'Auction');
		}

		update aoas;

		for(BPO__c bpo : (List<BPO__c>)database.query('SELECT Id, Place_Photo_Order__c FROM BPO__c')){
		//	System.assertEquals((Boolean)bpo.get('Place_Photo_Order__c'), true);
		}
	}
	
}