trigger CampaignTrigger on Campaign (after insert,after update) {
    CampaignTriggerhandler.process(Trigger.OldMap , Trigger.NewMap);
}