public with sharing class ProgramEnrollmentController {

	private final String programEnrollmentQuery = 'SELECT Id, Name, Order__c, Display_Group__c, Display_Group_Order__c, Description__c, Destination_Field__c, Destination_Field_2__c, Input_Type__c, Only_Allow_One_Option__c, Required__c, Parent_Requirement__c, (SELECT Id, Order__c, Description__c, Destination_Field__c, Parent_Field_Value__c, Destination_Field_2__c, Input_Type__c, Only_Allow_One_Option__c, Required__c FROM Child_Requirements__r WHERE Active__c = true ORDER BY Parent_Field_Value__c ASC, Order__c ASC) FROM Program_Requirement__c WHERE Program__c = :programId AND Active__c = true AND Parent_Requirement__c = null ORDER BY Display_Group_Order__c ASC, Order__c ASC';
	private final String programQuery = 'SELECT Id, Name, (SELECT Id FROM Program_Enrollments__r WHERE Account__c = :accountId) FROM Program__c WHERE Active__c = true ORDER BY Name ASC';

	public Map<String, List<Program_Requirement__c>> parentReqs { get; private set; }
	public Set<String> parentReqGroups { get; private set; }
	public Map<Id, Program__c> programs { get; private set; }

	public String enrollmentQuery { get; private set; }
	public String enrollmentId { get; private set; }
	public String accountId { get; private set; }
	public String programId { get; private set; }

	public Program_Enrollment__c enrollment { 
		get {
			if (enrollment == null) {
				if (enrollmentId == null) {
					enrollment = new Program_Enrollment__c(Account__c = accountId, Program__c = programId);
				} else {
					enrollment = Database.query(enrollmentQuery);
				}
			}
			return enrollment;
		}
		private set; 
	}

	public List<SelectOption> programOptions {
		get {
			if (programOptions == null) {
				programOptions = new List<SelectOption>();

				programOptions.add(new SelectOption('', '--None--'));

				for (Program__c p : programs.values()) {
					programOptions.add(new SelectOption(p.Id, p.Name));
				}
			}
			return programOptions;
		}
		private set;
	}

	public ProgramEnrollmentController(ApexPages.StandardController controller) {
		accountId = ApexPages.currentPage().getParameters().get(Label.PE_VFP_Account_Field_ID + '_lkid');
		enrollmentId = ApexPages.currentPage().getParameters().get('enrollmentId');

		if (accountId == null) {
			programId = ApexPages.currentPage().getParameters().get('programId');
			accountId = ApexPages.currentPage().getParameters().get('accountId');
			getRequirements(programId);
		} else {
			initRequirements();
		}
		getPrograms(accountId);
	}

	public PageReference getProgramRequirements() {
		String programId = ApexPages.currentPage().getParameters().get('programId');

		if (programId != null) {
			getRequirements(programId);
		}
		return null;
	}

	public PageReference submit() {
		PageReference savePage = null;

		try {
			upsert enrollment;

			savePage = new ApexPages.StandardController(enrollment).view();
			savePage.setRedirect(true);

		} catch (System.Exception e) {
			ApexPages.addMessages(e);
		}
		return savePage;
	}

	private void initRequirements() {
		parentReqs = new Map<String, List<Program_Requirement__c>>();
		parentReqGroups = new Set<String>();
	}

	private void getRequirements(String programId) {
		Set<String> fields = new Set<String>();

		try {
			List<Program_Requirement__c> reqts = Database.query(programEnrollmentQuery);

			initRequirements();

			/**
			 * Iterate over all requirements and build a unique list of fields that need to be 
			 * selected from the database.
			 */
			for (Program_Requirement__c reqt : reqts) {

				/**
				 * Pull the fields from both the Destination Field and Destination Field 2 
				 */
				if (reqt.Destination_Field__c != null && !fields.contains(reqt.Destination_Field__c)) {
					fields.add(reqt.Destination_Field__c);
				}
				if (reqt.Destination_Field_2__c != null && !fields.contains(reqt.Destination_Field_2__c)) {
					fields.add(reqt.Destination_Field_2__c);
				}

				/**
				 * If there are child requirements then iterate over those records and include those fields
				 * in the list if there are some that do not already exist within the list. In addition, 
				 * build two maps that will allow the VFP to index into the child field groups so they can
				 * be displayed appropriately.
				 */
				if (reqt.Child_Requirements__r != null && !reqt.Child_Requirements__r.isEmpty()) {
					Set<String> childGroups = new Set<String>();

					for (Program_Requirement__c cr : reqt.Child_Requirements__r) {
						if (cr.Destination_Field__c != null && !fields.contains(cr.Destination_Field__c)) {
							fields.add(cr.Destination_Field__c);
						}
						if (cr.Destination_Field_2__c != null && !fields.contains(cr.Destination_Field_2__c)) {
							fields.add(cr.Destination_Field_2__c);
						}
					}
				}
			}

			/**
			 * Query the database for all the fields that are on the requirements so that we know which fields
			 * will exist on the questionnaire.
			 */
			enrollmentQuery = 'SELECT Id, Name, Unique_ID__c, Account__c, Program_Manager__c, Client_Manager__c, Program__c' + (fields.isEmpty() ? '' : ',' + String.join(new List<String>(fields), ',')) + ' FROM Program_Enrollment__c WHERE Id = :enrollmentId';
			parentReqs = MapUtils.groupByString(reqts, 'Display_Group__c');
			parentReqGroups = SetUtils.getStrings(reqts, 'Display_Group__c');

		} catch (System.Exception e) {
			ApexPages.addMessages(e);
		}
	}

	public void getPrograms(String accountId) {
		try {
			programs = new Map<Id, Program__c>((List<Program__c>)Database.query(programQuery));
		} catch (System.Exception e) {
			ApexPages.addMessages(e);
		}
	}
}