@isTest
private class AOAResiOpptyLookupValidatorTests {
	
	//private static final Integer BATCH_SIZE = 10;

	//@isTest static void validateOpportunityIdSet() {
	//	RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SobjectType = 'Opportunity'];

	//	Account seller = new Account();
	//	seller.put('Prefix__c','BAC');
	//	seller.put('Name','Test Apex Account');
	//	insert seller;

	//	Program__c reo = new Program__c ();
	//	reo.put('Product_Type__c', 'REO');
	//	reo.put('Active__c', true);
	//	insert reo;

	//	List<Program_Enrollment__c> enrollments = new List<Program_Enrollment__c> ();

	//	for(Integer i = 0; i < BATCH_SIZE; i++){
	//		Program_Enrollment__c pe = new Program_Enrollment__c ();
	//		pe.put('Account__c', seller.Id);
	//		pe.put('Program__c', reo.Id);
	//		pe.put('Seller_Code__c', 'BA'+String.valueOf(i).substring(0,1));

	//		enrollments.add(pe);
	//	}		

	//	insert enrollments;

	//	Map<String, Opportunity> opps = new Map<String, Opportunity> ();

	//	for(Integer i = 0; i < BATCH_SIZE; i++){
	//		String zip = '4444'+string.valueOf(i);
	//		String street = '12'+i+'Main st';
	//		String servicerCode = 'BAC';
	//		String productType = 'REO';
	//		String uniqueId = servicerCode+'-'+productType+'-'+street+'-'+zip;

	//		Opportunity opp = new Opportunity ();
	//		opp.put('Name', 'Test Opp Apex');
	//		opp.put('RecordTypeId', resiRT.Id);
	//		opp.put('Seller_Program_ID__c', uniqueId);
	//		opp.put('AccountId', seller.Id);
	//		opp.put('CloseDate', Date.today());
	//		opp.put('StageName', 'Stage 4. Pre-Auction');

	//		opps.put(street, opp);
	//	}

	//	insert opps.values();

	//	List<Auction_Opportunity_Assignment__c> aoas = new List<Auction_Opportunity_Assignment__c> ();
	//	for(Integer i = 0; i < BATCH_SIZE; i++){
	//		String zip = '4444'+string.valueOf(i);
	//		String street = '12'+i+'Main st';
	//		String sellerCode = 'BA'+String.valueOf(i).substring(0,1);
	//		String productType = 'REO';

	//		Auction_Opportunity_Assignment__c aoa = new Auction_Opportunity_Assignment__c ();
	//		aoa.put('MLH_Seller_Code__c', sellerCode);
	//		aoa.put('MLH_Property_Address__c', street);
	//		aoa.put('MLH_Property_Zipcode__c', Decimal.valueOf(zip));
	//		aoa.put('MLH_Product_Type__c', productType);

	//		aoas.add(aoa);
	//	}

	//	insert aoas;

	//	for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query('SELECT MLH_Property_Address__c, Opportunity__c FROM Auction_Opportunity_Assignment__c')){
	//		String street = (String)aoa.get('MLH_Property_Address__c');
	//		Opportunity opp = opps.get(street);

	//		System.assertEquals((String)aoa.get('Opportunity__c'), (String)opp.get('Id'), 'The opportunity was not set value is: '+(String)aoa.get('Opportunity__c'));
	//	}
	//}
}