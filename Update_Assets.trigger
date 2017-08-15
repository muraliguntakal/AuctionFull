trigger Update_Assets on Valuation__c (after update) {
  Map<ID, Asset__c> parentassets = new Map<ID, Asset__c>(); //Making it a map instead of list for easier lookup
  List<Id> listIds = new List<Id>();

  for (Valuation__c childObj : Trigger.new) {
    listIds.add(childObj.Asset__c);
  }


  parentassets = new Map<Id, Asset__c>([SELECT Id, HOA_Name__c,Lot_Size_Sq_Ft__c,Lot_Size_Acres__c,HOA_Phone__c,Monthly_HOA_Dues__c,Property_Condition__c, Property_Type__c, Modification_Method__c, Home_Square_Footage__c, Bedrooms__c,Modified_Date_time__c, Baths__c, Year_Built__c, Occupancy_Status__c ,(SELECT Id,Property_Type_Int_Appr__c,HOA_Name_Ext_Appr__c,HOA_Name_Int_Appr__c,
                                             HOA_Name_Srvcr_BPO__c,HOA_Phone_BPO__c,HOA_Phone_Ext_Appr__c,HOA_Phone_Int_Appr__c,
                                             HOA_Phone_Srvcr_BPO__c,Property_Condition_Int_Appr__c,Subject_Bed_Count_Int_Appr__c,
                                             Subject_Bath_Count_Int_Appr__c,Subject_Lot_Size_Sqft_BPO__c,Subject_Lot_Size_Sqft_Ext_Appr__c,Subject_Lot_Size_Sqft_Int_Appr__c,Subject_Lot_Size_Sqft_Srvcr_BPO__c,Subject_Year_Built_Int_Appr__c,Occupancy_Status_Int_Appr__c,
                                             Monthly_HOA_Dues_Ext_Appr__c,Monthly_HOA_Dues_BPO__c,Monthly_HOA_Dues_Int_Appr__c,
                                             Monthly_HOA_Dues_Srvcr_BPO__c,Subject_Bed_Count_Ext_Appr__c,HOA_Name_BPO__c,
                                             Subject_SQFT_BPO__c,Subject_Bath_Count_Ext_Appr__c,Subject_Year_Built_Ext_Appr__c,
                                             Occupancy_Status_Ext_Appr__c,Subject_SQFT_Ext_Appr__c,Subject_SQFT_Int_Appr__c,
                                             Subject_SQFT_Srvcr_BPO__c,Property_Type_Srvcr_BPO__c, Property_Condition_Srvcr_BPO__c,
                                             Subject_Bed_Count_Srvcr_BPO__c,Subject_Bath_Count_Srvcr_BPO__c,Subject_Year_Built_Srvcr_BPO__c,
                                             Occupancy_Status_Srvcr_BPO__c ,Update_Assets_Hide__c, Property_Condition_Ext_Appr__c, 
                                             Property_Type_Ext_Appr__c, Update_From_Servicer_BPO__c, Update_From_Internal_Appraisal__c, 
                                             Update_From_External_Appraisal__c, Update_From_BPO__c, Property_Condition_BPO__c, 
                                             Property_Type_BPO__c, Subject_Bed_Count_BPO__c, Subject_Bath_Count_BPO__c, 
                                             Subject_Year_Built_BPO__c, Occupancy_Status_BPO__c FROM Valuations_del__r) FROM Asset__c WHERE ID IN :listIds]);

 If(trigger.isafter || trigger.isupdate){
  for (Valuation__c v: Trigger.new){
     Asset__c a =  parentassets.get(v.Asset__c);
        // Subject_Lot_Size_Sqft_BPO__c,Subject_Lot_Size_Sqft_Ext_Appr__c,Subject_Lot_Size_Sqft_Int_Appr__c,Subject_Lot_Size_Sqft_Srvcr_BPO__c
     if (v.Update_From_BPO__c == True ) {
                    a.Property_Type__c  = v.Property_Type_BPO__c;
                    a.Property_Condition__c = v.Property_Condition_BPO__c;
                    a.Bedrooms__c = v.Subject_Bed_Count_BPO__c;
                    a.HOA_Name__c = v.HOA_Name_BPO__c;
                    a.HOA_Phone__c = v.HOA_Phone_BPO__c;
                    a.Monthly_HOA_Dues__c = v.Monthly_HOA_Dues_BPO__c;
                    a.Home_Square_Footage__c = v.Subject_SQFT_BPO__c;
                    a.Baths__c = v.Subject_Bath_Count_BPO__c;
                    a.Year_Built__c = v.Subject_Year_Built_BPO__c;
                    system.debug ('************* ++++++BPO');
                    a.Occupancy_Status__c = v.Occupancy_Status_BPO__c; 
                    a.Modification_Method__C = 'BPO Team';
                    a.Modified_Date_time__c = system.now();
                    a.Lot_Size_Sq_Ft__c = v.Subject_Lot_Size_Sqft_BPO__c;
                    a.Lot_Size_Acres__c  = v.Subject_Lot_Size_sq_Ft_Acres_BPO__c;
                       
                    }
         
          else if ( v.Update_From_Internal_Appraisal__c == True ) {
                    a.Property_Type__c  = v.Property_Type_Int_Appr__c;
                    a.Property_Condition__c = v.Property_Condition_Int_Appr__c;
                   a.Bedrooms__c = v.Subject_Bed_Count_Int_Appr__c;
                    a.Baths__c = v.Subject_Bath_Count_Int_Appr__c;
                    a.HOA_Name__c = v.HOA_Name_Int_Appr__c;
                    a.HOA_Phone__c = v.HOA_Phone_Int_Appr__c;
                    a.Monthly_HOA_Dues__c = v.Monthly_HOA_Dues_Int_Appr__c;
                    a.Home_Square_Footage__c = v.Subject_SQFT_Int_Appr__c;
                    a.Year_Built__c = v.Subject_Year_Built_Int_Appr__c;
                    system.debug ('************* ++++++intapp');
                    a.Occupancy_Status__c = v.Occupancy_Status_Int_Appr__c;
                    a.Modification_Method__c = 'Internal Appraisal Team';
                    a.Modified_Date_time__c = system.now();  
                    a.Lot_Size_Sq_Ft__c = v.Subject_Lot_Size_Sqft_Int_Appr__c;
                    a.Lot_Size_Acres__c = v.Subject_Lot_Size_sq_Ft_Acres_Int_Appr__c;  
          }  
         
          else if ( v.Update_From_External_Appraisal__c == True ) {
                    a.Property_Type__c  = v.Property_Type_Ext_Appr__c;
                    a.Property_Condition__c = v.Property_Condition_Ext_Appr__c;
                    a.Bedrooms__c = v.Subject_Bed_Count_Ext_Appr__c;
                    a.Baths__c = v.Subject_Bath_Count_Ext_Appr__c;
                    a.Year_Built__c = v.Subject_Year_Built_Ext_Appr__c;
                    a.HOA_Name__c = v.HOA_Name_Ext_Appr__c;
                    a.HOA_Phone__c = v.HOA_Phone_Ext_Appr__c;
                    a.Monthly_HOA_Dues__c = v.Monthly_HOA_Dues_Ext_Appr__c;
                    a.Home_Square_Footage__c = v.Subject_SQFT_Ext_Appr__c;
                    system.debug ('************* ++++++extapp');
                    a.Occupancy_Status__c = v.Occupancy_Status_Ext_Appr__c;  
                    a.Modification_Method__c = 'External Appraisal Team';  
                    a.Modified_Date_time__c = system.now();
                    a.Lot_Size_Sq_Ft__c = v.Subject_Lot_Size_Sqft_Ext_Appr__c;
                    a.Lot_Size_Acres__c = v.Subject_Lot_Size_sq_Ft_Acres_Ext_Appr__c;
          }
           
           else if ( v.Update_From_Servicer_BPO__c == True ) {
                    a.Property_Type__c  = v.Property_Type_Srvcr_BPO__c;
                    a.Property_Condition__c = v.Property_Condition_Srvcr_BPO__c;
                    a.Bedrooms__c = v.Subject_Bed_Count_Srvcr_BPO__c;
                    a.HOA_Name__c = v.HOA_Name_Srvcr_BPO__c;
                    a.HOA_Phone__c = v.HOA_Phone_Srvcr_BPO__c;
                    a.Home_Square_Footage__c = v.Subject_SQFT_Srvcr_BPO__c;
                    a.Baths__c = v.Subject_Bath_Count_Srvcr_BPO__c;
                    a.Monthly_HOA_Dues__c = v.Monthly_HOA_Dues_Srvcr_BPO__c;
                    a.Year_Built__c = v.Subject_Year_Built_Srvcr_BPO__c;
                    system.debug ('************* ++++++');
                    a.Occupancy_Status__c = v.Occupancy_Status_Srvcr_BPO__c; 
                    a.Modification_Method__c = 'Servicer BPO Team';
                    a.Modified_Date_time__c = system.now();
                    a.Lot_Size_Sq_Ft__c = v.Subject_Lot_Size_Sqft_Srvcr_BPO__c;
                    a.Lot_Size_Acres__c = v.Subject_Lot_Size_sq_Ft_Acres_Srvcr_BPO__c;
                  } 
        
    
  }
}
  update parentassets.values(); 
}