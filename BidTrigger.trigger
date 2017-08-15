//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  BidTrigger : All the work done by the handler.
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 11/12/13 */ 
// Modified By                    Modified Date                                    What Changed                                                    Reason
// Ganesh Vinnakota                02/20/2014                                       added Winning Bid Class                                         New requirement
//******************************************************************************************************************************************************************************************  

trigger BidTrigger on Bid__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

  //if(TriggerSettings__c.getValues('BidTrigger').Status__c){

  TriggerSettings__c ts = TriggerSettings__c.getValues('BidTrigger');

  if (ts != null && ts.Status__c) {
    TriggerFactory.createHandlerAndExecute(Bid__c.sObjectType);

    if (Trigger.isAfter) {

      if (Trigger.isInsert) {
        WinningBidClass.UpdateWinningBid(Trigger.new, trigger.oldMap,Trigger.isInsert);  
      } 
      else if (Trigger.isUpdate) {
        WinningBidClass.UpdateWinningBid(Trigger.new, trigger.oldMap,Trigger.isInsert);  
        WinningBidClass.CreateContractingRoles(trigger.newMap, trigger.oldMap);
      } 
      else if (Trigger.isDelete) {
        WinningBidClass.BidRollUp(trigger.new, trigger.old, Trigger.isDelete);
      }
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
      BidUtils.validateWinningBidderContacts(Trigger.new, Trigger.old, Trigger.oldMap);
    }

    /**
     * Commented out 
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) { 
      WinningBidClass.UpdateWinningBid(Trigger.new, trigger.oldMap,Trigger.isInsert);  
    }
        
    //  2. Bid and WinningBid Count Rollup for Contact   
    //if((Trigger.isinsert || Trigger.isupdate || Trigger.isdelete) && Trigger.isafter) {
    if (Trigger.isdelete && Trigger.isafter) {
      WinningBidClass.BidRollUp(trigger.new, trigger.old, Trigger.isDelete);
    }

    if (Trigger.isupdate && Trigger.isafter) {
      WinningBidClass.CreateContractingRoles(trigger.newMap, trigger.oldMap);
      OfferUtils.validateOOAContacts(Trigger.new, Trigger.oldMap);
    }
    */
  }
}