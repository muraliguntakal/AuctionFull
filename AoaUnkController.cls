public class AoaUnkController {

	private final ApexPages.StandardSetController stdSetController;

	public AoaUnkController(ApexPages.StandardSetController controller) {
		stdSetController = controller;
	}

	public PageReference unkRecords() {
		List<Auction_Opportunity_Assignment__c> aoasToUpdate = new List<Auction_Opportunity_Assignment__c>();
		String retUrl = ApexPages.currentPage().getParameters().get('retURL');
		PageReference savePage = null;

		for (SObject aoa : stdSetController.getSelected()) {
			aoasToUpdate.add(new Auction_Opportunity_Assignment__c(Id = aoa.Id, MLH_Seller_Code__c = 'UNK', MLH_Pool_Number__c = 'UNK', Status__c = 'Removed', Removal_Reason__c = 'Unknown', Removal_Requested_By__c = 'Move From Holding To Active', Removal_Date__c = Date.today()));
		}

		try {
			update aoasToUpdate;

			savePage = new PageReference((retUrl == null ? '/' : retUrl));
			savePage.setRedirect(true);

		} catch (System.DmlException de) {
			ApexPages.addMessages(de);
		}
		return savePage;
	}
}