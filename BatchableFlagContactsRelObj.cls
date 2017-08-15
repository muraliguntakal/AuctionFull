global class BatchableFlagContactsRelObj implements Database.Batchable<sObject>, Database.Stateful
{
    // This class is part of a two class set:
    //      BatchableFlagContactsRelObj
    //      BatchableFlagContactsRelObj_2
    // Both classs set a flag on the contact based on whether or not it has certain related object.
    // But there are too many subqueries to fit in one class.
    // This class must run BEFORE the BatchableFlagContactsRelObj_2 since the first class initialize the HasRelatedObjects__c field
    // and the second class only updates it if it is true.
    // Author: Erik Myklestad June 2014
    
    private string groupKey = '';
    private integer totalContacts = 0;
    private integer ContactsWithRelatedObjectsCount = 0;
    private string emailMessage = '';
    private string emailAddress = '';

    private static final string defaultAccountId = '001d000001GsU22'; // Individual Account

    private string accountId = null;
   
    global final string query;
 
    global BatchableFlagContactsRelObj(){
        this(defaultAccountId);
    }
    
    global BatchableFlagContactsRelObj(Id accountId){
        query = 
        'Select id, name, email,' +
        '(select Buyer_Name__c from  bids__r limit 1), ' +
        '(select contact__c from Bidder_Registrations__r limit 1) , ' +
        '(select broker_agent__c from Opportunities__r limit 1), ' +
        '(select seller__c from Opportunities1__r limit 1), ' +
        '(select referred_By__c from Opportunities2__r limit 1), ' +
        '(select List_Assist_Agent__c from Opportunities_ListAssistAgent__r limit 1), ' +
        '(select contact__c from Vault__r limit 1), ' +
        '(select whoId from ActivityHistories limit 1), ' + 
        '(select whoId from OpenActivities limit 1), ' +
        '(select whoId from Tasks limit 1), ' +
        '(select contact__c from Buyer_Profiles__r limit 1), ' +
        '(select contactId from Cases limit 1) ' +    
        'from contact where accountId = \'' + accountId + '\' ' ;
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        emailAddress = a.CreatedBy.Email;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<Contact> contactList){
        List<Contact> contactUpdates = new List<Contact>();
        Datetime currentTime = Datetime.now();
        for (contact con :contactList){
            totalContacts++;
            Contact conUpdate = new Contact(id = con.id, HasRelatedObjectsVerified__c = currentTime);
            if (!con.bids__r.isEmpty() || !con.Bidder_Registrations__r.isEmpty() || !con.Opportunities__r.isEmpty() || !con.Opportunities1__r.isEmpty() || !con.Opportunities2__r.isEmpty() ||
                !con.Opportunities_ListAssistAgent__r.isEmpty() || !con.Vault__r.isEmpty() || !con.ActivityHistories.isEmpty() || !con.OpenActivities.isEmpty()  || !con.Tasks.isEmpty() ||
                !con.Buyer_Profiles__r.isEmpty() || !con.Cases.isEmpty()){
                    conUpdate.HasRelatedObjects__c = 1;
                    ContactsWithRelatedObjectsCount++;
            }
            else{
                conUpdate.HasRelatedObjects__c = -1;
            }
            contactUpdates.add(conUpdate);
        }
        
        if (contactUpdates.size() > 0){
            string errorMessage = '';
            Database.SaveResult[] srList = Database.update(contactUpdates, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage += 'Contact update error - ' + err.getStatusCode() + ': ' + err.getMessage() + '. \n';
                        
                    }
                 }
            }
            if (errorMessage.length() > 1){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {emailAddress};
                mail.setToAddresses(toAddresses);
                mail.setSubject('BatchableFlagContactsRelObj Stage 1 Error ');
                mail.setPlainTextBody(errorMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                         
            }           
        }
       
    }
    
    global void finish(Database.BatchableContext bc) {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
       // Send an email  notifying of job completion.
       emailMessage += 'Total Batches is ' + a.JobItemsProcessed.format() + ' with ' + a.NumberOfErrors.format() + ' failures. '; 
       emailMessage += '\nTotal Number of Contacts processed  ' + totalContacts.format() + ' contacts. ';
       emailMessage += '\nStage 1 - Number of Contacts with related objects is ' + ContactsWithRelatedObjectsCount.format() + '. ';
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('BatchableFlagContactsRelObj Stage 1 ' + a.Status);
       mail.setPlainTextBody(emailMessage);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
       // Launch Stage 2
       BatchableFlagContactsRelObj_2 batch = new BatchableFlagContactsRelObj_2();
       Id batchId = Database.executeBatch(batch, 2000);      
    }    
}