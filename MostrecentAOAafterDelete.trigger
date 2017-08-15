trigger MostrecentAOAafterDelete on Auction_Opportunity_Assignment__c (before update) {

  /**
   * Updated to reduce the number of SOQL queries and DML being run on the AOA object. The logic in the trigger is rarely 
   * ever used (only 850 records in the system as of 4/15/2015) and should not impact the overall performance of the 
   * system for a process that is rarely ever needed.
   *
    Set<Id> oppIds = new Set<Id>();     
    Set<Id> currentId = new Set<Id>();
    for(Auction_Opportunity_Assignment__c aoa: trigger.new) { 
           if(aoa.Status__c=='Deleted' && aoa.Most_Recent_AOA__c==true){
                aoa.Most_Recent_AOA__c=false;
                oppIds.add(aoa.Opportunity__c); 
                currentId.add(aoa.Id);
            }    
    }

  List<Opportunity> childAOA= [SELECT Id,Most_Recent_Auction__c,(SELECT Id, Opportunity__c,Most_Recent_AOA__c
                                                                                   FROM Auction_Opportunity_Assignments__r 
                                                                                   WHERE Opportunity__c!=null AND Auction_Campaign__c!=null AND Status__c!='Deleted' AND Id NOT IN: currentId 
                                                                                   ORDER BY  CreatedDate DESC LIMIT 1)FROM Opportunity where Id in: oppIds];  
                                                                                   
  List<Auction_Opportunity_Assignment__c> AOAupdate = new List<Auction_Opportunity_Assignment__c>();                                                                                                                           
  for(Opportunity opp: childAOA)
  {
    if(opp.Auction_Opportunity_Assignments__r !=null && opp.Auction_Opportunity_Assignments__r.size()!=0) {
                for (Auction_Opportunity_Assignment__c  aoa : opp.Auction_Opportunity_Assignments__r) {
                
                     aoa.Most_Recent_AOA__c=true;
                     AOAupdate.add(aoa);
                       
                    }
      }
  }
  Update AOAupdate;
  */

  //AOAUtils.validateAoaUpdates(Trigger.new, Trigger.old, Trigger.oldMap);
}