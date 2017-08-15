trigger LeadListTrigger on Lead_List__c (after insert, after update) {

    LeadListTriggerHelper.triggerHandler(Trigger.New);

}