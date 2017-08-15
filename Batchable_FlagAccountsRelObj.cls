global class Batchable_FlagAccountsRelObj implements Database.Batchable<sObject>, Database.Stateful
{

    // This class sets a flag on the account based on whether or not it has certain related object.
    // Author: Erik Myklestad June 2014
    
    private string groupKey = '';
    private integer totalAccounts = 0;
    private integer AccountsWithRelatedObjectsCount = 0;
    private string emailMessage = '';
    private string emailAddress = '';
    private string account_personAccountRecordTypeId = '012d0000000t1zAAAQ';


    private string accountId = null;
   
    private string query;

    
    global Batchable_FlagAccountsRelObj(){
        query = 
        'Select id, name, recordTypeId,' +
			'(select account__c from Account_Intelligence__r limit 1), ' +
			'(select accountId from activityHistories limit 1), ' +
			'(select parentId from Attachments limit 1), ' +
			'(select accountId, name from contacts limit 1), ' +
			'(select parentId from Notes limit 1), ' +
			'(select accountId from Opportunities limit 1), ' +
			'(select servicer1__c from ServicerOpportunities__r limit 1), ' +
			// '(select X3rd_Party_BPO_Vendor__c from Opportunities__r limit 1), ' +
			'(select account__c from Sample_Object_For_Mark__r limit 1)' +  // Client_Summary_Resi__c table
	        'from Account' ;
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        emailAddress = a.CreatedBy.Email;
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext bc, list<Account> accountList){
        List<Account> accountUpdates = new List<Account>();
        Datetime currentTime = Datetime.now();
        for (account acct :accountList){
            totalAccounts++;
            Account acctUpdate = new Account(id = acct.id, HasRelatedObjectsVerified__c = currentTime);
            
        	// A person-account account record always has a associated contact even though it does not show up on the related list in the UI.
        	// If this is a person-account, disregard that one contact when detecting related contact records
            if ((acct.contacts.size() > 1) || ((acct.recordTypeId != account_personAccountRecordTypeId) && (acct.contacts.size() == 1))){
                acctUpdate.HasRelatedObjects__c = 1;
                AccountsWithRelatedObjectsCount++;  
	        }
            else if (!acct.Account_Intelligence__r.isEmpty() || !acct.Attachments.isEmpty() || !acct.Notes.isEmpty() || !acct.Opportunities.isEmpty() ||
                !acct.ServicerOpportunities__r.isEmpty() || !acct.ActivityHistories.isEmpty() ||
                !acct.Sample_Object_For_Mark__r.isEmpty() ){
                    acctUpdate.HasRelatedObjects__c = 1;
                    AccountsWithRelatedObjectsCount++;
            }
            else{
                acctUpdate.HasRelatedObjects__c = -1;
            }
            accountUpdates.add(acctUpdate);
        }
        
        if (accountUpdates.size() > 0){
            string errorMessage = '';
            Database.SaveResult[] srList = Database.update(accountUpdates, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage += 'Account update error - ' + err.getStatusCode() + ': ' + err.getMessage() + '. \n';
                        
                    }
                 }
            }
            if (errorMessage.length() > 1){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {emailAddress};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Batchable_FlagAccountsRelObj Stage 1 Error ');
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
       emailMessage += '\nTotal Number of Accounts processed  ' + totalAccounts.format() + ' accounts. ';
       emailMessage += '\nNumber of Accounts with related objects is ' + AccountsWithRelatedObjectsCount.format() + '. ';
       emailMessage += '\nNumber of Accounts without related objects is ' + (totalAccounts - AccountsWithRelatedObjectsCount).format() + '. ';
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Batchable_FlagAccountsRelObj' + a.Status);
       mail.setPlainTextBody(emailMessage);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
       // Launch Stage 2
       //Batchable_FlagAccountsRelObj_2 batch = new Batchable_FlagAccountsRelObj_2();
       //Id batchId = Database.executeBatch(batch, 2000);      
    }    
}