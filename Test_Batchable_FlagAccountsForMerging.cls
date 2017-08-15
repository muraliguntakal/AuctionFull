@isTest
private class Test_Batchable_FlagAccountsForMerging {
    
    static private string STATUS_DELETE_BAD_ACCOUNT_NAME = 'Delete:BadAccountName';
    static private string STATUS_MASTER = 'Master';
    static private string STATUS_DUP_MLH_ID = 'Duplicate:HasMLHid';
    static private string STATUS_DUP_MERGE = 'Duplicate:Merge';
    static private string masterSuffix = '-M';
    static private string duplicateSuffix = '-X';
    

    static testMethod void testAccountFlagging() {
    
            //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        // Disable the Opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false);
        
        List<Account_Intelligence__c> aiList = new List<Account_Intelligence__c>();        
        List<Opportunity> opList = new List<Opportunity>();
            
        List<Account> accountList = new List<Account>();
        
        // Handle a numeric account name
        accountList.add(new Account(name = '999'));
        insert accountList;
        accountList.clear();
        
        // In determining a master, MLHid take precedence above all other criteria
        for (integer i=0; i<8; i++){
            accountList.add(new Account(name = 'MLHMaster'));
        }
        accountList.add(new Account(name = 'MLHMaster',  MLH_Company_ID__c = '498'));
        accountList.add(new Account(name = 'MLHMaster',  MLH_Company_ID__c = '787878'));
        insert accountList;
        createAccountIntelligence(aiList, accountList[3].id);
        createOp(opList, accountList[2].id);
        accountList.clear();
        
        // In determining a master, Account Intelligence records are next.
        for (integer i=0; i<10; i++){
            accountList.add(new Account(name = 'AIisMaster'));
        }
        insert accountList;
        createAccountIntelligence(aiList, accountList[3].id);
        createOp(opList, accountList[2].id);
        accountList.clear();
        
        // Opportunities are next in line for being a master
        for (integer i=0; i<6; i++){
            accountList.add(new Account(name = 'OpIsMaster'));
        }
        insert accountList;
        createOp(opList, accountList[2].id);
        createOp(opList, accountList[3].id);
        createOp(opList, accountList[4].id);
        createOp(opList, accountList[5].id);
        accountList.clear();
        
        // Create duplicates with none of the above
        accountList.add(new Account(name = 'SimpleDuplicates'));
        accountList.add(new Account(name = 'SimpleDuplicates'));
        insert accountList;
        accountList.clear();
        
        
        // Create an account with no duplicates
        accountList.add(new Account(name = 'NoDuplicates'));
        insert accountList;
        accountList.clear();
        
        // Insert the related lists used to determine a master record
        insert aiList;
        insert opList;
  
        Test.startTest();
        Batchable_FlagAccountsForMerging bat = new Batchable_FlagAccountsForMerging();
        Id batchId = Database.executeBatch(bat, 1000);
        Test.stopTest();
        
        // Test for numeric account name
        accountList = getAccounts('999', false);
        for (Account act : accountList){
            System.assertEquals(STATUS_DELETE_BAD_ACCOUNT_NAME, act.mergeStatus__c);
            system.assertEquals(null, act.mergeKey__c);
        }
           
        // Test for MLHMaster
        // Records should be in order of (not merged), master, duplicates to be merged
        accountList = getAccounts('MLHMaster', false);
        string masterId = '';
        for (Account act : accountList){
            if (act.mergeKey__c == null){
                System.assertequals(STATUS_DUP_MLH_ID, act.mergeStatus__c, 'Duplicate MLHid records are not merged');
            }
            else {
                if (act.mergeKey__c.substringafter('-') == 'M'){
                    masterId = act.id;
                    system.assertEquals(masterId  + masterSuffix, act.mergeKey__c);
                }
                else{
                    system.assertEquals(masterId  + duplicateSuffix, act.mergeKey__c);
                }
            }

            
        }
        
        // Test for Account Intelligence Master  
        accountList = getAccounts('AIisMaster', true);
        for (Account act : accountList){
            if (act.id == accountList[0].id){
                System.assertequals(true, !act.Account_Intelligence__r.isEmpty(), 'The master must have an Account Intelligence record.');
            }
            else {
                if (!act.Opportunities.isEmpty()) system.assertequals(STATUS_DUP_MERGE, act.MergeStatus__c);
                else system.assertequals(STATUS_DUP_MERGE, act.MergeStatus__c);
            }
        }
        
        //Test for Opportunity Master
        accountList = getAccounts('OpIsMaster', true);
        for (Account act : accountList){
            if (act.id == accountList[0].id){
                System.assertequals(true, !act.Opportunities.isEmpty(), 'The master must have an Opportunity record.');
            }
            else {
                system.assertequals(STATUS_DUP_MERGE, act.MergeStatus__c);
            }
        }
        
        // Test simple duplicates
        accountList = getAccounts('SimpleDuplicates', false);
        // master
        system.assertequals(STATUS_MASTER, accountList[0].MergeStatus__c);
        // system.assertequals(null, accountList[0].MergeMaster__c);
        system.assertequals(accountList[0].id + masterSuffix, accountList[0].MergeKey__c);
        // Duplicate
        system.assertequals(STATUS_DUP_MERGE, accountList[1].MergeStatus__c);
        // system.assertequals(accountList[0].id, accountList[1].MergeMaster__c);
        system.assertequals(accountList[0].id + duplicateSuffix, accountList[1].MergeKey__c);
        
        // Test for no duplicates which should leave no master
        accountList = getAccounts('NoDuplicates', false);
        system.assertequals(null, accountList[0].MergeStatus__c);
        // system.assertequals(null, accountList[0].MergeMaster__c);
        
        
        
    }
    
    // Get a list of accounts and returns the id of the master account
    private static List<Account> getAccounts(string testCase, boolean verifyMaster){
        List<Account> accounts = [Select id, mergeKey__c, mergeStatus__c, Name, MLH_Company_ID__c, Phone, BillingStreet, BillingState, BillingPostalCode, BillingCity,
            (select account__c from Account_Intelligence__r limit 1),
            (select accountId from activityHistories limit 1),
            (select parentId from Attachments limit 1),
            (select accountId from contacts limit 1),
            (select parentId from Notes limit 1),
            (select accountId from Opportunities limit 1),
            (select servicer1__c from ServicerOpportunities__r limit 1)
            // (select X3rd_Party_BPO_Vendor__c from Opportunities__r limit 1)
            from Account where name = :testCase order by mergeKey__c];
            
        // Verify the master is always first and all the rest are duplicates
        if (verifyMaster){
            string masterId = accounts[0].id;
            for (integer i=0; i < accounts.size(); i++){
                if (i==0){
                    system.assertEquals('Master', accounts[i].mergeStatus__c, 'The first record is always the master');
                    system.assertEquals(masterId + masterSuffix, accounts[i].mergeKey__c, 'The first record is always the master');
                }
                else{
                    system.assertEquals(masterId + duplicateSuffix, accounts[i].mergeKey__c, 'All other records must be duplicates');  
                }
            }
        }
        
        return accounts;
    }
    
    private static void createAccountIntelligence(List<Account_Intelligence__c> aiList, id accountId){
        Account_Intelligence__c ai = new Account_Intelligence__c(account__c = accountId); 
        aiList.add(ai);     
    }
    
    private static void createOp(List<Opportunity> opList, id acctId){
        
        Opportunity op = new Opportunity(accountId = acctId, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today()+ 12);
        opList.add(op);
    }
}