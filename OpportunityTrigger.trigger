trigger OpportunityTrigger on Opportunity (after update, after insert) {
    OpportunityUtils.validateBPOUpdates(Trigger.new, Trigger.oldMap);
    if(Trigger.isInsert){
        OpportunityTriggerHandler.process(Trigger.New);
    }
   
}