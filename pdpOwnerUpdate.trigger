trigger pdpOwnerUpdate on pdp__c (after update) {
    List<pdp__c> updateCS = new List<pdp__c>();
    Map<Id,pdp__c> pdps = new Map<Id,pdp__c>();
    
    for (pdp__c cs : Trigger.new)
    {
        if(Trigger.isUpdate) {  
            System.debug('>>>>> Owner ID: '+cs.ownerId+' Temp Owner ID: '+cs.TempOwnerId__c);
            if(cs.TempOwnerId__c <> null && cs.TempOwnerId__c <> '') {
                if(cs.OwnerId <> cs.TempOwnerId__c) {
                    pdps.put(cs.id,cs);
                }
            }           
        }   
    }
    if (pdps.isEmpty()) return;
    
    for (pdp__c cs : [SELECT OwnerId,TempOwnerId__c FROM pdp__c WHERE id in :pdps.keySet()]) {
        cs.OwnerId = pdps.get(cs.Id).TempOwnerId__c;
        cs.TempOwnerId__c = 'SKIP'; //flag to stop infinite loop upon update
        updateCS.add(cs);
    }

    
    //
    //Update last assignment for Assignment Group in batch
    //
    if (updateCS.size()>0) {
        try {
            update updateCS;
        } catch (Exception e){

        }
    }
}