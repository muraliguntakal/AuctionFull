//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To create Valuation and also to find the most recent Valuation
//  --------------------------------------------------------------------
/* Author : Rakesh Created  on 02/12/14 */
// Test Class : TestAssetConsiderationFlag
// Modified By                    Modified Date                                    What Changed                                                                Reason
// Ganesh Vinnakota               02/12/14                                          Added two Classes
//******************************************************************************************************************************************************************************************  
trigger CreateValue_Reserve_orders on Valuation__c (after insert) {

  TriggerSettings__c ts = TriggerSettings__c.getValues('CreateValue_Reserve_orders');
  
  if (ts != null && ts.Status__c) {
    if (Trigger.isInsert && Trigger.isAfter) { 
      List<BPO__c> createBPOs = new List <BPO__c> {};
                     
      for (Valuation__c v : trigger.new) {    
        if (v.Opportunity_Record_Type_Id__c == Label.Short_Sale_Opp_Rectype_Id) {
          if (v.Servicer_Code__c != null && v.Servicer_Code__c != '') {
            if(v.Servicer_Code__c.contains('NSM') || v.Servicer_Code__c.contains('JPM')){
              createBPOs.add(new BPO__c(
                Valuation__c = v.Id, 
                Valuation_Id__c = v.Id, 
                RecordTypeId = Label.BPO_RecType_Id 
                //Vendor__c = v.Vendor_BPO__c, 
                //Coordinator__c = v.Coordinator_BPO__c  
              ));
            }
          }
        } else if (v.Opportunity_Record_Type_Id__c == Label.Opportunity_Record_TypeId_Trustee) {
          String state = (v.Asset_Property_State__c != null ? v.Asset_Property_State__c.toUpperCase() : null);
          Map<String, Photo_Assignment__c> assignmentMap = Photo_Assignment__c.getAll();

          if (assignmentMap.containsKey(state) && assignmentMap.get(state).Active__c) {
            createBPOs.add(
              new BPO__c(
                Valuation__c = v.Id, 
                Department__c = 'Trustee', 
                Vendor__c = assignmentMap.get(state).Vendor_Account_ID__c, 
                Valuation_Type__c = 'Photo', 
                RecordTypeId = Label.Picture_Records_TypeId
              )
            );
          } else {
            createBPOs.add(
              new BPO__c(
                Valuation__c = v.Id, 
                Department__c = 'Trustee', 
                Vendor__c = Label.Order_Vendor_Photo_NVMS, 
                Valuation_Type__c = 'Photo', 
                RecordTypeId = Label.Picture_Records_TypeId
              )
            );
          }

          /**
           * Date: 3/27/16
           *
           * Decommissioned so the business could better manage the assignment matrix without
           * having to change system code each and every time.
           *
          if (v.Asset_Property_State__c == 'CO' || v.Asset_Property_State__c == 'NV' || v.Asset_Property_State__c == 'ID' || v.Asset_Property_State__c == 'OR' || v.Asset_Property_State__c == 'UT' || v.Asset_Property_State__c == 'WA') {
            createBPOs.add(new BPO__c ( Valuation__c = v.Id, Department__c = 'Trustee', Vendor__c = Label.Sierra_Trustee_Acount, Valuation_Type__c = 'Photo', RecordTypeId = Label.Picture_Records_TypeId));
          } else if (v.Asset_Property_State__c == 'GA' || v.Asset_Property_State__c == 'MI' || v.Asset_Property_State__c == 'IL' || v.Asset_Property_State__c == 'KS' || v.Asset_Property_State__c == 'NJ' || v.Asset_Property_State__c == 'FL') {
            createBPOs.add(new BPO__c ( Valuation__c = v.Id, Department__c = 'Trustee', Vendor__c = Label.Mortgage_Bankers_FS, Valuation_Type__c = 'Photo', RecordTypeId = Label.Picture_Records_TypeId));
          } else if (v.Asset_Property_State__c == 'CA' || v.Asset_Property_State__c == 'NY' || v.Asset_Property_State__c == 'OH' || v.Asset_Property_State__c == 'SC') {
            createBPOs.add(new BPO__c ( Valuation__c = v.Id, Department__c = 'Trustee', Vendor__c = Label.Vectra_Account_Trustee, Valuation_Type__c = 'Photo', RecordTypeId = Label.Picture_Records_TypeId));
          } else {
            createBPOs.add(new BPO__c ( Valuation__c = v.Id, Department__c = 'Trustee', Vendor__c = Label.Order_Vendor_Photo_NVMS, Valuation_Type__c = 'Photo', RecordTypeId = Label.Picture_Records_TypeId));
          }
          */
        }
        //Updated by Ganesh Vinnakota on 01/23/2015
        else if (v.Opportunity_Record_Type_Id__c == Opportunity_Product_Type_Mapping__c.getValues('Commercial').RecordTypeId__c && v.AssetOppJunction__c == null) {
          createBPOs.add(new BPO__c (Valuation__c = v.Id,Valuation_Id__c = v.Id,RecordTypeId = Label.VRO_Internal_Apprisal, High_Range__c = v.Value_REDC_High__c, Low_Range__c = v.Value_REDC_Low__c,Valuation_Date__c= system.today()));
        }
      }

      try {
        if (!createBPOs.isEmpty()) {
          insert createBPOs;
        }
      } catch (Exception Ex) {
        system.debug(Ex);
      }
    }
          
    // Ganesh Vinnakota - added
    if(Trigger.isInsert && Trigger.isAfter){  
      MostrecentValuationcheckClass.CheckLatestvaluationFlag(Trigger.new, Trigger.newMap.keyset());
    } 

    // Ganesh Vinnakota - added
    if(Trigger.isInsert || Trigger.isUpdate && Trigger.isAfter) { 
      MostRecentvaluationClass.updateMostRecentvaluationClass(Trigger.new);                                                             
    }
  }          
}