//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To uncheck the Most Recent Valuation Flag on the Previous Valuation
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota Created  on 02/12/14 */
// Test Class : TestAssetConsiderationFlag
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public with sharing class MostrecentValuationcheckClass
{

public static void CheckLatestvaluationFlag(List<Valuation__c> ValList, Set<Id> CurrentvalId) {

        Set<Id> oppIds = new Set<Id>();
        Set<Id> valIds = new Set<Id>();

    for(Valuation__c valr : ValList) {
        if(valr.Opportunity_Record_Type__c == Label.Short_Sale_Opp_Rectype_Id){
            valIds .add(valr.Id); 
            if(valr.Opportunity__c!=null)
            oppIds.add(valr.Opportunity__c); 
         }   
     }

    //Get all the AuctionsOppJuntion records connected to Opportunity with Latest AOA set as TRUE 
    List<Valuation__c> newvalList = new List<Valuation__c>([SELECT Id,Opportunity__c FROM Valuation__c WHERE Opportunity__c IN :OppIds AND Opportunity__c!=null AND Most_Recent_Valuation__c=true AND Id NOT IN :CurrentvalId ORDER BY  CreatedDate DESC]);
    
     List<Valuation__c> oldval = new List<Valuation__c> ();
            for(Valuation__c val : newvalList) {        
                   val.Most_Recent_Valuation__c=false;
                   oldval.add(val);        
             }
        
        if(oldval.size() > 0)
           Update oldval;    

}
           
}