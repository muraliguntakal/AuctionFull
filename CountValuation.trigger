trigger CountValuation on Valuation__c (after insert, after delete) {
   // if(TriggerSettings__c.getValues('CountValuation').Status__c){
    TriggerSettings__c ts = TriggerSettings__c.getValues('CountValuation');
    if (ts != null && ts.Status__c) {

      Set<Id> assetId = new Set<Id>();
      Set<Id> valId = new Set<Id>();
            
      if( trigger.isDelete ) {
             for(Valuation__c oldval: trigger.old)
            {
                if(oldval.Asset__c!=null)
                assetId.add(oldval.Asset__c);
                valId.add(oldval.Id);
            }
        }
        else
        {
            for(Valuation__c newval: Trigger.new)
            {
                assetId.add(newval.Asset__c);
                valId.add(newval.Id);
            }
        }
    
        List<Asset__c> countVal = [SELECT Id,(SELECT Id FROM  Valuations_del__r) FROM Asset__c WHERE Id IN :assetId];
                    
        for(Asset__c asst: countVal)   {                
                List<Valuation__c> relatedRecords = asst.getSObjects('Valuations_del__r');
                if(relatedRecords!=null)
                    asst.Times_Ordered__c= relatedRecords.size();
                 else
                    asst.Times_Ordered__c= 0;                           
        }
                 
     
         update countVal;
         
    }
}