@isTest
private class Test_BatchableFlagContactsForMerging {

    static private string STATUS_DELETE_BAD_FIRST_CHARACTER = 'Delete:NameHasBadFirstCharacter';
    static private string STATUS_MASTER = 'Master';
    static private string STATUS_DUP_MLH_ID = 'Duplicate:HasMLHid';
    static private string STATUS_DUP_MERGE = 'Duplicate:Merge';
    static private string masterSuffix = '-M';
    static private string duplicateSuffix = '-X';
    

    static testMethod void testContactFlagging() {
    
            //Setup all Custom Settings
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        // Disable the Opportunity triggers
        upsert new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = false);
        upsert new TriggerSettings__c(name = 'updateClientManager', Status__c = false);
                
        // Disable the Bid triggers
        upsert new TriggerSettings__c(name = 'BidTrigger', Status__c = false);
        upsert new TriggerSettings__c(name = 'CreateBidContact', Status__c = false);
        upsert new TriggerSettings__c(name = 'FindWinningBid', Status__c = false);
        upsert new TriggerSettings__c(name = 'BidRegistrationTrigger', Status__c = false);
        
        // Disable the Vault trigger
        upsert new TriggerSettings__c(name = 'VaultRollUp', Status__c = false);        
        
        List<Bidder_Registration__c> bidRegList = new List<Bidder_Registration__c>();        
        List<Opportunity> opList = new List<Opportunity>();
            
            
        // Create the individual account
        Account acct = new Account(name = 'Test Account');
        insert acct;
        Account acct2 = new Account(name = 'Other Account');
        insert acct2;
        
        List<Contact> contactList = new List<Contact>();
        
        // Handle bad characters
        for (integer i=0; i<10; i++){
            contactList.add(new Contact(lastname = 'BadCharacter', firstname = i.format(), accountId = acct.id));
        }
        
        // Blank and null first names are acceptable
        for (integer i=0; i<10; i++){
            string fname = null;
            if (i>=5) fname = '';
            contactList.add(new Contact(lastname = 'NoFirstName', firstname = fname, email = 'me@auction.com', accountId = acct.id));
        }
        
        // No email address is acceptable
        for (integer i=0; i<10; i++){
            contactList.add(new Contact(lastname = 'NoEmail_HasOtherData', firstname = 'John', VIP_Status__c = 'vip', accountId = acct.id));
        }
        insert contactList;
        contactList.clear();
        
        // In determining a master, MLHid take precedence above all other criteria
        string stateCode = 'Arizona';
        for (integer i=0; i<8; i++){
            if (i>=4) stateCode = '';
            contactList.add(new Contact(lastname = 'MLHMaster', firstname = 'John', email = 'me@auction.com', mailingstate = stateCode, accountId = acct.id));
        }
        contactList.add(new Contact(lastname = 'MLHMaster', firstname = 'John', email = 'me@auction.com', MLH_Contact_ID__c = '498', accountId = acct.id));
        contactList.add(new Contact(lastname = 'MLHMaster', firstname = 'John', email = 'me@auction.com', MLH_Contact_ID__c = '787878', accountId = acct.id));
        insert contactList;
        createBidRegistration(bidRegList, acct2.id, contactList[3].id);
        createOp(opList, acct2.id, contactList[2].id, 'seller__c');
        contactList.clear();
        
        // In determining a master, Bidder registration records are next.
        for (integer i=0; i<10; i++){
            contactList.add(new Contact(lastname = 'BidRegIsMaster', firstname = 'John', email = 'me@auction.com', VIP_Status__c = 'vip', Last_Activity_Date__c = Date.today(), accountId = acct.id));
        }
        insert contactList;
        createBidRegistration(bidRegList, acct2.id, contactList[3].id);
        createOp(opList, acct2.id, contactList[2].id, 'referred_By__c');
        contactList.clear();
        
        // Opportunities are next in line for being a master
        for (integer i=0; i<6; i++){
            contactList.add(new Contact(lastname = 'OpIsMaster', firstname = 'John', email = 'you@auction.com', accountId = acct.id));
        }
        insert contactList;
        insert new Bid__c(Buyer_Name__c = contactList[0].id, Bid_Amount__c = 50000);
        insert new Vault__c(contact__c = contactList[1].id);
        createOp(opList, acct2.id, contactList[2].id, 'broker_agent__c');
        createOp(opList, acct2.id, contactList[3].id, 'seller__c');
        createOp(opList, acct2.id, contactList[4].id, 'referred_By__c');
        createOp(opList, acct2.id, contactList[5].id, 'List_Assist_Agent__c');
        contactList.clear();
        
        // Activity date is next in line for being a master
        for (integer i=0; i<9; i++){
            contactList.add(new Contact(lastname = 'LastActivityMaster', firstname = 'John', email = 'you@auction.com', Last_Activity_Date__c = Datetime.newInstance(2014,1,1), mailingcity = 'San Fran', accountId = acct.id));
        }
        contactList.add(new Contact(lastname = 'LastActivityMaster', firstname = 'John', email = 'you@auction.com', Last_Activity_Date__c = Datetime.newInstance(2014,1,2), mailingcity = 'San Fran', accountId = acct.id));
        insert contactList;
        contactList.clear();
        
        // Test a contact with no duplicates
        contactList.add(new Contact(lastname = 'NoDuplicates', firstname = 'James', email = 'you@auction.com', mailingcity = 'San Fran', accountId = acct.id));
        insert contactList;
        contactList.clear();
        
        // Insert the related lists used to determine a master record
        insert bidRegList;
        insert opList;
  
        Test.startTest();
        BatchableFlagContactsForMerging bat = new BatchableFlagContactsForMerging(acct.id);
        Id batchId = Database.executeBatch(bat, 1000);
        Test.stopTest();
        
        // Test for bad characters
        contactList = getContacts('BadCharacter', false);
        for (Contact con : contactList){
            System.assertEquals(STATUS_DELETE_BAD_FIRST_CHARACTER, con.mergeStatus__c);
            system.assertEquals(null, con.mergeKey__c);
        }

        // Test for no name
        // The master record is always first in the list
        contactList = getContacts('NoFirstName', true);
        for (Contact con : contactList){
            if (con.id != contactList[0].id){
                System.assertEquals(STATUS_DUP_MERGE, con.mergeStatus__c);

            }
        }       
        // Test for no email
        contactList = getContacts('NoEmail_HasOtherData', true);
        for (Contact con : contactList){
            if (con.id != contactList[0].id){
                System.assertEquals(STATUS_DUP_MERGE, con.mergeStatus__c);

            }
        }    
           
        // Test for MLHMaster
        // Records should be in order of (not merged), master, duplicates to be merged
        contactList = getContacts('MLHMaster', false);
        string masterId = '';
        for (Contact con : contactList){
            if (con.mergeKey__c == null){
                System.assertequals(STATUS_DUP_MLH_ID, con.mergeStatus__c, 'Duplicate MLHid records are not merged');
            }
            else {
                if (con.mergeKey__c.substringafter('-') == 'M'){
                    masterId = con.id;
                    system.assertEquals(masterId  + masterSuffix, con.mergeKey__c);
                }
                else{
                    system.assertEquals(masterId  + duplicateSuffix, con.mergeKey__c);
                }
            }

            
        }
        
        // Test for Bidder Registration Master  
        contactList = getContacts('BidRegIsMaster', true);
        for (Contact con : contactList){
            if (con.id == contactList[0].id){
                System.assertequals(true, !con.Bidder_Registrations__r.isEmpty(), 'The master must have a Bidder Registration record.');
            }
            else {
                if (!con.Opportunities2__r.isEmpty()) system.assertequals(STATUS_DUP_MERGE, con.MergeStatus__c);
                else system.assertequals(STATUS_DUP_MERGE, con.MergeStatus__c);
            }
        }
        
        //Test for Opportunity Master
        contactList = getContacts('OpIsMaster', true);
        for (Contact con : contactList){
            if (con.id == contactList[0].id){
                System.assertequals(true, !con.Opportunities__r.isEmpty() || !con.Opportunities1__r.isEmpty() ||
                    !con.Opportunities2__r.isEmpty() || !con.Opportunities_ListAssistAgent__r.isEmpty(), 'The master must have an Opportunity record.');
            }
            else {
                system.assertequals(STATUS_DUP_MERGE, con.MergeStatus__c);
            }
        }
        
        //Test for Last Activity Date being a master
        contactList = getContacts('LastActivityMaster', true);
        for (Contact con : contactList){
            if (con.id == contactList[0].id){
                system.assertEquals(Datetime.newInstance(2014,1,2), con.Last_Activity_Date__c);
            }
            else {
                system.assertequals(STATUS_DUP_MERGE, con.MergeStatus__c);
            }
        }
        
        // Test for no duplicates which should leave no master
        contactList = getContacts('NoDuplicates', false);
        system.assertequals(null, contactList[0].MergeStatus__c);
        system.assertequals(null, contactList[0].MergeMaster__c);
        
        
        
    }
    
    // Get a list of contacts and returns the id of the master contact
    private static List<Contact> getContacts(string testCase, boolean verifyMaster){
        List<Contact> contacts = [Select accountId, firstName, Lastname, email, MLH_Contact_ID__c, Last_Activity_Date__c, id, 
            phone, mobilePhone, mailingstreet, mailingcity, mailingstate, mailingpostalcode, mailingcountry, mergeMaster__c, mergeStatus__c, mergeKey__c,
            (select id, contact__c from Bidder_Registrations__r limit 1) ,
            (select id, Buyer_Name__c from  bids__r limit 1),
            (select id, broker_agent__c from Opportunities__r limit 1),
            (select id, seller__c from Opportunities1__r limit 1),
            (select id, referred_By__c from Opportunities2__r limit 1),
            (select id, List_Assist_Agent__c from Opportunities_ListAssistAgent__r limit 1),
            (select id, contact__c from Vault__r limit 1)
            from Contact where lastName = :testCase order by mergeKey__c];
            
        // Verify the master is always first and all the rest are duplicates
        if (verifyMaster){
            string masterId = contacts[0].id;
            for (integer i=0; i < contacts.size(); i++){
                if (i==0){
                    system.assertEquals('Master', contacts[i].mergeStatus__c, 'The first record is always the master');
                    system.assertEquals(masterId + masterSuffix, contacts[i].mergeKey__c, 'The first record is always the master');
                }
                else{
                    system.assertEquals(masterId + duplicateSuffix, contacts[i].mergeKey__c, 'All other records must be duplicates');  
                }
            }
        }
        
        return contacts;
    }
    
    private static void createBidRegistration(List<Bidder_Registration__c> bidRegList, id acctId, id contactId){
        Bidder_Registration__c bidReg = new Bidder_Registration__c(contact__c = contactId, mlh_Bidder_id__c = '12'); 
        bidRegList.add(bidReg);     
    }
    
    private static void createOp(List<Opportunity> opList, id acctId, id contactId, string contactReferenceField){
        
        Opportunity op = new Opportunity(accountId = acctId, Name = 'Test op ', StageName = 'test stage', CloseDate = Date.today()+ 12);
        op.put(contactReferenceField, contactId);
        opList.add(op);
    }
}