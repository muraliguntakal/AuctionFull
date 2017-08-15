trigger Auto_Create_Valuation_Recrod on Opportunity (before insert, after insert, after update, after delete) {
       // if(TriggerSettings__c.getValues('Auto_Create_Valuation_Recrod').Status__c) { 
          TriggerSettings__c ts = TriggerSettings__c.getValues('Auto_Create_Valuation_Recrod');
          if (ts != null && ts.Status__c) {

    
    //************************************* Check Trigger Lock is FALSE ***************************************************//
           if (!TriggerHelperClass.hasAlreadyfired()) {
    
               //Initialize OpportunityTriggerHelper Class   
               OpportunityTriggerHelper oct = new OpportunityTriggerHelper();
    
               //Create Asset 
               if (Trigger.isinsert && Trigger.isBefore){
                   oct.Create_Assets(trigger.new);
               }                                                           
               
               //   3. Create AOA when Auction is associated with Opportunity     
              if((Trigger.isinsert || Trigger.isupdate) && Trigger.isafter){
                   oct.CreateAOAfromOpp(trigger.newMap, trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
               }               
                
             if((Trigger.isinsert || Trigger.isupdate) && Trigger.isafter) {
                  OpportunityContactTrigger opct = new OpportunityContactTrigger();
                  if (!OpportunityContactTrigger.isTriggerUpdate) {
                       opct.UpdateOpportunityInfo(trigger.newMap, trigger.oldMap, Trigger.isInsert);
                  } 
              }                         
    
              if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
                   if (RecursionHelper.CanProcess('My_OppteamSplit')) { 
                        RecursionHelper.BlockProcess('My_OppteamSplit'); 
                        oct.CreateOppTeamAndOppSplit(trigger.newMap, Trigger.isinsert);
                        // Do some work here that might generate a recursive call
                        RecursionHelper.AllowProcess('My_Trigger');
                   }   
               } 
               
               if (Trigger.isInsert && Trigger.isAfter) {
                    oct.UpdateParentOpptoChildonValuation(trigger.newMap);
               }
               
              if((Trigger.isinsert || Trigger.isupdate || Trigger.isdelete) && Trigger.isafter) {
                    oct.ChildOppRollUpCountOnParent(Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);   
                } 
    
              if (Trigger.isUpdate && Trigger.isAfter) {
                  TriggerSettings__c ts = TriggerSettings__c.getValues('OppCustomReporting');
                  if (ts != null && ts.Status__c) {     
                      OpportunityCustomReprting OpCu = new OpportunityCustomReprting();
                      OpCu.CustomReporting(trigger.newMap, trigger.oldMap);               
                  }
}    
    
    
    //************************************* Set Trigger lock to TRUE   ***************************************************//
              if(!(Trigger.isbefore)) {
                  TriggerHelperClass.setAlreadyfired();              
              }                           
           } 
        }       
    }