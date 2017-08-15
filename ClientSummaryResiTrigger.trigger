trigger ClientSummaryResiTrigger on Client_Summary_Resi__c (after insert, after update) {

    if(TriggerSettings__c.getValues('ClientSummaryResiTrigger').Status__c){
       ClientSummaryHandler.ProcessSummaryFlags(trigger.new);  
    }
}