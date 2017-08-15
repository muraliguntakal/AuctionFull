trigger AssignLeadOwner_Velocify on Lead ( after insert, before update ) { 
     //TriggerSettings__c is Custom Setting for setting trigger Active/Inactive
     if(TriggerSettings__c.getValues('AssignLeadOwner_Velocify').Status__c) {       
         // 28-Jan-14 - Murali Guntakal  - Future call to set DML Options for Auto Lead Assignments, Auto Response and User Emails   
         LeadTriggerHandler lth = new LeadTriggerHandler();
         if(Trigger.isInsert && Trigger.isAfter) {
             lth.AddLeadsToCampaign(Trigger.New);
             LeadTriggerHandler.setLeadDMLOptions(Trigger.newMap.Keyset());
         }
     }
}