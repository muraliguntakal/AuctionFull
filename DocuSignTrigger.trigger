trigger DocuSignTrigger on dsfs__DocuSign_Status__c (after insert, after update) {
//if(TriggerSettings__c.getValues('DocuSignTrigger').Status__c) { 
  TriggerSettings__c ts = TriggerSettings__c.getValues('DocuSignTrigger');
  if (ts != null && ts.Status__c) {

   
    DocuSignTriggerHelper DocTr = new DocuSignTriggerHelper(); 
  
 
    if((Trigger.isupdate || Trigger.isinsert) && Trigger.isafter){
         DocTr.DocusigntoOfferUpdate(Trigger.NewMap, Trigger.OldMap, Trigger.isinsert, Trigger.isupdate);
    }
    
      
  } 
 }