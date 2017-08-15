trigger AssetBeforeupdate on Asset__c (before update) {
//if(TriggerSettings__c.getValues('AssetBeforeupdate').Status__c) {  
  TriggerSettings__c ts = TriggerSettings__c.getValues('AssetBeforeupdate');
  if (ts != null && ts.Status__c) {

  for(Asset__c ass:Trigger.new){
    if(ass.Most_Recent_AOA__c != null && Trigger.oldMap.get(ass.Id).Most_Recent_AOA__c == null && ass.Initial_AOA__c == null) {
      ass.Initial_AOA__c = ass.Most_Recent_AOA__c;
     }
  }
 } 
}