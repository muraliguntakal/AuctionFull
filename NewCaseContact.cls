public with sharing class NewCaseContact {

    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}

    // add the instance for the variables being passed by id on the url
    public Case cs {get;set;}
    public Case updatedCase {get;set;}
    private Id caseId {get;set;}
    // initialize the controller
    public NewCaseContact (ApexPages.StandardController controller) {
 
        //initialize the stanrdard controller
        this.controller = controller;

        // load the current record        
        cs= (Case)controller.getRecord(); 
    }
 
    // Method called from the VF's action attribute to Creating Contact
    public PageReference setFields() { 
         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         updatedCase = [SELECT Id,AccountId,Company__c,Contact_First_Name__c,Contact_Last_Name__c,Contact_Email__c,Contact_Phone__c FROM Case WHERE Id = :cs.Id LIMIT 1];

         List<Contact> CaseContactList = new List<Contact>();
         Contact c = new Contact();
         if(updatedCase.Contact_First_Name__c!=null && updatedCase.Contact_Last_Name__c!=null && updatedCase.Contact_Email__c!=null) {
             CaseContactList =         [SELECT Id,AccountId FROM Contact 
                                        WHERE FirstName =  :updatedCase.Contact_First_Name__c AND LastName = :updatedCase.Contact_Last_Name__c AND Email = :updatedCase.Contact_Email__c  
                                        LIMIT 1];
            if(CaseContactList.size() > 0)
                
                c = CaseContactList[0];
         }

         Account newAccount; 
         String derivedAcc = null;   

         Contact newContact = new Contact();
         String derivedCon = null;

         if( updatedCase.Contact_Email__c!=null || updatedCase.Contact_Phone__c!=null ) {
             if(c.AccountId==null) {
                 if(updatedCase.AccountId == null) { 
                     newAccount = new Account(Name = updatedCase.Company__c != null? updatedCase.Company__c : updatedCase.Contact_First_Name__c+updatedCase.Contact_Last_Name__c+' -- Account',
                                              RecordTypeId=Label.Commercial_Account, //Created_by_Customer_Service__c = TRUE
                                              Created_From_Source__c='Customer Service'  
                                             );
                     Insert newAccount;
                 }
             }
             
             derivedAcc =  c.AccountId!=null? c.AccountId : (updatedCase.AccountId!=null? updatedCase.AccountId : newAccount.Id);           

             if(c.Id==null) {
                 newContact = new Contact(FirstName = updatedCase.Contact_First_Name__c,
                                          LastName = updatedCase.Contact_Last_Name__c,
                                          Email=updatedCase.Contact_Email__c,
                                          AccountId=derivedAcc,
                                          Phone=updatedCase.Contact_Phone__c,
                                          RecordTypeId=Label.Commercial_Contact,
                                          //Created_by_Customer_Service__c = TRUE                                          
                                          Created_From_Source__c='Customer Service'  
                                         );                                             
                 Insert newContact;
             }          
             
             derivedCon =  c.Id!=null? c.Id : newContact.Id;     
                 
             try {
                updatedCase = new Case(Id=cs.Id, ContactId=derivedCon,AccountId=derivedAcc); 
                Update updatedCase;
             }
             catch (Exception e) {
                //Roll everything back in case of error
                Database.rollback(sp);
                ApexPages.addMessages(e);
                return null;
             }
         }
         return new PageReference('/'+cs.Id);
    } 
}