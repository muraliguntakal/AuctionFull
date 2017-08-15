trigger OppCustomReporting on Opportunity (after update) {
    TriggerSettings__c ts = TriggerSettings__c.getValues('OppCustomReporting');
    if (ts != null && ts.Status__c) {     
        OpportunityCustomReprting OpCu = new OpportunityCustomReprting();
        OpCu.CustomReporting(trigger.newMap, trigger.oldMap);               
    }
}