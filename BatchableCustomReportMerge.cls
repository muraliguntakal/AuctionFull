//*******************************************************************************************************************//
// Change Log                                                                                                       *// 
// Version 1.0 - Update Custom Reporting MergeBatch  *//
// Version ?.? -                                                                                                    *//
// Created By: Ganesh Vinnakota                                                                                    *//
// Test Class :                                                                    *//
//*******************************************************************************************************************//
global class BatchableCustomReportMerge  implements Database.Batchable<sObject>, Database.AllowsCallOuts, Database.Stateful {
    global   String  query;
   
    //  ---------------------------------------------------------------------
    //  CONSTRUCTOR
    //  ---------------------------------------------------------------------
    global BatchableCustomReportMerge() {

             query = 'SELECT Id,Intake_Submission_Form__c,Auction_Id_and_Global_Property_ID__c,SF_Auction_ID__c,SF_Global_Property_ID__c FROM Custom_Reporting__c WHERE User_Created_AOA__c != True AND SF_Auction_ID__c != null AND SF_Global_Property_ID__c  != null AND  RecordTypeId = \''+Label.AOA_Custom_Reporting+'\'';    
                  
     if(Test.isRunningTest()) { 
            query = 'SELECT Id,Intake_Submission_Form__c,Auction_Id_and_Global_Property_ID__c,SF_Auction_ID__c,SF_Global_Property_ID__c FROM Custom_Reporting__c WHERE User_Created_AOA__c != True AND SF_Auction_ID__c != null AND SF_Global_Property_ID__c  != null AND  RecordTypeId = \''+Label.AOA_Custom_Reporting+'\' LIMIT 25';
        }  
        
    }
    
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: start
    //  ---------------------------------------------------------------------
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
   
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: execute 
    //  ---------------------------------------------------------------------
    global void execute(Database.BatchableContext bc, List<sObject> scope) {         
                         
       Map<String, Custom_Reporting__c> CRInkMap = new Map<String, Custom_Reporting__c>();
 
       for (SObject s: scope) {  
            Custom_Reporting__c crp = (Custom_Reporting__c) s;     
             if(crp.SF_Auction_ID__c != null && crp.SF_Global_Property_ID__c != null){                                  
                 CRInkMap.put((crp.Auction_Id_and_Global_Property_ID__c), crp);  
               }                             
        }
                                                               

      List<Custom_Reporting__c> CRAOAList = [SELECT Id,Auction_Id_and_Global_Property_ID__c,RecordTypeId,Merged__c FROM Custom_Reporting__c WHERE SF_Auction_ID__c != null AND SF_Global_Property_ID__c  != null AND Auction_Id_and_Global_Property_ID__c IN:CRInkMap.KeySet() AND RecordTypeId =:Label.AOA_Custom_Reporting AND User_Created_AOA__c = True];
          
      List<Custom_Reporting__c> UpdateAOACustRep = new List<Custom_Reporting__c>();
    
      
      for (Custom_Reporting__c cr: CRAOAList) {     
         if(CRInkMap.ContainsKey(cr.Auction_Id_and_Global_Property_ID__c)){    
                 cr.Merged__c = True;  
                 UpdateAOACustRep.add(cr);                
             }
         }    
           
    if (!UpdateAOACustRep.isEmpty()) {  
        update UpdateAOACustRep;   
      }
      
     

}
   global void finish(Database.BatchableContext bc){       }

}