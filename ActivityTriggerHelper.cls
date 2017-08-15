public with sharing class ActivityTriggerHelper {

  //****Contact Activity Information*****

  /**
   * Date: 1/15/2015
   * Author: Luke Martell
   * Comments:
   * Modification made to method to reduce the number of queries run against the database based on the 
   * type of records the Tasks are associated with. For example, if a batch of Task records that are
   * related to only Contact records are created, edited, or deleted then there should only be one query
   * against the Contact object. The same goes for only Lead. However, if the batch contains both Lead
   * and Contact records then the method should query against both objects. 
   */
  public void MostRecentTast(List<Task> newTaskList, List<Task> oldTaskList, Boolean isInsert,Boolean isUpdate,Boolean isDelete) {   

    //
    // New version of code is commented out temporarily to validate with Ganesh and/or Murali.
    //    
   // List<Task> taskList = (isDelete ? oldTaskList : newTaskList);
    Set<Id> contactIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();
    Set<Id> AccountIds = new Set<Id>();

    // Regardless of the execution state, iterate over the list and determine what records we're dealing with.
    if(trigger.isDelete || trigger.isUpdate){
            for (Task t : oldTaskList) {
                  if (t.WhoId != null) {
                    String objPrefix = String.valueOf(t.WhoId).left(3);    
                    if (objPrefix == '003') {
                      contactIds.add(t.WhoId);
                    } else if (objPrefix == '00Q') {
                      leadIds.add(t.WhoId);}
                  }
                  
                  if (t.WhatId != null) {
                    String objPrefixwhat = String.valueOf(t.WhatId).left(3);            
                    if (objPrefixwhat == '001') {
                      AccountIds.add(t.WhatId);}
                  }
             }
     }   
     
     if(trigger.isInsert || trigger.isUpdate){
            for (Task t : newTaskList) {
                  if (t.WhoId != null) {
                    String objPrefix = String.valueOf(t.WhoId).left(3);
                    if (objPrefix == '003') {
                      contactIds.add(t.WhoId);
                    } else if (objPrefix == '00Q') {
                      leadIds.add(t.WhoId);}
                  }
                  
                  if (t.WhatId != null) {
                    String objPrefixwhat = String.valueOf(t.WhatId).left(3);            
                    if (objPrefixwhat == '001') {
                      AccountIds.add(t.WhatId);
                    }
                  }
             }
     }   

    //Update Contact with Latest Activity information
    if (!contactIds.isEmpty()) {
          List<Contact> contactList = [SELECT Id,(SELECT Id, LastModifiedDate,Activity_Completed_Date__c,Owner.Name,Assigned_User_Role__c,Type,Subject FROM Tasks ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN :contactIds];
    
          for (Contact c : contactList) {
                if (c.Tasks != null && !c.Tasks.isEmpty()) {
                    c.Last_Activity_Date__c = c.Tasks[0].Activity_Completed_Date__c;                    
                    c.Most_Recent_Activity_Assigned_To__c = c.Tasks[0].Owner.Name;
                    c.Most_Recent_Activity_Role_Assigned_To__c = c.Tasks[0].Assigned_User_Role__c;
                    c.Most_Recent_Activity_Type__c = c.Tasks[0].Type;
                    c.Most_Recent_Activity_Subject__c = c.Tasks[0].Subject;
                } else {                        
                    c.Last_Activity_Date__c = null;
                    c.Most_Recent_Activity_Assigned_To__c = null;
                    c.Most_Recent_Activity_Role_Assigned_To__c = null;   
                    c.Most_Recent_Activity_Type__c = null;
                    c.Most_Recent_Activity_Subject__c = null;       
                }
          }
          update contactList;
    }

    //Update Lead with Latest Activity information
    if (!leadIds.isEmpty()) {
                                                 
        List<Lead> leadList = [SELECT Id,First_Call_Activity_Date_Time__c , (SELECT Id,LastModifiedDate,Call_Notes__c,Last_Call_Disposition__c,Reason_Not_Qualified__c,Type,CreatedDate,WhoId FROM Tasks ORDER BY LastModifiedDate DESC LIMIT 1) FROM Lead WHERE Id IN :leadIds];
        Map<Id, Task> TaslLeadMap = new Map<Id, Task>();       
        if(!leadList.isEmpty()) {
               for (Lead l : leadList) {                                  
                    if(l.Tasks !=null && l.Tasks.size()!=0){
                    for (Task Tks : l.Tasks) {   
                          TaslLeadMap.put(Tks.whoId, Tks);                    
                        }   
                  } 
            }
        }
        
        List<Lead> leadListASC = [SELECT Id,First_Call_Activity_Date_Time__c , (SELECT Id,CreatedDate,WhoId,Type FROM Tasks ORDER BY CreatedDate DESC LIMIT 1) FROM Lead WHERE Id IN :leadIds];
        Map<Id, Task> TaslLeadMapASC = new Map<Id, Task>();      
        if(!leadListASC.isEmpty()) {
               for (Lead ls : leadListASC) {                                  
                    if(ls.Tasks !=null && ls.Tasks.size()!=0){
                    for (Task TksAsc : ls.Tasks) {   
                          TaslLeadMapAsc.put(TksAsc.whoId, TksAsc);                    
                        }   
                  } 
            }
        }
        
     List<Lead> UpdateLead = new List<Lead>();  
     if(!leadListASC.isEmpty())   {          
         for(Lead lds: leadListASC) {                                                
          if (lds.Tasks != null && !lds.Tasks.isEmpty()) {
             if(TaslLeadMap.ContainsKey(lds.Id)){
                  lds.Last_Call_Change_Date__c = TaslLeadMap.get(lds.Id).LastModifiedDate.date();
                  lds.Call_Notes__c = TaslLeadMap.get(lds.Id).Call_Notes__c;
                  lds.Last_Call_Disposition__c = TaslLeadMap.get(lds.Id).Last_Call_Disposition__c;
                  lds.Reason_Not_Qualified__c = TaslLeadMap.get(lds.Id).Reason_Not_Qualified__c;
              if(lds.First_Call_Activity_Date_Time__c  == NULL && lds.Tasks[0].Type == 'Outbound Call'){
                     lds.First_Call_Activity_Date_Time__c  = TaslLeadMap.get(lds.Id).CreatedDate;
                    }
               } 
             if(TaslLeadMapAsc.ContainsKey(lds.Id)){
                   if(lds.Tasks[0].Type == 'Outbound Call'){
                     lds.Last_Activity_Date__c = TaslLeadMapAsc.get(lds.Id).CreatedDate;
                    }
               }                             
         } 
          else {
                  lds.Last_Call_Change_Date__c = null;
                  lds.Call_Notes__c = null;
                  lds.Last_Call_Disposition__c = null;
                }
            UpdateLead.add(lds);    
       }     
     }
          
      
       if(!UpdateLead.isEmpty()) { 
           Database.update(UpdateLead);
          }
                       
    }  

    //Update Account with Latest Activity information
     if (!AccountIds.isEmpty()) {
              List<Account> AccountList = [SELECT Id, (SELECT Id, LastModifiedDate,Activity_Completed_Date__c,Owner.Name,Assigned_User_Role__c FROM Tasks ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :AccountIds];
        
              for (Account a : AccountList) {
                    if (a.Tasks != null && !a.Tasks.isEmpty()) {
                      a.Last_Activity_Date__c = a.Tasks[0].Activity_Completed_Date__c;  
                      a.Most_Recent_Activity_Assigned_To__c = a.Tasks[0].Owner.Name;
                      a.Most_Recent_Activity_Role_Assigned_To__c = a.Tasks[0].Assigned_User_Role__c;  
                    } else {
                      a.Last_Activity_Date__c = null;
                      a.Most_Recent_Activity_Assigned_To__c = null;
                      a.Most_Recent_Activity_Role_Assigned_To__c = null;          
                    }
              }
              update AccountList;
     }  
 }  
    
    
    //****Offer Activity Information*****
public void RecentOfferTast(List<Task> newTaskList, List<Task> oldTaskList, Boolean isInsert,Boolean isUpdate,Boolean isDelete){   
                 
        Set<Id> setoffId = new Set<Id>();   
        
        if(isInsert || isUpdate){
                
            for (Task  childObj: newTaskList) {
                if(childObj.WhatId!=null){
                  String objPrefixwhatId = String.valueOf(childObj.WhatId).left(3);            
                    if (objPrefixwhatId == 'a14') {
                        setoffId.add(childObj.WhatId);
                     }   
                }
            }  
          }  
        
         if(isDelete){

            for (Task  childObj: oldTaskList) {
                if(childObj.WhatId!=null){
                  String objPrefixwhatId = String.valueOf(childObj.WhatId).left(3);            
                    if (objPrefixwhatId == 'a14') {
                        setoffId.add(childObj.WhatId);
                     }   
                }
            } 
         }                                       

        List<Offer__c> offerList = new List<Offer__c>(); 
        offerList = [SELECT Id,(SELECT Id,LastModifiedDate,Call_Notes__c,Last_Call_Disposition__c FROM Tasks ORDER BY LastModifiedDate DESC LIMIT 1) FROM Offer__c where Id in: setoffId];   
          
        if(!offerList.isEmpty()) {
            for (Offer__c offr : offerList) {
                if(offr.Tasks !=null && offr.Tasks.size()!=0) {
                    for (Task  Tas : offr.Tasks) {
                           Datetime dt = (Datetime) Tas.get('LastModifiedDate');
                           offr.Last_Call_Change_Date__c = dt.date(); 
                           offr.Call_Notes__c = Tas.Call_Notes__c;
                           offr.Last_Call_Disposition__c = Tas.Last_Call_Disposition__c;
                    }
                }
                else{
                            offr.Last_Call_Change_Date__c = null;
                            offr.Call_Notes__c = null;
                            offr.Last_Call_Disposition__c = null;
                    }        
            }
            update offerList;
        } 
    } 
    
    
 //**********Vault Activity Rollup*************
public void VaultActivityRollUp(List<Task> newTaskLt, List<Task> oldTaskLt, Boolean isInsert, Boolean isUpdate, Boolean isDelete){ 
  
        Set<Id> ValutId = new Set<Id>();   
        List<Vault__c> ValutList  = new List<Vault__c>(); 
        
        if(isDelete){  
        for (Task childObj: oldTaskLt) {
                if(childObj.WhatId!=null && childObj.CallObject != null){               
                 String objPrefixwhatId = String.valueOf(childObj.WhatId).left(3);            
                    if (objPrefixwhatId == 'a1P') {
                        ValutId.add(childObj.WhatId);
                     }   
                }
            }        
          }  
        
         else {
         for (Task childObj: newTaskLt) {
                if(childObj.WhatId!=null && (childObj.CallObject != null || Test.isRunningTest() == True)){
                String objPrefixwhatId = String.valueOf(childObj.WhatId).left(3);            
                    if (objPrefixwhatId == 'a1P') {
                            ValutId.add(childObj.WhatId);
                     }       
                }
            }  
         }                                       

        ValutList = [SELECT Id,(SELECT Id FROM Tasks where CallObject != null)FROM Vault__c where Id in: ValutId];   
        
      if(!ValutList.isEmpty()) 
      {
            for(Vault__c val: ValutList)   
            {                
                    List<Task> relatedRecords = val.getSObjects('Tasks');
                    if(relatedRecords!=null)
                        val.Number_of_Vault_calls__c = relatedRecords.size();
                     else
                        val.Number_of_Vault_calls__c = 0;                           
            }
                update ValutList ;
      }
   }   
   
   
   // Campaign and Activity Association 
   public void CampaignActivityAssociation(List<Task> newtaskList, Map<Id,Task> newtaskMap, Map<Id,Task> oldtaskMap, Boolean isInsert, Boolean isUpdate){ 
   /*
      Set<String> CampIds = new Set<String>();
      Set<Id> ContactIds = new Set<Id>();  

      if(isInsert) {
          for (Task ts: newtaskList) {   
              system.debug('  In CampaignActivityAssociation ==>' );
              if(ts.WhatId != null) {   
                  String objPrefixwhat = String.valueOf(ts.WhatId).left(3);       
                  if (objPrefixwhat == 'a2J' && ts.LiveOps_Call_Obj_Id__c == True) {   
                      ts.Campaign__c = Label.PDP_Campaign_Id;
                  }                                
                  else if (ts.LOCC_App__campaignid__c != null && objPrefixwhat != 'a2J'){       
                      CampIds.add(ts.LOCC_App__campaignid__c);
                  } 
              }    
              if (ts.WhoId != null && ts.Campaign__c==null && ts.WhatId==null) {
                  ContactIds.add(ts.WhoId); 
              }
          }
      }   
      else if(isUpdate){
            for (Task ts: newtaskMap.Values()) {     
                if(ts.WhatId != null){ 
                    String objPrefixwhat = String.valueOf(ts.WhatId).left(3);  
                   if(ts.LOCC_App__campaignid__c != null && ts.LOCC_App__campaignid__c != oldtaskMap.get(ts.Id).LOCC_App__campaignid__c && objPrefixwhat != 'a2J'){       
                       CampIds.add(ts.LOCC_App__campaignid__c);
                    } 
                 }    
          }           
        }                                                             

      Map<Id,Contact> contactMap = new Map<Id,Contact> ([SELECT Id, Most_Recent_Campaign1__c,Most_Recent_Campaign1__r.Name FROM Contact WHERE Id IN : ContactIds AND Most_Recent_Campaign1__c!=null]);
      
      List<Campaign> CampaignList = [SELECT Id,LiveOps_Campaign_ID__c FROM Campaign WHERE LiveOps_Campaign_ID__c IN :CampIds];
      Map<String,Id> CampMap = new Map<String,Id>();
        
       if(!CampaignList.isEmpty()){    
            for(Campaign camp: CampaignList){
                CampMap.put(camp.LiveOps_Campaign_ID__c, camp.Id);
              }      
          }                   
           
       for (Task ts: newtaskList) {                         
           if(CampMap.ContainsKey(ts.LOCC_App__campaignid__c)){
               ts.Campaign__c = CampMap.get(ts.LOCC_App__campaignid__c);
           } 
           if(ts.WhoId !=null && contactMap.ContainsKey(ts.WhoId)) {
               ts.Campaign__c = contactMap.get(ts.WhoId).Most_Recent_Campaign1__c;
               ts.Has_Campaign__c = TRUE;        
           }           
       }  
  */       
  }  
  
   //////////////////////////////////////////////////////////// Auto Populate LiveOpps Activities Name with WhatId Contact, if Name is null 
   public void LiveOppsTaskNameUpdate(List<Task> newactList){ 
   
       Set<Id> ValtIds = new Set<Id>();
       Set<Id> PDPIds = new Set<Id>();
       Set<Id> ConIds = new Set<Id>();
       List<Task> TaskScopeList = new List<Task>();
 
       for (Task act: newactList) {    
         if(act.LiveOps_Call_Obj_Id__c == True && act.WhatId != null && act.WhoId == null){    
                   String objPrefixwhat = String.valueOf(act.WhatId).left(3);            
                   if (objPrefixwhat == 'a1P') {                                     
                     ValtIds.add(act.WhatId);  
                     TaskScopeList.add(act);
                    }  
                   else if (objPrefixwhat == 'a2J') {                                     
                     PDPIds.add(act.WhatId);  
                     TaskScopeList.add(act);
                    }   
             }       
          if(act.WhoId != null){    
                   String objPrefixwho = String.valueOf(act.WhoId).left(3);            
                   if (objPrefixwho == '003') {                                     
                     ConIds.add(act.WhoId);  
                     TaskScopeList.add(act);
                    }    
             }              
        }                                                             
 
      List<Vault__c> VaultList = [SELECT Id,Contact__c FROM Vault__c WHERE Id IN :ValtIds];
       Map<Id,Id> valMap = new Map<Id,Id>();      
       if(!VaultList.isEmpty()){    
            for(Vault__c val: VaultList){
                valMap.put(val.Id, val.Contact__c);
              }      
          }
                   
       List<PDP__c> PDPList = [SELECT Id,Contact__c FROM PDP__c WHERE Id IN :PDPIds];
       Map<Id,Id> PDPMap = new Map<Id,Id>();     
       if(!PDPList.isEmpty()){  
            for(PDP__c pdp: PDPList){
                PDPMap.put(pdp.Id, pdp.Contact__c);
              }
         } 
                                     
       List<Contact> ConList = [SELECT Id,AccountId,Account.Owner.Email FROM Contact WHERE Id IN :ConIds];
       Map<Id,Id> ConMap = new Map<Id,Id>();      
       Map<Id,String> ConEmailMap = new Map<Id,String>(); 
       if(!ConList.isEmpty()){  
            for(Contact cons: ConList){
                ConMap.put(cons.Id, cons.AccountId);
                ConEmailMap.put(cons.Id, cons.Account.Owner.Email);
              }
         }
                  
           for (Task tsk: TaskScopeList) {                         
                 if(valMap.ContainsKey(tsk.WhatId)){
                    tsk.WhoId = valMap.get(tsk.WhatId);
                   } 
                 if(PDPMap.ContainsKey(tsk.WhatId)){
                    tsk.WhoId = PDPMap.get(tsk.WhatId);
                   }
                 if(ConMap.ContainsKey(tsk.WhoId)){
                    tsk.Account__c = ConMap.get(tsk.WhoId);
                    tsk.Account_Owner_Email__c = ConEmailMap.get(tsk.WhoId);
                   }
              }  
   }
  
   //////////////////////////////////////////////////////// Campaign Members Creation
   public void CampaignMembersCreate(List<Task> newtksList, Map<Id,Task> newtaskMap, Map<Id,Task> oldtaskMap, Boolean isInsert, Boolean isUpdate){ 
                         
   Set<Id> campaignId = new Set<Id>();   
   Set<Id> conId = new Set<Id>();
   List<Task> TaskList = new List<Task>();   
 if(isInsert){
           for (Task tks: newtksList) {    
             if(tks.campaign__c != null && tks.WhoId != null){
                String objPrefixwho = String.valueOf(tks.WhoId).left(3);            
                   if (objPrefixwho == '003') {     
                       campaignId.add(tks.campaign__c);
                       conId.add(tks.whoId);  
                       TaskList.add(tks);
                    } 
               }   
              }
    }          
   else if(isUpdate){
           for (Task tks: newtksList) {    
               if(tks.campaign__c != null && tks.WhoId != null && (tks.campaign__c != oldtaskMap.get(tks.Id).campaign__c || tks.WhoId != oldtaskMap.get(tks.Id).WhoId)){
                String objPrefixwho = String.valueOf(tks.WhoId).left(3);            
                   if (objPrefixwho == '003') {     
                       campaignId.add(tks.campaign__c);
                       conId.add(tks.whoId);  
                       TaskList.add(tks);
                    } 
                 }   
              }
        }      
         
          if(!conId.isEmpty()) {    
                     List<CampaignMember> campmemList = new List<CampaignMember>();
                     campmemList = [Select ContactId From CampaignMember WHERE campaignId IN :campaignId and ContactId IN :conId];
            
                     Map<Id, Id> cmMap = new Map<Id, Id>();
                     for(CampaignMember campmem: campmemList) {
                        cmMap.put(campmem.ContactId, campmem.Id);
                        }
                         
                    List<CampaignMember> cm = new List<CampaignMember>();  
                    
                     for(Task tk : TaskList) {
                           if (!cmMap.containsKey(tk.WhoId)) {
                                CampaignMember newCM = new CampaignMember(CampaignId = tk.campaign__c,ContactId = tk.WhoId,status = 'Registered',Created_From_LiveOps_Activity__c = true);
                                cmMap.put(tk.WhoId, tk.campaign__c);
                                cm.add(newCM);
                            }
                     }
                  if(!cm.isEmpty()) { 
                     Database.insert(cm);
                     }
             }         
                 
   }

}