/******************************************************************************************************************************************************************************************
/* Author : Ganesh Created  on 10/16/14 */
// Test Class :
// Modified By                    Modified Date                                    What Changed                                                                Reason
//                                                       
//******************************************************************************************************************************************************************************************  
trigger OfferTrigger on Offer__c (before insert, before update, after insert, after update, after delete) {

	//if(TriggerSettings__c.getValues('OfferTrigger').Status__c) {  

  //TriggerSettings__c ts = TriggerSettings__c.getValues('OfferTrigger');

  //if (ts != null && ts.Status__c) {
  	
  //  if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
		//	OfferTriggerhelper oth = new OfferTriggerhelper();
		//	oth.FindbidId(Trigger.new);
		//}

if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
	OfferUtils.validateOOAContacts(Trigger.new, Trigger.old, Trigger.oldMap);
}
	//}            
}