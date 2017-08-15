//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To find the most recent Valuation related to opportunity and display it in the  most recent valuation lookup in opportunity
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota Created  on 02/12/14 */
// Test Class : TestAssetConsiderationFlag
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public with sharing class MostRecentvaluationClass
{

public static void updateMostRecentvaluationClass(List<Valuation__c> valList){
                
                Set<Id> setoppId = new Set<Id>();   
                List<Opportunity> mostrecentval = new List<Opportunity>(); 
                    
                    for (Valuation__c  childObj: valList) {
                        if(childObj.Opportunity__c!=null && childObj.Opportunity_Record_Type__c == Label.Short_Sale_Opp_Rectype_Id){
                        setoppId.add(childObj.Opportunity__c);
                        }
                    }
                                                       
                   mostrecentval= [select Id,Most_Recent_Valuation__c,(Select Id,Opportunity__c,Most_Recent_Valuation__c From Valuations__r where Opportunity__c!=null AND Most_Recent_Valuation__c=true ORDER BY  CreatedDate DESC LIMIT 1)from Opportunity where Id in: setoppId];       
                                if(!mostrecentval.isEmpty())
                                {
                                    for (Opportunity opp : mostrecentval)
                                    {
                                        if(opp.Valuations__r !=null && opp.Valuations__r.size()!=0)
                                        {
                                            for (Valuation__c  val : opp.Valuations__r)
                                            {                                                       
                                                        opp.Most_Recent_Valuation__c = val.Id;                                                   
                                            }
                                        }
                                    }
                               if(!mostrecentval.isEmpty()) { 
                                    update mostrecentval;
                                 }   
                                }
                }     
}