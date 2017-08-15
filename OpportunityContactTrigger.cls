public with sharing class OpportunityContactTrigger {
    
    public static Boolean isTriggerUpdate = false;

    public void UpdateOpportunityInfo(Map<Id, Opportunity> newOpportunities, Map<Id,Opportunity> oldOpportunities, Boolean isInsert) {
        
        List<OpportunityContactRole> newContactRoleList=new List<OpportunityContactRole>();
        List<OpportunityContactRole> oldContactRoleList=new List<OpportunityContactRole>();
        Set<Id> oldOppIds=new Set<Id>();
        Set<Id> oldContactIds = new Set<Id>();
        Set<Id> newContactIds = new Set<Id>();
        
        try {
            if (newOpportunities != null) {           
                // Getting opportunities
                for(Opportunity oppObj : newOpportunities.values()) {
                    //Broker/Agent
                    if (isInsert || oppObj.Broker_Agent__c != oldOpportunities.get(oppObj.Id).Broker_Agent__c || oppObj.Primary_Contact__c != oldOpportunities.get(oppObj.Id).Primary_Contact__c) {                                         
                        //Getting the contact and oppty Id from old values and adding this in set     
                        if ((!isInsert) &&( (oldOpportunities != null && oldOpportunities.get(oppObj.Id) != null) || (oppObj.Primary_Contact__c != oldOpportunities.get(oppObj.Id).Primary_Contact__c)))  {    
                            Opportunity OldOppObj=oldOpportunities.get(oppObj.Id);
                            if (oldOppObj != null) {    
                                if (!oldOppIds.Contains(OldoppObj.id)) oldOppIds.add(OldoppObj.Id);
                                if (OldoppObj.Broker_Agent__c != null) 
                                    oldContactIds.add(OldoppObj.Broker_Agent__c);
                            }
                        }
                        if (oppObj.Broker_Agent__c != null) {                           
                            //Creating new contact role
                            oldContactIds.add(oppObj.Broker_Agent__c);
                            newContactIds.add(oppObj.Broker_Agent__c);
                            newContactRoleList.add(new OpportunityContactRole (ContactId=oppObj.Broker_Agent__c, OpportunityId=oppObj.Id, Role='Broker/Agent', IsPrimary = (oppObj.Primary_Contact__c == 'Broker/Agent')));
                        }
                    }                    
                    
                    // Seller
                    if (isInsert || oppObj.Seller__c != oldOpportunities.get(oppObj.Id).Seller__c || oppObj.Primary_Contact__c != oldOpportunities.get(oppObj.Id).Primary_Contact__c) {                                          
                        //Getting the contact and oppty Id from old values and adding this in set 
                        if ((!isInsert) && ((oldOpportunities != null && oldOpportunities.get(oppObj.Id) != null) || (oppObj.Primary_Contact__c != oldOpportunities.get(oppObj.Id).Primary_Contact__c))) {                      
                            Opportunity OldOppObj=oldOpportunities.get(oppObj.Id);  
                            if (oldOppObj != null) {     
                                if (!oldOppIds.Contains(OldoppObj.id)) oldOppIds.add(OldoppObj.Id);
                                if (OldoppObj.Seller__c != null) 
                                    oldContactIds.add(OldoppObj.Seller__c);
                            }
                        }
                        
                        if (oppObj.Seller__c != null) {
                            //Creating new contact role
                            oldContactIds.add(oppObj.Seller__c);
                            newContactIds.add(oppObj.Seller__c);
                            newContactRoleList.add(new OpportunityContactRole (ContactId=oppObj.Seller__c, OpportunityId=oppObj.Id, Role='Seller', IsPrimary = (oppObj.Primary_Contact__c == 'Seller')));
                        }
                    }     
                    // Reffering Broker
                    if (isInsert || oppObj.Referring_Broker_Name__c != oldOpportunities.get(oppObj.Id).Referring_Broker_Name__c || oppObj.Primary_Contact__c != oldOpportunities.get(oppObj.Id).Primary_Contact__c) {                                          
                        //Getting the contact and oppty Id from old values and adding this in set 
                        if ((!isInsert) && ((oldOpportunities != null && oldOpportunities.get(oppObj.Id) != null) || (oppObj.Primary_Contact__c != oldOpportunities.get(oppObj.Id).Primary_Contact__c))) {                      
                            Opportunity OldOppObj=oldOpportunities.get(oppObj.Id);  
                            if (oldOppObj != null) {     
                                if (!oldOppIds.Contains(OldoppObj.id)) oldOppIds.add(OldoppObj.Id);
                                if (OldoppObj.Referring_Broker_Name__c != null) 
                                    oldContactIds.add(OldoppObj.Referring_Broker_Name__c);
                            }
                        }
                        
                        if (oppObj.Referring_Broker_Name__c != null) {
                            //Creating new contact role
                            oldContactIds.add(oppObj.Referring_Broker_Name__c);
                            newContactIds.add(oppObj.Referring_Broker_Name__c);
                            newContactRoleList.add(new OpportunityContactRole (ContactId=oppObj.Referring_Broker_Name__c, OpportunityId=oppObj.Id, Role='Referring Broker', IsPrimary = (oppObj.Primary_Contact__c == 'Referring Broker')));
                        }
                    }            
                }
    
                // Selecting old contact roles
                if (oldOppIds.size()>0) oldContactRoleList=[Select Id from OpportunityContactRole where ContactId =: oldContactIds  and OpportunityId in : oldOppIds];
                if (isInsert) oldContactRoleList=[Select Id from OpportunityContactRole where OpportunityId in : newOpportunities.KeySet()];           
               
                //Deleting old contact roles
                if (oldContactRoleList.size()>0) delete oldContactRoleList;
                
                //inserting new Contact Roles
                if(newContactRoleList.size() >0) insert newContactRoleList;
                
                //updating the email field
                Map<Id, Contact> contactsList = new Map<Id, Contact>([Select Id, Email from Contact where Id =: newContactIds ]);
                
                List<Opportunity> oppToUpdate = new List<Opportunity>();
                
                if (isInsert)
                    newOpportunities = new Map<Id, Opportunity>([select Id, Seller_Email__c, Seller__c, Broker_Agent__c, Broker_Agent_Email__c from Opportunity where Id = : newOpportunities.KeySet()]);
                               
                for(Opportunity oppObj: newOpportunities.values()) {
                    Boolean oppChanged = false;
                    if (oppObj.Seller__c != null && contactsList.get(oppObj.Seller__c) != null) {
                        if (contactsList.get(oppObj.Seller__c) != null) {
                            //oppObj.Seller_Email__c = contactsList.get(oppObj.Seller__c).Email == null ? '' : contactsList.get(oppObj.Seller__c).Email;
                            oppChanged = true;
                        }
                    }
                        
                    if (oppObj.Broker_Agent__c != null && contactsList.get(oppObj.Broker_Agent__c) != null) {
                        if (contactsList.get(oppObj.Seller__c) != null) {
                            //oppObj.Seller_Email__c = contactsList.get(oppObj.Seller__c).Email == null ? '' : contactsList.get(oppObj.Seller__c).Email;
                            oppChanged = true;
                        }
                    }
                    
                    if (oppChanged && isInsert) oppToUpdate.add(oppObj); 
                }
                
                if(oppToUpdate.size() > 0) {
                    isTriggerUpdate = true;
                    update oppToUpdate;
                    isTriggerUpdate = false;
                }
               
            }
                
        } catch(Exception e) {
            System.debug(e);
            trigger.new[0].addError('Technical error occurred. Please contact to your system administrator or try after some time.');
        }
       
    }
}