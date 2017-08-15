trigger leadOwnerUpdate on lead (after update) {
    List<lead> updateCS = new List<lead>();
    Map<Id,lead> leads = new Map<Id,lead>();
    
    for (lead cs : Trigger.new)
    {
        if(Trigger.isUpdate) {  
            System.debug('>>>>> Owner ID: '+cs.ownerId+' Temp Owner ID: '+cs.TempOwnerId__c);
            if(cs.TempOwnerId__c <> null && cs.TempOwnerId__c <> '') {
                if(cs.OwnerId <> cs.TempOwnerId__c) {
                    leads.put(cs.id,cs);
                }
            }           
        }   
    }
    if (leads.isEmpty()) return;
    
    for (lead cs : [SELECT OwnerId,TempOwnerId__c FROM lead WHERE id in :leads.keySet()]) {
        cs.OwnerId = leads.get(cs.Id).TempOwnerId__c;
        cs.TempOwnerId__c = 'SKIP'; //flag to stop infinite loop upon update
        updateCS.add(cs);
    }
    System.debug('>>>>>Update leads: '+updateCS);
    
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