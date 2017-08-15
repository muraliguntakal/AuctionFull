trigger AssetOppJunctionTrigger on AssetOppJunction__c (before insert,before update,after insert,after update) {

    TriggerSettings__c ts = TriggerSettings__c.getValues('AssetOppJunctionTrigger');
    if (ts != null && ts.Status__c) {

        AOJTriggerHelper AOJClass = new AOJTriggerHelper();      
        
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){ 
            AOJClass.Create_Assets(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
          } 

        if(Trigger.isInsert && Trigger.isafter){ 
            AOJClass.Create_Valuation(Trigger.new);
            } 

        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){ 
            AOJClass.AutopopulateListingBroker(Trigger.new, Trigger.newMap, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
        } 
         

           if(Trigger.isUpdate && Trigger.isafter){
//************************************* Check Trigger Lock is FALSE ***************************************************// 
        if (!AOJTriggerHelperClass.hasAlreadyfiredAOJ()) {  
        
               set<id> setOFAssOppJunID= new set<Id>();
                 for (AssetOppJunction__c inks : Trigger.new) {
                 
                    if((inks.Auction_Approval_Status__c != Trigger.oldMap.get(inks.Id).Auction_Approval_Status__c && inks.Auction_Approval_Status__c == 'Approved') || 
                       (inks.CAMP_Resubmit_Asset__c != Trigger.oldMap.get(inks.Id).CAMP_Resubmit_Asset__c && inks.CAMP_Resubmit_Asset__c == True)){
                           setOFAssOppJunID.add(inks.id);
                      }
                }
                
                        if(!system.isFuture() && setOFAssOppJunID.size() >0 )
                        {                 
                            CampWebServiceCallout.sendNotification(setOFAssOppJunID);
                        } 
                        
                // AOJClass.Create_VRO(Trigger.newMap,Trigger.oldMap);
                AOJClass.UpdatePhotoOrder(Trigger.newMap,Trigger.oldMap);
                AOJClass.UpdateParentOppStage(Trigger.newMap,Trigger.oldMap);
               // AOJClass.UpdateParentOppSubmitted(Trigger.newMap,Trigger.oldMap);
                

            } 

//************************************* Set Trigger lock to TRUE ***************************************************//
           AOJTriggerHelperClass.setAlreadyfiredAOJ(); 
        }  
        
        //System.debug(logginglEvel.ERROR, 'inside the trigger');
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){ 
        
            // Make sure the trigger has not already been fired. 
            System.debug('intake already fired? ' + IntakeSubmissionTriggerHelperClass.hasAlreadyfired());
            if (!IntakeSubmissionTriggerHelperClass.hasAlreadyfired()) { 
                System.debug(loggingLevel.ERROR, 'creating new intake submission trigger class');
                IntakeSubmissionTrigger intakeSubmissionTrigger = new IntakeSubmissionTrigger(trigger.New);
                intakeSubmissionTrigger.setTriggerMaps(Trigger.oldMap, Trigger.newMap);
                intakeSubmissionTrigger.setIsInsert(trigger.isInsert);
                intakeSubmissionTrigger.createValueReserve();          
            }
        
            // Set the flag that shows the trigger has lready been fired. 
            IntakeSubmissionTriggerHelperClass.setAlreadyfired(); 
        
        
        }
   } 

}