public class AOAUpdateWinningBidValidator {

	public Map<String, Auction_Opportunity_Assignment__c> aoas;

	public AOAUpdateWinningBidValidator() {
		aoas = new Map<String, Auction_Opportunity_Assignment__c> ();
	}

	public void preValidate(Auction_Opportunity_Assignment__c aoa, Auction_Opportunity_Assignment__c oldAoa){

		String aoaId = (String)aoa.get('Id');
		String status = (String)aoa.get('Auction_Day_Status__c');
		String oldStatus = (String)oldAoa.get('Auction_Day_Status__c');
		String stage = (String)aoa.get('Stage__c');
		String oldStage = (String)oldAoa.get('Stage__c');

		if( (stage != oldStage && stage != null) || (status != oldStatus && status == 'Escrow In Progress') ){
			aoas.put(aoaId, aoa);
		}	
	}

	public void validate(Map<String, Bid__c> bidsForUpdate){

		if(!aoas.isEmpty()){
			Set<String> aoaIds = aoas.keySet();
			for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, OwnerId, Auction_Opportunity_Assignment__c, MLH_Bid_Stage__c FROM Bid__c WHERE Auction_Opportunity_Assignment__c IN: aoaIds AND Winning_Bid__c = True')){
				
				String bidId = (String)bid.get('Id');
				bid = bidsForUpdate.containsKey(bidId) ? bidsForUpdate.get(bidId) : bid;

				String aoaId = (String)bid.get('Auction_Opportunity_Assignment__c');
				Auction_Opportunity_Assignment__c aoa = aoas.get(aoaId);				
		
				if( (String)aoa.get('Stage__c') != null ){
					bid.put('MLH_Bid_Stage__c', (String)aoa.get('Stage__c'));
				}

				if( (String)aoa.get('Auction_Day_Status__c') == 'Escrow In Progress'){
					bid.OwnerId = '005d0000002jB6P';
				}

				bidsForUpdate.put(bidId, bid);
			}
		}
	}
}