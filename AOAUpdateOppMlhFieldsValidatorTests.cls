@isTest
private class AOAUpdateOppMlhFieldsValidatorTests {

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
			params.add(new Map<String, Object>{'Opportunity__c' => opps[i].Id, 'MLH_Product_Type__c' => 'REO', 'Auction_Campaign__c' => campaigns[i].Id, 'MLH_Loan_Number__c' => '12345'+i, 'Status__c' => 'Paused', 'MLH_Seller_Code__c' => 'ZZ'+i});
		}

		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;
	}
	
	@isTest static void validateAoaDetailsPushedToOpportunity() {
		List<Auction_Opportunity_Assignment__c> aoas = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, MLH_Loan_Number__c, Status__c, Opportunity__c, MLH_Seller_Code__c FROM Auction_Opportunity_Assignment__c');

		for(Auction_Opportunity_Assignment__c aoa : aoas){
			String loanNo = (String)aoa.get('MLH_Loan_Number__c') + 'ii';
			String sellerCode = (String)aoa.get('MLH_Seller_Code__c');
			sellerCode = sellerCode.substring(0,2) + 'i';
			
			aoa.put('MLH_Loan_Number__c', loanNo);
			aoa.put('MLH_Seller_Code__c', sellerCode);
			aoa.put('Status__c', 'Auction');
			aoa.put('Property_Auction_Date__c', Date.today());
			aoa.put('MLH_Outsourcer_Code__c', sellerCode);
			aoa.put('MLH_Pool_Number__c', sellerCode);
			aoa.put('Seller_Name__c', 'Auction');
			aoa.put('MLH_File_Received_Date__c', Date.today().addDays(-7));
		}

		update aoas;

		Map<String, Opportunity> oppMap = new Map<String, Opportunity> ();
		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Loan_Number__c, MLH_Seller_Code__c, Auction_Status__c,MLH_Bid_Start_Date__c FROM Opportunity')){
			oppMap.put((String)opp.get('Id'), opp);
		}

		for(Auction_Opportunity_Assignment__c aoa : aoas){
			Opportunity opp = oppMap.get((String)aoa.get('Opportunity__c'));
			System.assertEquals((String)aoa.get('MLH_Seller_Code__c'), (String)opp.get('MLH_Seller_Code__c'));
			System.assertEquals((String)aoa.get('MLH_Loan_Number__c'), (String)opp.get('Loan_Number__c'));
			System.assertEquals((String)aoa.get('Status__c'), (String)opp.get('Auction_Status__c'));
			System.assertEquals((Date)aoa.get('Property_Auction_Date__c'), (Date)opp.get('MLH_Bid_Start_Date__c'));
		}
	}
}