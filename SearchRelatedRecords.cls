//Test Class : pdpTriggerHelperTest | Method : SearchRelatedRecordTest)
public class SearchRelatedRecords{

    private final Contact contact { get; set; }
    private Map<Id,sObject> ContactMap;
    private final List<sObject> contactList;
    private Set<Id> cIds;
    
    public searchfields sFields { get; set; }
 
    public SearchRelatedRecords (ApexPages.StandardController controller) {
        this.contact= (Contact)controller.getRecord(); 
    }    

    public SearchRelatedRecords(ApexPages.StandardSetController controller) {
        this.contactList= (List<sObject>)controller.getRecords(); 
    }    
    
    public List<Contact> getContacts() {
         intializevariables();
         system.debug('Getting Contact =>');
         if(string.isNotBlank(sFields.firstName) || string.isNotBlank(sFields.lastName) || string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone) ||  string.isNotBlank(sFields.MobilePhone)){
             ContactMap = new Map<Id,sObject>(ContactRecords.getRecords());
             return (ContactMap.values()) ;
         }
         else {
             return null;
         }
    }

    public ApexPages.StandardSetController ContactRecords {
        get {
            if(ContactRecords == null) {
                if(string.isNotBlank(sFields.firstName) || string.isNotBlank(sFields.lastName) || string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone) ||  string.isNotBlank(sFields.MobilePhone)){
                    ContactRecords = new ApexPages.StandardSetController(Database.getQueryLocator(ContactQueryBuilder()));                    
                }
            }
            return ContactRecords;
        }
        private set;
    }

    public List<Lead> getLeads() {
         if(string.isNotBlank(sFields.firstName) || string.isNotBlank(sFields.lastName) || string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone) ||  string.isNotBlank(sFields.MobilePhone)){
             system.debug('Getting Lead Inside=>');             
             return (List<Lead>) LeadRecords.getRecords();
         }
         else {
             return null;
         }
    }
    
    public ApexPages.StandardSetController LeadRecords {
        get {
            if(LeadRecords == null) {
                LeadRecords = new ApexPages.StandardSetController(Database.getQueryLocator(LeadQueryBuilder()));
            }
            return LeadRecords;
        }
        private set;
    }


    public List<Opportunity> getOpportunities() {
        cIds=ContactMap.Keyset(); 
        system.debug('Contacts => '+ContactMap.KeySet());
        if(ContactMap.KeySet()!=null && (string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone) ||  string.isNotBlank(sFields.MobilePhone))) {
            return (List<Opportunity>) OpportunityRecords.getRecords() ;
        }
        else {
            return null;
        }
    }

    public ApexPages.StandardSetController OpportunityRecords {
        get {
            if(OpportunityRecords == null) {
                if(ContactMap.KeySet()!=null && (string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone) ||  string.isNotBlank(sFields.MobilePhone))) {
                    OpportunityRecords = new ApexPages.StandardSetController(Database.getQueryLocator(OpportunityQueryBuilder()));                    
                }
            }
            return OpportunityRecords;
        }
        private set;
    }

    public class searchfields{
        public String   firstName     { get; set; }
        public String   lastName      { get; set; }
        public String   email         { get; set; }
        public String   phone         { get; set; }
        public String   mobilephone   { get; set; }
        public boolean  exactMatch    { get{ return exactMatch == null ? false : exactMatch; } set; }
    }

    public PageReference search() {       
       ApexPages.Message myMsg = null;
       system.debug('sFields => ' +sFields);
       if(sFields == null)  {
           myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter at aleast one search field');              
       }        
        return null;
    }     

    private String ContactQueryBuilder() {
       String contactQryStr = 'Select Id, AccountId, Name, Email, Phone, MobilePhone, OwnerId, Duplicate__c, Last_Activity_Date__c, Most_Recent_Activity_Assigned_To__c, Most_Recent_Activity_Role_Assigned_To__c'+ ' FROM Contact WHERE';
       if(string.isNotBlank(sFields.firstName) || string.isNotBlank(sFields.lastName) || string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone)){
           contactQryStr+= string.isNotEmpty(sFields.firstName)? addquerycondition('FirstName',sFields.firstName,sFields.exactMatch): '';              
           contactQryStr+= string.isNotEmpty(sFields.lastName) ? (contactQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('LastName',sFields.lastName,sFields.exactMatch) : ' AND '+addquerycondition('LastName',sFields.lastName,sFields.exactMatch)):'';
           contactQryStr+= string.isNotEmpty(sFields.email)    ? (contactQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('Email',sFields.email,sFields.exactMatch) : ' AND '+addquerycondition('Email',sFields.email,sFields.exactMatch)):'';
           contactQryStr+= string.isNotEmpty(sFields.phone)    ? (contactQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('LiveOps_Phone_Formatted__c',sFields.phone,sFields.exactMatch) : ' AND '+addquerycondition('LiveOps_Phone_Formatted__c', sFields.phone,sFields.exactMatch)):'';
           contactQryStr+= string.isNotEmpty(sFields.mobilephone)    ? (contactQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('LiveOps_Mobile_Formatted__c',sFields.mobilephone,sFields.exactMatch) : ' AND '+addquerycondition('LiveOps_Mobile_Formatted__c', sFields.mobilephone,sFields.exactMatch)):'';
           contactQryStr+= ' ORDER BY Last_Activity_Date__c DESC LIMIT 50';
       }
       return contactQryStr;
    }

    private String LeadQueryBuilder() {
       String LeadQryStr = 'Select Id, Name, Email, Phone, MobilePhone, OwnerId, Company, Status, Last_Call_Change_Date__c'+ ' from Lead WHERE';
       if(string.isNotBlank(sFields.firstName) || string.isNotBlank(sFields.lastName) || string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone)) {
              LeadQryStr+= string.isNotEmpty(sFields.firstName)? addquerycondition('FirstName',sFields.firstName,sFields.exactMatch): '';
              LeadQryStr+= string.isNotEmpty(sFields.lastName) ? (LeadQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('LastName',sFields.lastName,sFields.exactMatch) : ' AND '+addquerycondition('LastName',sFields.lastName,sFields.exactMatch)):'';
              LeadQryStr+= string.isNotEmpty(sFields.email)    ? (LeadQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('Email',sFields.email,sFields.exactMatch) : ' AND '+addquerycondition('Email',sFields.email,sFields.exactMatch)):'';
              LeadQryStr+= string.isNotEmpty(sFields.phone)    ? (LeadQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('LiveOps_Phone_Formatted__c' ,sFields.phone,sFields.exactMatch) : ' AND '+addquerycondition('LiveOps_Phone_Formatted__c', sFields.phone,sFields.exactMatch)):'';
              LeadQryStr+= string.isNotEmpty(sFields.mobilephone)    ? (LeadQryStr.endsWithIgnoreCase('WHERE') ? addquerycondition('LiveOps_Mobile_Formatted__c',sFields.mobilephone,sFields.exactMatch) : ' AND '+addquerycondition('LiveOps_Mobile_Formatted__c', sFields.mobilephone,sFields.exactMatch)):'';
              LeadQryStr+= ' AND isConverted = FALSE ORDER BY LastActivityDate DESC LIMIT 50';
        }        
        return LeadQryStr; 
    }

    private String OpportunityQueryBuilder() {
           cIds = ContactMap.KeySet();
           String OppQryStr = 'Select Id,Name,StageName,AccountId,OwnerId,Property_City__c,Property_State__c,Seller__c,Broker_Agent__c,Most_Recent_Auction_End_Date__c '+ ' FROM Opportunity WHERE';
           OppQryStr+= '(Seller__c IN :cIds OR Broker_Agent__c IN :cIds )';  
           OppQryStr+= 'AND RecordTypeId= \''+Label.Parent_Opportunity+'\'';                     
           OppQryStr+= ' ORDER BY Most_Recent_Auction_End_Date__c DESC LIMIT 50';
           system.debug(OppQryStr);
       return OppQryStr;
    }

    private String addQueryCondition(String fieldName,String FieldValue,boolean isExactMatch ){
        String queryExtension = ' '+FieldName+' !=null';
        if(string.isNotEmpty(FieldValue)&&string.isNotEmpty(FieldName)){
            queryExtension += isExactMatch? ' AND '+FieldName+ '='+'\'' + String.escapeSingleQuotes(FieldValue) + '\'' : ' AND '+FieldName+' like '+'\'%' + String.escapeSingleQuotes(FieldValue) + '%\'' ;
            return queryExtension;   
        }
        return null;
    }

    public void intializevariables() {
        sFields = new searchfields();
        LeadRecords = null;
        ContactRecords = null;
        OpportunityRecords = null;
        system.debug('contacts => ' +contact);
        sFields.firstName = contact.firstName!=null? contact.firstName : null; 
        sFields.lastName = contact.lastName!=null? contact.lastName : null;
        sFields.email = contact.email!=null? contact.email : null;
        sFields.Phone = contact.Phone!=null ? cleanPhone(contact.Phone) : null; 
        sFields.MobilePhone = contact.MobilePhone!=null? cleanPhone(contact.MobilePhone) : null; 
    }

    public String cleanPhone(String cleanPhone) {        
        cleanPhone = cleanPhone.replaceAll('\\(', '');
        cleanPhone = cleanPhone.replaceAll('\\) ', '');
        cleanPhone = cleanPhone.replaceAll('\\)', '');
        cleanPhone = cleanPhone.replaceAll('-','');
        cleanPhone = cleanPhone.trim();
        return cleanPhone;
    }    

}