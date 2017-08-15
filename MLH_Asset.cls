public class MLH_Asset { //Properties
    public List<Assets> assets {get;set;}
    public class Assets {
        public String event_type {get;set;}
        public Object accrual_method {get;set;}
        public Object additional_information {get;set;}
        public Object has_additional_seller {get;set;}
        public Object additional_seller_contact {get;set;}
        public Object additional_seller_email {get;set;}
        public Object additional_seller_name {get;set;}
        public Object additional_seller_phone {get;set;}
        public Object broker_email {get;set;}
        public Object broker_name {get;set;}
        public Object broker_phone {get;set;}
        public String broker_phone_extension {get;set;}
        public Object broker_city {get;set;}
        public Object broker_county {get;set;}
        public Object broker_state {get;set;}
        public Object broker_address {get;set;}
        public Object broker_zip {get;set;}
        public Object alternative_asset_type {get;set;}
        public Object amortization {get;set;}
        public Object amortization_period {get;set;}
        public Object recent_appraisal_date {get;set;}
        public Object recent_appraisal_value {get;set;}
        public Object original_appraisal_date {get;set;}
        public Object original_appraisal_value {get;set;}
        public Object apn {get;set;}
        public Object asset_level_deposit {get;set;}
        public Object event_status {get;set;}
        public Object event_number {get;set;}
        public Object event_day_sequence {get;set;}
        public Object average_daily_rate {get;set;}
        public Object average_current_balance {get;set;}
        public Object baths {get;set;}
        public Object beds {get;set;}
        public Object borrower {get;set;}
        public Object is_borrower_bankrupt {get;set;}
        public Object second_broker_address {get;set;}
        public Object third_broker_address {get;set;}
        public Object second_broker_city {get;set;}
        public Object third_broker_city {get;set;}
        public Object second_broker_county {get;set;}
        public Object second_broker_email {get;set;}
        public Object third_broker_email {get;set;}
        public Object second_broker_firm {get;set;}
        public Object third_broker_firm {get;set;}
        public Object broker_license_number {get;set;}
        public Object second_broker_license_number {get;set;}
        public Object third_broker_license_number {get;set;}
        public Object broker_license_state {get;set;}
        public Object second_broker_license_state {get;set;}
        public Object third_broker_license_state {get;set;}
        public Object second_broker_phone {get;set;}
        public String second_broker_phone_extension {get;set;}
        public Object third_broker_phone {get;set;}
        public String third_broker_phone_extension {get;set;}
        public Object third_broker_county {get;set;} 
        public Object second_broker_state {get;set;}
        public Object third_broker_state {get;set;}
        public Object second_broker_zip {get;set;}
        public Object third_broker_zip {get;set;}
        public Object broker_commission {get;set;}
        public Object building_class {get;set;}    
        public Object is_certified_diligence {get;set;}
        public Object closing_company_assigned_by {get;set;}
        public Object closing_company_city {get;set;}
        public Object closing_company_contact {get;set;}
        public Object closing_company_email {get;set;}
        public Object closing_company_phone {get;set;}
        public Object closing_company {get;set;}
        public Object closing_company_state {get;set;}
        public Object closing_company_address {get;set;}
        public Object closing_company_zip {get;set;}
        public Object marketing_comments {get;set;}
        public Object coupon_rate {get;set;}
        public Object current_balance {get;set;}
        public Object second_broker_contact {get;set;}
        public Object third_broker_contact {get;set;}
        public Object current_debt_service_coverage_ratio {get;set;}
        public Object current_list_price {get;set;}
        public Object current_loan_to_value {get;set;}
        public Object days_on_market {get;set;}
        public Object executive_summary_link {get;set;}
        public Object financing_available {get;set;}
        public Object financing_pre_qualification_date {get;set;}
        public Object forclosure_attorney {get;set;}
        public Object free_clear_title {get;set;}
        public Object is_first_sale_by_owner {get;set;}
        public Object global_asset_id {get;set;}
        public Object asset_id {get;set;} // For Non-Auction
        public Object asset_manager_name {get;set;}
        public Object asset_manager_email {get;set;}
        public Object asset_manager_phone {get;set;}
        public Object gross_square_footage {get;set;}
        public Object impound_balance_field {get;set;}
        public Object has_impounds {get;set;}
        public Object investment_class {get;set;}
        public Object investment_opportunity {get;set;}
        public Object lot_size {get;set;}
        public Object last_offer_amount {get;set;}
        public Object last_offer_date {get;set;}
        public Object lease_service {get;set;}
        public Object lien_position {get;set;}
        public Object listing_agreement {get;set;}
        public Object listing_agreement_date {get;set;}
        public Object listing_aggrement_expiration_date {get;set;}
        public Object listing_broker_company {get;set;}
        public Object loan_balloon_payment {get;set;}
        public Object loan_intrest_only_term {get;set;}
        public Object loan_last_payment_date {get;set;}
        public Object loan_maturity_date {get;set;}
        public Object loan_monthly_payment_amount {get;set;}
        public Object seller_loan_number {get;set;}
        public Object loan_original_balance {get;set;}
        public Object loan_original_term {get;set;}
        public Object loan_origination_date {get;set;}
        public Object loan_participation {get;set;}
        public Object loan_participation_lead {get;set;}
        public Object loan_prepayment_provision {get;set;}
        public Object loan_remaining_term {get;set;}
        public Object loan_status {get;set;}
        public Object market_guidance_high {get;set;}
        public Object market_guidance_low {get;set;}
        public Object market_information {get;set;}
        public Object minimum_buyer_premium {get;set;}
        public Object multi_city_list {get;set;}
        public Object multi_county_list {get;set;}
        public Object multi_state_list {get;set;}
        public Object multi_zip_list {get;set;}
        public Object net_rentable_area {get;set;}
        public Object notice_of_default_date {get;set;}
        public Object net_operating_income {get;set;}
        public Object net_operating_income_as_of_date {get;set;}
        public Object net_operating_income_period {get;set;}
        public Object notes_internal_id {get;set;}
        public Object number_of_keys {get;set;}
        public Object number_of_buildings {get;set;}
        public Object number_of_stories {get;set;}
        public Object number_of_units {get;set;}
        public Object occupancy_rate {get;set;}
        public Object occupancy_as_of_date {get;set;}
        public Object ownership_sold {get;set;}
        public Object seller_code {get;set;}
        public Object previously_valued_to {get;set;}
        public Object probability_of_sale_high {get;set;}
        public Object probability_of_sale_low {get;set;}
        public Object product_type {get;set;}
        public Object asset_address {get;set;}
        public Object asset_city {get;set;}
        public Object asset_county {get;set;}
        public Object asset_overview {get;set;}
        public Object asset_state {get;set;}
        public Object asset_sub_type {get;set;}
        public Object asset_type {get;set;}
        public Object asset_zip {get;set;}
        public Object asset_description {get;set;}
        public Object asset_name {get;set;}
        public Object rate_adjustment_frequency {get;set;}
        public Object rate_ceiling {get;set;}
        public Object rate_first_adjustment_date {get;set;}
        public Object rate_floor {get;set;}
        public Object rate_index {get;set;}
        public Object rate_initial_fixed_period {get;set;}
        public Object rate_interest_margin {get;set;}
        public Object rate_next_adjustment_date {get;set;}
        public Object rate_periodic_adjustment_amount {get;set;}
        public Object rate_type {get;set;}
        public Object receiver {get;set;}
        public Object recourse {get;set;}
        public Object redc_id {get;set;}
        public Object removal_date {get;set;}
        public Object removal_reason {get;set;}
        public Object removal_requested_by {get;set;}
        public Object reserve {get;set;}
        public Object small_business_administration_loan {get;set;}
        public Object seller {get;set;}
        public Object seller_contact {get;set;}
        public Object seller_contact_email {get;set;}
        public Object seller_contact_phone {get;set;}
        public Object salesforce_id {get;set;}
        public Object salesforce_opportunity_id {get;set;}
        public Object starting_bid {get;set;}
        public Object auction_status {get;set;}
        public Object reserve_subject_to {get;set;}
        public Object system_add_date {get;set;}
        public Object tenancy {get;set;}
        public Object title_company_name {get;set;}
        public Object title_ordered_by {get;set;}
        public Object title_ordered_date {get;set;}
        public Object title_received_date {get;set;}
        public Object title_report {get;set;}
        public Object title_report_date {get;set;}
        public Object title_underwriter {get;set;}
        public Object latitude_longitude {get;set;}
        public Object updated_subject_to_reserve {get;set;}
        public Object use_address_only {get;set;}
        public Object value_broker_date {get;set;}
        public Object value_broker_high {get;set;}
        public Object value_broker_low {get;set;}
        public Object value_broker_mod {get;set;}
        public Object value_redc_date {get;set;}
        public Object value_redc_low {get;set;}
        public Object value_redc_mod {get;set;}
        public Object value_redc_high {get;set;}
        public Object value_seller_date {get;set;}
        public Object value_seller_high {get;set;}
        public Object value_seller_low {get;set;}
        public Object value_seller_mod {get;set;}
        public Object year_built {get;set;}
        public Object alternate_asset_type {get;set;}
        public Object bid_agreement_flag {get;set;}
        public Object sale_type{get;set;}
        public Object sf_contact_id {get;set;}
        //public Object sf_broker_id {get;set;}
        public Object total_room_count {get;set;}
        public Object property_video_url {get;set;}
    }

    // Response - Start        
    public class property_response_list {
        public List<upload_success_list> uploadSuccessList;
        public List<commit_success_list> commitSuccessList;
        public List<error_list> errorList;
    }

    public class upload_success_list{
        public Object upload_status;
        public Object asset_id;
        public Object listing_id;
        public Object global_asset_id;
        public Object salesforce_opportunity_id;
        public Object aution;
        public Object redc_id;
        public Object asset_address;
        public Object seller_loan_number;
    }

    public class commit_success_list{
        public Object commit_status;
        public Object asset_id;
        public Object listing_id;
        public Object global_asset_id;
        public Object salesforce_opportunity_id;
        public Object aution;
        public Object redc_id;
        public Object asset_address;
        public Object seller_loan_number;
    }        

    public class error_list {
        public Object upload_status;
        public Object asset_id;
        public Object global_asset_id;
        public Object salesforce_opportunity_id;
        public Object aution;
        public Object redc_id;
        public Object asset_address;
        public Object seller_loan_number;
        public Object error_count;
        public Object message; //Created to accomodate code change in MLHAPIv2
        public List<err_msg> error_msg;
    }
    
    public class err_msg {
        public Object message;
    }
          
    public static MLH_Asset parse(String json) {
        return (MLH_Asset) System.JSON.deserialize(json, MLH_Asset.class);
    }    

    public static String CreatePropertiesJSON(MLH_Asset assetList) {
        return System.JSON.Serialize(assetList);
    }


    public Static String AssetJSON(Set<Id> OppIds) {

        List<Opportunity> oppList = new List<Opportunity>();
        OppList       =   new LIST<Opportunity>([SELECT Id,  
                                                        Name,
                                                        Asset__c,
                                                        Auction_Opportunity_Assignment__c,
                                                        Asset__r.MLH_Global_Property_ID__c,
                                                        Asset__r.NAF_Global_Property_ID__c,
                                                        Auction_day_sequence__c,
                                                        Most_Recent_Auction_Event__c,
                                                        MLH_REDC_ID__c,
                                                        Asset__r.System_Add_Date__c,
                                                        Auction_Opportunity_Assignment__r.Status__c,
                                                        Auction_Opportunity_Assignment__r.Removal_Date__c,
                                                        Auction_Opportunity_Assignment__r.Removal_Reason__c,
                                                        Auction_Opportunity_Assignment__r.Removal_Requested_By__c,
                                                        Seller__r.Name,
                                                        MLH_Seller_code__c,
                                                        Seller_Email_F__c,
                                                        Seller_Phone__c,
                                                        Loan_Number__c,
                                                        Additional_Seller__c,
                                                        Additional_Seller_Contact__c,
                                                        Additional_Seller_Contact_Email__c,
                                                        Additional_Seller_Contact_Phone__c,
                                                        Additional_Seller_Name__c,
                                                        Asset_Manager_Email__c,
                                                        Asset_Manager_Name__c,
                                                        Asset_Manager_Phone__c,
                                                        Asset__r.Id,
                                                        Asset__r.Product_Type__c,
                                                        Asset__r.Property_Type__c,
                                                        Asset__r.Property_Sub_Type__c,
                                                        Asset__r.Property_Name__c,
                                                        Asset__r.Property_Description__c,
                                                        Marketing_Description__c,
                                                        Asset__r.Property_Street__c,
                                                        Asset__r.Property_City__c,
                                                        Asset__r.Property_State__c,
                                                        Asset__r.Property_County__c,
                                                        Asset__r.Property_Zip_Postal_Code__c,
                                                        Asset__r.Year_Built__c,
                                                        Asset__r.APN__c,
                                                        Asset__r.Lot_Size_Acres__c,
                                                        Asset__r.Gross_Square_Footage_SF__c,
                                                        Asset__r.Net_Rentable_Area_SF__c,
                                                        Asset__r.Baths__c,
                                                        Asset__r.Bedrooms__c,
                                                        Asset__r.Number_of_Buildings__c,
                                                        Asset__r.Number_of_Keys__c,
                                                        Asset__r.Number_of_Stories__c,
                                                        Asset__r.Number_of_Units__c,
                                                        Asset__r.Lien_Position__c,
                                                        Asset__r.Loan_Status__c,
                                                        Asset__r.SBA_Loan_Y_N__c,
                                                        Asset__r.Loan_Original_Balance__c,
                                                        Asset__r.Current_Balance__c,
                                                        Asset__r.Loan_Original_Term__c,
                                                        Asset__r.Loan_Origination_Date__c,
                                                        Asset__r.Loan_Remaining_Term_years__c,
                                                        Asset__r.Loan_IO_Term_years__c,
                                                        Asset__r.Loan_Balloon_Payment__c,
                                                        Asset__r.Loan_Last_Payment_Date__c,
                                                        Asset__r.Loan_Maturity_Date__c,
                                                        Asset__r.Loan_Monthly_Payment_Amount__c,
                                                        Asset__r.Rate_Type__c,
                                                        Asset__r.Rate_Index__c,
                                                        Asset__r.Average_Daily_Rate__c,
                                                        Asset__r.Coupon_Rate__c,
                                                        Asset__r.Rate_Ceiling__c,
                                                        Asset__r.Rate_Floor__c,
                                                        Asset__r.Rate_Interest_Margin__c,
                                                        Asset__r.Rate_Initial_Fixed_Period__c,
                                                        Asset__r.Rate_Adjustment_Frequency__c,
                                                        Asset__r.Rate_First_Adjustment_Date__c,
                                                        Asset__r.Rate_Next_Adjustment_Date__c,
                                                        Asset__r.Rate_Periodic_Adjustment_Amount__c,
                                                        Asset__r.Accrual_Method__c,
                                                        Asset__r.Occupancy__c,
                                                        Asset__r.Impound_Balance_Field__c,
                                                        Asset__r.Occupancy_as_of_Date__c,
                                                        Asset__r.NOI__c,
                                                        Asset__r.NOI_Date__c,
                                                        Asset__r.NOI_Period_months__c,
                                                        Asset__r.Borrower__c,
                                                        Asset__r.Borrower_Bankruptcy_Y_N__c,
                                                        Asset__r.NOD_Date__c,
                                                        Asset__r.Receiver__c,
                                                        Asset__r.Foreclosure_Attorney__c,
                                                        Asset__r.Recourse__c,
                                                        Asset__r.Impounds__c,
                                                        Asset__r.Loan_Participation__c,
                                                        Asset__r.Loan_Prepayment_Provision__c,
                                                        Loan_Participation_Lead__c,
                                                        Days_on_Market_CRE__c,
                                                        Executive_Summary_Link__c,
                                                        Appraisal_Most_Recent_Date__c,
                                                        Appraisal_Most_Recent_Value__c,
                                                        Appraisal_Original_Date__c,
                                                        Appraisal_Original_Value__c,
                                                        Prev_Valued_To__c,
                                                        Current_Listing_Price__c,
                                                        Asset__r.Offer_Amount__c,
                                                        Asset__r.Offer_Date__c,
                                                        Current_LTV__c,
                                                        Current_DSCR__c,
                                                        MLH_Pool_Number__c,
                                                        Asset__r.Additional_Information__c,
                                                        Value_REDC_High__c,
                                                        Value_REDC_Low__c,
                                                        Value_REDC_Mod__c,
                                                        Value_REDC_Date__c,
                                                        Value_Broker_LSA_High__c,
                                                        Value_Broker_LSA_Low__c,
                                                        Value_Broker_LSA_Mod__c,
                                                        Value_Broker_LSA_Date__c,
                                                        Value_Seller_High__c,
                                                        Value_Seller_Low__c,
                                                        Value_Seller_Mod__c,
                                                        Value_Seller_Date__c,
                                                        Asset__r.Listing_Agreement__c,
                                                        Asset__r.Listing_Agreement_Date__c,
                                                        Listing_Agreement_Date_Expiration_Date__c,
                                                        Co_Op_Commission__c,
                                                        Asset__r.FSBO__c,
                                                        Broker_RE_License_Number__c,
                                                        Broker_RE_License_State__c,
                                                        Broker_Agent__r.Name,
                                                        Broker_Agent_Email_F__c,
                                                        Broker_Agent_Phone__c,
                                                        Broker_Agent_Phone_Extension__c,
                                                        Brokerage__c,
                                                        Broker_Agent_Street__c,
                                                        Broker_Agent_City__c,
                                                        Broker_Agent_State__c,
                                                        Broker_Agent_County__c,
                                                        Broker_Agent_Postal_Zip__c,
                                                        Second_Broker_LSA_License_No__c,
                                                        Second_Broker_LSA_License_State__c,
                                                        Second_Broker_LSA_Company__c,
                                                        Second_Broker_LSA_Email__c,
                                                        Second_Broker_LSA_Phone__c,
                                                        Second_Broker_LSA_Contact__c,
                                                        Second_Broker_LSA_Street__c,
                                                        Second_Broker_LSA_City__c,
                                                        Second_Broker_LSA_State__c,
                                                        Second_Broker_LSA_County__c,
                                                        Second_Broker_LSA_Zip_Postal_Code__c,
                                                        Third_Broker_LSA_License_No__c,
                                                        Third_Broker_LSA_License_State__c,
                                                        Third_Broker_LSA_Contact__c,
                                                        Third_Broker_LSA_Email__c,
                                                        Third_Broker_LSA_Phone__c,
                                                        Third_Broker_LSA_Company__c,
                                                        Third_Broker_LSA_Street_Address__c,
                                                        Third_Broker_LSA_City__c,
                                                        Third_Broker_LSA_State__c,
                                                        Third_Broker_LSA_County__c,
                                                        Third_Broker_LSA_Zip__c,
                                                        Closing_Company__c,
                                                        Closing_Company_Assigned_By__c,
                                                        Closing_Company_Contact__c,
                                                        Closing_Company_Contact_Email__c,
                                                        Closing_Company_Contact_Phone__c,
                                                        Closing_Company_Street_Address__c,
                                                        Closing_Company_City__c,
                                                        Closing_Company_State__c,
                                                        Closing_Company_Zip__c,
                                                        Title_Company_Name__c,
                                                        Title_Report__c,
                                                        Title_Report_Date__c,
                                                        Title_Ordered_By__c,
                                                        Title_Approval_Approved_Rejected_Date__c,
                                                        TitleReceivedDate__c,
                                                        Title_Underwriter__c,
                                                        Asset__r.Amortization__c,
                                                        Asset__r.Amortization_Period_years__c,
                                                        Property_Reserve_Price__c,
                                                        Reserve_Subject_To__c,
                                                        Starting_Bid__c,
                                                        Asset_Level_Deposit__c,
                                                        Updated_Link_Address__c,
                                                        Notes_Internal_ID__c,
                                                        Updated_Subject_To_Reserve__c,
                                                        Financing_Available__c,
                                                        Financing_Pre_Qual_Deadline__c,
                                                        Use_Address_Only__c,
                                                        Average_Current_Balance__c,
                                                        Multi_City_List__c,
                                                        Multi_County_List__c,
                                                        Multi_State_List__c,
                                                        Multi_Zip_List__c,
                                                        Asset__r.Certified_Diligence__c,
                                                        Asset__r.Ownership_Sold__c,
                                                        Asset__r.Free_Clear_Title__c,
                                                        Asset__r.Minimum_BP__c,
                                                        Asset__r.Property_Overview__c,
                                                        Asset__r.Investment_Opportunity__c,
                                                        Asset__r.Market_Information__c,
                                                        Asset__r.Tenancy__c,
                                                        Asset__r.Building_Class__c,
                                                        Asset__r.Investment_Class__c,
                                                        Asset__r.Lease_Service__c,
                                                        Asset__r.Second_Property_Type__c,
                                                        Guidance_High_Value__c,
                                                        Guidance_Low_Value__c,
                                                        Prob_of_Sale_High__c,
                                                        Prob_of_Sale_Low__c,
                                                        Flex__c,                                                                                  
                                                        Bid_Agreement_Flag__c,
                                                        Type_of_Sale__c,
                                                        Asset__r.Total_Room_Count__c,
                                                        Property_Video_URL__c
                          FROM Opportunity  
                          WHERE Id IN :OppIds ]);  
        
        Map<Id,MLH_Asset.Assets> mlhUploadMap = MLH_Asset_SF_Mapper.CreatePropertiesList(OppList); 

        MLH_Asset mlhAssets = new MLH_Asset();
        mlhAssets.Assets = mlhUploadMap.values(); 
        String AssetsJSON = JSON.serialize(mlhAssets); 
        system.debug('MLH Input => ' +AssetsJSON);
        return AssetsJSON;    
    }

}