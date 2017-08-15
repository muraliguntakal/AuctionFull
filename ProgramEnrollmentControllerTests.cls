@isTest
private class ProgramEnrollmentControllerTests {
	
	private static final Integer BATCH_SIZE;

	static {
		BATCH_SIZE = (TestUtils.BATCH_SIZE_OVERRIDE > 0 ? TestUtils.BATCH_SIZE_OVERRIDE : 250);
	} 

	@testSetup static void setup() {
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
			params.add(new Map<String, Object>{ 'Program__c' => p.Id, 'Destination_Field__c' => 'Return_Type__c', 'Destination_Field_2__c' => 'Seller_Code__c', 'Parent_Requirement__c' => prs[0].Id });
		}
		List<Program_Requirement__c> cprs = TestFactory.newInstance(Program_Requirement__c.class, params);
		insert cprs;

		Account a = (Account)TestFactory.newInstance(Account.class, 1)[0];
		insert a;
	}

	@isTest static void valdiateNewEnrollmentCreated() {
		Account a = [SELECT Id FROM Account LIMIT 1];

		Test.setCurrentPage(Page.ProgramEnrollmentQuestionnaire);

		ApexPages.currentPage().getParameters().put(Label.PE_VFP_Account_Field_ID + '_lkid', a.Id);

		ProgramEnrollmentController pec = new ProgramEnrollmentController(new ApexPages.StandardController(new Program_Enrollment__c()));

		System.assertEquals(a.Id, pec.enrollment.Account__c);
		System.assertEquals(null, pec.enrollment.Program__c);

		List<SelectOption> options = pec.programOptions;
		System.assertEquals(2, options.size(), 'There should be 2 options in picklist.');

		String programId = options[1].getValue();
		pec.enrollment.Program__c = programId;

		ApexPages.currentPage().getParameters().put('programId', programId);
		System.assertEquals(null, pec.getProgramRequirements());
		System.assertNotEquals(null, pec.parentReqGroups);
		System.assertEquals(1, pec.parentReqGroups.size());
		System.assertNotEquals(null, pec.parentReqs);
		System.assertEquals(1, pec.parentReqs.size());

		PageReference savePage = pec.submit();

		Program_Enrollment__c pe = [SELECT Id FROM Program_Enrollment__c LIMIT 1];
		System.assertNotEquals('/' + pe.Id, savePage.getUrl());

		Test.setCurrentPage(Page.ProgramEnrollmentQuestionnaire);

		ApexPages.currentPage().getParameters().put('accountId', a.Id);
		ApexPages.currentPage().getParameters().put('programId', programId);
		ApexPages.currentPage().getParameters().put('enrollmentId', pe.Id);

		ProgramEnrollmentController pec2 = new ProgramEnrollmentController(new ApexPages.StandardController(pe));

		System.assertEquals(a.Id, pec2.enrollment.Account__c);
		System.assertEquals(programId, pec2.enrollment.Program__c);

		PageReference newSavePage = pec2.submit();

		List<Program_Enrollment__c> pes = [SELECT Id FROM Program_Enrollment__c];
		System.assertEquals(1, pes.size(), 'There should only be one PE record created: ' + pes.size());
	}
	
}