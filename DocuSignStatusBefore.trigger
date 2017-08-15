trigger DocuSignStatusBefore on dsfs__DocuSign_Status__c (before insert, before update) {
 //if(TriggerSettings__c.getValues('DocuSignStatusBefore').Status__c) { 
   TriggerSettings__c ts = TriggerSettings__c.getValues('DocuSignStatusBefore');
   if (ts != null && ts.Status__c) {

    set<String> dsEnvolopeStatus = new Set<String>();
   
        for(dsfs__DocuSign_Status__c ds: Trigger.new) {
            if(ds.dsfs__DocuSign_Envelope_ID__c!=null) {    
                dsEnvolopeStatus.add(ds.dsfs__DocuSign_Envelope_ID__c);                   
            }
          }
         system.debug('dsEnvolopeStatus '+dsEnvolopeStatus);
        List<dsfs__DocuSign_Envelope__c> envList = new List<dsfs__DocuSign_Envelope__c>();       
        envList = [SELECT Id,dsfs__DocuSign_Envelope_ID__c,Conga_Template_Name__c FROM dsfs__DocuSign_Envelope__c WHERE dsfs__DocuSign_Envelope_ID__c IN :dsEnvolopeStatus];
       system.debug('envList'+envList);
        map<String, String> dsEnvolpemap = new map<String, String>(); 
        for(dsfs__DocuSign_Envelope__c de : envList) {
            if(de.dsfs__DocuSign_Envelope_ID__c!=null)
                dsEnvolpemap.put(de.dsfs__DocuSign_Envelope_ID__c,de.Conga_Template_Name__c);
        }
        system.debug('dsEnvolpemap '+dsEnvolpemap);
        for(dsfs__DocuSign_Status__c ds: Trigger.new) {
           if(ds.dsfs__DocuSign_Envelope_ID__c!=null) { 
            if(dsEnvolpemap.get(ds.dsfs__DocuSign_Envelope_ID__c.toLowerCase())!=null){
                ds.Document_Name__c = dsEnvolpemap.get(ds.dsfs__DocuSign_Envelope_ID__c.toLowerCase()); 
            }
           } 
        } 
 }
}