@isTest
private class EqMessageControllerTests {
	
	@isTest static void validateEqMessagesFailBeingCreated() {
		Test.startTest();
			Map<String, Object> results = EqMessageController.createMessages(new List<EQ_Message__c>{
				new EQ_Message__c(Client__c = 'Bank of America', Status__c = 'Requested', Loan_Number__c = '12345')
			});
		Test.stopTest();

		System.assert(!results.isEmpty(), 'Results should not be null');
		System.assertEquals(true, results.containsKey('Errors'));
	}
	
	@isTest static void validateEqMessagesAreSuccessfulBeingCreated() {
		Test.startTest();
			Map<String, Object> results = EqMessageController.createMessages(new List<EQ_Message__c>{
				new EQ_Message__c(Client__c = 'Bank of America', Status__c = 'Requested', Loan_Number__c = '12345', Subject__c = 'Testing', Body__c = 'Testing')
			});
		Test.stopTest();

		System.assert(!results.isEmpty(), 'Results should not be null');
		System.assertEquals(true, results.containsKey('Success'));
	}
	
}