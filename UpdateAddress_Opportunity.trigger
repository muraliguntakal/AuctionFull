trigger UpdateAddress_Opportunity on Asset__c (after update) {
  //if(TriggerSettings__c.getValues('UpdateAddress_Opportunity').Status__c) {       
    TriggerSettings__c ts = TriggerSettings__c.getValues('UpdateAddress_Opportunity');
    if (ts != null && ts.Status__c) {
    
        List<opportunity> OppList = new List<opportunity>();
        OppList = [SELECT Id,RecordTypeId,Asset__c,Property_Street__c,Property_City__c,Property_State__c,Property_Zip_Postal_Code__c,
                          Occupancy__c,Square_Feet__c,Bedrooms__c,Baths__c,Property_Type__c
                   FROM Opportunity
                   WHERE Asset__c IN :Trigger.newMap.keyset()];

        List<opportunity> updateOppList = new List<opportunity>();
        if(trigger.isupdate){
            for(opportunity opp :OppList) {              
                if(opp.RecordTypeId != Label.Opportunity_Record_TypeId_Trustee && opp.RecordTypeId != Opportunity_Product_Type_Mapping__c.getValues('Commercial').RecordTypeId__c) {
                    if( opp.Property_Street__c          != Trigger.newMap.get(opp.Asset__c).Property_Street__c || 
                        opp.Property_City__c            != Trigger.newMap.get(opp.Asset__c).Property_City__c  ||
                        opp.Property_State__c           != Trigger.newMap.get(opp.Asset__c).Property_State__c ||
                        opp.Property_Zip_Postal_Code__c != Trigger.newMap.get(opp.Asset__c).Property_Zip_Postal_Code__c  ||  
                        opp.Occupancy__c                != Trigger.newMap.get(opp.Asset__c).Occupancy_Status__c  ||
                        opp.Square_Feet__c              != Trigger.newMap.get(opp.Asset__c).Home_Square_Footage__c  ||
                        opp.Bedrooms__c                 != Trigger.newMap.get(opp.Asset__c).Bedrooms__c  ||
                        opp.Baths__c                    != Trigger.newMap.get(opp.Asset__c).Baths__c  ||
                        opp.Property_Type__c            != Trigger.newMap.get(opp.Asset__c).Property_Type__c)    {                                
                     
                             opp.Property_Street__c          = Trigger.newMap.get(opp.Asset__c).Property_Street__c;
                             opp.Property_City__c            = Trigger.newMap.get(opp.Asset__c).Property_City__c;
                             opp.Property_State__c           = Trigger.newMap.get(opp.Asset__c).Property_State__c;
                             opp.Property_Zip_Postal_Code__c = Trigger.newMap.get(opp.Asset__c).Property_Zip_Postal_Code__c;  
                             opp.Occupancy__c                = Trigger.newMap.get(opp.Asset__c).Occupancy_Status__c; 
                             opp.Square_Feet__c              = Trigger.newMap.get(opp.Asset__c).Home_Square_Footage__c;
                             opp.Bedrooms__c                 = Trigger.newMap.get(opp.Asset__c).Bedrooms__c;
                             opp.Baths__c                    = Trigger.newMap.get(opp.Asset__c).Baths__c;
                             opp.Property_Type__c            = Trigger.newMap.get(opp.Asset__c).Property_Type__c;  
                                                               
                             updateOppList.add(opp); 
                     } 
                }     
            }
        }
        if(updateOppList.size()>0)
            update updateOppList;
    }
}