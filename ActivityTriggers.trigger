trigger ActivityTriggers on Task (After Insert,After Update, Before Delete, After Delete, Before Insert, Before Update) {
  //if(TriggerSettings__c.getValues('ActivityTriggers').Status__c){
    TriggerSettings__c ts = TriggerSettings__c.getValues('ActivityTriggers');
    if (ts != null && ts.Status__c) {

 
        if(trigger.isDelete && trigger.isBefore) {
           for(Task t : trigger.old) {
              if(!UserInfo.getProfileId().Contains('00ed0000000HJIc') && !UserInfo.getProfileId().Contains('00ed0000000f4Ai')) {
                  t.adderror('Insufficient access to delete task');   
              }
           }
        }  
            
        ActivityTriggerHelper Acthelper = new ActivityTriggerHelper();

         //  1. Contact Activity Information   2. Contact Activity Information  3. Vault Activity Rollup
         if((Trigger.isinsert || Trigger.isupdate || Trigger.isdelete) && Trigger.isafter) {
            Acthelper.MostRecentTast(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate,  Trigger.isDelete);   
            Acthelper.RecentOfferTast(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate,  Trigger.isDelete); 
            Acthelper.VaultActivityRollUp(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);    
         }        
         
         // 4. Campaign and Activity Association    
           if((Trigger.isinsert || Trigger.isupdate) && Trigger.isBefore) {
            Acthelper.CampaignActivityAssociation(Trigger.new, Trigger.NewMap, Trigger.OldMap, Trigger.isInsert, Trigger.isUpdate);   
         }      
         
          // 5.  LiveOpps Task Name Update   
           if((Trigger.isinsert || Trigger.isupdate) && Trigger.isBefore) {
            Acthelper.LiveOppsTaskNameUpdate(Trigger.new);   
         }       
         
         // 6. Campaign Members Creation 
           if((Trigger.isinsert || Trigger.isupdate) && Trigger.isafter) {
            Acthelper.CampaignMembersCreate(Trigger.new, Trigger.NewMap, Trigger.OldMap, Trigger.isInsert, Trigger.isUpdate);   
           }
                                
    }
}