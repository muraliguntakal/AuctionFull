/******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To check most recent Valuation flag when ever Valuation record is created
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota Created  on 02/12/14 */
// Test Class : TestAssetConsiderationFlag
// Modified By                    Modified Date                                    What Changed                                                                Reason
//                                                     
//****************************************************************************************************************************************************************************************** 

trigger CheckmostRecentValuation on Valuation__c (Before Insert) {
//if(TriggerSettings__c.getValues('CheckmostRecentValuation').Status__c){
  TriggerSettings__c ts = TriggerSettings__c.getValues('CheckmostRecentValuation');
  if (ts != null && ts.Status__c) {


     if(Trigger.isInsert && Trigger.isBefore)
       {
       set<id> OpportunityIDSet= new set<id>();
            for(Valuation__c valtr: trigger.new) { 
              if(valtr.Opportunity_Record_Type__c == Label.Short_Sale_Opp_Rectype_Id){
                    if(!OpportunityIDSet.contains(valtr.Opportunity__c))
                    {
                        valtr.Most_Recent_Valuation__c= true;
                        OpportunityIDSet.add(valtr.Opportunity__c);
                    }
                }    
            }
       }
 }
}