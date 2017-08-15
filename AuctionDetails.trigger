//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To assign the Auction associated with AOA to auction lookup field
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota Created  on 02/12/14 */
// Test Class : TestOpenHouse
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  

trigger AuctionDetails on Open_House__c (Before Insert, Before Update) {
  //if(TriggerSettings__c.getValues('AuctionDetails').Status__c){
    TriggerSettings__c ts = TriggerSettings__c.getValues('AuctionDetails');
    if (ts != null && ts.Status__c) {


     if((Trigger.isupdate || Trigger.isInsert) && Trigger.isBefore){
            for(Open_House__c OH : trigger.new){
                    if(OH.AOA_Auction_Id__c != null && OH.AOA_Auction_Id__c != '')
                    {
                    OH.Auction__c=OH.AOA_Auction_Id__c;
                    }      
                    if(OH.AOA_Asset_Id__c != null && OH.AOA_Asset_Id__c != '')
                    {
                    OH.Custom_Assets__c=OH.AOA_Asset_Id__c;
                    }  
                    if(OH.AOA_Opportunity_Id__c != null && OH.AOA_Opportunity_Id__c != '')
                    {
                    OH.Opportunity__c=OH.AOA_Opportunity_Id__c;
                    }
                                
            }
       }    
       
   }
}