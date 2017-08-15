//Test Class : CampaignMemberUpdateTests
Public class CaseTriggerHelper {

    public static void triggerHandler(List<case> caseRecords) {
        ProcessCRECases(getCRECases(caseRecords));
    }

    //Get all the CRE Marketing Cases and give the CRE Case Processor
    private static Set<Id> getCRECases(List<Case> caseRecords) {    
        Set<Id> CaseIds = new Set<Id>();
        for(case obj : caseRecords) {
            if(obj.RecordTypeId == Label.CRE_Marketing_Case && obj.Campaign_Name__c!=null) {
                CaseIds.add((String) obj.get('Id'));
            }    
        }
        return CaseIds;         
    }

    private static void ProcessCRECases(Set<Id> caseIds) {    
        List<Case> caseRecords= new List<Case>([Select Id,RecordTypeId,SFDC_Campaign_Name__c,Campaign_Name__c,Start_Date__c,End_Date__c,Campaign_Member_Status__c,
                                                       CRE_Campaign_Type__c,Campaign_Score__c,CRE_Category_Type__c,CRE_Channel__c,CRE_Communication_Type__c,CRE_Data_Source__c,
                                                       CRE_Inbound_Outbound__c,CRE_Subchannel__c,Marketing_Source__c,Open_House_Event_Date__c,Related_Opportunity__c,
                                                       Property_Website__c
                                                FROM Case Id WHERE Id =:CaseIds]);  
         Map<String,Id> currentCRECampaigns = new  Map<String,Id>();
        
        Map<Id,Id> CaseIdCampaignMap = new Map<Id,Id>(createNewCRECampaigns(caseRecords,currentCRECampaigns));                
        system.debug('Current CCMap ==> ' +CaseIdCampaignMap);
        UpdateCase(caseIds,CaseIdCampaignMap);
    }

    public static  Map<String,Id> getCampaignsUsingCampaignName(Set<String> campaignNames) {    
        Map<String,Id> CampaignNameIdMap = new Map<String,Id> ();
        for(Campaign c : [Select Id, Name FROM Campaign WHERE Name =:campaignNames AND RecordTypeId =:Label.CRE_Marketing] ) {
            CampaignNameIdMap.put((String)c.get('Name'), (Id)c.get('Id'));        
        }
        return CampaignNameIdMap;
    }

    public static Map<Id, Id> createNewCRECampaigns(List<Case> caseRecords,Map<String,Id> currentCampaigns) {    
        system.debug('Check creating campaigns => ');
        Map<Id,sObject> newCampaigns = new Map<Id,sObject>();
        Map<Id,Id> CaseCampaignMap = new Map<Id,Id>();
        for(case obj : caseRecords) {
            if(obj.RecordTypeId == Label.CRE_Marketing_Case) {
                system.debug('=> ' + obj.Campaign_Name__c);  
                if(obj.Campaign_Name__c!=null) {
                    newCampaigns.put(obj.Id, getCampaignMapping(obj,'Campaign'));
                    system.debug('CM => ' +getCampaignMapping(obj,'Campaign'));
                }                
            }    
        }

        Insert newCampaigns.values();
        system.debug(' ==> '+newCampaigns); 
        for(Id cId : newCampaigns.KeySet()) {
           CaseCampaignMap.put(cId,newCampaigns.get(cId).Id); 
        }
        return CaseCampaignMap;
    }

    public static sObject getCampaignMapping(sObject Source,String ObjectName) {    
        sObject target = Schema.getGlobalDescribe().get(ObjectName).newSObject();
        target.put('Name', source.get('Campaign_Name__c'));
        target.put('isActive', TRUE);
        target.put('StartDate', source.get('Start_Date__c'));
        target.put('EndDate', source.get('End_Date__c'));
        target.put('Campaign_Member_Status__c', source.get('Campaign_Member_Status__c'));
        target.put('RecordTypeId', Label.CRE_Campaign_RecordType);
        target.put('CRE_Campaign_Type__c', source.get('CRE_Campaign_Type__c'));
        target.put('CRE_Category_Type__c', source.get('CRE_Category_Type__c'));
        target.put('CRE_Channel__c', source.get('CRE_Channel__c'));
        target.put('Campaign_Score__c', source.get('Campaign_Score__c'));
        target.put('CRE_Communication_Type__c', source.get('CRE_Communication_Type__c'));
        target.put('CRE_Data_Source__c', source.get('CRE_Data_Source__c'));
        target.put('CRE_InboundOutbound__c', source.get('CRE_Inbound_Outbound__c'));
        target.put('CRE_Subchannel__c', source.get('CRE_Subchannel__c'));
        target.put('Marketing_Source__c', source.get('Marketing_Source__c'));
        target.put('Open_House_Event_Date__c', source.get('Open_House_Event_Date__c'));    
        target.put('Opportunity__c', source.get('Related_Opportunity__c'));   
        target.put('Property_Website__c', source.get('Property_Website__c'));         
        return target;
    }

    @future
    private static void UpdateCase(Set<Id> caseIds,Map<Id,Id> CaseCampaignMap) {    
        List<Case> caseRecords= new List<Case>([Select Id,RecordTypeId,SFDC_Campaign_Name__c,Campaign_Name__c,Start_Date__c,End_Date__c,Campaign_Member_Status__c FROM Case Id WHERE Id =:CaseIds]);  
        system.debug('Check Updating Cases => ');
        for(case obj : caseRecords) {
            system.debug('Current Campaign ==> ' +CaseCampaignMap.get(obj.Id));
            obj.SFDC_Campaign_Name__c = CaseCampaignMap.get(obj.Id)!=null ? CaseCampaignMap.get(obj.Id) : null;
        }
        Update caseRecords;
    }

}