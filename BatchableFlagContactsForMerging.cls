global class BatchableFlagContactsForMerging implements Database.Batchable<sObject>, Database.Stateful
{
    // This class flags duplicate contacts for deletion or merging.
    // Duplicate contacts are grouped by account, lastname, firstname, and email.
    // Only one contact in a group can be the master contact, the others can be deleted or merged into the master.
    // This class only flags records, it does not merge or delete them.
    // Erik Myklestad June 2014
    
    private string account_personAccountRecordTypeId = '012d0000000t1zAAAQ';
    private static final string default_individualAccountId = '001d000001GsU22';
    global final string query;
    private integer TotalContactCount = 0;
    private integer BadRecordCount = 0;
    private integer MasterCount = 0;
    private integer DupMLHCount = 0;
    private integer DupCount = 0;
    private integer MaxContactsPerGroup = 0;
    private integer TotalBatches = 0;
    private integer CurrentBatch = 0;
    private integer physicalUpdateCount = 0;
    private integer physicalUpdateErrCount = 0;
    private integer removedPriorStatusCount = 0;
    private string emailAddress = '';
    private string currentMatchKey = null;
    private string emailMessage = '';
    private List<Contact> contactGroup = new List<Contact>();
    private List<Contact> contactUpdates = new List<Contact>();
    private string masterSuffix = '-M';
    private string duplicateSuffix = '-X';
    
    public final string STATUS_DELETE_BAD_FIRST_CHARACTER = 'Delete:NameHasBadFirstCharacter';
    public final string STATUS_MASTER = 'Master';
    public final string STATUS_DUP_MLH_ID = 'Duplicate:HasMLHid';
    public final string STATUS_DUP_MERGE = 'Duplicate:Merge';
     
    global BatchableFlagContactsForMerging(){
        this(default_individualAccountId);
    }
    global BatchableFlagContactsForMerging(string individualAccountId){
        query = 'Select id, mergeKey__c, mergeStatus__c, mergeMaster__c, accountId, firstName, Lastname, email, MLH_Contact_ID__c, Last_Activity_Date__c, ' +
            '(select id, contact__c from Bidder_Registrations__r limit 1) , ' +
            '(select id, broker_agent__c from Opportunities__r limit 1), ' +
            '(select id, seller__c from Opportunities1__r limit 1), ' +
            '(select id, referred_By__c from Opportunities2__r limit 1), ' +
            '(select id, List_Assist_Agent__c from Opportunities_ListAssistAgent__r limit 1) ' +
            'from contact ' +
            'order by accountId, lastname, firstname, email';
    }
        
    global Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<Contact> contactList){
        // Get total batch count and email address
        if (TotalBatches == 0){
            AsyncApexJob a = [SELECT TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            TotalBatches = a.TotalJobItems;
            emailAddress = a.CreatedBy.Email;
        }

        CurrentBatch++;

        for (Contact con : contactList){
            TotalContactCount++;
            // Flag bad records for later deletion
            if (nameStartsWithBadCharacter(con)){
                if ((con.mergeStatus__c != STATUS_DELETE_BAD_FIRST_CHARACTER) || (con.mergeKey__c != null) || (con.mergeMaster__c != null)){
                    contactUpdates.add(new Contact(id = con.id, mergeStatus__c = STATUS_DELETE_BAD_FIRST_CHARACTER, mergeKey__c = null, MergeMaster__c = null));
                    BadRecordCount++;
                    continue;
                }
            }
                        
            string key = createKey(con.accountId, con.lastname, con.firstname, con.email);
            if (currentMatchKey == null) currentMatchKey = key;
                                                
            // Process group at key break
            if (currentMatchKey != key){
                processContactGroup();
                currentMatchKey = key;
            }       
            contactGroup.add(con);

        }
        // Process the final group of contacts after last batch
        if (CurrentBatch == TotalBatches){
            processContactGroup();
        }
        
        // Update the physical records
        string errorMessage = '';
        boolean dmlError = false;
        try{
            if (!contactUpdates.isEmpty()){
                update contactUpdates;
                physicalUpdateCount += contactUpdates.size();
                contactUpdates.clear();
            }
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += '\nDML Error: \n' + e.getDmlMessage(i) + 'nFailed Contact ID: ' + e.getDmlID(i);
            }
            physicalUpdateErrCount += contactUpdates.size();
            contactUpdates.clear();
            sendEmail('BatchableFlagContactsForMerging had a DML Error', errorMessage);
            throw e;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        integer logicalRecordUpdateCount = BadRecordCount + MasterCount + DupMLHCount + DupCount + removedPriorStatusCount;
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        emailMessage+= 'Total Batches: ' + a.TotalJobItems + '. Number of Errors: ' + a.NumberOfErrors + '. ';
        emailMessage+= '\nTotal Contacts Processed: ' + TotalContactCount.format() + ', ' +
            '\nContact records with leading bad character in name: ' + BadRecordCount.format() + ', ' +
            '\nTotal master records: ' + MasterCount.format() +  ', ' +
            '\nDuplicate contacts with MLHid: ' + DupMLHCount.format() + ', ' +
            '\nDuplicate contacts to be merged: ' + DupCount.format() + ', ' + 
            '\nMax contacts per group: ' + MaxContactsPerGroup.format() + '.' +
            '\r\fRemoved prior status count: ' + removedPriorStatusCount.format() + ', ' + 
            '\r\fLogical record update count: ' + logicalRecordUpdateCount.format() + ', ' +
            '\r\fPhysical record update count: ' + physicalUpdateCount.format() + ', ' +
            '\r\fPhysical record error count: ' + physicalUpdateErrCount.format() + '.' ;
        sendEmail('BatchableFlagContactsForMerging ' + a.Status, emailMessage);
    }
    
    private void processContactGroup(){
        integer masterIndex = null;
        integer firstBidRegistrationIndex = null;
        integer firstOpportunityIndex = null;
        integer latestActivityDateIndex = null;
        Datetime latestActivityDate = Datetime.newinstance(1960, 1, 1);
        
        if (contactGroup.size() == 0) return;
        if (contactGroup.size() == 1){
            // Remove the merge status from any previously merged master records
            Contact con = contactGroup[0];
            if ((con.mergeStatus__c != null) || (con.mergeKey__c != null) || (con.MergeMaster__c != null)){
                contactUpdates.add(new Contact(id = con.id, mergeStatus__c = null, mergeKey__c = null, MergeMaster__c = null));
                removedPriorStatusCount++;
            }
            contactGroup.clear();
            return;
        }
        if (contactGroup.size() > MaxContactsPerGroup) MaxContactsPerGroup = contactGroup.size();
                
        // Find master contact for the group
        for (integer i=0; i< contactGroup.size(); i++){
            if (masterIndex == null){
                // If there is an MLHid, it becomes the master contact
                if (contactGroup[i].MLH_Contact_ID__c != null){
                    masterIndex = i;
                    break;
                }
                else{
                    // Otherwise find the first qualifying master candidate record for each type of possible master
                    if ((firstBidRegistrationIndex == null) && !contactGroup[i].Bidder_Registrations__r.isEmpty()) firstBidRegistrationIndex = i;
                    if ((firstOpportunityIndex == null) && (!contactGroup[i].Opportunities__r.isEmpty() || !contactGroup[i].Opportunities1__r.isEmpty() || !contactGroup[i].Opportunities2__r.isEmpty() ||
                        !contactGroup[i].Opportunities_ListAssistAgent__r.isEmpty())) firstOpportunityIndex = i;
                    if ((contactGroup[i].Last_Activity_Date__c != null) && (contactGroup[i].Last_Activity_Date__c > latestActivityDate)){
                        latestActivityDate = contactGroup[i].Last_Activity_Date__c;
                        latestActivityDateIndex = i;
                    }
                }
            }                 
        }
        // If there was no MLHid master, select the master from the qualifying candidates in the following order
        if (masterIndex == null){
            if(firstBidRegistrationIndex != null) masterIndex = firstBidRegistrationIndex;
            else if (firstOpportunityIndex != null) masterIndex = firstOpportunityIndex;
            else if (latestActivityDateIndex != null) masterIndex = latestActivityDateIndex;
            else{
                // Use the first contact in the group as the master
                masterIndex = 0;
            }
        }
        
        // Mark the merge status for all the contacts
        // Always insert the master first to maintain referential integrity
        string masterContactId = contactGroup[masterIndex].id;
        Contact masterContact = new Contact(id = masterContactId, MergeStatus__c = STATUS_MASTER, MergeMaster__c = null, mergeKey__c = masterContactId + masterSuffix);
        contactUpdates.add(masterContact);
        MasterCount++;
        for (Contact con :contactGroup){
            Contact conUpd = new Contact(id=con.id, MergeMaster__c = masterContactId);
            if (con.id == masterContactId){
                // The master contact was already added to the update list so skip it
                continue;
            }
            else if ((con.MLH_Contact_ID__c != null)){
                conUpd.MergeStatus__c = STATUS_DUP_MLH_ID;
                // These contacts are not merged.
                conUpd.mergeKey__c = masterContactId + masterSuffix;
                DupMLHCount++;
            }
            else{
                conUpd.MergeStatus__c = STATUS_DUP_MERGE;
                // This contact is to be merged
                conUpd.mergeKey__c = masterContactId + duplicateSuffix;
                DupCount++;
            }           
            contactUpdates.add(conUpd);
        }
        
        contactGroup.clear();
    }
    
    private string createKey(string accountId, string lastName, string firstName, string email){
        if (accountId == null) accountId = '';
        if (firstName == null) firstName = '';
        if (lastName == null) lastName = '';
        if (email == null) email = '';
        return accountId + '|' + lastName + '|' + firstName + '|' + email + '|';
    }
    
    private boolean nameStartsWithBadCharacter(Contact con){

        if (con.firstName == null || con.firstName == '') return false;
        if (con.lastName == null || con.lastName == '') return false;
        // Test for bad characters at the beginning of the name
        string badCharacters = '0123456789!@#$%^&*()_+-={[}]|:;<,>.?/';
        if (badCharacters.contains(con.firstName.left(1))) return true;
        if (badCharacters.contains(con.lastName.left(1))) return true;
        return false;
    }

    private void sendEmail(string subject, string bodyText){
       // Send an email notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {emailAddress};
       mail.setToAddresses(toAddresses);
       mail.setSubject(subject);
       mail.setPlainTextBody(bodyText);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}