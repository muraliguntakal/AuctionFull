public class OpportunityTriggerHandler {

    public static void process(List<Opportunity> triggerNew){
        /*
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : triggerNew){
            oppIds.add(opp.Id);
        }
        if(!oppIds.isEmpty()){
            queryAndProcessCampaignMembers(oppIds);   
        }  
        */
        queryAndProcessCampaignMembers(new Map<Id,Opportunity>(triggerNew).keySet());
    }


    @future
    public static void queryAndProcessCampaignMembers(Set<Id> oppIds){
        Map<Id,CampaignMember> cmemberMap = new Map<Id,CampaignMember>();
        Map<Id,Integer> campaignCountMap = new Map<Id,Integer>();
        Set<Id> contactIds = new Set<Id>();         
        List<Contact> conList = new List<Contact>();
        for(Lead lead :[
            SELECT Id,convertedContactId,Initial_Campaign__c,Most_Recent_Campaign1__c,Campaign_count__c 
            FROM Lead 
            WHERE isConverted=true AND convertedOpportunityId IN:oppIds
        ]){
            contactIds.add(lead.convertedContactId) ; 
            Contact con = new Contact(
                Id =lead.convertedContactId,
                Campaign_count__c = lead.Campaign_count__c,
                Initial_Campaign__c=lead.Initial_Campaign__c,
                Most_Recent_Campaign1__c = lead.Most_Recent_Campaign1__c
            );
            conList.add(con);
              
        }
        if(!contactIds.isEmpty()){
            for(CampaignMember cm : [
              SELECT id,ContactId,LeadId,Lead.Most_Recent_Campaign1__c,Lead.Initial_Campaign__c,
                     CampaignId,Contact.Most_Recent_Campaign1__c,Contact.Initial_Campaign__c,
                     Campaign_Influence_Score_Other__c,Campaign_Influence_Score_Initial__c,Campaign_Influence_Score_Most_Recent__c,
                     Campaign_Influence_Score_Recent_Total__c,Campaign_Influence_Score_Initial_Total__c  
              FROM CampaignMember
              WHERE ContactId IN:contactIds
              ORDER BY CampaignId
            ]){              
                cmemberMap.put(cm.Id,cm) ; 
                String key = cm.contactId==NULL ? cm.LeadId : cm.ContactId;
                if(campaignCountMap.containsKey(key)){
                    campaignCountMap.put(key,campaignCountMap.get(key) + 1) ;
                }
                else{
                    campaignCountMap.put(key,1);   
                }
            }                                                                                              
        }
        else{
           Set<id> conIds = new Set<Id>(); 
           for(Opportunity opps :[
              SELECT Id,Seller__c 
              FROM Opportunity 
              WHERE Id IN : oppIds AND Seller__c !=NULL]){
              conIds.add(opps.Seller__c);    
           }
           for(Contact con : [
               SELECT Id,Most_Recent_Campaign1__c,Campaign_count__c,(SELECT id FROM Opportunities1__r) 
               FROM Contact 
               WHERE Id IN:conIds AND Most_Recent_Campaign1__c!=NULL
           ]){
               if(con.Opportunities1__r.size() ==1){
                   contactIds.add(con.Id);
               }
           }
           if(!contactIds.isEmpty()){
                for(CampaignMember cm : [
                  SELECT id,ContactId,LeadId,Lead.Most_Recent_Campaign1__c,Lead.Initial_Campaign__c,
                    CampaignId,Contact.Most_Recent_Campaign1__c,Contact.Initial_Campaign__c,
                    Campaign_Influence_Score_Other__c,Campaign_Influence_Score_Initial__c,Campaign_Influence_Score_Most_Recent__c,
                    Campaign_Influence_Score_Recent_Total__c,Campaign_Influence_Score_Initial_Total__c 
                  FROM CampaignMember
                  WHERE ContactId IN:contactIds
                  ORDER BY CampaignId
                ]){
                    cmemberMap.put(cm.Id,cm) ;
                    String key = cm.contactId==NULL ? cm.LeadId : cm.ContactId;
                    if(campaignCountMap.containsKey(key)){
                        campaignCountMap.put(key,campaignCountMap.get(key) + 1);
                    }
                    else{
                        campaignCountMap.put(key,1);   
                    }
                }  
           }  
        } 
        
        if(!conList.isEmpty()){
            update conList ;
        }
        if(!cmemberMap.values().isEmpty()){
            calculateCampaignScores(cMemberMap,campaignCountMap);
        }    
    }
    
    public static void calculateCampaignScores(Map<Id,CampaignMember> cMemberMap,Map<Id,Integer> campaignCountMap){
      for(CampaignMember cMember : cMemberMap.values()){
          if(cMember.contactId!=NULL){
             // system.debug('@@@@@@ Most recent Campaign'+cMember.Contact.Most_Recent_Campaign__c+'Initial Campaign' +cMember.Contact.Initial_Campaign__c) ;
              if(cMember.Contact.Most_Recent_Campaign1__c == cMember.CampaignId){
                  cMember.Campaign_Influence_Score_Most_Recent__c = 0.5 ;
                  cMember.Campaign_Influence_Score_Recent_Total__c = 0.5;
                  //system.debug('@@@@@ Scoring For recent');
              }
              if(cMember.Contact.Initial_Campaign__c == cMember.CampaignId){
                  cMember.Campaign_Influence_Score_Initial__c = 0.5 ;
                  cMember.Campaign_Influence_Score_Initial_Total__c  = 0.5;
                  //system.debug('@@@@@ Scoring For Initial');
              }
              else if(campaignCountMap.get(cMember.contactId) > 1){
                  cMember.Campaign_Influence_Score_Other__c = 0.5 / (campaignCountMap.get(cMember.contactId) - 1);
                  cMember.Campaign_Influence_Score_Recent_Total__c = cMember.Campaign_Influence_Score_Most_Recent__c == NULL ? (0 + cMember.Campaign_Influence_Score_Other__c ) :(cMember.Campaign_Influence_Score_Most_Recent__c + cMember.Campaign_Influence_Score_Other__c ) ;
                  cMember.Campaign_Influence_Score_Initial_Total__c = cMember.Campaign_Influence_Score_Initial__c == NULL ? (0 + cMember.Campaign_Influence_Score_Other__c ) :(cMember.Campaign_Influence_Score_Initial__c + cMember.Campaign_Influence_Score_Other__c ) ;
                  //system.debug('@@@@@ Scoring For other');
              }

          }
          else{
              //system.debug('@@@@@@ Most recent Campaign'+cMember.Lead.Most_Recent_Campaign__c+'Initial Campaign' +cMember.Lead.Initial_Campaign__c) ;
              if(cMember.Lead.Most_Recent_Campaign1__c == cMember.CampaignId){
                  cMember.Campaign_Influence_Score_Most_Recent__c = 0.5 ;
                  cMember.Campaign_Influence_Score_Recent_Total__c = 0.5;
                  //system.debug('@@@@@ Scoring For recent');
              }
              if(cMember.Lead.Initial_Campaign__c == cMember.CampaignId){
                  cMember.Campaign_Influence_Score_Initial__c = 0.5 ;
                  cMember.Campaign_Influence_Score_Initial_Total__c  = 0.5;
                  //system.debug('@@@@@ Scoring For Initial');
              }
              else if(campaignCountMap.get(cMember.LeadId) > 1){
                  cMember.Campaign_Influence_Score_Other__c = 0.5 / (campaignCountMap.get(cMember.LeadId) - 1);
                  cMember.Campaign_Influence_Score_Recent_Total__c = cMember.Campaign_Influence_Score_Most_Recent__c == NULL ? (0 + cMember.Campaign_Influence_Score_Other__c ) :(cMember.Campaign_Influence_Score_Most_Recent__c + cMember.Campaign_Influence_Score_Other__c ) ;
                  cMember.Campaign_Influence_Score_Initial_Total__c = cMember.Campaign_Influence_Score_Initial__c == NULL ? (0 + cMember.Campaign_Influence_Score_Other__c ) :(cMember.Campaign_Influence_Score_Initial__c + cMember.Campaign_Influence_Score_Other__c ) ;
                  //system.debug('@@@@@ Scoring For other');
              }
          }
      } 

      Database.update(cMemberMap.values()) ;
      cMemberMap = new Map<Id,CampaignMember>();          
  }
}