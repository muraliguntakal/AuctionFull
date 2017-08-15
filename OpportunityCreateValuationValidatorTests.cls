@isTest
private class OpportunityCreateValuationValidatorTests {
	
	public static final Integer BATCH_SIZE = 20;
	public static final RecordType trusteeRT = [SELECT Id FROM RecordType WHERE Name = 'Trustee' AND SobjectType = 'Opportunity' Limit 1];

	@testSetup static void setup() {
		
		Opportunity_Product_Type_Mapping__c rtv = new Opportunity_Product_Type_Mapping__c(Name = 'Trustee');
		rtv.RecordTypeId__c = trusteeRT.Id;
		insert rtv;
		
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
	}
	

	@isTest static void validateCreationOnInsert() {
		List<Map<String, Object>> params = new List<Map<String, Object>>();
		Date startDate = Date.today().addDays(2);

		for(Asset__c asset : (List<Asset__c>)database.query('SELECT Id FROM Asset__c')){
			params.add(new Map<String, Object>{'Asset__c' => asset.Id, 'Auction_Status__c' => 'Auction', 'MLH_Seller_Code__c' => 'TRT', 'MLH_Pool_Number__c' => 'TRT', 'MLH_Bid_Start_Date__c' => startDate, 'Auction_Test_Event__c' => false, 'RecordTypeId' => trusteeRT.Id});
		}

		List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, params);
		
		Test.startTest();
			insert opps;
		Test.stopTest();

		List<Valuation__c> valuations = (List<Valuation__c>)database.query('SELECT Id FROM Valuation__c');
		System.assertEquals(valuations.size(), BATCH_SIZE);		
	}

	@isTest static void validateNoCreationOnUpdate() {
		List<Map<String, Object>> params = new List<Map<String, Object>>();
		Date startDate = Date.today().addDays(2);

		for(Asset__c asset : (List<Asset__c>)database.query('SELECT Id FROM Asset__c')){
			params.add(new Map<String, Object>{'Asset__c' => asset.Id, 'Auction_Status__c' => 'Paused', 'MLH_Seller_Code__c' => 'TRT', 'MLH_Pool_Number__c' => 'TRT', 'MLH_Bid_Start_Date__c' => startDate, 'Auction_Test_Event__c' => false, 'RecordTypeId' => trusteeRT.Id});
		}

		List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, params);
		insert opps;

		List<Valuation__c> valuations = new List<Valuation__c> ();
		for(Opportunity opp : opps){
			Valuation__c val = new Valuation__c ();
			val.put('Opportunity__c', opp.Id);
			val.put('Asset__c', (String)opp.get('Asset__c'));
			val.put('Order_Status_BPO__c', 'Requested');
			val.put('Order_Requested_Date__c', Date.today());
			valuations.add(val);
				
			opp.put('Auction_Status__c', 'Auction');
		}
		
		insert valuations;

		Test.startTest();
			update opps;
		Test.stopTest();

		valuations = (List<Valuation__c>)database.query('SELECT Id FROM Valuation__c');
		System.assertEquals(valuations.size(), BATCH_SIZE);		
	}
	
}