global class Batchable_FlagAccountsForMerging implements Database.Batchable<sObject>, Database.Stateful
{
    // This class flags duplicate accounts for deletion or merging.
    // Duplicate accounts are grouped by account name.
    // Alternately,accounts can be grouped by phone and physical address.
    // Only one account in a group can be the master account, the others can be deleted, ignored or merged into the master.
    // This class only flags records, it does not merge or delete them.
    // Erik Myklestad July 2014
    
    global final string query;
    private integer TotalAccountCount = 0;
    private integer BadRecordCount = 0;
    private integer MasterCount = 0;
    private integer DupMLHCount = 0;
    private integer DupCount = 0;
    private integer MaxAccountsPerGroup = 0;
    private integer TotalBatches = 0;
    private integer CurrentBatch = 0;
    private string emailAddress = '';
    private string currentMatchKey = null;
    private string emailMessage = '';
    private List<Account> accountGroup = new List<Account>();
    private List<Account> accountUpdates = new List<Account>();
    private string masterSuffix = '-M';
    private string duplicateSuffix = '-X';
    
    public final string STATUS_DELETE_BAD_ACCOUNT_NAME = 'Delete:BadAccountName';
    public final string STATUS_MASTER = 'Master';
    public final string STATUS_DUP_MLH_ID = 'Duplicate:HasMLHid';
    public final string STATUS_DUP_MERGE = 'Duplicate:Merge';
    public final string MERGE_KEY_NAME = 'Name';
    public final string MERGE_KEY_NAME_AND_ADDRESS = 'Name&Address';
   
    public boolean performPhysicalUpdates = true;
    public string mergeKeyType = MERGE_KEY_NAME;
     

    global Batchable_FlagAccountsForMerging(){
        query = 'Select id, mergeKey__c, mergeStatus__c, Name, MLH_Company_ID__c, CRE_Account_Rating__c, CRE_Target_Account__c, Resi_BD_Primary__c, ' + 
        	'LastActivityDate, Phone, BillingStreet, BillingState, BillingPostalCode, BillingCity, ' +
			'(select account__c from Account_Intelligence__r limit 1), ' +
			'(select accountId from Opportunities limit 1), ' +
			'(select servicer1__c from ServicerOpportunities__r limit 1) ' +
			//'(select X3rd_Party_BPO_Vendor__c from Opportunities__r limit 1) ' +
			'from Account order by name';
    }
        
    global Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<Account> accountList){
        // Get total batch count and email address
        if (TotalBatches == 0){
            AsyncApexJob a = [SELECT TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            TotalBatches = a.TotalJobItems;
            emailAddress = a.CreatedBy.Email;
        }

        CurrentBatch++;

        for (Account acc : accountList){
            TotalAccountCount++;
            // Flag accounts with bad names for deletion
            if (acc.name.isNumericSpace()){
                Account a = new Account(id=acc.Id, mergeStatus__c = STATUS_DELETE_BAD_ACCOUNT_NAME);
                accountUpdates.add(a);
                BadRecordCount++;
                continue;
            }
                        
            string key = createKey(acc);
            if (currentMatchKey == null) currentMatchKey = key;
                                                
            // Process group at key break
            if (currentMatchKey != key){
                processAccountGroup();
                currentMatchKey = key;
            }       
            accountGroup.add(acc);

        }
        // Process the final group of accounts after last batch
        if (CurrentBatch == TotalBatches){
            processAccountGroup();
        }
        
        // Update the physical records
        string errorMessage = '';
        boolean dmlError = false;
        try{
            if (performPhysicalUpdates && !accountUpdates.isEmpty()){
                update accountUpdates;
                accountUpdates.clear();
            }
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += '\nDML Error: \n' + e.getDmlMessage(i) + 'nFailed Account ID: ' + e.getDmlID(i);
            }
            sendEmail('Batchable_FlagAccountsForMerging had a DML Error', errorMessage);
            accountUpdates.clear();
            throw e;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        emailMessage+= 'Total Batches: ' + a.TotalJobItems + '. Number of Errors: ' + a.NumberOfErrors + '. ';
        emailMessage+= '\nTotal Accounts Processed: ' + TotalAccountCount.format() + ', ' +
            '\nAccount records with bad name: ' + BadRecordCount.format() + ', ' +
            '\nTotal master records: ' + MasterCount.format() +  ', ' +
            '\nDuplicate accounts with MLHid: ' + DupMLHCount.format() + ', ' +
            '\nDuplicate accounts to be merged: ' + DupCount.format() + ', ' + 
            '\nMax accounts per group: ' + MaxAccountsPerGroup.format() + '.';
        sendEmail('Batchable_FlagAccountsForMerging ' + a.Status, emailMessage);
    }
    
    private void processAccountGroup(){
        integer masterIndex = null;
        integer firstAccountIntelligenceIndex = null;
        integer firstOpportunityIndex = null;
        integer latestActivityDateIndex = null;
        Datetime latestActivityDate = Datetime.newinstance(1960, 1, 1);
        
        if (accountGroup.size() == 0) return;
        if (accountGroup.size() == 1){
            // Remove the merge status from any previously merged master records
            Account con = accountGroup[0];
            if ((con.mergeStatus__c != null) || (con.mergeKey__c != null)){
                accountUpdates.add(new Account(id = con.id, mergeStatus__c = null, mergeKey__c = null));
            }
            accountGroup.clear();
            return;
        }
        if (accountGroup.size() > MaxAccountsPerGroup) MaxAccountsPerGroup = accountGroup.size();
                
        // Find master account for the group
        for (integer i=0; i< accountGroup.size(); i++){
            if (masterIndex == null){
                // If there is an MLHid, or a variety of other fields, it becomes the master account
                Account acct = accountGroup[i];
                if ((acct.MLH_Company_ID__c != null) || 
                	(acct.CRE_Account_Rating__c == 'A.) Key Account') ||
                	(acct.CRE_Account_Rating__c == 'B.) Potential Account') ||
                	(acct.CRE_Account_Rating__c == 'C.) Unassigned Account') ||
                	(acct.CRE_Target_Account__c == '2014-BD') ||
                	(acct.Resi_BD_Primary__c == 'Primary') ||
                	(acct.Resi_BD_Primary__c == 'Secondary')){
                    masterIndex = i;
                    break;
                }
                else{
                    // Otherwise find the first qualifying master candidate record for each type of possible master
                    if ((firstAccountIntelligenceIndex == null) && !accountGroup[i].Account_Intelligence__r.isEmpty()) firstAccountIntelligenceIndex = i;
                    if ((firstOpportunityIndex == null) && (!accountGroup[i].Opportunities.isEmpty() || !accountGroup[i].ServicerOpportunities__r.isEmpty())) firstOpportunityIndex = i;
                    if ((accountGroup[i].LastActivityDate != null) && (accountGroup[i].LastActivityDate > latestActivityDate)){
                        latestActivityDate = accountGroup[i].LastActivityDate;
                        latestActivityDateIndex = i;
                    }
                }
            }                 
        }
        // If there was no MLHid master, select the master from the qualifying candidates in the following order
        if (masterIndex == null){
            if(firstAccountIntelligenceIndex != null) masterIndex = firstAccountIntelligenceIndex;
            else if (firstOpportunityIndex != null) masterIndex = firstOpportunityIndex;
            else if (latestActivityDateIndex != null) masterIndex = latestActivityDateIndex;
            else{
                // Use the first account in the group as the master
                masterIndex = 0;
            }
        }
        
        // Mark the merge status for all the accounts
        // Always insert the master first to maintain referential integrity
        string masterAccountId = accountGroup[masterIndex].id;
        Account masterAccount = new Account(id = masterAccountId, MergeStatus__c = STATUS_MASTER, mergeKey__c = masterAccountId + masterSuffix);
        accountUpdates.add(masterAccount);
        MasterCount++;
        for (Account con :accountGroup){
            Account conUpd = new Account(id=con.id);
            if (con.id == masterAccountId){
                // The master account was already added to the update list so skip it
                continue;
            }
            else if ((con.MLH_Company_ID__c != null)){
                conUpd.MergeStatus__c = STATUS_DUP_MLH_ID;
                // These accounts are not merged.
                DupMLHCount++;
            }
            else{
                conUpd.MergeStatus__c = STATUS_DUP_MERGE;
                // This account is to be merged
                conUpd.mergeKey__c = masterAccountId + duplicateSuffix;
                DupCount++;
            }           
            accountUpdates.add(conUpd);
        }
        
        accountGroup.clear();
    }
    
    private string createKey(Account a){
    	string key = '';
    	if (mergeKeyType == MERGE_KEY_NAME_AND_ADDRESS){
    		if (a.name == null) a.name = '';
    		if (a.BillingStreet == null) a.BillingStreet = '';
    		if (a.BillingCity == null) a.BillingCity = '';
    		if (a.BillingState == null) a.BillingState = '';
    		if (a.BillingPostalCode == null) a.BillingPostalCode = '';
    		key = a.name + '|' + a.BillingStreet + '|' + a.BillingCity + '|' + a.BillingState + '|' + a.BillingPostalCode + '|'; 
    	}
    	else{
	        if (a.name == null) key = '|';
	        else key = a.name + '|';
    	}
		return key;
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