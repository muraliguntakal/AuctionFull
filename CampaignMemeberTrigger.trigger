trigger CampaignMemeberTrigger on CampaignMember (after insert,before delete,after delete) {


   CampaignMemberTriggerHandler cmtr = new CampaignMemberTriggerHandler();
       cmtr.process(Trigger.NewMap,Trigger.OldMap);
       
       if((Trigger.isinsert || Trigger.isdelete) && Trigger.isafter) { 
           cmtr.UpdateCREFlagOnContact(Trigger.NewMap,Trigger.OldMap); 
         }  
           
          


}