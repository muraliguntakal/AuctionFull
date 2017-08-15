public class AOAResiOpptyLookupValidator {

	/*
	*
	*/

	//public static List<SObject> prevalidate(List<SObject> aoas){
	//	List<SObject> returnList = new List<SObject> ();

	//	for(SObject so : aoas){
	//		String oppId = (String)so.get('Opportunity__c');
	//		String sellerCode = (String)so.get('MLH_Seller_Code__c');
	//		String street = (String)so.get('MLH_Property_Address__c');
	//		Decimal zipCode = (Decimal)so.get('MLH_Property_Zipcode__c');
	//		String zip = String.valueOf(zipCode);
	//		String productType = (String)so.get('MLH_Product_Type__c');
	//		String business = (String)so.get('Line_of_Business__c');

	//		if(oppId == null && sellerCode != null && street != null && zip != null && business == 'Residential'){
	//			returnList.add(so);
	//		}
	//	}

	//	return returnList;
	//}

	/*
	*
	*/

	//public static Map<String,SObject> prefixAOAbySeller(List<SObject> aoas){

	//	Map<String,SObject> aoaMap = new Map<String, SObject> ();
	//	Map<String, String> servicerCodes = new Map<String, String> ();
	//	Set<String> sellerCodes = new Set<String> ();

	//	for(SObject aoa : aoas){
	//		sellerCodes.add((String)aoa.get('MLH_Seller_Code__c'));
	//	}

	//	if(!sellerCodes.isEmpty()){
	//		for(SObject so : (List<SObject>)database.query('SELECT Id, Account__r.Prefix__c, Seller_Code__c FROM Program_Enrollment__c WHERE Seller_Code__c IN : sellerCodes')){
	//			Program_Enrollment__c pe = (Program_Enrollment__c)so;

	//			if(pe.Account__r.Prefix__c != null){
	//				servicerCodes.put((String)pe.get('Seller_Code__c'), pe.Account__r.Prefix__c);
	//			}
	//		}
	//	}

	//	for(SObject aoa : aoas){
	//		String sellerCode = (String)aoa.get('MLH_Seller_Code__c');

	//		if(servicerCodes.containsKey(sellerCode)){
	//			String servicerCode = servicerCodes.get(sellerCode);
	//			String street = (String)aoa.get('MLH_Property_Address__c');
	//			Decimal zip = (Decimal)aoa.get('MLH_Property_Zipcode__c');
	//			String productType = (String)aoa.get('MLH_Product_Type__c');

	//			String zipCode = String.valueOf(zip);


	//			String uniqueId = servicerCode+'-'+productType+'-'+street+'-'+zipCode;
	//			aoaMap.put(uniqueId, aoa);
	//		}
	//	}

	//	return aoaMap;
	//}

	/*
	*
	*/
	//public static Map<String, SObject> getParentOpportunities(Map<String, SObject> aoaMap){
	//	Map<String, SObject> opps = new Map<String, SObject> ();

	//	if(!aoaMap.isEmpty()){
	//		Set<String> oppUniqueIds = aoaMap.keySet();
	//		for(SObject opp : (List<SObject>)database.query('SELECT Id, Seller_Program_ID__c FROM Opportunity WHERE Seller_Program_ID__c IN : oppUniqueIds')){
	//			String uniqueId = (String)opp.get('Seller_Program_ID__c');
	//			opps.put(uniqueId, opp);
	//		}
	//	}

	//	return opps;
	//}

	/*
	*
	*/
	//public static void validate(Map<String, SObject> aoaMap, Map<String, SObject> opps){

	//	for(String id : aoaMap.keySet()){
	//		SObject aoa = aoaMap.get(id);

	//		if(opps.containsKey(id)){
	//			SObject oppty = opps.get(id);
	//			aoa.put('Opportunity__c', (String)oppty.get('Id'));
	//		}
	//	}
	//}
}