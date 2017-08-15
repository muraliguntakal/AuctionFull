public with sharing class ProgramController {

	private final Program__c baseProgram = null;

	public Program__c program {
		get {
			if (program == null) {
				if (baseProgram == null) {
					program = new Program__c();
				} else {
					program = baseProgram.clone();
				}
			}
			return program;
		}
		private set;
	}

	public ProgramController(ApexPages.StandardController controller) {
		try {
			baseProgram = [SELECT Id, Name, Product_Type__c, Line_of_Business__c, Active__c, Description__c, OwnerId, (SELECT Id, Name, Active__c, Description__c, Destination_Field__c, Display_Group__c, Display_Group_Order__c, Order__c, Parent_Field_Value__c, Parent_Requirement__c, Program__c FROM Program_Requirements__r) FROM Program__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
		} catch(System.Exception e) {
			baseProgram = null;
		}
	}

	public PageReference submit() {
		Map<Id, Program_Requirement__c> parentReqs = new Map<Id, Program_Requirement__c>();
		List<Program_Requirement__c> childReqs = new List<Program_Requirement__c>();
		PageReference savePage = null;

		try {
			insert program;

			if (baseProgram.Program_Requirements__r != null && !baseProgram.Program_Requirements__r.isEmpty()) {
				for (Program_Requirement__c pr : baseProgram.Program_Requirements__r) {
					Program_Requirement__c npr = pr.clone();

					npr.Program__c = program.Id;

					if (pr.Parent_Requirement__c != null) {
						childReqs.add(npr);
					} else {
						parentReqs.put(pr.Id, npr);
					}
				}
			}
			insert parentReqs.values();

			for (Program_Requirement__c cr : childReqs) {
				cr.Parent_Requirement__c = parentReqs.get(cr.Parent_Requirement__c).Id;
			}
			insert childReqs;

			savePage = new ApexPages.StandardController(program).view();
			savePage.setRedirect(true);

		} catch (System.Exception e) {
			ApexPages.addMessages(e);			
		}
		return savePage;
	}

}