public class AuctionCampaignMerge {	

	public static List<String> copyFlds = new List<String>{'MLH_Venue_Id__c', 'MLH_Auction_ID2__c', 'Test_Event__c', 'Venue_Name__c', 'Venue_Order__c', 'AuctionIDVenueOrder__c', 'Auction_Name__c'};

	public static String queryFldsStr(){
		String str = '';
		for(String fld : copyFlds){
			str += (fld != copyFlds.get(copyFlds.size() -1)) ? fld + ',' : fld;
		}

		return str;
	}

	public String uniqueId;	

	public AuctionCampaignMerge(String uniqueId) {
		this.uniqueId = uniqueId;
		reassignedAoas = new List<Auction_Opportunity_Assignment__c> ();
	}

	public Auction_Campaign__c mergeCampaign;
	public Auction_Campaign__c deleteCampaign;
	public List<Auction_Opportunity_Assignment__c> reassignedAoas;	

	public Boolean mergeAuctions(Auction_Campaign__c auc1, Auction_Campaign__c auc2){
		Boolean mergeResult = false;

		String uId1 = (String)auc1.get('SF_Integration_ID__c');
		String uId2 = (String)auc2.get('SF_Integration_ID__c');

		if((uId1 != null && uId1 == uniqueId) || (uId2 != null && uId2 == uniqueId)){
			mergeCampaign = (uId1 != null) ? auc1 : auc2;
			deleteCampaign = (uId1 != null) ? auc2 : auc1;

			for(String fld : copyFlds){
				Object val = deleteCampaign.get(fld);
				Object destVal = mergeCampaign.get(fld);

				if(val != null && val != destVal){
					mergeCampaign.put(fld, val);
				}
			}

			mergeResult = true;
			reassignAoas();
		}

		return mergeResult;
	}

	private void reassignAoas(){
		if(deleteCampaign.Auction_Opportunity_Assignments__r != null && !deleteCampaign.Auction_Opportunity_Assignments__r.isEmpty()){
			for(Auction_Opportunity_Assignment__c aoa : deleteCampaign.Auction_Opportunity_Assignments__r){
				aoa.put('Auction_Campaign__c', mergeCampaign.Id);
				reassignedAoas.add(aoa);
			}
		}
	}
}