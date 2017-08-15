public with sharing class AssetOppJunctionHelper
{
    public static void uncheckLatestOpportunityFlag(List<AssetOppJunction__c> aojList) {
    
        Set<Id> oppIds = new Set<Id>();
        Set<Id> astIds = new Set<Id>();
        Map<String,Id> aoMap  = new Map<String,Id> ();
        
        Set<String> currentOptyName = new Set<String>();
        for(AssetOppJunction__c aoj : aojList) {
            if(aoj.Opportunity__c!=null)
                oppIds.add(aoj.Opportunity__c);        
        }

        system.debug('Current Oppty Names : ' +currentOptyName);    

        //Get all the Opportunities Linked connected to selected Assets with Latest Opportunity flag set as TRUE      
        List<AssetOppJunction__c> newaojList = new List<AssetOppJunction__c>([SELECT Opportunity__r.Id,Opportunity__r.Name,Opportunity__r.Loan_Number__c,Opportunity__r.Servicer_Code__c 
                                                                              FROM AssetOppJunction__c
                                                                              WHERE Opportunity__c IN :OppIds              AND 
                                                                                    Opportunity__r.RecordTypeId = :Label.Short_Sale_Opp_Rectype_Id AND
                                                                                    Opportunity__r.Latest_Opportunity__c=true ]);  

        Set<String> ServicerCodes = new Set<String>(); 
        Set<String> LoanNumbers = new Set<String>(); 
        Set<String> oldOppNames = new Set<String>(); 

        for(AssetOppJunction__c  ao : newaojList) {        
/*            if(ao.Opportunity__r.Servicer_Code__c!=null && ao.Opportunity__r.Servicer_Code__c!='0' && ao.Opportunity__r.Servicer_Code__c!=' ')
                ServicerCodes.add(ao.Opportunity__r.Servicer_Code__c); 
            if(ao.Opportunity__r.Loan_Number__c!=null && ao.Opportunity__r.Loan_Number__c!='0' && ao.Opportunity__r.Loan_Number__c!=' ')
                LoanNumbers.add(ao.Opportunity__r.Loan_Number__c);      
*/
            if(ao.Opportunity__r.Name!=null)
              oldOppNames.add(ao.Opportunity__r.Name);
        }
/*        
        List<Opportunity> OldOptyList = new List<Opportunity>([SELECT Id,Latest_Opportunity__c 
                                                                              FROM Opportunity
                                                                              WHERE Id NOT IN :OppIds                               AND 
                                                                                    RecordTypeId = :Label.Short_Sale_Opp_Rectype_Id AND
                                                                                    Latest_Opportunity__c=true                      AND                                                                                         
                                                                                    Servicer_Code__c IN :ServicerCodes              AND
                                                                                    Loan_Number__c IN :LoanNumbers                  AND                  
                                                                                    Servicer_Code__c !=null                         AND
                                                                                    Loan_Number__c !=null                           AND                  
                                                                                    isClosed!=true    
                                                                              ORDER BY Loan_Number__c,LastModifiedDate DESC]);
    
*/
        List<Opportunity> OldOptyList = new List<Opportunity>([SELECT Id,Latest_Opportunity__c 
                                                                              FROM Opportunity
                                                                              WHERE Id NOT IN :OppIds                               AND 
                                                                                    RecordTypeId = :Label.Short_Sale_Opp_Rectype_Id AND
                                                                                    Latest_Opportunity__c=true                      AND                                                                                         
                                                                                    Name IN :oldOppNames                            
                                                                                    //isClosed!=true    Fix - 4/1/2014 as per Robert's/Hammad's Email
                                                                              ORDER BY Loan_Number__c,LastModifiedDate DESC]);
        system.debug('Selected Old Opptys : ' +newaojList );
        List<Opportunity> OldOptyListuncheck = new List<Opportunity>(); 
        for(Opportunity  opp : OldOptyList ) {        
            OldOptyListuncheck.add(new Opportunity(Id=opp.Id,Latest_Opportunity__c=false));
        }
    
        if(oldOptyList.size() > 0)
           Update OldOptyListuncheck;    
    }
}