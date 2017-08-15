public class AOASellerCodeValidator {
	
	public static void validate(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap, Map<String, Opportunity> oppsForUpdate, Map<String, Asset_Management__c> amForUpdate){		

		Set<String> sellerCodes = new Set<String> ();
		Set<String> oppIds = new Set<String> ();
		for(Auction_Opportunity_Assignment__c aoa : newList){			
			String oppId = (String)aoa.get('Opportunity__c');
			String amId = (String)aoa.get('Asset_Management__c');
			String sellerCode = (String)aoa.get('MLH_Seller_Code__c');
			String oldSellerCode = Trigger.isUpdate ? (String)oldMap.get(aoa.Id).get('MLH_Seller_Code__c') : null;

			if(oppId != null && amId != null && sellerCode != oldSellerCode){
				sellerCodes.add(sellerCode);
				oppIds.add(oppId);
			}
		}

		//query opportunity for the the current program enrollment
		List<Opportunity> oppList = (List<Opportunity>)database.query('SELECT Id, Program_Enrollment__c FROM Opportunity WHERE Id IN : oppIds');
		Map<String, List<Opportunity>> opps = MapUtils.groupByString(oppList,'Id');

		//query program enrollment records
		List<Program_Enrollment__c> enrollments = (List<Program_Enrollment__c>)database.query('SELECT Id, Seller_Code__c FROM Program_Enrollment__c WHERE Seller_Code__c IN : sellerCodes');
		Map<String, List<Program_Enrollment__c>> programEnrollments = MapUtils.groupByString(enrollments,'Seller_Code__c');

		//compare new aoas seller code to the program enrollment on the opportunity
		for(Auction_Opportunity_Assignment__c aoa : newList){
			String sellerCode = (String)aoa.get('MLH_Seller_Code__c');
			String oppId = (String)aoa.get('Opportunity__c');
			String amId = (String)aoa.get('Asset_Management__c');

			String oppEnrollmentId = (opps.containsKey(oppId)) ? opps.get(oppId)[0].Program_Enrollment__c : null;
			String aoaEnrollmentId = (programEnrollments.containsKey(sellerCode)) ? programEnrollments.get(sellerCode)[0].Id : null;

			//set the program enrollment on the aoa
			if(aoaEnrollmentId != null){
				aoa.put('Program_Enrollment__c', aoaEnrollmentId);
			}

			if(aoaEnrollmentId != null && oppEnrollmentId != aoaEnrollmentId){
				
				if(oppId != null){
					Opportunity updateOpp = new Opportunity( Id = oppId );
					updateOpp.put('Program_Enrollment__c', aoaEnrollmentId);				
					oppsForUpdate.put(oppId, updateOpp);
				}

				if(amId != null){
					Asset_Management__c updateAm = new Asset_Management__c( Id = amId );
					updateAm.put('Program_Enrollment__c', aoaEnrollmentId);
					amForUpdate.put(amId, updateAm);
				}
			}
		}
	}
}