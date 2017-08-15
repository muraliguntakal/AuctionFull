/**
 * Search and Update sercondary contact records.
 * Search by contact name, account name, and other fields(MLH Contact ID, Email, Phone, Mailing City and Mailing State).
 * 
 * @author      UC Innovation Tonny Xia
 * @version     1.0
 * @since       1.0
 */

public with sharing class AddAdditionalContactController {
    
    public transient List<Contact> ContactList{get;set;}                                      // quary the contact for the database.
    public transient List<AdditionalContactWrapper> AdditionalContactList{get;set;}           // the conctact wrapper will be showed on the VF page.
    public Id selectedContactId{get;set;}                                           // get the primary contact Id from the url link.
    public String ContactName{get; set;}                                            // get the primary contact name.
    public String ShowResultName{get; set;}                                         // hold the search information and showed on the VF page.
    public String keyword{get; set;}                                                // the keywoed for the "Other fields".
    public String SearchContactName{get; set;}                                      // the keywoed for the "Contact Name".
    public String SearchAccountName{get; set;}                                      // the keywoed for the "Account Name".
    public Boolean noError{get;set;}                                                // catch the error message.
    private List<String> ReassignNameList{get;set;}                                 // all the contacts name that have another primary contat will be update.
    private List<AdditionalContactWrapper> AllContactList{get;set;}                 // all the contact wrapper.
    private ApexPages.StandardSetController setCon{get;set;}                        // for mutiple page for show contact record.
    private transient  Map<Id, Contact> ContactMap{get;set;}                                   // all the primary
    private Integer SaveCount{get;set;}                                             // controller the save button
    
    Integer PAGE_NUMBER = 200;
    Integer PAGE_SIZE = 20;
    
    /**
     * Constructor
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
    public AddAdditionalContactController(ApexPages.StandardController stdController){
        try {
            noError = true;
            AdditionalContactList = new List <AdditionalContactWrapper>();
            AllContactList = new List <AdditionalContactWrapper>();
            ContactMap = new Map<Id, Contact>([Select Id, AccountId, Name, Account.Name From Contact Where Primary_Status__c = 'Primary' limit 50000]);
            selectedContactId = ApexPages.currentPage().getParameters().get('ContactId');
            SaveCount = 0;
            //List<String> ListString = IdString.split(':', -2);
            //currentContactId = ListString[2];
            //selectedContactId = ListString[0];
            
            Contact tempCon = ContactMap.get(selectedContactId);
            
            ContactName = tempCon.Name;
            ShowResultName = 'Search by Account: ' + tempCon.Account.Name;
            
            ContactList = [Select Id, 
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
                            Where Id !=: selectedContactId And AccountId =: tempCon.AccountId And Primary_Status__c != 'Primary'];
            
            for (Contact cont: ContactList) {
                AdditionalContactWrapper acw;
                Contact tempCont = ContactMap.get(cont.Primary_Status_Contact__c);
                String primName;
                if (tempCont != null) {
                    primName = tempCont.Name;
                } else {
                    primName = '';
                }
                if (cont.Primary_Status_Contact__c == selectedContactId) {
                    acw  = new AdditionalContactWrapper(cont, true, primName);
                } else {
                    acw = new AdditionalContactWrapper(cont, false, primName);
                }
                
                AllContactList.add(acw);
            }
            
            setCon = new ApexPages.StandardSetController(ContactList);
            
            setCon.setpageNumber(PAGE_NUMBER);
            setCon.setPageSize(PAGE_SIZE);
        } catch (Exception error) {
            String errorMsg;
            noError = false;
            errorMsg = 'The Contact Id is Invalid or Does Not exist. Please enter a valid Contact Id and try again.';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            //System.Assert(false, errorMsg);
        }
    }
    
    /**
     * Create Wrapper class
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
    public class AdditionalContactWrapper {
        
        public Contact WrapperContact{get;set;}                        // Contact
        public Boolean IsSecondary{get;set;}                           // Secondary check box
        public String PrimaryContact{get;set;}                         // Primary Contact Name
        public String AccountName{get;set;}                            // Account Name
        public Id AccountsId{get;set;}                                 // Account Id
        public Id PrimaryId{get;set;}                                  // Primary Contact Id

        public AdditionalContactWrapper(Contact cont, Boolean isSec, String priName) {
       
            WrapperContact = cont;
            AccountsId = cont.AccountId;
            IsSecondary = isSec;
            PrimaryContact = priName;
            AccountName = cont.Account.Name;
            PrimaryId = cont.Primary_Status_Contact__c;
        }
    }
    
    /**
     * Create Wrapper list to show on the VF page
     *
     * @param       None
     * @return      List of wrapper
     * @since       1.0
     */
    public List<AdditionalContactWrapper> getAdditionalContactShowList() {
        AdditionalContactList = new List<AdditionalContactWrapper>();
        for (AdditionalContactWrapper aw: AllContactList) {
            
            for (sObject s: setCon.getRecords()) {
                Contact cont = (Contact)s;
                if (cont.Id == aw.WrapperContact.Id) {
                    AdditionalContactList.add(aw);
                }
            }
        }
        
        return AdditionalContactList;
    }
    
    /**
     * Search button function
     *
     * @param       None
     * @return      null
     * @since       1.0
     */
    public PageReference gosearch() {
        List<Contact> tempContactList = new List<Contact>();
        ContactList = new List<Contact>();
        AllContactList = new List<AdditionalContactWrapper>();
        SaveCount = 0;
        String ConFilter;
        String AccFilter;
        ShowResultName = 'Search by Keyword: ' + SearchContactName + ' ' + SearchAccountName + ' ' + keyword;
        ContactMap = new Map<Id, Contact>([Select Id, AccountId, Name, Account.Name From Contact Where Primary_Status__c = 'Primary' limit 50000]);
        if (SearchContactName == null || SearchContactName == '') {
            ConFilter = '';
        } else {
            ConFilter = ' AND Name LIKE \'%' + SearchContactName + '%\'';
        }
        
        if (SearchAccountName == null || SearchAccountName == '') {
            AccFilter = '';
        } else {
            AccFilter = ' AND Account.Name LIKE \'%' + SearchAccountName + '%\'';
        }
        
        if (keyword == null || keyword == '') {
            
            tempContactList = database.query('select Id, Name, Account.Name, Probability__c, Primary_Contact__c, Primary_Status__c, Primary_Status_Contact__c, AccountId,  MLH_Contact_ID__c, MailingState, MailingCity, Email, Phone From Contact where Id != \'' + selectedContactId +'\'' + ConFilter + AccFilter + ' And Primary_Status__c != \'Primary\' limit 1000');
                            
        } else {
            ShowResultName = 'Search by Keyword ' + keyword;
            String key = '%' + keyword + '%';
            tempContactList = database.query('select Id, Name, Account.Name, Probability__c, Primary_Contact__c, Primary_Status__c, Primary_Status_Contact__c, AccountId,  MLH_Contact_ID__c, MailingState, MailingCity, Email, Phone From Contact where Id != \'' + selectedContactId +'\'' + ConFilter + AccFilter + ' AND (MLH_Contact_ID__c LIKE \'' + key + '\' or MailingState LIKE \'' + key + '\' or MailingCity LIKE \'' + key + '\' or Email LIKE \'' + key + '\' or Phone LIKE \'' + key + '\') And Primary_Status__c != \'Primary\' limit 1000');   
                  
        }
        
        Set<Id> Idset = new Set<Id>();
        
        for (Contact c: tempContactList) {
            if (Idset.Contains(c.Id) == false) {
                Idset.add(c.Id);
                ContactList.add(c);
            }
        }
        
        for (Contact cont: ContactList) {
            AdditionalContactWrapper acw;
            Contact tempCon = ContactMap.get(cont.Primary_Status_Contact__c);
            String primName;
            if (tempCon != null) {
                primName = tempCon.Name;
            } else {
                primName = '';
            }
            if (cont.Primary_Status_Contact__c == selectedContactId) {
                acw  = new AdditionalContactWrapper(cont, true, primName);
            } else {
                acw = new AdditionalContactWrapper(cont, false, primName);
            }
            
            AllContactList.add(acw);
        }
        
        setCon = new ApexPages.StandardSetController(ContactList);
        
        setCon.setpageNumber(PAGE_NUMBER);
        setCon.setPageSize(PAGE_SIZE);
        if (ContactList.size() == 1000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'System can only quary 1,000 records at a time. Please add additional key words to filter search results.'));
        }
        return null;
    }
    
    /**
     * The link for go next page
     *
     * @param       None
     * @return      True or False for VF has next page 
     * @since       1.0
     */ 
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /**
     * The link for go previous page
     *
     * @param       None
     * @return      True or False for VF has previous page 
     * @since       1.0
     */ 
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    /**
     * The page number
     *
     * @param       None
     * @return      True or False for VF show the page number tag
     * @since       1.0
     */ 
    public Boolean hasPage {
        get {
            if (getTotalPages() == 0) {
                return false;
            }
            else {
                return true;
            }
        }
        set;
    }
    
    /**
     * The current page number
     *
     * @param       None
     * @return      Current page number
     * @since       1.0
     */ 
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    /**
     * The link for go previous page
     *
     * @param       None
     * @return      None
     * @since       1.0
     */ 
    public void previous() {
        SaveCount = 0;
        if (setCon.getHasPrevious())
            setCon.previous();
    }
  
    /**
     * The link for go next page
     *
     * @param       None
     * @return      None
     * @since       1.0
     */ 
    public void next() {
        SaveCount = 0;
        if (setCon.getHasNext())
            setCon.next();
    }
    
    /**
     * Show the all page number
     *
     * @param       None
     * @return      Total page number
     * @since       1.0
     */ 
    public Integer getTotalPages(){
 
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
 
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /**
     * Search button function
     *
     * @param       None
     * @return      null
     * @since       1.0
     */
    public PageReference SaveContact() {
        ReassignNameList = new List<String>();
        List<Contact> updateContactList = new List<Contact>();
        Boolean reassign = false;
        for (AdditionalContactWrapper acw: AllContactList) {
            if (acw.IsSecondary == true && acw.WrapperContact.Primary_Status_Contact__c != null && acw.WrapperContact.Primary_Status_Contact__c != selectedContactId) {
                reassign = true;
                ReassignNameList.add(acw.WrapperContact.Name);
            }
        }
        
        if ( SaveCount == 0 && reassign == true) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The following Contact\'s Primary Contact will be updated to '+ ContactName + ':'));
            
            for (String st: ReassignNameList) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'- ' + st));
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please press Save if you want to proceed with the update or press Cancel to leave the contact with the current Primary.'));
            SaveCount++;
        } else {
            for (AdditionalContactWrapper acw: AllContactList) {
                if (acw.IsSecondary == true) {
                    acw.WrapperContact.Primary_Status__c = 'Secondary';
                    //acw.WrapperContact.Probability__c = 0;
                    acw.WrapperContact.Primary_Status_Contact__c = selectedContactId;
                    acw.PrimaryContact = ContactName;
                    updateContactList.add(acw.WrapperContact);
                } else if (acw.IsSecondary == false && acw.WrapperContact.Primary_Status_Contact__c == selectedContactId) {
                    acw.WrapperContact.Primary_Status__c = '';
                    acw.WrapperContact.Primary_Status_Contact__c = null;
                    acw.PrimaryContact = '';
                    acw.WrapperContact.Probability__c = 0;
                    updateContactList.add(acw.WrapperContact);
                }
                
            }
            if (updateContactList.size() != 0) {
                update updateContactList;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Update successful.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There are no records to update. Please double check or press Cancel.'));
            }
            SaveCount = 0;
        }
        
        return null;
    }
    
    /**
     * Search button function
     *
     * @param       None
     * @return      Main contact record page
     * @since       1.0
     */
    public PageReference Cancel() {
        SaveCount = 0;
        PageReference pageRef = new PageReference('/' + selectedContactId);
        pageRef.setRedirect(true);
        return pageRef;
    }

}