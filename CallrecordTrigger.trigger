//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  CallrecordTrigger : All the work done by the handler.
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 11/25/13 */ 
// Modified By                    Modified Date                                    What Changed                                                    Reason

//******************************************************************************************************************************************************************************************  

trigger CallrecordTrigger on CallRecord__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //if(TriggerSettings__c.getValues('CallrecordTrigger').Status__c){
      TriggerSettings__c ts = TriggerSettings__c.getValues('CallrecordTrigger');
      if (ts != null && ts.Status__c) {

        TriggerFactory.createHandlerAndExecute(callrecord__c.sObjectType);
    }
}