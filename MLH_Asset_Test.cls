@isTest(SeeAllData=TRUE)
public class MLH_Asset_Test {
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '    \"assets\": ['+
        '        {'+
        '            \"aution\": \"commercial\",'+
        '           \"accrual_method\": null, '+
        '           \"additional_information\": null, '+
        '           \"has_additional_seller\": null, '+
        '           \"additional_seller_contact\": null, '+
        '           \"additional_seller_email\": null, '+
        '           \"additional_seller_name\": null, '+
        '           \"additional_seller_phone\": null, '+
        '           \"broker_email\": null, '+
        '           \"broker_name\": null, '+
        '           \"broker_phone\": null, '+
        '           \"broker_phone_extension\": null, '+
        '           \"broker_city\": null, '+
        '           \"broker_county\": null, '+
        '           \"broker_state\": null, '+
        '           \"broker_address\": null, '+
        '           \"broker_zip\": null, '+
        '           \"alternative_asset_type\": null, '+
        '           \"amortization\": null, '+
        '           \"amortization_period\": null, '+
        '           \"recent_appraisal_date\": null, '+
        '           \"recent_appraisal_value\": null, '+
        '           \"original_appraisal_date\": null, '+
        '           \"original_appraisal_value\": null, '+
        '           \"apn\": null, '+
        '           \"asset_level_deposit\": null, '+
        '           \"event_number\": null, '+
        '           \"event_day_sequence\": null, '+
        '           \"average_daily_rate\": null, '+
        '           \"average_current_balance\": null, '+
        '           \"baths\": null, '+
        '           \"beds\": null, '+
        '           \"borrower\": null, '+
        '           \"is_borrower_bankrupt\": null, '+
        '           \"second_broker_address\": null, '+
        '           \"third_broker_address\": null, '+
        '           \"second_broker_city\": null, '+
        '           \"third_broker_city\": null, '+
        '           \"second_broker_county\": null, '+
        '           \"third_broker_city\": null, '+
        '           \"second_broker_email\": null, '+
        '           \"third_broker_email\": null, '+
        '           \"second_broker_firm\": null, '+
        '           \"third_broker_firm\": null, '+
        '           \"broker_license_number\": null, '+
        '           \"second_broker_license_number\": null, '+
        '           \"third_broker_license_number\": null, '+
        '           \"broker_license_state\": null, '+
        '           \"second_broker_license_state\": null, '+
        '           \"third_broker_license_state\": null, '+
        '           \"second_broker_phone\": null, '+
        '           \"third_broker_phone\": null, '+
        '           \"second_broker_state\": null, '+
        '           \"third_broker_state\": null, '+
        '           \"second_broker_zip\": null, '+
        '           \"third_broker_zip\": null, '+
        '           \"broker_commission\": null, '+
        '           \"building_class\": null, '+
        '           \"is_certified_diligence\": null, '+
        '           \"closing_company_assigned_by\": null, '+
        '           \"closing_company_city\": null, '+
        '           \"closing_company_contact\": null, '+
        '           \"closing_company_email\": null, '+
        '           \"closing_company_phone\": null, '+
        '           \"closing_company\": null, '+
        '           \"closing_company_state\": null, '+
        '           \"closing_company_addtess\": null, '+
        '           \"closing_company_zip\": null, '+
        '           \"marketing_comments\": null, '+
        '           \"coupon_rate\": null, '+
        '           \"current_balance\": null, '+
        '           \"second_broker_contact\": null, '+
        '           \"third_broker_contact\": null, '+
        '           \"current_debt_service_coverage_ratio\": null, '+
        '           \"current_list_price\": null, '+
        '           \"current_loan_to_value\": null, '+
        '           \"days_on_market\": null, '+
        '           \"executive_summary_link\": null, '+
        '           \"financing_available\": null, '+
        '           \"financing_pre_qualification_date\": null, '+
        '           \"forclosure_attorney\": null, '+
        '           \"free_clear_title\": null, '+
        '           \"is_first_sale_by_owner\": null, '+
        '           \"global_asset_id\": null, '+
        '           \"asset_manager_name\": null, '+
        '           \"asset_manager_email\": null, '+
        '           \"asset_manager_phone\": null, '+
        '           \"gross_square_footage\": null, '+
        '           \"impound_balance_field\": null, '+
        '           \"has_impounds\": null, '+
        '           \"investment_class\": null, '+
        '           \"investment_opportunity\": null, '+
        '           \"lot_size\": null, '+
        '           \"last_offer_amount\": null, '+
        '           \"last_offer_date\": null, '+
        '           \"lease_service\": null, '+
        '           \"lien_position\": null, '+
        '           \"listing_agreement\": null, '+
        '           \"listing_agreement_date\": null, '+
        '           \"listing_aggrement_expiration_date\": null, '+
        '           \"listing_broker_company\": null, '+
        '           \"loan_balloon_payment\": null, '+
        '           \"loan_intrest_only_term\": null, '+
        '           \"loan_last_payment_date\": null, '+
        '           \"loan_maturity_date\": null, '+
        '           \"loan_monthly_payment_amount\": null, '+
        '           \"seller_loan_number\": null, '+
        '           \"loan_original_balance\": null, '+
        '           \"loan_original_term\": null, '+
        '           \"loan_origination_date\": null, '+
        '           \"loan_participation\": null, '+
        '           \"loan_participation_lead\": null, '+
        '           \"loan_prepayment_provision\": null, '+
        '           \"loan_remaining_term\": null, '+
        '           \"loan_status\": null, '+
        '           \"market_guidance_high\": null, '+
        '           \"market_guidance_low\": null, '+
        '           \"market_information\": null, '+
        '           \"minimum_buyer_premium\": null, '+
        '           \"multi_city_list\": null, '+
        '           \"multi_county_list\": null, '+
        '           \"multi_state_list\": null, '+
        '           \"multi_zip_list\": null, '+
        '           \"net_rentale_area\": null, '+
        '           \"notice_of_default_date\": null, '+
        '           \"net_operating_income\": null, '+
        '           \"net_operating_income_as_of_date\": null, '+
        '           \"net_operating_income_period\": null, '+
        '           \"notes_internal_id\": null, '+
        '           \"number_of_keys\": null, '+
        '           \"number_of_buildings\": null, '+
        '           \"number_of_stories\": null, '+
        '           \"number_of_units\": null, '+
        '           \"occupancy_rate\": null, '+
        '           \"occupancy_as_of_date\": null, '+
        '           \"ownership_sold\": null, '+
        '           \"seller_code\": null, '+
        '           \"previously_valued_to\": null, '+
        '           \"probability_of_sale_high\": null, '+
        '           \"probability_of_sale_low\": null, '+
        '           \"product_type\": null, '+
        '           \"asset_address\": null, '+
        '           \"asset_city\": null, '+
        '           \"asset_county\": null, '+
        '           \"asset_overview\": null, '+
        '           \"asset_state\": null, '+
        '           \"asset_sub_type\": null, '+
        '           \"asset_type\": null, '+
        '           \"asset_zip\": null, '+
        '           \"asset_description\": null, '+
        '           \"asset_name\": null, '+
        '           \"rate_adjustment_frequency\": null, '+
        '           \"rate_ceiling\": null, '+
        '           \"rate_first_adjustment_date\": null, '+
        '           \"rate_floor\": null, '+
        '           \"rate_index\": null, '+
        '           \"rate_initial_fixed_period\": null, '+
        '           \"rate_interest_margin\": null, '+
        '           \"rate_next_adjustment_date\": null, '+
        '           \"rate_periodic_adjustment_amount\": null, '+
        '           \"rate_type\": null, '+
        '           \"receiver\": null, '+
        '           \"recourse\": null, '+
        '           \"redc_id\": null, '+
        '           \"removal_date\": null, '+
        '           \"removal_reason\": null, '+
        '           \"removal_requested_by\": null, '+
        '           \"reserve\": null, '+
        '           \"small_business_administration_loan\": null, '+
        '           \"seller\": null, '+
        '           \"seller_contact\": null, '+
        '           \"seller_contact_email\": null, '+
        '           \"seller_contact_phone\": null, '+
        '           \"salesforce_id\": null, '+
        '           \"salesforce_opportunity_id\": null, '+
        '           \"starting_bid\": null, '+
        '           \"auction_status\": null, '+
        '           \"reserve_subject _to\": null, '+
        '           \"system_add_date\": null, '+
        '           \"tenancy\": null, '+
        '           \"title_company_name\": null, '+
        '           \"title_ordered_by\": null, '+
        '           \"title_ordered_date\": null, '+
        '           \"title_received_date\": null, '+
        '           \"title_report\": null, '+
        '           \"title_report_date\": null, '+
        '           \"title_underwriter\": null, '+
        '           \"latitude_longitude\": null, '+
        '           \"updated_subject_to_reserve\": null, '+
        '           \"use_address_only\": null, '+
        '           \"value_broker_date\": null, '+
        '           \"value_broker_high\": null, '+
        '           \"value_broker_low\": null, '+
        '           \"value_broker_mod\": null, '+
        '           \"value_redc_date\": null, '+
        '           \"value_redc_low\": null, '+
        '           \"value_redc_mod\": null, '+
        '           \"value_redc_high\": null, '+
        '           \"value_seller_date\": null, '+
        '           \"value_seller_high\": null, '+
        '           \"value_seller_low\": null, '+
        '           \"value_seller_mod\": null, '+
        '           \"year_built\": null'+
        ''+
        '        }'+
        '    ]'+
        '}';
        MLH_Asset r = new MLH_Asset();
        List<MLH_Asset.Assets> asList = new List<MLH_Asset.Assets>();  
        r= MLH_Asset.parse(json);
        System.assert(r != null);
    }

/*
    Private Static testmethod void TestSyncToMLH() {
        //Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id FROM Opportunity WHERE RecordTypeId = :Commercial_Opportunity_Rectype_Id LIMIT 1 WHERE Auction_Opportunity_Assignment__c!=null]); 
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null LIMIT 1]));
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
        mlhauthController.SyncToMLH();
    }
*/

}