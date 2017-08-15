/**
 * Show all the secondary contact records
 * Update relation betwwen primary and secondary
 * 
 * @author      UC Innovation Tonny Xia
 * @version     1.0
 * @since       1.0
 */
public with sharing class AdditionalContactRecordsController {
	
	public List<AdditionalContactWrapper> AdditionalContactList{get;set;}
	public Boolean Edited{get; set;}
	public Boolean ShowAddButton{get; set;}
	public Id primaryId{get;set;}
	private Id selectedContactId;
	private List<Contact> addContList;
	private Map<Id, Boolean> InitialConfirmMap;
	private Map<Id, Boolean> InitialPrimaryMap;
	
	/**
     * Constructor
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
	public AdditionalContactRecordsController(ApexPages.StandardController stdController){
		Edited = false;
        selectedContactId = ((Contact)stdController.getRecord()).id;
        
        Contact tempAddCont = [Select Id, 
									  Name,
									  Account.Name,
									  Primary_Status__c
								 From Contact
								Where Id =: selectedContactId];
        if (tempAddCont.Primary_Status__c == 'Primary') {
        	ShowAddButton = true;
        } else {
        	ShowAddButton = false;
        }
        
        //selectedContactId = '003d000001dvXRE';
        
       
    }
    
    /**
     * Create Wrapper class
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
    public class AdditionalContactWrapper {
        
        public Account WrapperAccount{get;set;}
        public Contact WrapperContact{get;set;}
        public Boolean IsPrimary{get;set;}
        public Boolean IsRemoved{get;set;}
        public Boolean Confirm{get;set;}
        public String AccountName{get;set;}
        public Id AccountsId{get;set;}

        public AdditionalContactWrapper(Contact cont, Boolean isPri) {
        	
	    	WrapperContact = cont;
	    	IsPrimary = isPri;
	    	AccountName = cont.Account.Name;
	    	AccountsId = cont.AccountId;
	    	if (cont.Probability__c == 100) {
	    		Confirm = true;
	    	} else {
	    		Confirm = false;
	    	}
	    }
    }
    
    /**
     * Edit button function
     *
     * @param       None
     * @return      null
     * @since       1.0
     */
    public PageReference EditChanged() {
    	if (Edited == false) {
    		Edited = true;
    		ShowAddButton = false;
    	} else {
    		Edited = false;
    		if (AdditionalContactList[0].IsPrimary == true) {
	    		ShowAddButton = true;
	    	}
    	}
    	return null;
    }
    
    /**
     * Cancel button function
     *
     * @param       None
     * @return      null
     * @since       1.0
     */
    public PageReference CancelButton() {
    	Edited = false;
    	if (AdditionalContactList[0].IsPrimary == true) {
    		ShowAddButton = true;
    	}
    	return null;
    }
    
    /**
     * Add Additional Contact  button function
     *
     * @param       None
     * @return      null
     * @since       1.0
     */
    public PageReference AddAdditionalContact() {
    	
    	for(AdditionalContactWrapper acw: AdditionalContactList) {
    		if (acw.IsPrimary == true) {
    			primaryId = acw.WrapperContact.Id;
    		}
    	}
    	PageReference pageRef = new PageReference('/apex/addadditionalcontact?ContactId=' + primaryId);
    	pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
     * Create Wrapper list to show on the VF page
     *
     * @param       None
     * @return      List of wrapper
     * @since       1.0
     */
    public List<AdditionalContactWrapper> getAdditionalContactShowList() {
    	InitialConfirmMap = new Map<Id, Boolean>();
    	InitialPrimaryMap = new Map<Id, Boolean>();
    	addContList = [Select Id, 
						  Name, 
						  Account.Name,
						  Primary_Contact__c, 
						  Primary_Status__c,
						  Primary_Status_Contact__c,
						  AccountId, 
						  MLH_Contact_ID__c,
						  MailingState, 
						  MailingCity,
						  Email,
						  Probability__c,
						  Phone
					 From Contact
					Where Id =: selectedContactId or Primary_Status_Contact__c =: selectedContactId];
					
		if (addContList.size() == 1 && addContList[0].Primary_Status_Contact__c != null) {
			List<Contact> tempaddContList = [Select Id, 
												  Name, 
												  Account.Name,
												  Primary_Contact__c, 
												  Primary_Status__c,
												  Primary_Status_Contact__c,
												  AccountId, 
												  MLH_Contact_ID__c,
												  MailingState, 
												  MailingCity,
												  Email, 
												  Probability__c,
												  Phone
											 From Contact
											Where Id =: addContList[0].Primary_Status_Contact__c or Primary_Status_Contact__c =: addContList[0].Primary_Status_Contact__c];
			addContList.addAll(tempaddContList);
		}
    	
    	AdditionalContactList = new List <AdditionalContactWrapper>();
    	
    	AdditionalContactWrapper tempOne;
    	
    	for (Contact cont: addContList) {
    		Boolean isPri;
    		if (cont.Primary_Status__c == 'Primary') {
    			cont.Probability__c = 100;
    			isPri = true;
    		} else {
    			isPri = false;
    		}
    		
    		if (cont.Id == selectedContactId) {
    			tempOne = new AdditionalContactWrapper(cont, isPri);
    		} else {
    			AdditionalContactWrapper acWarapper = new AdditionalContactWrapper(cont, isPri);
    			AdditionalContactList.add(acWarapper);
    			InitialConfirmMap.put(acWarapper.WrapperContact.Id, acWarapper.Confirm);
    			InitialPrimaryMap.put(acWarapper.WrapperContact.Id, acWarapper.IsPrimary);
    		}
    	}
    	if (AdditionalContactList.size() != 0) {
    		AdditionalContactList.add(0, tempOne);
    	} else {
    		AdditionalContactList.add(tempOne);
    	}
    	InitialConfirmMap.put(tempOne.WrapperContact.Id, tempOne.Confirm);
    	InitialPrimaryMap.put(tempOne.WrapperContact.Id, tempOne.IsPrimary);
    	return AdditionalContactList;
    }
    
    /**
     * Save button function
     *
     * @param       None
     * @return      null
     * @since       1.0
     */
    public PageReference SaveButton() {
    	integer counter = 0;
    	Id PrimaryContId;
    	Boolean clearAll = false;
    	for (AdditionalContactWrapper addCon: AdditionalContactList) {
    		if (addCon.IsPrimary == true) {
    			counter++;
    			PrimaryContId = addCon.WrapperContact.Id;
    		}
    	}
    	
    	if (counter != 1) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select only one Primary.'));
            //return null;
    	} else {
    		List<Contact> conList = new List<Contact>();
    		for (AdditionalContactWrapper addCon: AdditionalContactList) {
	    		if (addCon.IsPrimary == true) {
	    			addCon.WrapperContact.Primary_Status__c = 'Primary';
	    			addCon.WrapperContact.Probability__c = 100;
	    			addCon.WrapperContact.Primary_Status_Contact__c = null;
	    			if (addCon.IsRemoved == true) {
	    				clearAll = true;
	    			}
	    		} else{
	    			addCon.WrapperContact.Primary_Status__c = 'Secondary';
	    			addCon.WrapperContact.Primary_Status_Contact__c = PrimaryContId;
	    			if (addCon.Confirm == true) {
	    				addCon.WrapperContact.Probability__c = 100;
	    			} else if (InitialConfirmMap.get(addCon.WrapperContact.Id) != addCon.Confirm) {
	    				addCon.WrapperContact.Probability__c = 0;
	    			}
	    			
	    			if (InitialPrimaryMap.get(addCon.WrapperContact.Id) == true && addCon.IsPrimary == false) {
	    				addCon.WrapperContact.Probability__c = 0;
	    			}
	    			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'123.' + InitialPrimaryMap.get(addCon.WrapperContact.Id) + ' asd ' + addCon.IsPrimary + ' 1234.' + addCon.WrapperContact.Probability__c));
	    			
	    			
	    			/*} else {
	    				
	    			}*/
	    		}
	    		if (addCon.IsRemoved == true) {
	    			addCon.WrapperContact.Primary_Status__c = null;
	    			addCon.WrapperContact.Probability__c = 0;
	    			addCon.WrapperContact.Primary_Status_Contact__c = null;
	    		}
	    		conList.add(addCon.WrapperContact);
    		}
    		
    		if (clearAll == true) {
    			conList = new List<Contact>();
    			for (AdditionalContactWrapper addCon: AdditionalContactList) {
					addCon.WrapperContact.Primary_Status__c = null;
					addCon.WrapperContact.Probability__c = 0;
    				addCon.WrapperContact.Primary_Status_Contact__c = null;
    				conList.add(addCon.WrapperContact);
    			}
    		}
    		update conList;
    	}
    	Edited = false;
    	if (AdditionalContactList[0].IsPrimary == true && clearAll == false) {
    		ShowAddButton = true;
    	} else {
    		ShowAddButton = false;
    	}
    	//PageReference pageRef = new PageReference('/' + selectedContactId);
    	return null;
    }
    
}