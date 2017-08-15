trigger vaultOwnerUpdate on Vault__c (after update) {
    List<Vault__c> updateCS = new List<Vault__c>();
    Map<Id,Vault__c> cases = new Map<Id,Vault__c>();
    
    for (Vault__c cs : Trigger.new)
    {
        if(Trigger.isUpdate) {  
            System.debug('>>>>> Owner ID: '+cs.ownerId+' Temp Owner ID: '+cs.TempOwnerId__c);
            if(cs.TempOwnerId__c <> null && cs.TempOwnerId__c <> '') {
                if(cs.OwnerId <> cs.TempOwnerId__c) {
                    cases.put(cs.id,cs);
                }
            }           
        }   
    }
    if (cases.isEmpty()) return;
    
    for (Vault__c cs : [SELECT OwnerId,TempOwnerId__c FROM Vault__c WHERE id in :cases.keySet()]) {
        cs.OwnerId = cases.get(cs.Id).TempOwnerId__c;
        cs.TempOwnerId__c = 'SKIP'; //flag to stop infinite loop upon update
        updateCS.add(cs);
    }
    System.debug('>>>>>Update Vauls: '+updateCS);
    
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