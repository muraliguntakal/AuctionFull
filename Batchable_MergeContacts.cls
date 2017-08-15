global class Batchable_MergeContacts implements Database.Batchable<sObject>, Database.Stateful
{
        // This class merges the contacts flagged by the class BatchableFlagContactsForMerging.
        // Erik Myklestad, June, 2014

    private integer mergeCount = 0;
    private integer currentBatch = 0;    
    private string query;
    private integer errorCount = 0;
    private integer totalContactCount = 0;
    private integer batchErrorCount = 0;
    private string matchKey = null;
    private Contact masterContact = null;
    private Datetime startTime = null;
    private string emailAddress = '';
    public integer jobLimitMinutes = 480;  // Job limit is 8 hours unless specified otherwise
    private map<id, Contact> contactUpdates = new map<id, Contact>();
    private List<string> mergeFieldList = new List<string>{
            'Affordable_Housing__c', 'All_Property_Types__c', 'AssistantName', 'AssistantPhone', 'Auction_Participation__c', 'Batch_Received_Date__c', 'Best_Contact_Time__c', 'Best_Contact_Type__c', 'Bio_Life_Science__c', 'Broker_RE_License_Number__c', 'Broker_RE_License_State__c', 'Brokerage__c', 'Buyer_Contact_Status__c', 'Capital_Markets_Update__c', 'Central_MO_IA_KS_CO_UT_WY_ND__c', 'Cold_Storage__c', 'Community_Center__c', 'Condo_Hotel__c', 'Contact_Status__c', 'Converted_from_Lead__c', 'Core__c', 'Core_Plus__c', 'County__c', 'Describe_Your_Property_Holdings__c', 'Department',  'Development_Commercial__c', 'Development_Residential__c', 'Distribution__c', 'Division__c', 'DRE_License_Number__c', 'E_mail_2__c', 'EmailBouncedDate', 'EmailBouncedReason', 'Europe__c', 'Fax', 'Flex__c', 'Greater_New_York_NY_NJ__c', 'HasOptedOutOfEmail', 'HomePhone', 'Hospitality__c', 'Hotel__c', 'How_many_purchased_in_last_12__c', 'Industrial__c', 'Is_Buyer__c', 'Land__c', 'Last_Call_Change_Date__c', 'Last_Call_Count__c', 'Last_Call_Disposition__c', 'Last_Purchase_County__c', 'Last_Purchase_Date__c', 'Last_Purchase_State__c', 'Last_Purchase_Type__c', 'LastCURequestDate', 'LastCUUpdateDate', 'LeadSource', 'Leadsourcefilename_Contacts__c', 'Lifestyle_Center__c', 'Light_Industrial__c', 'Limited_Service_Economy_Hotel__c', 'LinkedIn__c', 'MailingCity', 'MailingCountry', 'MailingPostalCode', 'MailingState', 'MailingStreet', 'Malls__c', 'Manufacturing__c', 'Marinas__c', 'Medical_Office__c', 'Mid_South_PA_WV_VA_DE__c', 'Middle_Name__c', 'Midscale_Hotel__c', 'Midwest_OH_IL_IN_MI_WI_MN__c', 'Minimum_Deal_Size__c', 'Mixed_Use__c', 'mkto_si__Last_Interesting_Moment_Date__c', 'mkto_si__Last_Interesting_Moment_Desc__c', 'mkto_si__Last_Interesting_Moment_Source__c', 'mkto_si__Last_Interesting_Moment_Type__c', 'mkto_si__Priority__c', 'mkto_si__Relative_Score_Value__c', 'mkto_si__Urgency_Value__c', 'mkto2__Inferred_City__c', 'mkto2__Inferred_Company__c', 'mkto2__Inferred_Country__c', 'mkto2__Inferred_Metropolitan_Area__c', 'mkto2__Inferred_Phone_Area_Code__c', 'mkto2__Inferred_Postal_Code__c', 'mkto2__Inferred_State_Region__c', 'mkto2__Lead_Score__c', 'mkto2__Original_Referrer__c', 'mkto2__Original_Search_Engine__c', 'mkto2__Original_Search_Phrase__c', 'mkto2__Original_Source_Type__c', 'MLH_WorkPhone__c', 'Mobile_Home_Park__c', 'MobilePhone', 'MSCRM_ID__c', 'Multifamily__c', 'Neighborhood_Center__c', 'Net_Lease__c', 'NNN__c', 'NNN_Lease__c', 'Non_performing_Notes__c', 'Non_Real_Estate__c', 'Northeast_CT_ME_MA_VT_NH_RI__c', 'Northwest_OR_WA_ID__c', 'Notes__c', 'of_Activities__c', 'of_Bidder_Registrations__c', 'of_Bids__c', 'of_Opportunities__c', 'of_Winning_Bids__c', 'Office__c', 'Office_Condo__c', 'Opportunistic__c', 'Other__c', 'OtherCity', 'OtherCountry', 'OtherPhone', 'OtherPostalCode', 'OtherState', 'OtherStreet', 'Outlet_Center__c', 'Parent_Regions__c', 'Phone', 'Phone_Extension__c', 'Power_Center__c', 'Power_Centers__c', 'Preferred_Deal_Size__c', 'Primary_Contact__c', 'Primary_MLH_Client_ID__c', 'Primary_Role__c', 'Purchased_in_Last_12__c', 'R_D__c', 'Region__c', 'Region_new__c', 'Regional_Mall__c', 'Rent_Subsidized_Housing__c', 'ReportsToId', 'Resorts__c', 'Retail__c', 'Schools__c', 'Self_Storage__c', 'Seller__c', 'Senior_Housing__c', 'Shopping_Centers__c', 'Single_Tenant__c', 'South_TX_OK_AR_LA_NM__c', 'Southeast_KY_TN_NC_SC_MS_AL_GA__c', 'Speciality__c', 'Specialty__c', 'Specific_Cities_or_States__c', 'Strip_Center__c', 'Student_Housing__c', 'Suburban_Office__c', 'Suffix__c', 'TIC__c', 'Title', 'Total_reserve_of_Opportunities__c', 'Upper_Upscale_Luxury_Hotel__c', 'Upscale_Hotel__c', 'Value_Add__c', 'Value_Added__c', 'Vault_Entries__c', 'VIP_Assigned__c', 'VIP_Client_Rep__c', 'VIP_Status__c', 'Warehouse__c', 'Web_Site__c', 'West_CA_NV_AZ__c', 'Where_did_property_search__c', 'Workflow_ID__c', 'X1031_Exchange__c'
            };
  
  	global Batchable_MergeContacts(){
        string fieldList = '';
        for (string fieldName : mergeFieldList){
            fieldList += ', ' + fieldName;
        }
        query = 'select id, mergeKey__c' + fieldList + ' from contact where mergeKey__c != null order by mergeKey__c ';  		
  	}
 
    global Database.Querylocator start(Database.BatchableContext bc){
        startTime = system.Now();
        AsyncApexJob a = [SELECT  CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        emailAddress = a.CreatedBy.Email;
        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext bc, list<Contact> contactList){
        List<MergeItem> mergeItems = new List<MergeItem>();
        if (startTime.addMinutes(jobLimitMinutes) < system.Now()) abortThisJob(bc, 'Time limit exceeded, aborting job. ');
        
        currentBatch++;

        for (Contact con : contactList){
            totalContactCount++;
            
            // mergeKey contains the 18 character Master ContactId followed by
            // -M for the master or -X for the duplicates to be merged into the master.            
            string key = con.mergeKey__c;
            if (matchKey == null){
                // The first record in the recordset must be a master or else we need to skip it
                if (key.substringAfter('-') != 'M') continue;
                // Change the key to match duplicates
                key = con.mergeKey__c.substringBefore('-') + '-X';
                matchKey = key;
                masterContact = con;
                continue; 
            }
                                                
            // Process each duplicate
            if (matchKey == key){
                // add the record to the list for merging
                mergeDataFields(con);
                MergeItem item = new MergeItem();
                item.contact = masterContact;
                item.duplicateContact = con;
                mergeItems.add(item);
                mergeCount++;
            }
            else {
                // The first record in each group must be a master or else we need to skip it
                if (key.substringAfter('-') != 'M') continue;
                // Change the key to match duplicates
                key = con.mergeKey__c.substringBefore('-') + '-X';
                matchKey = key;
                masterContact = con;
            }

        }
        
        // Update the physical records
        string errorMessage = '';
        boolean dmlError = false;
        try{
            if (!contactUpdates.isEmpty()){
                update contactUpdates.values();
            }
            if (!mergeItems.isEmpty()){
                for (MergeItem item : mergeItems){
                    // The Salesforce merge command only reparents child objects.  It does not merge data fields.
                    merge item.contact item.duplicateContact;
                }
            }
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += '\nDML Error : \n' + e.getDmlMessage(i) + 'nFailed Contact ID: ' + e.getDmlID(i);
            }
            if (batchErrorCount < 25) sendEmail('Batchable_MergeContacts had a DML Error', errorMessage);
            batchErrorCount++;
            throw e;
        }
        catch(Exception e){
            if (batchErrorCount < 25) sendEmail('Batchable_MergeContacts threw an exception', e.getMessage());
            batchErrorCount++;
            throw e;
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        string emailMessage = 'Total Batches: ' + a.TotalJobItems + '. Number of Errors: ' + a.NumberOfErrors + '. ' + 'Execution time (min): ' + ((system.now().getTime() - startTime.getTime())/(1000*60)).format() + '. ';
        emailMessage+= '\nTotal Contacts Selected: ' + totalContactCount.format() + '. ';
        emailMessage+= '\nTotal Contacts Merged: ' + mergeCount.format() + '. ';
        sendEmail('Batchable_MergeContacts ' + a.Status, emailMessage);
    }
    
    private void abortThisJob(Database.BatchableContext bc, string message){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        string emailMessage = message;
        emailMessage+= '\nTotal Batches: ' + a.TotalJobItems + '. Batches Processed: ' + (a.JobItemsProcessed - 1)  + '. Batches with Errors: ' + a.NumberOfErrors + '. ' + 'Execution time (min): ' + ((system.now().getTime() - startTime.getTime())/(1000*60)).format() + '. ';
        emailMessage+= '\nTotal Contacts Selected: ' + totalContactCount.format() + '. ';
        emailMessage+= '\nTotal Contacts Merged: ' + mergeCount.format() + '. ';
        sendEmail('Batchable_MergeContacts ' + a.Status, emailMessage);
        system.debug('foo Aborting job due to time limit.');
    	system.abortJob(bc.getJobId());
    }
    
    private void mergeDataFields(Contact con){

        for (string fieldName :mergeFieldList){
            // Do not overwrite any values in the master contact
            if ((con.get(fieldName) != null) && (masterContact.get(fieldName) == null)){
                if (contactUpdates.containsKey(masterContact.id)){
                    contactUpdates.get(masterContact.id).put(fieldName, con.get(fieldName));
                }
                else{
                    Contact conUpd = new Contact(id = masterContact.id);
                    conUpd.put(fieldName, con.get(fieldName));
                    contactUpdates.put(masterContact.Id, conUpd);
                }
            }
        }
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

    class MergeItem{
        Contact contact {get; set;}
        Contact duplicateContact {get; set;}
    }
}