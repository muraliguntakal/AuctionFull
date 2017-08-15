trigger VROAssetDetails on BPO__c (Before Insert, Before Update, After Insert) {
 // if(TriggerSettings__c.getValues('VROAssetDetails').Status__c){
  
  TriggerSettings__c ts = TriggerSettings__c.getValues('VROAssetDetails');
  if (ts != null && ts.Status__c) {

     if((Trigger.isupdate || Trigger.isInsert) && Trigger.isBefore){
            for(BPO__c BP : trigger.new){    
                    if(BP.Valuation_AssetId__c != null && BP.Valuation_AssetId__c != '')
                    {
                    BP.Asset__c=BP.Valuation_AssetId__c;
                    }                                  
            }
       }    
       
         if (Trigger.isBefore && Trigger.isInsert) {
            BPOTrigger.insert_DateTimeDue(Trigger.new);  
             BPOTrigger.FindDuplicateCREPhotoOrder(Trigger.new);  
          }
          
          
          if ( Trigger.isBefore && Trigger.isUpdate ) {
            BPOTrigger.updateTurnAroundTime(Trigger.oldMap, Trigger.newMap);
            BPOTrigger.update_CRE_Photo_Vendor_Email(Trigger.oldMap, Trigger.newMap);
            BPOTrigger.update_vendorName_forEmail(Trigger.oldMap, Trigger.newMap);
            BPOTrigger.updateTransactionManagerEmail(Trigger.oldMap, Trigger.newMap);
        
            if ( system.isFuture() == false ) {
              
              // we don't allow future call for estimating distance because this function fires a future function
              // which updates BPO__C, if we allow future call on it, it will be executed again here, then
              // fires future function again, then calls it here again, and on and on... creating an infinite loop
              // on this function.
              BPOTrigger.update_CRE_Photo_Vendor_EstimatedDistance(Trigger.oldMap, Trigger.newMap);
            }
          }
          
          
  }
}