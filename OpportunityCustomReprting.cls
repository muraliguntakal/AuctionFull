public with sharing class OpportunityCustomReprting {

  Map<Id, Opportunity> ParentOppMap = new Map<Id, Opportunity>();
  public void CustomReporting(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap) { 
      
    for(Opportunity Opps: newOppMap.Values()){   
       if((Opps.Broker_Channel_Rep__c != oldOppMap.get(Opps.Id).Broker_Channel_Rep__c || Opps.Referring_Broker_Name__c != oldOppMap.get(Opps.Id).Referring_Broker_Name__c || 
          Opps.Sourced_by_Broker_Channel_Rep__c != oldOppMap.get(Opps.Id).Sourced_by_Broker_Channel_Rep__c) && Opps.RecordTypeId == Label.Parent_Opportunity){
        ParentOppMap.put(Opps.Id, Opps);
        }
     }
     
     Set<Id> ChildIdsSet = new Set<Id>();
     List<Opportunity> ChildOppList = [Select Id From Opportunity where Parent_Opportunity__c IN: ParentOppMap.KeySet() AND RecordTypeId=:Label.Commercial_Opportunity_Rectype_Id];
   if(ChildOppList.Size() > 0){
         for(Opportunity ChildOpps: ChildOppList){
             ChildIdsSet.add(ChildOpps.Id);
         }    
      }   
        
     List<Custom_Reporting__c> CustRepList = [Select Id,Parent_Opportunity__c,Opportunity__c From Custom_Reporting__c where Opportunity__c IN: ChildIdsSet OR Opportunity__c IN:ParentOppMap.KeySet()];
     
     List<Custom_Reporting__c> UpdateCustRep = new List<Custom_Reporting__c>();
        if(CustRepList.Size() > 0){
            for(Custom_Reporting__c Cust: CustRepList){
                  if(ParentOppMap.containskey(Cust.Parent_Opportunity__c)){
                     Cust.Broker_Channel_Rep_LookUp__c = ParentOppMap.get(Cust.Parent_Opportunity__c).Broker_Channel_Rep__c;
                     Cust.Referring_Broker_s_Name_LookUp__c = ParentOppMap.get(Cust.Parent_Opportunity__c).Referring_Broker_Name__c;
                     Cust.Sourced_by_Broker_Channel_Rep__c = ParentOppMap.get(Cust.Parent_Opportunity__c).Sourced_by_Broker_Channel_Rep__c;
                    }    
                  else if(ParentOppMap.containskey(Cust.Opportunity__c)){
                     Cust.Broker_Channel_Rep_LookUp__c = ParentOppMap.get(Cust.Opportunity__c).Broker_Channel_Rep__c;
                     Cust.Referring_Broker_s_Name_LookUp__c = ParentOppMap.get(Cust.Opportunity__c).Referring_Broker_Name__c;
                     Cust.Sourced_by_Broker_Channel_Rep__c = ParentOppMap.get(Cust.Opportunity__c).Sourced_by_Broker_Channel_Rep__c;
                  } 
                 UpdateCustRep.add(Cust);
             } 
         }     
     
      if(!UpdateCustRep.isEmpty()){
          Update UpdateCustRep;  
         }           
       
 }    
}