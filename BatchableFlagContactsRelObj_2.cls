global class BatchableFlagContactsRelObj_2 implements Database.Batchable<sObject>, Database.Stateful
{
    // This class is part of a two class set:
    //      BatchableFlagContactsRelObj
    //      BatchableFlagContactsRelObj_2
    // Class BatchableFlagContactsRelObj calls BatchableFlagContactsRelObj_2.
    // Both classes set a flag on the contact based on whether or not it has certain related objects.
    // But there are too many subqueries to fit in one class.
    // This class must run AFTER the BatchableFlagContactsRelObj since the first class initializes the HasRelatedObjects__c field
    // and this class only updates it if it is true for the related objects in this class.
    // Author: Erik Myklestad June 2014
    
    private string groupKey = '';
    private integer totalContacts = 0;
    private integer ContactsWithRelatedObjectsCount = 0;
    private string emailMessage = '';
    private string emailAddress = '';

    private static final string defaultAccountId = '001d000001GsU22'; // Individual Account

    private string accountId = null;
   
    global final string query;
 
    global BatchableFlagContactsRelObj_2(){
        this(defaultAccountId);
    }
    
    global BatchableFlagContactsRelObj_2(Id accountId){
        query = 
        'Select id, name, hasRelatedObjects__c,' +     
        '(select parentId from Notes limit 1), ' +
        '(select parentId from Attachments limit 1), ' +
        '(select whoId from EmailStatuses limit 1), ' +
        '(select contactId from LiveChatTranscripts limit 1), ' +
        '(select contact__c from Auction_Opportunity_Assignments__r limit 1), ' +
        '(select contact__c from CallRecords__r limit 1), ' +
        '(select contactId from CampaignMembers limit 1), ' +
        '(select contactId from OpportunityContactRoles limit 1), ' +
        '(select whoId from Events limit 1), ' +
        '(select dsfs__DSER_ContactID__c from dsfs__DocuSign_Envelope_Recipient__r limit 1), ' +
        '(select dsfs__Contact2eSignDoc01__c from dsfs__DocuSign_Envelope01__r limit 1), ' +
        '(select dsfs__Contact__c from dsfs__R00NS0000000WUMyMAO__r limit 1) ' +      
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
            // Only flag contacts with related objects if the flag has not already been set.
            if (con.HasRelatedObjects__c < 1){
                if (!con.Notes.isEmpty() || !con.Attachments.isEmpty() || !con.EmailStatuses.isEmpty()  || !con.LiveChatTranscripts.isEmpty() || !con.Auction_Opportunity_Assignments__r.isEmpty() || 
                    !con.CallRecords__r.isEmpty() ||
                    !con.CampaignMembers.isEmpty() || !con.OpportunityContactRoles.isEmpty() || !con.Events.isEmpty() || !con.dsfs__DocuSign_Envelope_Recipient__r.isEmpty()  || 
                    !con.dsfs__DocuSign_Envelope01__r.isEmpty() || !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()){
                        Contact conUpdate = new Contact(id = con.id, HasRelatedObjects__c = 1, HasRelatedObjectsVerified__c = currentTime);
                        contactUpdates.add(conUpdate);
                        ContactsWithRelatedObjectsCount++;
                }
            }
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
       emailMessage += '\nStage 2 - Additional Contacts with related objects is ' + ContactsWithRelatedObjectsCount.format() + '. ';
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {emailAddress};
       mail.setToAddresses(toAddresses);
       mail.setSubject('BatchableFlagContactsRelObj_2 - Stage 2 ' + a.Status);
       mail.setPlainTextBody(emailMessage);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
    
    
}