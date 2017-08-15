//*******************************************************************************************************************//
// Change Log                                                                                                       *// 
// Version 1.0 - Campaign Members creation from opportunity  *//
// Version ?.? -                                                                                                    *//
// Created By: Ganesh Vinnakota                                                                                    *//
// Test Class :                                                                    *//
//*******************************************************************************************************************//
global class BatchableUpsertCampaignMember implements Database.Batchable<sObject>, Database.AllowsCallOuts, Database.Stateful {
    global   String  query;
   
    //  ---------------------------------------------------------------------
    //  CONSTRUCTOR
    //  ---------------------------------------------------------------------
    global BatchableUpsertCampaignMember() {
        String sysdatetime = String.valueOfGmt(System.now().addHours(-32)).replace(' ','T')+'.000Z'; 
        system.debug('Date = ' +sysdatetime);

        query = 'SELECT Id,CampaignId,Seller__c,Broker_Agent__c FROM Opportunity WHERE CampaignId!=null AND RecordTypeId =  \''+Label.Parent_Opportunity+'\''; 
        if(Test.isRunningTest()) { 
            query = 'SELECT Id,CampaignId,Seller__c,Broker_Agent__c FROM Opportunity WHERE CampaignId!=null AND RecordTypeId =  \''+Label.Parent_Opportunity+'\' LIMIT 200';
        }
        system.debug('==> '+Query);
    }
    
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: start
    //  ---------------------------------------------------------------------
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
   
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: execute 
    //  ---------------------------------------------------------------------
    global void execute(Database.BatchableContext bc, List<sObject> scope) {         
                         
        Set<Id> campaignIds = new Set<Id>();   
        Set<Id> conId = new Set<Id>();   

        Map<String,CampaignMember> expectedCampaignMembers = new Map<String,CampaignMember>();
        for (SObject s: scope) {
            Opportunity opp = (Opportunity) s;
            if(opp.Seller__c != null) {
                conId.add(opp.Seller__c);  
                campaignIds.add(opp.CampaignId);
                expectedCampaignMembers.put(String.valueof(opp.CampaignId)+String.Valueof(opp.Seller__c),new CampaignMember(CampaignId = opp.CampaignId,ContactId = opp.Seller__c,Opportunity__c = opp.Id));
                system.debug('1==> '+expectedCampaignMembers);
            }
            if(opp.Broker_Agent__c != null) {
                conId.add(opp.Broker_Agent__c);  
                campaignIds.add(opp.CampaignId);
                expectedCampaignMembers.put(String.valueof(opp.CampaignId)+String.Valueof(opp.Broker_Agent__c),new CampaignMember( CampaignId = opp.CampaignId,ContactId = opp.Broker_Agent__c,Opportunity__c = opp.Id));
                system.debug('2==> '+expectedCampaignMembers);
            }
            system.debug('3==> '+expectedCampaignMembers);
        }
        system.debug('4==> '+expectedCampaignMembers);
    
        Map<String,CampaignMember> CampaignMemberMap = new Map<String,CampaignMember>();

        Map<String,Id> currentCampaignMembersMap = new Map<String,Id>();
        for(CampaignMember cm: [Select CampaignId,ContactId,Opportunity__c From CampaignMember WHERE campaignId IN :campaignIds and ContactId IN :conId]) {
            currentCampaignMembersMap.put(String.valueof(cm.CampaignId)+String.Valueof(cm.ContactId),cm.Id);
        }

        for (CampaignMember cm: expectedCampaignMembers.values()) {
            system.debug('Current Member ==> ' +cm);
            if(currentCampaignMembersMap.containsKey(String.valueof(cm.CampaignId)+String.Valueof(cm.ContactId))) {
                cm.Id = currentCampaignMembersMap.get(String.valueof(cm.CampaignId)+String.Valueof(cm.ContactId));
                CampaignMemberMap.put(String.valueof(cm.CampaignId)+String.Valueof(cm.ContactId),cm);
            }
            else {
                CampaignMemberMap.put(String.valueof(cm.CampaignId)+String.Valueof(cm.ContactId),cm);
            }
            system.debug('Member Map==> '+CampaignMemberMap);
        }
        system.debug('Member List ==> ' +CampaignMemberMap);         
        if(!CampaignMemberMap.values().isEmpty()) { 
            Database.Upsert(CampaignMemberMap.Values(),CampaignMember.Id);
        }
   }  

   global void finish(Database.BatchableContext bc){       }

}