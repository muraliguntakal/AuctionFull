public class BidUtils {
	
	public static void validateWinningBidderContacts(List<Bid__c> newList, List<Bid__c> oldList, Map<Id, Bid__c> oldMap) {
		Map<String, List<Bid__c>> bidMap = new Map<String, List<Bid__c>>();
		List<Bid__c> bids = (Trigger.isDelete ? oldList : newList);

		for (Bid__c b : bids) {
			if (Trigger.isDelete) {
				MapUtils.addToMap(bidMap, b.Assets__c, b);
			} else if (Trigger.isInsert) {
				if ((b.Created_From_Rest_API__c == true || b.True_Winning_Bid__c == true) && b.Assets__c != null && b.Buyer_Name__c != null) {
					MapUtils.addToMap(bidMap, b.Assets__c, b);
				}
			} else if (Trigger.isUpdate) {
				if (b.Buyer_Name__c != oldMap.get(b.Id).Buyer_Name__c || b.Assets__c != oldMap.get(b.Id).Assets__c || b.Created_From_Rest_API__c != oldMap.get(b.Id).Created_From_Rest_API__c || b.True_Winning_Bid__c != oldMap.get(b.Id).True_Winning_Bid__c) {
					MapUtils.addToMap(bidMap, b.Assets__c, b);

					if (b.Assets__c != oldMap.get(b.Id).Assets__c && oldMap.get(b.Id).Assets__c != null) {
						MapUtils.addToMap(bidMap, oldMap.get(b.Id).Assets__c, b);
					}
				}
			}
		}

		if (!bidMap.isEmpty()) {
			List<Asset__c> assets = 
				[SELECT Id, Winning_Bidder_Contact_IDs__c, (SELECT Id, Created_From_Rest_API__c, True_Winning_Bid__c, Buyer_Name__c FROM Bids__r WHERE Buyer_Name__c != null AND (Created_From_Rest_API__c = true OR True_Winning_Bid__c = true)) 
				 FROM Asset__c 
				 WHERE Id IN :bidMap.keySet()];

			for (Asset__c asset : assets) {
				asset.Winning_Bidder_Contact_IDs__c = null;

				for (Bid__c o : asset.Bids__r) {
					asset.Winning_Bidder_Contact_IDs__c = (asset.Winning_Bidder_Contact_IDs__c == null ? o.Buyer_Name__c + '|' : asset.Winning_Bidder_Contact_IDs__c + o.Buyer_Name__c + '|');
				}
			}
			update assets;
		}
	}
}