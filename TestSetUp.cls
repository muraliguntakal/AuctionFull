public without sharing class TestSetUp {
    public void CustomSettings() {  
    
         
        List<SystemSettings__c> ssList = new List<SystemSettings__c>();
        ssList.add(new SystemSettings__c(name = CONSTANTS.PARM_OUTBOUND_LEAD_CREATION_EMAIL, value__c = 'testemail1@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_VECTRA_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_SIERRA_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_MBFS_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));  
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_NAS_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));  
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_NVMS_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));  
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_VECTRA_CC_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_SIERRA_CC_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_MBFS_CC_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_NAS_CC_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.TRUSTEE_NVMS_CC_RECEPIENTS_EMAIL, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
        ssList.add(new SystemSettings__c(name = CONSTANTS.INTAKE_MEMO_VALUATIONS_TEAM, value__c = 'testemail1@testdomain.com;testemail2@testdomain.com'));
              
        INSERT ssList;
        
        //Validation Rule Bypass
        Validation_Rule_Bypass__c vrb = new Validation_Rule_Bypass__c(Name =  UserInfo.getUserId(), Disable_Validation_Rules__c = True);
        INSERT vrb;

        List<TriggerSettings__c> tsList = new List<TriggerSettings__c>(); 
        TriggerSettings__c ts;
        //*************************************************************************//
        //********************** Call Record MLH Teams ****************************//        
        //*************************************************************************//
        
        ts = new TriggerSettings__c(name = '90708', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '90709', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '90710', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '90711', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '94781', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '94782', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '95157', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = '99999', Status__c = true);
        tsList.add(ts);
        
        ts = new TriggerSettings__c(name = 'SF Chase', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'error', Status__c = false);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'NON REO', Status__c = false);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OOA', Status__c = false);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'REO STAGE 1', Status__c = false);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'Team 1', Status__c = false);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'Team 2', Status__c = false);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'VIP', Status__c = false);
        tsList.add(ts);       
        //*************************************************************************//
        //**********************   Trigger Settings   *****************************//
        //*************************************************************************//
        ts = new TriggerSettings__c(name = 'Auto_Create_Valuation_Recrod', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'AOATrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'AssetOppJunctionTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'AuctionDetails', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'AssignLeadOwner_Velocify', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'BidTrigger', Status__c = true);
        tsList.add(ts);

        ts = new TriggerSettings__c(name = 'CallrecordTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CheckmostRecentValuation', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CountAOA', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CountValuation', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CreateBidContact', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CreateTitles', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CreateValue_Reserve_orders', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'EmailCaseComment', Status__c = true);
        tsList.add(ts);
        

        ts = new TriggerSettings__c(name = 'Findwinningbid', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'InsertUpdateOptyId', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'MostResentOpportunityAuction', Status__c = true);
        tsList.add(ts);
        
        ts = new TriggerSettings__c(name = 'OpenHouseDate', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OpportunityContactTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OpportunityOpenhouseUpdate', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OpportunityTriggerBefore', Status__c = true);
        tsList.add(ts);
        
        ts = new TriggerSettings__c(name = 'ScheduledBatchableUpdateAOA', Status__c = true);
        tsList.add(ts);       
        ts = new TriggerSettings__c(name = 'SendCallsToLiveOps', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'ScheduledBatchableUpdateBids', Status__c = true);
        tsList.add(ts);
        
        ts = new TriggerSettings__c(name = 'Update_Tiltle_status', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'Update_Assets', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'UpdateOpportunity', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'Update_Valuations', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'UpdateAddress_Opportunity', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'Updateplacephotoorderflag', Status__c = true);
        tsList.add(ts);  
        
        ts = new TriggerSettings__c(name = 'VROAssetDetails', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'VaultRollUp', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'BidRegistrationTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'BuyerSellerContactProfile', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CountContactTasks', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'ActivityTriggers', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'LeadConversionTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'updateClientManager', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'Update_Contact_Phone', Status__c = true);
        tsList.add(ts);        
        ts = new TriggerSettings__c(name = 'VaultActivityTriggers', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'AccountTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'ContactTriggerAfter', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OfferTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'DocuSignTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'DocuSignStatusBefore', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'AssetBeforeupdate', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'GetBuyerName', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'UpdateOffertoAOA', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'ContactProfileBefore', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'ContactTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OpportunitySplitTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'VaultTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'CustomReprtingTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'ProcessTodaysLiveOpsActivities', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'pdpTrigger', Status__c = true);
        tsList.add(ts);
        ts = new TriggerSettings__c(name = 'OppCustomReporting', Status__c = true);
        tsList.add(ts);

        INSERT tsList;
       
        List<Opportunity_Product_Type_Mapping__c> pmList = new List<Opportunity_Product_Type_Mapping__c>(); 
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='C2C',RecordTypeId__c='012d0000000t0iD'));
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='C2C Asset',RecordTypeId__c='012d0000000t0iD'));
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Commercial',RecordTypeId__c='012d0000000t0iC'));                
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='FCL Marketing',RecordTypeId__c='012d0000000Swzi'));
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Luxury',RecordTypeId__c='012d0000000t0iH'));                
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='MTL',RecordTypeId__c='012d0000000tIno'));
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Private Seller - Institutional',RecordTypeId__c='012d0000000t0iD'));                
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Resi Notes',RecordTypeId__c='012d0000000SvvE'));
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Short Sale',RecordTypeId__c='012d0000000tIno'));                
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Trustee',RecordTypeId__c='012d0000000Swzi'));                        
        pmList.add(new Opportunity_Product_Type_Mapping__c(Name='Parent',RecordTypeId__c='012K00000004pGk'));                        
                
        INSERT pmList;
    }
}