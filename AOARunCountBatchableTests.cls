@isTest
private class AOARunCountBatchableTests {
	
	public static final Integer PARENT_BATCH_SIZE = 20;
	public static final Integer CHILD_BATCH_SIZE = 10;

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
	}
	
	@isTest static void validateRunCountOnInsert() {
		List<Auction_Campaign__c> campaigns = new List<Auction_Campaign__c> ();
		for(Integer i = 0; i < CHILD_BATCH_SIZE; i++){

			Auction_Campaign__c camp = new Auction_Campaign__c ();
			camp.put('Auction_Name__c', 'Midwest Auction  '+i);
			camp.put('Venue_Name__c', 'Venue '+i);
			camp.put('MLH_Event_Id__c', 'O-47 '+i);
			camp.put('MLH_Venue_Id__c', '1234'+i);
			camp.put('Auction_Region__c', 'Midwest');
			campaigns.add(camp);
		}

		insert campaigns;

		List<Opportunity> opps = (List<Opportunity>)database.query('SELECt Id FROM Opportunity');

		List<Map<String, Object>> params = new List<Map<String, Object>>();
		for(Opportunity opp : opps){
			for (Integer i = 0; i < CHILD_BATCH_SIZE; i++) {
				String productType = (i < 5) ? 'REO' : 'Commercial';
				String status = (i > 2) ? 'Auction' : 'Deleted';

				params.add(new Map<String, Object>{ 'Opportunity__c' => opp.Id, 'MLH_Product_Type__c' => productType, 'Auction_Campaign__c' => campaigns[i].Id, 'Status__c' => status});
			}
		}
		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Process_Run_Count__c FROM Auction_Opportunity_Assignment__c');
		for(Auction_Opportunity_Assignment__c aoa : aoas){
			System.assertEquals((Boolean)aoa.get('Process_Run_Count__c'), true);
		}

		Test.startTest();
			AOARunCountBatchable arcb = new AOARunCountBatchable();
			Database.executeBatch(arcb);

			String jobId = System.schedule('AOARunCountSchedulable', '0 0 0 3 9 ? 2020', new AOARunCountSchedulable());		
		Test.stopTest();

		opps = (List<Opportunity>)database.query('SELECt Id, Run_Number__c FROM Opportunity');
		for(Opportunity opp : opps){
		//	System.assertEquals((Decimal)opp.get('Run_Number__c'), 7);
		}

		aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Process_Run_Count__c FROM Auction_Opportunity_Assignment__c');
		for(Auction_Opportunity_Assignment__c aoa : aoas){
			System.assertEquals((Boolean)aoa.get('Process_Run_Count__c'), false);
		}
	}
	
}