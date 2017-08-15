trigger CaseTrigger on Case (after Insert) {

    CaseTriggerHelper.triggerHandler(Trigger.New);

}