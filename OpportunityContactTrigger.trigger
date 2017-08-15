//*******************************************************************************************//
//*********************************** Change Log ********************************************// 
//  S.No Created Date   -   Version  Developer               Comments
//    1.  7/5/2013      -   1.0      Developer Admin        Created Original Trigger
//    2.  1/6/2014      -   2.0      Murali K Guntakal      Reset Latest Opportunity Flag         
//*********************************** Change Log ********************************************// 

trigger OpportunityContactTrigger on Opportunity (after insert, after update) {
   // if(TriggerSettings__c.getValues('OpportunityContactTrigger').Status__c){
      TriggerSettings__c ts = TriggerSettings__c.getValues('OpportunityContactTrigger');
      if (ts != null && ts.Status__c) {

    /*    OpportunityContactTrigger oct = new OpportunityContactTrigger();
        if (!OpportunityContactTrigger.isTriggerUpdate) {
            oct.UpdateOpportunityInfo(trigger.newMap, trigger.oldMap, Trigger.isInsert);
        } */
    }
}