global class Batchable_ReassignContactsToIndAcct  implements Database.Batchable<sObject>, Database.Stateful
{
    // This class assigns contacts with no account to the individual account.Account.
    // It also reassigns ownsership of contacts with inactive owners to Jim Snyder.
    // Erik Myklestad June 2014
    
    global string individualAccountId = '001d000001GsU22';
    private string activeOwnerId = '00540000001E4CO'; // Jim Snyder
    private integer numberContactsWithInactiveOwner = 0;
    private integer numberContactsAssignedToIndAccount = 0;
    private string emailAddress = '';
    global final string query;

    global Batchable_ReassignContactsToIndAcct(){
        query = 'Select id, name, ownerId, Owner.IsActive From Contact where accountId = null';
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        emailAddress = a.CreatedBy.Email;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<Contact> contactList){
        if (contactList.size() == 0) return;
        List<Contact> contactUpdates = new List<Contact>();
        system.debug('foo ContactList.size: ' + contactList.size());
        for (Contact con : contactList){
            numberContactsAssignedToIndAccount++;        
            if (con.Owner.isActive){
                // Just change the account 
                system.debug('foo Active contact being updated is: ' + con.name);
                contactUpdates.add(new Contact(id = con.id, accountId = individualAccountId ));
            }
            else {
                // Change both the owner and the account
                numberContactsWithInactiveOwner++;
                system.debug('foo Inactive contact being updated is: ' + con.name);                
                contactUpdates.add(new Contact(id = con.id, ownerId = activeOwnerId, accountId = individualAccountId, previous_owner__c = con.ownerId));
            }
        }
        try{
            system.debug('foo contactUpdates.size: ' + contactUpdates.size());
            if (contactUpdates.size() > 0) update contactUpdates;
        }
        catch (System.DmlException e) {
        string errorMessage = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += '\nDML Error: ' + e.getDmlMessage(i);
            }
            sendEmail('Batchable_ReassignContactsToIndAcct had a DML exception:', errorMessage);
            throw e;
        }
        catch (Exception e) {
            sendEmail('Batchable_ReassignContactsToIndAcct had a general exception:', e.getTypeName() + '... ' + e.getMessage());
            throw e;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        string emailMessage = 'Contacts changed to an active user: ' + numberContactsWithInactiveOwner.format() + '. ' +
        '\nContacts reassigned to the individual account: ' + numberContactsAssignedToIndAccount.format() + '. ' ;

        sendEmail('Batchable_ReassignContactsToIndAcct ' + a.Status, emailMessage);
        
    }
    
    private void sendEmail(string subject, string bodyText){
       // Send an email  notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {emailAddress};
       mail.setToAddresses(toAddresses);
       mail.setSubject(subject);
       mail.setPlainTextBody(bodyText);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}