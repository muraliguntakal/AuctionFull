public class AOAUpdateBPOValidator {

	public Set<String> oppIds;

	public AOAUpdateBPOValidator() {
		oppIds = new Set<String> ();
	}

	public void preValidate(Auction_Opportunity_Assignment__c aoa, Auction_Opportunity_Assignment__c oldAoa){
		
		String oppId = (String)aoa.get('Opportunity__c');
		String productType = (String)aoa.get('MLH_Product_Type__c');
		String status = (String)aoa.get('Status__c');
		String oldStatus = (String)oldAoa.get('Status__c');		

		if(oppId != null && (productType == 'Trustee' || productType =='FCL Marketing') && status != null && status != oldStatus){
			oppIds.add(oppId);
		}
	}

	public void validate(){
		if(!oppIds.isEmpty()){
			AOAUpdateBPOValidator.checkPhotoOrders(oppIds);
		}
	}

	@Future
	public static void checkPhotoOrders(Set<String> oppIds){
		List<BPO__c> bposForUpdate = new List<BPO__c> ();
		Set<String> valuationIds = new Set<String> ();

		for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Most_Recent_Valuation__c FROM Opportunity WHERE Id IN :oppIds AND RecordType.Name = \'Trustee\' AND Most_Recent_Valuation__c != null')){
			String valuationId = (String)opp.get('Most_Recent_Valuation__c');
			valuationIds.add(valuationId);
		}

		if(!valuationIds.isEmpty()){
			for(BPO__c bpo : (List<BPO__c>)database.query('SELECT Id, Place_Photo_Order__c, Order_Status__c, Order_Placement_Date__c, Auction_Status__c FROM BPO__c WHERE Valuation__c IN :valuationIds AND (Auction_Status__c != \'Completed\' OR Order_Placement_Date__c = null) ORDER BY CreatedDate DESC')){
				
				String status = (String)bpo.get('Auction_Status__c');
				Date placementDate = (Date)bpo.get('Order_Placement_Date__c');
				Boolean placeOrder = (placementDate == null && status == 'Auction') ? true : false;
				
				bpo.put('Place_Photo_Order__c', placeOrder);
				bposForUpdate.add(bpo);
			}
		}

		if(!bposForUpdate.isEmpty()){
			update bposForUpdate;
		}
	}
}