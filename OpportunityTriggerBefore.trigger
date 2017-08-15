trigger OpportunityTriggerBefore on Opportunity (before insert) {
      TriggerSettings__c ts = TriggerSettings__c.getValues('OpportunityTriggerBefore');
      if (ts != null && ts.Status__c) {

        Set<Id> ParentOppId= new Set<Id>();
        
        for(Opportunity opp : trigger.new) {                                    
                opp.Latest_Opportunity__c = true;  
                if(opp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && opp.StageName == 'Stage 5. Auction') {                                        
                    opp.StageName  = Label.Opportunity_Stage3;         
                }
                opp.Unique_Asset_Field_new__c = opp.Property_Street__c + ' ' + opp.Property_Zip_Postal_Code__c ;
                
                if(opp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && opp.Parent_Opportunity__c != null){                 
                     ParentOppId.add(opp.Parent_Opportunity__c);                         
                }
            }
            
            List<Opportunity> ParentOpps = new List<Opportunity>();
            ParentOpps = [Select Id,OwnerId,Owner.Full_Name__c,Owner.Email From Opportunity Where Id In :ParentOppId];           
            
            Map<Id,String> ParentOppMap = new Map<Id,String>();
            Map<Id,String> ParentOppEmailMap = new Map<Id,String>();
            Map<Id,Id> ParentOppOwner = new Map<Id,Id>();
            for(Opportunity Parentopp : ParentOpps) {  
              ParentOppMap.put(Parentopp.Id,Parentopp.Owner.Full_Name__c);       
              ParentOppEmailMap.put(Parentopp.Id,Parentopp.Owner.Email);     
              ParentOppOwner.put(Parentopp.Id,Parentopp.OwnerId);  
            }           
                        
             for(Opportunity opp : trigger.new) {    
                   if(ParentOppMap.containsKey(opp.Parent_Opportunity__c)) {
                      opp.Parent_Opportunity_Owner__c = ParentOppMap.get(opp.Parent_Opportunity__c);
                    }  
                   if(ParentOppEmailMap.containsKey(opp.Parent_Opportunity__c)) {
                      opp.Parent_Opportunity_Owner_Email__c = ParentOppEmailMap.get(opp.Parent_Opportunity__c);
                    } 
                   if(ParentOppEmailMap.containsKey(opp.Parent_Opportunity__c)) {
                      opp.Parent_Opportunity_User__c = ParentOppOwner.get(opp.Parent_Opportunity__c);
                    } 
             }   
}
}