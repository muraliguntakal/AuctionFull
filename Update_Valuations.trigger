trigger Update_Valuations on BPO__c (after update) { 
  Map<ID, Valuation__c> parentvaluations = new Map<ID, Valuation__c>(); //Making it a map instead of list for easier lookup
  List<Id> listIds = new List<Id>();

  for (BPO__c childObj : Trigger.new) {
    listIds.add(childObj.Valuation__c);
  }


  parentvaluations = new Map<Id, Valuation__c>([SELECT  OwnerId,Subject_Lot_Size_Sqft_BPO__c,Subject_Lot_Size_Sqft_Ext_Appr__c,Subject_Lot_Size_Sqft_Int_Appr__c,Subject_Lot_Size_Sqft_Srvcr_BPO__c, TPV_Comments__c, IsDeleted, Name, BPO_Vendor_ID__c, Opportunity__c, Test_Field__c, Test_Field_2__c, Asset__c, Valuation_type__c, BPO_Order_Type__c, Order_Requested_Date__c, Order_Received_Date__c, Vendor_BPO__c, Coordinator_BPO__c, Order_Status_BPO__c, Comments__c, Quick_Sale_Value__c, BPO_Uploaded_to_Equator_Date__c, X3rd_Party_BPO_Value__c, 
                                                        Additional_3rd_Party_BPO_Value__c, BPO_Link__c, Servicer_BPO_Value__c, Listing_Agent_BPO_Value__c, Appraisal_Value__c, Auction_com_Reserve_Amount__c,Value_REDC_High__c,Value_REDC_Low__c,
                                                        Final_Reserve_Amount__c, Initial_Reserve_Amount__c, Servicer_Reserve__c, Internal_RMV__c, IVG_Date__c, IVG__c, Listing_Agent_BPO_Date__c, Property_Reserve_Price__c, Reserve_Floor__c, RMV_Date_SrvRMV__c, RMV_Repair_Value_SrvRMV__c, RMV_Value_SrvRMV__c, Seller_Suggested_Reserve__c, BPO_Report_Date__c, AVM__c, AVM_Date__c, Predominate_Tract_Value__c, Internal_Appraisal_Value__c, Internal_Appraisal_Predominant_Tract__c, X30_Day_Sale_Value_BPO__c, X90_120_As_Is_Sale_Price_BPO__c,
                                                        Completed_Date_BPO__c, Property_Condition_BPO__c, Occupancy_Status_BPO__c, Subject_SQFT_BPO__c, Total_Room_Count_BPO__c, Subject_Bed_Count_BPO__c, Subject_Bath_Count_BPO__c, Subject_Lot_Size_sq_Ft_Acres_BPO__c, Subject_Year_Built_BPO__c, HOA_Name_BPO__c, HOA_Phone_BPO__c, Monthly_HOA_Dues_BPO__c, Seller_Current_List_Price_BPO__c, Property_Type_BPO__c, X30_Day_Sale_Value_Ext_Appr__c, X90_120_As_Is_Sale_Price_Ext_Appr__c, Completed_Date_Ext_Appr__c, Property_Condition_Ext_Appr__c, Property_Condition_Int_Appr__c,
                                                        Property_Type_Ext_Appr__c, Property_Type_Int_Appr__c, Subject_SQFT_Ext_Appr__c, Subject_SQFT_Int_Appr__c, Total_Room_Count_Ext_Appr__c, Total_Room_Count_Int_Appr__c, Subject_Bath_Count_Ext_Appr__c, Subject_Bath_Count_Int_Appr__c, Subject_Bed_Count_Ext_Appr__c, Subject_Bed_Count_Int_Appr__c, Subject_Lot_Size_sq_Ft_Acres_Ext_Appr__c, Subject_Lot_Size_sq_Ft_Acres_Int_Appr__c, Subject_Year_Built_Ext_Appr__c, Subject_Year_Built_Int_Appr__c, Occupancy_Status_Ext_Appr__c, Occupancy_Status_Int_Appr__c, HOA_Name_Ext_Appr__c,
                                                        Subject_Bath_Count_Srvcr_BPO__c, Subject_Bed_Count_Srvcr_BPO__c, Vendor_Srvcr_BPO__c, Subject_SQFT_Srvcr_BPO__c, Subject_Year_Built_Srvcr_BPO__c, Total_Room_Count_Srvcr_BPO__c, Subject_Lot_Size_sq_Ft_Acres_Srvcr_BPO__c, Servicer_BPO_Order_Received_Date__c, Servicer_BPO_Order_Type__c, Servicer_BPO_Uploaded_to_Equator_Date__c, Servicer_BPO_Link__c, Servicer_BPO_Order_Date__c, Seller_Current_List_Price_Srvcr_BPO__c, Quick_Sale_Value_Srvcr_BPO__c, Property_Condition_Srvcr_BPO__c, Property_Type_Srvcr_BPO__c, 
                                                        Order_Status_Srvcr_BPO__c, Order_Requested_Date_Srvcr_BPO__c, Occupancy_Status_Srvcr_BPO__c, Monthly_HOA_Dues_Srvcr_BPO__c, Listing_Agent_Srvcr_BPO_Date__c, HOA_Phone_Srvcr_BPO__c, HOA_Name_Srvcr_BPO__c, Complted_Date_Srvcr_BPO__c, Coordinator_Srvcr_BPO__c, Comments_Srvcr_BPO__c, Appraisal_Value_Srvcr_BPO__c, X3rd_Party_BPO_Value_Srvcr_BPO__c, Additional_3rd_Party_Srvcr_BPO_Value__c, HOA_Name_Int_Appr__c, Comments_AVM__c, Comments_Ext_Appr__c, Comments_Int_Appr__c, Comments_Int_Res__c, Comments_Int_RMV__c,
                                                        Comments_IVG__c, Comments_Serv_Res__c, Comments_Serv_RMV__c,  HOA_Phone_Ext_Appr__c, HOA_Phone_Int_Appr__c, Current_Seller_Reserve_Received_Date__c, Monthly_HOA_Dues_Ext_Appr__c, Monthly_HOA_Dues_Int_Appr__c, Seller_Current_List_Price_Ext_Appr__c, Seller_Current_List_Price_Int_Appr__c, Order_Status_Ext_Appr__c, Order_Status_Int_Appr__c, Order_Status_Serv_Res__c, Order_Status_Int_Res__c, Order_Status_Serv_RMV__c, Order_Status_Int_RMV__c, Order_Status_AVM__c, Order_Status_IVG__c,
                                                        (SELECT Id, BPO_Vendor_ID__c, OwnerId, TPV_Comments__c, IsDeleted, Name, RecordTypeId,Valuation_Id__c, Valuation__c, Valuation_Type__c, Order_Requested_Date__c, BPO_Order_Type__c, Order_Status__c, Order_Received_Date__c, Vendor__c, Comments__c, Coordinator__c, Quick_Sale_Value__c, BPO_Uploaded_to_Equator_Date__c, X3rd_Party_BPO_Value__c, Additional_3rd_Party_BPO_Value__c, Servicer_BPO_Value__c, Listing_Agent_BPO_Value__c, BPO_Link__c, X30_Day_Sale_Value__c, X90_120_As_Is_Sale_Price__c, Completed_Date__c, 
                                                                Property_Condition__c, Property_Type__c, Subject_SQFT__c, Total_Room_Count__c, Subject_Bed_count__c, Subject_Bath_Count__c, Subject_Year_Built__c, HOA_Name__c, OccupancyStatus__c, HOA_Phone__c, Monthly_HOA_Dues__c, Seller_Current_List_Price__c, Appraisal_Value__c, Auction_com_Reserve_Amount__c, Final_Reserve_Amount__c, Initial_Reserve_Amount__c, Servicer_Reserve__c, Internal_RMV__c, IVG__c, IVG_Date__c, Listing_Agent_BPO_Date__c, Property_Reserve_Price__c, 
                                                                Reserve_Floor__c, RMV_Date__c, RMV_Repair_Value__c, RMV_Value__c, Current_Seller_Reserve_Received_Date__c, Seller_Suggested_Reserve__c, BPO_Report_Date__c, AVM__c, AVM_Date__c, Predominate_Tract_Value__c,Subject_Lot_Size_Sq_Ft__c,Subject_Lot_Size_sq_Ft_Acres__c, Internal_Appraisal_Value__c, Internal_Appraisal_Predominant_Tract__c FROM BPO__r) FROM Valuation__c WHERE ID IN :listIds]);


// Subject_Lot_Size_Sq_Ft__c, Subject_Lot_Size_Sqft_BPO__c,Subject_Lot_Size_Sqft_Ext_Appr__c,Subject_Lot_Size_Sqft_Int_Appr__c,Subject_Lot_Size_Sqft_Srvcr_BPO__c;
  for (BPO__c VO: Trigger.new) {
     Valuation__c v =  parentvaluations.get(VO.Valuation__c);
	 if(v!=null) {
        if(VO.RecordTypeId == Label.BPO_RecType_Id /*&& VO.Order_Received_Date__c != null*/) {
                  v.X30_Day_Sale_Value_BPO__c = VO.X30_Day_Sale_Value__c ;  
                  v.Additional_3rd_Party_BPO_Value__c = VO.Additional_3rd_Party_BPO_Value__c;
                  v.X3rd_Party_BPO_Value__c = VO.X3rd_Party_BPO_Value__c;
                  v.X90_120_As_Is_Sale_Price_BPO__c = VO.X90_120_As_Is_Sale_Price__c;
                  v.BPO_Link__c = VO.BPO_Link__c;
                  v.BPO_Order_Type__c = VO.BPO_Order_Type__c;
                  v.BPO_Report_Date__c = VO.BPO_Report_Date__c;
                  v.BPO_Uploaded_to_Equator_Date__c = VO.BPO_Uploaded_to_Equator_Date__c;
                  v.Completed_Date_BPO__c = VO.Completed_Date__c;
                  v.Coordinator_BPO__c = VO.Coordinator__c;
                  v.HOA_Name_BPO__c = VO.HOA_Name__c;
                  v.HOA_Phone_BPO__c = VO.HOA_Phone__c;
                  v.Vendor_BPO__c = VO.Vendor__c;
                  v.Subject_Lot_Size_Sqft_BPO__c = VO.Subject_Lot_Size_Sq_Ft__c;
                  v.Listing_Agent_BPO_Date__c = VO.Listing_Agent_BPO_Date__c;
                  v.Listing_Agent_BPO_Value__c = VO.Listing_Agent_BPO_Value__c;
                  v.Monthly_HOA_Dues_BPO__c = VO.Monthly_HOA_Dues__c;
                  v.Occupancy_Status_BPO__c = VO.OccupancyStatus__c;
                  v.Order_Status_BPO__c = VO.Order_Status__c;
                  v.Appraisal_Value__c = VO.Appraisal_Value__c;
                  v.Order_Requested_Date__c = VO.Order_Requested_Date__c;
                  v.Order_Received_Date__c = VO.Order_Received_Date__c;
                  v.Property_Condition_BPO__c = VO.Property_Condition__c;
                  v.Servicer_BPO_Value__c = VO.Servicer_BPO_Value__c;
                  v.Quick_Sale_Value__c = VO.Quick_Sale_Value__c;
                  v.Property_Type_BPO__c = VO.Property_Type__c; 
                  v.Seller_Current_List_Price_BPO__c = VO.Seller_Current_List_Price__c;
                  v.Subject_Bath_Count_BPO__c = VO.Subject_Bath_Count__c;
                  v.Subject_Bed_Count_BPO__c = VO.Subject_Bed_Count__c;
                  v.Subject_Lot_Size_sq_Ft_Acres_BPO__c = VO.Subject_Lot_Size_sq_Ft_Acres__c;
                  v.Subject_SQFT_BPO__c = VO.Subject_SQFT__c;
                  v.Subject_Year_Built_BPO__c = VO.Subject_Year_Built__c;
                  v.Total_Room_Count_BPO__c = VO.Total_Room_Count__c;
                  v.Vendor_BPO__c = VO.Vendor__c;
                  v.comments__c = VO.Comments__c;                  
        }
        else if(VO.RecordTypeId == Label.Servicer_Reserve_Rectype_Id /*&& VO.Order_Received_Date__c != null*/){
               v.Initial_Reserve_Amount__c = VO.Initial_Reserve_Amount__c;
               v.Final_Reserve_Amount__c = VO.Final_Reserve_Amount__c;
               v.Seller_Suggested_Reserve__c = VO.Seller_Suggested_Reserve__c;
               v.Servicer_Reserve__c = VO.Servicer_Reserve__c;
               v.Current_Seller_Reserve_Received_Date__c = VO.Current_Seller_Reserve_Received_Date__c;
               v.Order_Status_Serv_Res__c = VO.Order_status__c;
               v.Comments_Serv_Res__c = VO.Comments__c;
        }
       ////Ganesh Vinnakota
        else if(VO.RecordTypeId == Label.Picture_Records_TypeId){
               v.X3rd_Party_BPO_Value__c = VO.X3rd_Party_BPO_Value__c;
               v.Completed_Date_BPO__c = VO.Completed_Date__c;
               v.Order_Received_Date__c = VO.Order_Received_Date__c;
               v.Order_Requested_Date__c = VO.Order_Requested_Date__c;
               v.TPV_Comments__c = VO.TPV_Comments__c;
               v.Order_Status_BPO__c = VO.Order_Status__c;
        }
        else if(VO.RecordTypeId == Label.SerRMV_RecTypeId /*&& VO.Order_Received_Date__c != null*/){
               v.RMV_Date_SrvRMV__c = VO.RMV_Date__c;
               v.RMV_Repair_Value_SrvRMV__c = VO.RMV_Repair_Value__c;
               v.RMV_Value_SrvRMV__c = VO.RMV_Value__c;
               v.Order_Status_Serv_RMV__c = VO.Order_Status__c;
               v.Comments_Serv_RMV__c = VO.Comments__c;
        }
        else if(VO.RecordTypeId == Label.IntRes_RecTypeId /*&& VO.Order_Received_Date__c != null*/){
               v.Order_Status_Int_Res__c = VO.Order_status__c;
               v.Auction_com_Reserve_Amount__c = VO.Auction_com_Reserve_Amount__c; 
               v.Comments_Int_Res__c = VO.Comments__c;         
        }        
        else if(VO.RecordTypeId == Label.IntRMV_RecTypeId /*&& VO.Order_Received_Date__c != null*/){
               v.Order_Status_Int_RMV__c = VO.Order_Status__c;
               v.Internal_RMV__c = VO.Internal_RMV__c;
               v.Comments_Int_RMV__c = VO.Comments__c;
        }
        else if(VO.RecordTypeId == Label.IntApp_RectypeId /*&& VO.Order_Received_Date__c != null*/){
               v.HOA_Name_Int_Appr__c = VO.HOA_Name__c;
               v.Comments_Int_Appr__c = VO.Comments__c;
               v.HOA_Phone_Int_Appr__c = VO.HOA_Phone__c;
               v.Monthly_HOA_Dues_Int_Appr__c = VO.Monthly_HOA_Dues__c;
               v.Subject_Lot_Size_Sqft_Int_Appr__c = VO.Subject_Lot_Size_Sq_Ft__c;
               v.Occupancy_Status_Int_Appr__c = VO.OccupancyStatus__c;
               v.Order_Status_Int_Appr__c = VO.Order_Status__c;
               v.Property_Condition_Int_Appr__c = VO.Property_Condition__c;
               v.Property_Type_Int_Appr__c = VO.Property_Type__c;
               v.Seller_Current_List_Price_Int_Appr__c = VO.Seller_Current_List_Price__c;
               v.Subject_Bath_Count_Int_Appr__c = VO.Subject_Bath_Count__c;
               v.Subject_Bed_Count_Int_Appr__c = VO.Subject_Bed_Count__c;
               v.Subject_Lot_Size_sq_Ft_Acres_Int_Appr__c = VO.Subject_Lot_Size_sq_Ft_Acres__c;
               v.Subject_SQFT_Int_Appr__c = VO.Subject_SQFT__c;
               v.Subject_Year_Built_Int_Appr__c = VO.Subject_Year_Built__c;
               v.Total_Room_Count_Int_Appr__c = VO.Total_Room_Count__c;
               v.Internal_Appraisal_Value__c = VO.Internal_Appraisal_Value__c;
               v.Value_REDC_Low__c = VO.Low_Range__c;
               v.Value_REDC_High__c = VO.High_Range__c;
               v.Predominate_Tract_Value__c =  VO.Predominate_Tract_Value__c;
         }       
         else if(VO.RecordTypeId == Label.IVG_RecTypeId /*&& VO.Order_Received_Date__c != null*/){
               v.Order_Status_IVG__c = VO.Order_Status__c;
               v.IVG__c = VO.IVG__c;
               v.IVG_Date__c = VO.IVG_Date__c;
               v.Comments_IVG__c = VO.Comments__c;
         }
         else if(VO.RecordTypeId == Label.ExtApp_RecTypeId /*&& VO.Order_Received_Date__c != null*/){
               v.X30_Day_Sale_Value_Ext_Appr__c = VO.X30_Day_Sale_Value__c;
               v.X90_120_As_Is_Sale_Price_Ext_Appr__c = VO.X90_120_As_Is_Sale_Price__c;
               v.Completed_Date_Ext_Appr__c = VO.Completed_Date__c;
               v.HOA_Name_Ext_Appr__c = VO.HOA_Name__c;
               v.Subject_Lot_Size_Sqft_Ext_Appr__c = VO.Subject_Lot_Size_sq_Ft__c;      
               v.HOA_Phone_Ext_Appr__c = VO.HOA_Phone__c;
               v.Monthly_HOA_Dues_Ext_Appr__c = VO.Monthly_HOA_Dues__c;
               v.Occupancy_Status_Ext_Appr__c = VO.OccupancyStatus__c;
               v.Order_Status_Ext_Appr__c = VO.Order_Status__c;
               v.Property_Condition_Ext_Appr__c = VO.Property_Condition__c;
               v.Property_Type_Ext_Appr__c = VO.Property_Type__c;
               v.Seller_Current_List_Price_Ext_Appr__c = VO.Seller_Current_List_Price__c;
               v.Subject_Bath_Count_Ext_Appr__c = VO.Subject_Bath_Count__c;
               v.Subject_Bed_Count_Ext_Appr__c = VO.Subject_Bed_Count__c;
               v.Subject_Lot_Size_sq_Ft_Acres_Ext_Appr__c = VO.Subject_Lot_Size_sq_Ft_Acres__c;
               v.Subject_SQFT_Ext_Appr__c = VO.Subject_SQFT__c;
               v.Subject_Year_Built_Ext_Appr__c = VO.Subject_Year_Built__c;
               v.Total_Room_Count_Ext_Appr__c = VO.Total_Room_Count__c;
               v.Reserve_Floor__c = VO.Reserve_Floor__c;
               v.Property_Reserve_Price__c = VO.Property_Reserve_Price__c;
               v.Comments_Ext_Appr__c = VO.Comments__c;
        }        
        else if(VO.RecordTypeId == Label.AVM_RecTypeId /*&& VO.Order_Received_Date__c != null*/){
               v.Order_Status_AVM__c = VO.Order_Status__c;
               v.AVM__c = VO.AVM__c;
               v.AVM_Date__c = VO.AVM_Date__c;
               v.Comments_AVM__c = VO.Comments__c;
        }
        else if(VO.RecordTypeId == Label.Servicer_BPO_RecType_Id /*&& VO.Order_Received_Date__c != null*/){
               v.Subject_Lot_Size_Sqft_Srvcr_BPO__c = VO.Subject_Lot_Size_sq_Ft__c;
               v.Subject_Bath_Count_Srvcr_BPO__c = VO.Subject_Bath_Count__c;
               v.Subject_Bed_Count_Srvcr_BPO__c = VO.Subject_Bed_Count__c;
               v.Vendor_Srvcr_BPO__c =  VO.Vendor__c;
               v.Subject_SQFT_Srvcr_BPO__c = VO.Subject_SQFT__c;
               v.Servicer_BPO_Value__c = VO.Servicer_BPO_Value__c; //
               v.Subject_Year_Built_Srvcr_BPO__c = VO.Subject_Year_Built__c;
               v.Total_Room_Count_Srvcr_BPO__c = VO.Total_Room_Count__c;
               v.Subject_Lot_Size_sq_Ft_Acres_Srvcr_BPO__c = VO.Subject_Lot_Size_sq_Ft_Acres__c;
               v.Servicer_BPO_Order_Received_Date__c = VO.Order_Received_Date__c;
               v.Servicer_BPO_Order_Type__c = VO.BPO_Order_Type__c;  
               v.Servicer_BPO_Uploaded_to_Equator_Date__c = VO.BPO_Uploaded_to_Equator_Date__c;
               v.Servicer_BPO_Link__c =  VO.BPO_Link__c;
               v.Seller_Current_List_Price_Srvcr_BPO__c = VO.Seller_Current_List_Price__c;
               v.Quick_Sale_Value_Srvcr_BPO__c = VO.Quick_Sale_Value__c;
               v.Property_Condition_Srvcr_BPO__c = VO.Property_Condition__c;
               v.Property_Type_Srvcr_BPO__c = VO.Property_Type__c;
               v.Order_Status_Srvcr_BPO__c =  VO.Order_Status__c;
               v.Order_Requested_Date_Srvcr_BPO__c = VO.Order_Requested_Date__c; 
               v.Occupancy_Status_Srvcr_BPO__c =  VO.OccupancyStatus__c;
               v.Monthly_HOA_Dues_Srvcr_BPO__c = VO.Monthly_HOA_Dues__c;  
               v.Listing_Agent_Srvcr_BPO_Date__c =  VO.Listing_Agent_BPO_Date__c;
               v.HOA_Phone_Srvcr_BPO__c = VO.HOA_Phone__c;
               v.HOA_Name_Srvcr_BPO__c = VO.HOA_Name__c; 
               v.Complted_Date_Srvcr_BPO__c = VO.Completed_Date__c;
               v.Coordinator_Srvcr_BPO__c = VO.Coordinator__c;
               v.Comments_Srvcr_BPO__c = VO.Comments__c;
               v.Appraisal_Value_Srvcr_BPO__c = VO.Appraisal_Value__c;
               v.X3rd_Party_BPO_Value_Srvcr_BPO__c = VO.X3rd_Party_BPO_Value__c; 
               v.Additional_3rd_Party_Srvcr_BPO_Value__c = VO.Additional_3rd_Party_BPO_Value__c;
        }
	}
  }
  Update parentvaluations.values();  
}