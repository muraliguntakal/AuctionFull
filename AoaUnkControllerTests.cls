@isTest
private class AoaUnkControllerTests {
	
	@isTest static void validateRecordsAreUnkedAfterButtonClick() {
		final Integer BATCH_SIZE = (TestUtils.BATCH_SIZE_OVERRIDE > 0 ? TestUtils.BATCH_SIZE_OVERRIDE : 250);
		List<Map<String, Object>> params = null;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Status__c' => 'Auction', 'MLH_Seller_Code__c' => 'TST', 'MLH_Pool_Number__c' => 'TST' });
		}
		List<Auction_Opportunity_Assignment__c> aoas = TestFactory.newInstance(Auction_Opportunity_Assignment__c.class, params);
		insert aoas;

		Test.setCurrentPage(Page.AoaUnk);

		List<Auction_Opportunity_Assignment__c> uaoas = [SELECT Id FROM Auction_Opportunity_Assignment__c];

		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(uaoas);
		ssc.setSelected(new List<Auction_Opportunity_Assignment__c>{ uaoas[0] });

		ApexPages.currentPage().getParameters().put('retURL', '/' + uaoas[0].Id);

		AoaUnkController auc = new AoaUnkController(ssc);
		System.assertNotEquals(null, auc.unkRecords());

		Auction_Opportunity_Assignment__c uaoas2 = [SELECT Id, Status__c, MLH_Pool_Number__c, MLH_Seller_Code__c, Removal_Reason__c, Removal_Date__c FROM Auction_Opportunity_Assignment__c WHERE Id = :uaoas[0].Id];
		System.assertEquals('Removed', uaoas2.Status__c);
		System.assertEquals('UNK', uaoas2.MLH_Pool_Number__c);
		System.assertEquals('UNK', uaoas2.MLH_Seller_Code__c);
		System.assertEquals('Unknown', uaoas2.Removal_Reason__c);
		System.assertEquals(Date.today(), uaoas2.Removal_Date__c);
	}
	
}