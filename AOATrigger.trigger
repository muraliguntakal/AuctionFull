/******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To Create Open House when Auction is associated to AOA. Classes to find the most recent auction.
//  --------------------------------------------------------------------
/* Author : Ganesh Created  on 02/12/14 */
// Test Class : TestOpenHouse
// Modified By                    Modified Date                                    What Changed                                                                Reason
//                                                       
//******************************************************************************************************************************************************************************************  

trigger AOATrigger on Auction_Opportunity_Assignment__c (after insert, after update) {
/*
    AOAUtils.validateAOASellerCode(Trigger.new, Trigger.oldMap);

   // if(TriggerSettings__c.getValues('AOATrigger').Status__c){
      TriggerSettings__c ts = TriggerSettings__c.getValues('AOATrigger');
      if (ts != null && ts.Status__c) {

        AOATriggerHelper aoahelper = new AOATriggerHelper();

        //After Insert and Update Process  
        if((Trigger.isInsert || Trigger.isUpdate )&& Trigger.isAfter){ 
            //After Insert Process
            if(Trigger.isInsert && Trigger.isAfter){  
                  aoahelper.CheckLatestAuctionOppFlag(Trigger.new, Trigger.newMap.keyset());
                  aoahelper.updateMostRecentAuctionClass(Trigger.new);  
                  aoahelper.MostRecentAOAonAsset(Trigger.new); 
            } 
            
            //After Insert and Update Process
                                                              
            aoahelper.CreatOpenHouses(trigger.newMap, trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
            aoahelper.CountAuctionOpptyAssignment(trigger.newMap, trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
            
            //After Update Process
            if(Trigger.isUpdate && Trigger.isAfter){  
                aoahelper.Findwinningbid(trigger.newMap);
                aoahelper.UpdatebidfromAOA(trigger.newMap, trigger.oldMap);
                aoahelper.TrusteeOpportunityUpdate(trigger.newMap);
                aoahelper.UncheckPhotoOrder(trigger.newMap, trigger.oldMap);
            } 
        }                              
    } 
  */    
}