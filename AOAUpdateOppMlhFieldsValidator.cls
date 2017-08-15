public class AOAUpdateOppMlhFieldsValidator {


	public void preValidate(Auction_Opportunity_Assignment__c aoa, Auction_Opportunity_Assignment__c oldAoa, Map<String, Opportunity> oppsForUpdate){
		
		String oppId = (String)aoa.get('Opportunity__c');
		String productType = (String)aoa.get('MLH_Product_Type__c');
		String line = (String)aoa.get('Line_Of_Business__c');
		String loanNo = (String)aoa.get('MLH_Loan_Number__c');
		String venueId = (String)aoa.get('MLH_Venue_ID__c');
		String oldVenueId = (String)oldAoa.get('MLH_Venue_ID__c');
		String status = (String)aoa.get('Status__c');
		String oldStatus = (String)oldAoa.get('Status__c');
		Date startDate = (Date)aoa.get('Property_Auction_Date__c');
		Date oldStartDate = (Date)oldAoa.get('Property_Auction_Date__c');
		String homeowner = (String)aoa.get('Trustor__c');
		String oldHomeOwner = (String)oldAoa.get('Trustor__c');
		String outsourcer = (String)aoa.get('MLH_Outsourcer_Code__c');
		String oldOutsourcer = (String)oldAoa.get('MLH_Outsourcer_Code__c');
		String sellerCode = (String)aoa.get('MLH_Seller_Code__c');
		String oldSellerCode = (String)oldAoa.get('MLH_Seller_Code__c');
		String pool = (String)aoa.get('MLH_Pool_Number__c');
		String oldPool = (String)oldAoa.get('MLH_Pool_Number__c');
		Date recdDate = (Date)aoa.get('MLH_File_Received_Date__c');
		Date oldRecdDate = (Date)oldAoa.get('MLH_File_Received_Date__c');
		String sellerName = (String)aoa.get('Seller_Name__c');
		String oldSellerName = (String)oldAoa.get('Seller_Name__c');		

		if( oppId != null && ( (productType == 'Trustee') || (productType == 'FCL Marketing') || (line == 'Residential') ) ){
			if( (status != oldStatus) || (startDate != oldStartDate) || (homeowner != oldHomeOwner) || (outsourcer != oldOutsourcer) || (sellerCode != oldSellerCode) || (pool != oldPool) || (sellerName != oldSellerName) || (recdDate != oldRecdDate) || (venueId != oldVenueId) ){
				Opportunity opp = new Opportunity( Id = oppId );				
				opp.put('MLH_Venue_ID__c', venueId);
				opp.put('Auction_Status__c', status);
				opp.put('MLH_Bid_Start_Date__c', startDate);
				opp.put('First_Last_Name_Homeowner__c', homeowner);

				if(loanNo != null){
					opp.put('Loan_Number__c', loanNo);
				}

				if(outsourcer != null){
					opp.put('Outsourcer_Code__c', outsourcer);
				}

				if(sellerCode != null){
					opp.put('MLH_Seller_Code__c', sellerCode);
				}

				if(pool != null){
					opp.put('MLH_Pool_Number__c', pool);
				}

				if(recdDate != null){
					opp.put('MLH_File_Received_Date__c', recdDate);
				}

				if(sellerName != null){
					opp.put('MLH_Seller_Name__c', sellerName);
				}

				oppsForUpdate.put(oppId, opp);
			}
		}
	}

	//public void validate(){}
}