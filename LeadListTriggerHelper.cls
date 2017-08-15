//Test Class : CampaignMemberUpdateTests
Public class LeadListTriggerHelper {

    Public class Status{
        Boolean Inserted;
        Boolean Updated;
        Boolean Failed; 
        List<String> Messages;
    }
    public static Map<Id, campaign> campaignMap {get; set;}
    public static void triggerHandler(List<Lead_List__c> LeadListRecords) {
        Set<String> firstNames = new Set<String>();
        Set<String> lastNames = new Set<String>();
        Set<String> emails = new Set<String>(); 
        Set<String> accountNames = new Set<String>(); 
        Set<String> phones = new Set<String>(); 
        Set<String> mobilePhones = new Set<String>(); 
        Set<Id> contactIds = new Set<Id>(); 
        Set<Id> leadIds = new Set<Id>(); 
        Set<Id> campaignIds = new Set<Id>(); 
        
        campaignMap = new Map<Id,Campaign>();
        Map<Id,LeadListTriggerHelper.Status> ListRecordStatusMap = new Map<Id,LeadListTriggerHelper.Status>();

        for(Lead_List__c rec : LeadListRecords) {
            if(rec.get('Last_Name__c') != null) {
                lastNames.add((String) rec.get('Last_Name__c'));
            }
            if(rec.get('First_Name__c') != null) {
                firstNames.add((String) rec.get('First_Name__c'));
            }
            if(rec.get('Email__c') != null) {
                emails.add((String) rec.get('Email__c'));
            }
            if(rec.get('Company_Name__c') != null) {
                AccountNames.add((String) rec.get('Company_Name__c'));
            }
            if(rec.get('Phone__c') != null) {    
                phones.add((String) rec.get('Phone__c'));
            }
            if(rec.get('Mobile__c') != null) {
                mobilePhones.add((String) rec.get('Mobile__c'));
            }
            if(rec.get('Contact_ID__c')!=null) {
                contactIds.add((String) rec.get('Contact_ID__c'));            
            }
            if(rec.get('Lead_ID__c')!=null) {
                leadIds.add((String) rec.get('Lead_ID__c'));            
            }
            if(rec.get('Campaign_ID__c')!=null) {
                campaignIds.add((String) rec.get('Campaign_ID__c'));            
            }
        }

        List<sObject> existingLeads = [SELECT Id, FirstName,LastName, Email, Phone,Phone_Extension__c,MobilePhone, Title, Company FROM Lead WHERE FirstName =: firstNames AND LastName =: lastNames AND Company =: AccountNames AND (Email =: emails OR Phone =: phones OR MobilePhone = :mobilePhones)];        
        system.debug('==> ' +existingLeads);

        List<sObject> existingContacts = [SELECT Id, FirstName,LastName, Email, Phone,Phone_Extension__c,Title, MobilePhone,Account.Name,AccountId FROM Contact WHERE FirstName =: firstNames AND LastName =: lastNames AND Account.Name =: AccountNames AND (Email =: emails OR Phone =: phones OR MobilePhone = :mobilePhones)];
        system.debug('==> ' +existingContacts);
      
        Map<Id,sObject> existingContactIds = new Map<Id,sObject>([SELECT Id,Email,Phone,Phone_Extension__c,MobilePhone,Title FROM Contact WHERE Id  =:contactIds]);
        Map<Id,sObject> existingLeadIds = new Map<Id,sObject>([SELECT Id,Email,Phone,Phone_Extension__c,MobilePhone,Title FROM Lead WHERE Id =:leadIds ]);        
        campaignMap = new Map<Id,campaign>([SELECT Id,CRE_Communication_Type__c FROM Campaign WHERE Id IN :campaignIds]);
        system.debug('==> ' +campaignMap);
        
        List<sObject> newLeadRecords = new List<sObject>();
        Map<Id,sObject> existingLeadRecords= new Map<Id,sObject>();
        Map<Id,sObject> existingContactRecords = new Map<Id,sObject>();
 
        for(Lead_List__c rec : LeadListRecords) {
            LeadListTriggerHelper.Status ListStatus = new LeadListTriggerHelper.Status();
            Boolean isNew = False;
            SearchResult result = new SearchResult();
            sObject currentRecord = null;

            if(rec.get('Last_Name__c') == null) {
                ListStatus.Messages.add('Missing Last Name');  
                ListStatus.Failed = TRUE;
                ListRecordStatusMap.put((Id)rec.get('Id'),ListStatus);             
            }

            result = DoesIdExists((Id)rec.get('Lead_ID__c'),(Id)rec.get('Contact_ID__c'),existingLeadIds,existingContactIds);
            system.debug('Result ==> ' +result );            
            
            if(result.isFound) {

                currentRecord = result.Record; 
                system.debug('Found Record ==> ' +result );            
            }
            else {
                currentRecord = DoesObjectExist(existingContacts, existingLeads, (String) rec.get('Email__c'), (String) rec.get('Phone__c'), (String) rec.get('Mobile__c'), (String) rec.get('Last_Name__c'), (String) rec.get('First_Name__c'), (String) rec.get('Company_Name__c')); 
            }

            if(currentRecord!=null) {
                system.debug('Found ' +rec);
                if(currentRecord.Id.getSObjectType().getDescribe().getName() == 'Contact') {
                    isNew = False;
                    existingContactRecords.put(currentRecord.Id,getContactMapping(rec,'Contact',currentRecord.Id,currentRecord,isNew));
                }
                else {
                    isNew = False;
                    existingLeadRecords.put(currentRecord.Id,getLeadMapping(rec,'Lead',currentRecord.Id,currentRecord,isNew));
                }                                
            }
            else {
                system.debug('Creating New for '+rec);
                isNew = True;
                sObject newLead = getLeadMapping(rec,'Lead',null,null,isNew);
                system.debug('New Lead  ==> '+newLead);                
                newLeadRecords.add(newLead);
                system.debug('Adding New Lead to List ==> '+newLeadRecords);                
            }
        }

        //New Leads
        Integer newLeadCount = newLeadRecords.size();
        system.debug('New Lead Records ==> '+newLeadRecords);
        if(newLeadRecords.size()>0) {
            //Database.Insert(newLeadRecords,false);
             system.debug('Creating New Records r '+newLeadRecords);
             Insert newLeadRecords;
        }

        if(existingLeadRecords.Values().size()>0) {
            //Database.Update(existingLeadRecords,false);
            Update existingLeadRecords.Values();
        }

        if(existingContactRecords.Values().size()>0) {
            //Database.Update(existingContactRecords,false);
            Update existingContactRecords.Values();
        }
        
        //Add new leads to existing record leads
        for(sObject rec : newLeadRecords) {
            existingLeadRecords.put(rec.Id,rec);
        }

        List<sObject> newCampaignMembers = new List<sObject>();

        for(sObject rec : newLeadRecords) {
            newCampaignMembers.add(getCampaignMapping(rec,'CampaignMember',true));
        }

        for(sObject rec : existingLeadRecords.Values()) {
            newCampaignMembers.add(getCampaignMapping(rec,'CampaignMember',false));
        }

        for(sObject rec : existingContactRecords.Values()) {
            newCampaignMembers.add(getCampaignMapping(rec,'CampaignMember',false));
        }

        existingLeadRecords.Values().addAll(newLeadRecords);
        
        //Insert newCampaignMembers;
        Database.SaveResult[] srList = Database.Insert(newCampaignMembers, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('CampaignMember fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    public class SearchResult{
        sObject record;
        Boolean isFound;
    }


    private static SearchResult DoesIdExists(Id leadId, Id contactId, Map<Id,sObject> leadMap, Map<Id,sObject> contactMap) {    
        SearchResult result = new SearchResult();

        if((contactId!=null && contactMap!=null && contactMap.KeySet().contains(contactId))){
            //currentId = contactId!=null? contactId : leadId;
                result.isFound = true;
                result.Record = contactMap.get(contactId);
        } 
        else if(leadId!=null && leadMap!=null && leadMap.KeySet().contains(leadId)) {
                result.isFound = true;
                result.Record = leadMap.get(leadId);        
        }    
        else {
            result.isFound = false;
        }
        return result;
    }

    public static sObject DoesObjectExist(List<sObject> contacts, List<sObject> leads, String email, String phone, String mobilePhone, String lastname, String firstName, string accountName) {
        sObject currentRecord = null; 
        Boolean isFound = false;
        Contact curContact = null;
        Lead curLead = null;
        
        System.Debug('Checking Contacts');         
        for (sObject obj : contacts) {
            curContact = (Contact) obj;
            System.Debug('Checking Contacts =>' +curContact );                     
            if ((curContact.firstName == firstname && curContact.LastName == lastname && curContact.Email != null && curContact.Email == email) 
                 || (curContact.firstName == firstname && curContact.LastName == lastname && curContact.Phone != null && curContact.Phone == phone) 
                 || (curContact.firstName == firstname && curContact.LastName == lastname && curContact.MobilePhone != null && curContact.MobilePhone == mobilePhone)) {
                currentRecord = curContact;            
                isFound = TRUE;
                System.Debug('Found Existing Contact');
            }
        }

        if(!isFound) {
            for (sObject obj : leads) {
                curLead = (Lead) obj;
                System.Debug('Checking Leads =>' +curLead );                     
                system.debug('Current Phone => '  +phone+ 'Contact Phone => ' +curLead.get('Phone'));
                if ((curLead.firstName == firstname &&  curLead.LastName == lastname && curLead.Email != null && curLead.Email == email) 
                     || (curLead.firstName == firstname &&  curLead.LastName == lastname && curLead.Phone != null && curLead.Phone == phone) 
                     || (curLead.firstName == firstname &&  curLead.LastName == lastname && curLead.MobilePhone != null && curLead.MobilePhone == mobilePhone)) {
                    currentRecord = curLead;
                    isFound = TRUE;
                    System.Debug('Found Existing Lead');
                }
            }
        }
        return currentRecord;        
    }

    private static sObject getLeadMapping(sObject rec,String ObjectName, Id existingRecordId, sObject existingRecord, Boolean isNew) {    
        system.debug('Get Lead Mapping');
        sObject ld = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        if(isNew ) {
            ld.put('Account_Insight__c', rec.get('Account_Insight__c'));        
            ld.put('Assets_Owned__c', rec.get('Assets_Owned__c'));
            ld.put('Broker_Year_Active__c', rec.get('Broker_Year_Active__c'));
            ld.put('City', rec.get('City__c'));
            ld.put('Company', rec.get('Company_Name__c'));
            ld.put('Contact_Information_Score__c', rec.get('Contact_Information_Score__c'));
            ld.put('Country', rec.get('Country__c'));
            ld.put('County__c', rec.get('County__c'));
            ld.put('CRE_Lead_Score__c', rec.get('CRE_Lead_Score__c'));
            ld.put('CRE_Market_Research_Analyst__c', rec.get('CRE_Market_Research_Analyst__c'));
            ld.put('Est_Portfolio_Value__c', rec.get('Assets_Under_Management__c'));
            ld.put('FirstName', rec.get('First_Name__c'));
            ld.put('LastName', rec.get('Last_Name__c'));
            ld.put('Title', rec.get('Title__c'));
            ld.put('Email', rec.get('Email__c'));
            ld.put('Phone', rec.get('Phone__c'));
            ld.put('MobilePhone', rec.get('Mobile__c'));
            ld.put('Phone_Extension__c', rec.get('Phone_Extension__c'));
            ld.put('General_Notes__c', rec.get('General_Notes__c'));
            ld.put('Is_Lead_Info_Broker_Agent_or_Seller__c', rec.get('Is_Lead_Info_Broker_Agent_or_Seller__c'));
            ld.put('Lead_Source_Filename__c', rec.get('Lead_Source_Filename__c'));
            ld.put('LeadSource','Uploaded List');
            ld.put('Portfolio_Details__c', rec.get('Portfolio_Details__c'));
            ld.put('Portfolio_Insight__c', rec.get('Portfolio_Insight__c'));
            ld.put('PostalCode', rec.get('Zip_Postal_Code__c'));
            ld.put('Properties_Managed__c', rec.get('Properties_Managed__c'));
            ld.put('Property_Types_Interest_Buy__c', rec.get('Property_Types_Interest_Buy__c'));
            ld.put('Property_Types_Own__c', rec.get('Property_Types_Own__c'));
            ld.put('Property_Types_Sell__c', rec.get('Property_Types_Sell__c'));
            ld.put('Secondary_Lead_Owner__c', rec.get('Secondary_Lead_Owner__c'));
            ld.put('State', rec.get('State_Province__c'));
            ld.put('Street', rec.get('Street__c'));
            ld.put('Website', rec.get('Website__c'));
            ld.put('Campaign__c', rec.get('Campaign_ID__c')); 
            if(campaignMap.get(String.Valueof(rec.get('Campaign_ID__c'))).CRE_Communication_Type__c!='Email') {
                ld.put('Most_Recent_Campaign1__c', rec.get('Campaign_ID__c'));
            }
        }
        else{
            ld.put('Id',existingRecordId);
            if(existingRecord.get('Title') == null) {
                ld.put('Title', rec.get('Title__c'));
            }
            if(existingRecord.get('Email') == null) {
                ld.put('Email', rec.get('Email__c'));
            }
            if(existingRecord.get('Phone') == null) {
                ld.put('Phone', rec.get('Phone__c'));
            }
            if(existingRecord.get('MobilePhone') == null) {
                ld.put('MobilePhone', rec.get('Mobile__c'));
            }
            if(existingRecord.get('Phone_Extension__c') == null) {
                ld.put('Phone_Extension__c', rec.get('Phone_Extension__c'));
            }
            ld.put('Status','D) Reopened');
            ld.put('Account_Insight__c', rec.get('Account_Insight__c'));
            ld.put('Assets_Owned__c', rec.get('Assets_Owned__c'));
            ld.put('Broker_Year_Active__c', rec.get('Broker_Year_Active__c'));
            ld.put('City', rec.get('City__c'));
            ld.put('Country', rec.get('Country__c'));
            ld.put('CRE_Lead_Score__c', rec.get('CRE_Lead_Score__c'));
            ld.put('CRE_Market_Research_Analyst__c', rec.get('CRE_Market_Research_Analyst__c'));
            ld.put('Est_Portfolio_Value__c', rec.get('Assets_Under_Management__c'));
            ld.put('General_Notes__c', rec.get('General_Notes__c'));
            ld.put('Lead_Source_Filename__c', rec.get('Lead_Source_Filename__c'));
            ld.put('Portfolio_Details__c', rec.get('Portfolio_Details__c'));
            ld.put('Portfolio_Insight__c', rec.get('Portfolio_Insight__c'));
            ld.put('PostalCode', rec.get('Zip_Postal_Code__c'));
            ld.put('Properties_Managed__c', rec.get('Properties_Managed__c'));
            ld.put('Property_Types_Interest_Buy__c', rec.get('Property_Types_Interest_Buy__c'));
            ld.put('Property_Types_Own__c', rec.get('Property_Types_Own__c'));
            ld.put('Property_Types_Sell__c', rec.get('Property_Types_Sell__c'));
            ld.put('State', rec.get('State_Province__c'));
            ld.put('Street', rec.get('Street__c'));
            ld.put('Campaign__c', rec.get('Campaign_ID__c')); 
            if(campaignMap.get(String.Valueof(rec.get('Campaign_ID__c'))).CRE_Communication_Type__c!='Email') {
                ld.put('Most_Recent_Campaign1__c', rec.get('Campaign_ID__c'));
            }
        }  
        return ld;
    }

    private static sObject getContactMapping(sObject rec,String ObjectName, Id existingRecordId, sObject existingRecord, Boolean isNew) {    
        system.debug('Get Contact Mapping');
        sObject ld = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        ld.put('Id',existingRecordId);
        if(existingRecord.get('Title') == null) {
            ld.put('Title', rec.get('Title__c'));
        }
        if(existingRecord.get('Email') == null) {
            ld.put('Email', rec.get('Email__c'));
        }
        if(existingRecord.get('Phone') == null) {
            ld.put('Phone', rec.get('Phone__c'));
        }
        if(existingRecord.get('MobilePhone') == null) {
            ld.put('MobilePhone', rec.get('Mobile__c'));
        }
        if(existingRecord.get('Phone_Extension__c') == null) {
            ld.put('Phone_Extension__c', rec.get('Phone_Extension__c'));
        }
        ld.put('Property_Types_Own__c', rec.get('Property_Types_Own__c'));
        ld.put('Assets_Owned__c', rec.get('Assets_Owned__c'));
        ld.put('Properties_Managed__c', rec.get('Properties_Managed__c'));
        ld.put('Est_Portfolio_Value__c', rec.get('Assets_Under_Management__c'));
        ld.put('Broker_Year_Active__c', rec.get('Broker_Year_Active__c'));
        ld.put('CRE_Lead_Score__c', rec.get('CRE_Lead_Score__c'));
        ld.put('CRE_Market_Research_Analyst__c', rec.get('CRE_Market_Research_Analyst__c'));
        ld.put('General_Notes__c', rec.get('General_Notes__c'));
        ld.put('Portfolio_Details__c', rec.get('Portfolio_Details__c'));
        ld.put('Portfolio_Insight__c', rec.get('Portfolio_Insight__c'));
        ld.put('Property_Types_Sell__c', rec.get('Property_Types_Sell__c'));
        ld.put('Property_Types_Interest_Buy__c', rec.get('Property_Types_Interest_Buy__c'));
        ld.put('LeadSource','Uploaded List');
        ld.put('MailingStreet', rec.get('Street__c'));
        ld.put('MailingCity', rec.get('City__c'));
        ld.put('MailingState', rec.get('State_Province__c'));
        ld.put('MailingPostalCode', rec.get('Zip_Postal_Code__c'));
        ld.put('MailingCountry', rec.get('Country__c'));
        ld.put('Campaign__c', rec.get('Campaign_ID__c')); 
        if(campaignMap.get(String.Valueof(rec.get('Campaign_ID__c'))).CRE_Communication_Type__c!='Email') {
            ld.put('Most_Recent_Campaign1__c', rec.get('Campaign_ID__c'));
        }
        return ld;
    }

    private static sObject getCampaignMapping(sObject rec,String ObjectName, Boolean isNew) {    
        system.debug('Get Campaign Mapping');
        sObject ld = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        if(rec.get('Id')!=null) {
            Id currentId= (Id)rec.get('Id');
            String sourceObject = currentId.getSObjectType().getDescribe().getName();
            if(sourceObject == 'Lead') {
                ld.put('LeadId',rec.get('Id'));        
                if(isNew){ 
                    ld.put('New_Lead__c',TRUE);
                }
                ld.put('CampaignId', rec.get('Campaign__c'));    
            }
            else {
                ld.put('ContactId',rec.get('Id'));                
                ld.put('CampaignId', rec.get('Campaign__c'));    
            }
        }
        return ld;
    }
}