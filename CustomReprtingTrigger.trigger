trigger CustomReprtingTrigger on Custom_Reporting__c (before insert) {

  TriggerSettings__c ts = TriggerSettings__c.getValues('CustomReprtingTrigger');
  if (ts != null && ts.Status__c) {
  
        CustomReportingHelper CusRepTr = new CustomReportingHelper(); 
        CusRepTr.GetIntakeForm(Trigger.New); 
        CusRepTr.GetIntakeForOfferSelect(Trigger.New);        
  }
}