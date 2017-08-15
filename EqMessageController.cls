public with sharing class EqMessageController {
	
	/**
	 * Consume a list of EQ Message records that need to be created. Return the list of errors if any 
	 * are returned while creating the records.
	 */
	@RemoteAction
	public static Map<String, Object> createMessages(List<EQ_Message__c> messages) {
		Map<String, Object> createResults = new Map<String, Object>{ 'Success' => true };
		Map<String, String> errorMap = new Map<String, String>();

		Database.SaveResult[] srs = Database.insert(messages, false);

		for (Integer i = 0; i < srs.size(); i++) {
			Database.SaveResult sr = srs[i];

			if (!sr.isSuccess()) {
				List<String> errorMessages = new List<String>();

				for (Database.Error e : sr.getErrors()) {
					errorMessages.add(e.getMessage());
				}
				errorMap.put(messages[i].Loan_Number__c, String.join(errorMessages, '\n'));
			}
		}

		if (!errorMap.isEmpty()) {
			createResults.put('Errors', errorMap);
		}
		return createResults;
	}
}