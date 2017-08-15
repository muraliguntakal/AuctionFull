@isTest
private class ProgramControllerTests {
	
	@isTest static void validateProgramIsClonedWithRequirements() {
		final Integer BATCH_SIZE = (TestUtils.BATCH_SIZE_OVERRIDE > 0 ? TestUtils.BATCH_SIZE_OVERRIDE : 250);
		List<Map<String, Object>> params = null;

		Program__c p = (Program__c)TestFactory.newInstance(Program__c.class, 1)[0];
		insert p;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Program__c' => p.Id });
		}
		List<Program_Requirement__c> prs = TestFactory.newInstance(Program_Requirement__c.class, params);
		insert prs;

		params = new List<Map<String, Object>>();
		for (Integer i = 0; i < BATCH_SIZE; i++) {
			params.add(new Map<String, Object>{ 'Program__c' => p.Id, 'Parent_Requirement__c' => prs[0].Id });
		}
		List<Program_Requirement__c> cprs = TestFactory.newInstance(Program_Requirement__c.class, params);
		insert cprs;

		ApexPages.currentPage().getParameters().put('id', p.Id);

		ProgramController pc = new ProgramController(new ApexPages.StandardController(p));
		PageReference savePage = pc.submit();

		List<Program__c> ups = [SELECT Id, (SELECT Id FROM Program_Requirements__r) FROM Program__c WHERE Id != :p.Id];
		System.assertEquals(1, ups.size(), 'There should only be one new program created.');
		System.assertEquals(2*BATCH_SIZE, ups[0].Program_Requirements__r.size(), 'There size of the PRs should match the base program.');
	}

	@isTest static void validateProgramBlankIfErrorInQuery() {
		Program__c p = (Program__c)TestFactory.newInstance(Program__c.class, 1)[0];
		insert p;

		ApexPages.currentPage().getParameters().put('id', 'FakeId');

		ProgramController pc = new ProgramController(new ApexPages.StandardController(p));
		System.assertEquals(null, pc.program.Id, 'The program should be blank if there was an error on page load.');
	}

}