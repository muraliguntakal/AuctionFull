public class MLH_Asset_SF_Mapper { //mlhMapSFDCFields

   public static Map<Id,MLH_Asset.Assets> CreatePropertiesList(List<Opportunity> OppList) {        
        Map<Id,MLH_Asset.Assets> pcmMap = new Map<Id,MLH_Asset.Assets>();

        for (Opportunity Opp : OppList) {
            MLH_Asset.Assets pcm = new MLH_Asset.Assets ();
            pcm.event_type = 'commercial';
            pcm.global_asset_id = Opp.Asset__r.MLH_Global_Property_ID__c;  
            pcm.asset_id = Opp.Asset__r.NAF_Global_Property_ID__c;
            system.debug(' TOS => ' +opp.Type_of_Sale__c+ ' P ID ' +Opp.Asset__r.NAF_Global_Property_ID__c);
            pcm.event_number = Opp.Most_Recent_Auction_Event__c;
            //pcm.event_day_sequence = Opp.Auction_day_sequence__c;
            pcm.redc_id = Opp.MLH_REDC_ID__c;
            if(Opp.Asset__r.System_Add_Date__c!=null) {
                pcm.system_add_date = mlhdateformat(Opp.Asset__r.System_Add_Date__c);
            }
            pcm.auction_status = Opp.Auction_Opportunity_Assignment__r.Status__c;
            if(Opp.Auction_Opportunity_Assignment__r.Removal_Date__c!=null) {
                pcm.removal_date = mlhdateformat(Opp.Auction_Opportunity_Assignment__r.Removal_Date__c);
            }
            pcm.event_status = Opp.Auction_Opportunity_Assignment__r.Status__c!=null? Opp.Auction_Opportunity_Assignment__r.Status__c : 'Auction';
            pcm.removal_reason = Opp.Auction_Opportunity_Assignment__r.Removal_Reason__c;
            pcm.removal_requested_by = Opp.Auction_Opportunity_Assignment__r.Removal_Requested_By__c;
            pcm.seller = Opp.MLH_Seller_Code__c;
            pcm.seller_contact = Opp.Seller__r.Name;
            pcm.seller_contact_email = Opp.Seller_Email_F__c;

            if(Opp.Seller_Phone__c!=null) {   
                pcm.seller_contact_phone = formatPhone(Opp.Seller_Phone__c);
            }
            pcm.seller_loan_number = Opp.Loan_Number__c;
            pcm.has_additional_seller = Opp.Additional_Seller__c;
            pcm.additional_seller_contact = Opp.Additional_Seller_Contact__c;
            pcm.additional_seller_email = Opp.Additional_Seller_Contact_Email__c;
            if(Opp.Additional_Seller_Contact_Phone__c!=null) {
                pcm.additional_seller_phone = formatPhone(Opp.Additional_Seller_Contact_Phone__c);
            }
            pcm.additional_seller_name = Opp.Additional_Seller_Name__c;
            pcm.asset_manager_email = Opp.Asset_Manager_Email__c;
            pcm.asset_manager_name = Opp.Asset_Manager_Name__c;
            if(Opp.Asset_Manager_Phone__c!=null) {
                pcm.asset_manager_phone = formatPhone(Opp.Asset_Manager_Phone__c);
            }
            pcm.executive_summary_link = opp.Executive_Summary_Link__c;
            pcm.product_type = Opp.Asset__r.Product_Type__c;
            pcm.asset_type = Opp.Asset__r.Property_Type__c;
            pcm.asset_sub_type = Opp.Asset__r.Property_Sub_Type__c;
            pcm.asset_name = Opp.Asset__r.Property_Name__c;
            if(Opp.Asset__r.Property_Description__c!=null) {
                pcm.asset_description = cleanText(Opp.Asset__r.Property_Description__c);
            }
            if(Opp.Marketing_Description__c!=null) {
                pcm.marketing_comments = cleanText(Opp.Marketing_Description__c);
            }
            pcm.asset_address = Opp.Asset__r.Property_Street__c;
            pcm.asset_city = Opp.Asset__r.Property_City__c;
            pcm.asset_state = Opp.Asset__r.Property_State__c;
            pcm.asset_county = Opp.Asset__r.Property_County__c;
            pcm.asset_zip = Opp.Asset__r.Property_Zip_Postal_Code__c;
            pcm.year_built = Opp.Asset__r.Year_Built__c;
            pcm.apn = Opp.Asset__r.APN__c;
            pcm.lot_size = Opp.Asset__r.Lot_Size_Acres__c;
            pcm.gross_square_footage = Opp.Asset__r.Gross_Square_Footage_SF__c;
            pcm.net_rentable_area = Opp.Asset__r.Net_Rentable_Area_SF__c;
            pcm.baths = Opp.Asset__r.Baths__c;
            pcm.beds = Opp.Asset__r.Bedrooms__c;
            pcm.number_of_buildings = Opp.Asset__r.Number_of_Buildings__c;
            pcm.number_of_keys = Opp.Asset__r.Number_of_Keys__c;
            pcm.number_of_stories = Opp.Asset__r.Number_of_Stories__c;
            pcm.number_of_units = Opp.Asset__r.Number_of_Units__c;
            pcm.lien_position = Opp.Asset__r.Lien_Position__c;
            pcm.loan_status = Opp.Asset__r.Loan_Status__c;
            pcm.small_business_administration_loan = Opp.Asset__r.SBA_Loan_Y_N__c;
            pcm.loan_original_balance = Opp.Asset__r.Loan_Original_Balance__c;
            pcm.current_balance = Opp.Asset__r.Current_Balance__c;
            pcm.loan_original_term = Opp.Asset__r.Loan_Original_Term__c;
            if(Opp.Asset__r.Loan_Origination_Date__c!=null) {
                pcm.loan_origination_date = mlhdateformat(Opp.Asset__r.Loan_Origination_Date__c);
            }
            pcm.loan_remaining_term = Opp.Asset__r.Loan_Remaining_Term_years__c;
            pcm.loan_intrest_only_term = Opp.Asset__r.Loan_IO_Term_years__c;
            pcm.loan_balloon_payment = Opp.Asset__r.Loan_Balloon_Payment__c;
            if(Opp.Asset__r.Loan_Last_Payment_Date__c!=null) {
                pcm.loan_last_payment_date = mlhdateformat(Opp.Asset__r.Loan_Last_Payment_Date__c);
            }

            if(Opp.Asset__r.Loan_Maturity_Date__c!=null) {
                pcm.loan_maturity_date =mlhdateformat(Opp.Asset__r.Loan_Maturity_Date__c);
            }
            pcm.loan_monthly_payment_amount = Opp.Asset__r.Loan_Monthly_Payment_Amount__c;
            pcm.rate_type = Opp.Asset__r.Rate_Type__c;
            pcm.rate_index = Opp.Asset__r.Rate_Index__c;
            pcm.average_daily_rate = Opp.Asset__r.Average_Daily_Rate__c;
            pcm.coupon_rate = Opp.Asset__r.Coupon_Rate__c;
            pcm.rate_ceiling = Opp.Asset__r.Rate_Ceiling__c;
            pcm.rate_floor = Opp.Asset__r.Rate_Floor__c;
            pcm.rate_interest_margin = Opp.Asset__r.Rate_Interest_Margin__c;
            pcm.rate_initial_fixed_period = Opp.Asset__r.Rate_Initial_Fixed_Period__c;
            pcm.rate_adjustment_frequency = Opp.Asset__r.Rate_Adjustment_Frequency__c;
            pcm.current_list_price = Opp.Current_Listing_Price__c;
            if(Opp.Asset__r.Rate_First_Adjustment_Date__c!=null) {
                pcm.rate_first_adjustment_date = mlhdateformat(Opp.Asset__r.Rate_First_Adjustment_Date__c);
            }
            if(Opp.Asset__r.Rate_Next_Adjustment_Date__c!=null) {
                pcm.rate_next_adjustment_date = mlhdateformat(Opp.Asset__r.Rate_Next_Adjustment_Date__c);
            }
            pcm.rate_periodic_adjustment_amount = Opp.Asset__r.Rate_Periodic_Adjustment_Amount__c;
            pcm.accrual_method = Opp.Asset__r.Accrual_Method__c;
            pcm.occupancy_rate = Opp.Asset__r.Occupancy__c;
            pcm.impound_balance_field = Opp.Asset__r.Impound_Balance_Field__c;
            if(Opp.Asset__r.Occupancy_as_of_Date__c!=null) {
                pcm.occupancy_as_of_date = mlhdateformat(Opp.Asset__r.Occupancy_as_of_Date__c);
            }
            pcm.net_operating_income = Opp.Asset__r.NOI__c;
            if(Opp.Asset__r.NOI_Date__c!=null) {
                pcm.net_operating_income_as_of_date = mlhdateformat(Opp.Asset__r.NOI_Date__c);
            }
            pcm.net_operating_income_period = Opp.Asset__r.NOI_Period_months__c;
            if(Opp.Asset__r.Borrower__c!=null) {
                pcm.borrower = cleanText(Opp.Asset__r.Borrower__c);
            }
            pcm.is_borrower_bankrupt = Opp.Asset__r.Borrower_Bankruptcy_Y_N__c;
            if(Opp.Asset__r.NOD_Date__c!=null) {
                pcm.notice_of_default_date = mlhdateformat(Opp.Asset__r.NOD_Date__c);
            }
            pcm.receiver = Opp.Asset__r.Receiver__c;
            pcm.forclosure_attorney = Opp.Asset__r.Foreclosure_Attorney__c;
            pcm.recourse = Opp.Asset__r.Recourse__c;
            pcm.has_impounds = Opp.Asset__r.Impounds__c;
            pcm.loan_participation = Opp.Asset__r.Loan_Participation__c;
            pcm.loan_participation_lead = Opp.Loan_Participation_Lead__c;
            pcm.loan_prepayment_provision = Opp.Asset__r.Loan_Prepayment_Provision__c;
            pcm.days_on_market = Opp.Days_on_Market_CRE__c;
            if(Opp.Appraisal_Most_Recent_Date__c!=null) {
                pcm.recent_appraisal_date = mlhdateformat(Opp.Appraisal_Most_Recent_Date__c);
            }
            pcm.recent_appraisal_value = Opp.Appraisal_Most_Recent_Value__c;
            if(Opp.Appraisal_Original_Date__c!=null) {
                pcm.original_appraisal_date = mlhdateformat(Opp.Appraisal_Original_Date__c);
            }
            pcm.original_appraisal_value = Opp.Appraisal_Original_Value__c;
            pcm.previously_valued_to = Opp.Prev_Valued_To__c;
            pcm.current_list_price = Opp.Current_Listing_Price__c;
            pcm.last_offer_amount = Opp.Asset__r.Offer_Amount__c;

            if(Opp.Asset__r.Offer_Date__c!=null) {
                pcm.last_offer_date= mlhdateformat(Opp.Asset__r.Offer_Date__c);
            }
            
            pcm.current_loan_to_value = Opp.Current_LTV__c;
            pcm.current_debt_service_coverage_ratio = Opp.Current_DSCR__c;
            pcm.seller_code = Opp.MLH_Pool_Number__c;
            pcm.additional_information = Opp.Asset__r.Additional_Information__c;
            pcm.value_redc_high = Opp.Value_REDC_High__c;
            pcm.value_redc_low = Opp.Value_REDC_Low__c;
            pcm.value_redc_mod = Opp.Value_REDC_Mod__c;

            if(Opp.Value_REDC_Date__c!=null) {
                pcm.value_redc_date = mlhdateformat(Opp.Value_REDC_Date__c);
            }

            pcm.value_broker_high = Opp.Value_Broker_LSA_High__c;
            pcm.value_broker_low = Opp.Value_Broker_LSA_Low__c;
            pcm.value_broker_mod = Opp.Value_Broker_LSA_Mod__c;
            if(Opp.Value_Broker_LSA_Date__c!=null) {
                pcm.value_broker_date = mlhdateformat(Opp.Value_Broker_LSA_Date__c);
            }
            pcm.value_seller_high = Opp.Value_Seller_High__c;
            pcm.value_seller_low = Opp.Value_Seller_Low__c;
            pcm.value_seller_mod = Opp.Value_Seller_Mod__c;
            if(Opp.Value_Seller_Date__c!=null) {
                pcm.value_seller_date = mlhdateformat(Opp.Value_Seller_Date__c);
            }
            pcm.listing_agreement = Opp.Asset__r.Listing_Agreement__c;
            if(Opp.Asset__r.Listing_Agreement_Date__c!=null) {
                pcm.listing_agreement_date = mlhdateformat(Opp.Asset__r.Listing_Agreement_Date__c);
            }            

            if(Opp.Listing_Agreement_Date_Expiration_Date__c!=null) {
                pcm.listing_aggrement_expiration_date = mlhdateformat(Opp.Listing_Agreement_Date_Expiration_Date__c);
            }
            pcm.broker_commission = Opp.Co_Op_Commission__c;
            pcm.is_first_sale_by_owner = Opp.Asset__r.FSBO__c;
            pcm.broker_license_number = Opp.Broker_RE_License_Number__c;
            pcm.broker_license_state = Opp.Broker_RE_License_State__c;
            pcm.sf_contact_id = opp.Broker_Agent__c;
            pcm.broker_name = Opp.Broker_Agent__r.Name;
            pcm.broker_email = Opp.Broker_Agent_Email_F__c;
            if(Opp.Broker_Agent_Phone__c!=null) {
                pcm.broker_phone = formatPhone(Opp.Broker_Agent_Phone__c);
            }
            if(Opp.Broker_Agent_Phone_Extension__c!=null) {
                pcm.Broker_Phone_Extension = Opp.Broker_Agent_Phone_Extension__c;
            }
            pcm.listing_broker_company = Opp.Brokerage__c;
            pcm.broker_address = Opp.Broker_Agent_Street__c;
            pcm.broker_city = Opp.Broker_Agent_City__c;
            pcm.broker_state = Opp.Broker_Agent_State__c;
            pcm.broker_county = Opp.Broker_Agent_County__c;
            pcm.broker_zip = Opp.Broker_Agent_Postal_Zip__c;
            pcm.second_broker_license_number = Opp.Second_Broker_LSA_License_No__c;
            pcm.second_broker_license_state = Opp.Second_Broker_LSA_License_State__c;
            pcm.second_broker_firm = Opp.Second_Broker_LSA_Company__c;
            pcm.second_broker_email = Opp.Second_Broker_LSA_Email__c;
            if(Opp.Second_Broker_LSA_Phone__c!=null) {
                pcm.second_broker_phone = formatPhone(Opp.Second_Broker_LSA_Phone__c);
            }
            //if(Opp.Second_Broker_Phone_Ext__c!=null) {
            //    pcm.second_broker_phone_extension = Opp.Second_Broker_Phone_Ext__c);
            //}
            pcm.second_broker_contact = Opp.Second_Broker_LSA_Contact__c;
            pcm.second_broker_address = Opp.Second_Broker_LSA_Street__c;
            pcm.second_broker_city = Opp.Second_Broker_LSA_City__c;
            pcm.second_broker_state = Opp.Second_Broker_LSA_State__c;
            pcm.second_broker_county = Opp.Second_Broker_LSA_County__c;
            pcm.second_broker_zip = Opp.Second_Broker_LSA_Zip_Postal_Code__c;
            pcm.third_broker_license_number = Opp.Third_Broker_LSA_License_No__c;
            pcm.third_broker_license_state = Opp.Third_Broker_LSA_License_State__c;
            pcm.third_broker_contact = Opp.Third_Broker_LSA_Contact__c;
            pcm.third_broker_email = Opp.Third_Broker_LSA_Email__c;
            if(opp.Third_Broker_LSA_Phone__c!=null) {
                pcm.third_broker_phone = formatPhone(Opp.Third_Broker_LSA_Phone__c);
            }
            //if(Opp.Third_Broker_Phone_Ext__c!=null) {
            //    pcm.third_broker_phone_extension = Opp.Third_Broker_Phone_Ext__c);
            //}
            pcm.third_broker_firm = Opp.Third_Broker_LSA_Company__c;
            if(Opp.Third_Broker_LSA_Street_Address__c!=null) {
                pcm.third_broker_address = cleanText(Opp.Third_Broker_LSA_Street_Address__c);
            }
            pcm.third_broker_city = Opp.Third_Broker_LSA_City__c;
            pcm.third_broker_state = Opp.Third_Broker_LSA_State__c;
            pcm.third_broker_county = Opp.Third_Broker_LSA_County__c;
            pcm.third_broker_zip = Opp.Third_Broker_LSA_Zip__c;
            if(Opp.Closing_Company__c!=null) {
                pcm.closing_company = cleanText(Opp.Closing_Company__c);
            }
            pcm.closing_company_assigned_by = Opp.Closing_Company_Assigned_By__c;
            pcm.closing_company_contact = Opp.Closing_Company_Contact__c;
            pcm.closing_company_email = Opp.Closing_Company_Contact_Email__c;
            if(Opp.Closing_Company_Contact_Phone__c!=null) {
                pcm.closing_company_phone = formatPhone(Opp.Closing_Company_Contact_Phone__c);
            }
            pcm.closing_company_address = Opp.Closing_Company_Street_Address__c;
            pcm.closing_company_city = Opp.Closing_Company_City__c;
            pcm.closing_company_state = Opp.Closing_Company_State__c;
            pcm.closing_company_zip = Opp.Closing_Company_Zip__c;
            pcm.title_company_name = Opp.Title_Company_Name__c;
            pcm.title_report = Opp.Title_Report__c;

            if(Opp.Title_Report_Date__c!=null) {
                pcm.title_report_date = mlhdateformat(Opp.Title_Report_Date__c);
            }  
            pcm.title_ordered_by = Opp.Title_Ordered_By__c;
            if(Opp.Title_Approval_Approved_Rejected_Date__c!=null) {
                pcm.title_ordered_date = mlhdateformat(Opp.Title_Approval_Approved_Rejected_Date__c);
            }              
            if(Opp.TitleReceivedDate__c!=null) {
                pcm.title_received_date = mlhdateformat(Opp.TitleReceivedDate__c);
            }  
            pcm.title_underwriter = Opp.Title_Underwriter__c;
            pcm.amortization = Opp.Asset__r.Amortization__c;
            pcm.amortization_period = Opp.Asset__r.Amortization_Period_years__c;
            pcm.reserve = Opp.Property_Reserve_Price__c;
            pcm.reserve_subject_to = Opp.Reserve_Subject_To__c;
            pcm.starting_bid = Opp.Starting_Bid__c;
            pcm.asset_level_deposit = Opp.Asset_Level_Deposit__c;
            pcm.latitude_longitude = Opp.Updated_Link_Address__c;
            pcm.notes_internal_id = Opp.Notes_Internal_ID__c;
            pcm.updated_subject_to_reserve = Opp.Updated_Subject_To_Reserve__c;
            pcm.financing_available = Opp.Financing_Available__c;
            if(Opp.Financing_Pre_Qual_Deadline__c!=null) {
                pcm.financing_pre_qualification_date  = mlhdateformat(Opp.Financing_Pre_Qual_Deadline__c);
            }
            pcm.use_address_only = Opp.Use_Address_Only__c;
            pcm.average_current_balance = Opp.Average_Current_Balance__c;

            if(Opp.Multi_City_List__c!=null) {
                pcm.multi_city_list = cleanText(Opp.Multi_City_List__c);
            }    


            if(Opp.Multi_County_List__c!=null) {
                pcm.multi_county_list = cleanText(Opp.Multi_County_List__c);
            }    

            if(Opp.Multi_State_List__c!=null) {
                pcm.multi_state_list = cleanText(Opp.Multi_State_List__c);
            }

            if(Opp.Multi_Zip_List__c!=null) {                
                pcm.multi_zip_list= cleanText(Opp.Multi_Zip_List__c);
            }
            pcm.bid_agreement_flag = opp.Bid_Agreement_Flag__c;            
            pcm.salesforce_opportunity_id = Opp.Id;
            pcm.salesforce_id = Opp.Asset__r.Id;
            pcm.is_certified_diligence = Opp.Asset__r.Certified_Diligence__c;
            pcm.ownership_sold = Opp.Asset__r.Ownership_Sold__c;
            pcm.free_clear_title = Opp.Asset__r.Free_Clear_Title__c;
            pcm.minimum_buyer_premium = Opp.Asset__r.Minimum_BP__c;
            pcm.asset_overview = Opp.Asset__r.Property_Overview__c;
            pcm.investment_opportunity = Opp.Asset__r.Investment_Opportunity__c;
            pcm.market_information = Opp.Asset__r.Market_Information__c;
            pcm.tenancy = opp.Asset__r.Tenancy__c;
            pcm.building_class = opp.Asset__r.Building_Class__c;
            pcm.investment_class = opp.Asset__r.Investment_Class__c;
            pcm.lease_service = opp.Asset__r.Lease_Service__c;
            pcm.market_guidance_high = Opp.Guidance_High_Value__c;
            pcm.market_guidance_low = Opp.Guidance_Low_Value__c;
            pcm.probability_of_sale_high = Opp.Prob_of_Sale_High__c;
            pcm.probability_of_sale_low = Opp.Prob_of_Sale_Low__c;
            pcm.alternative_asset_type = Opp.Asset__r.Second_Property_Type__c;
            pcm.sale_type = opp.Type_of_Sale__c=='Offer Select'? 'NAF' : null;
            if(pcm!=null)
                pcmMap.put(Opp.Id,pcm);
            if(opp.Asset__r.Total_Room_Count__c!=null) {
                pcm.total_room_count = integer.valueof(opp.Asset__r.Total_Room_Count__c);
            }
            if(opp.Property_Video_URL__c != null) {
                pcm.property_video_url = String.valueof(opp.Property_Video_URL__c);
            }
        }
        return pcmMap;
    }
    
    public static string mlhdateformat (Date sfdate) {
        Datetime sfdateTime = datetime.newInstance(sfdate.year(), sfdate.month(),sfdate.day()); 
        String stDate = sfdateTime.format('MM/dd/yyyy');
        return stDate;
    }
/*
    public static string formatPhone (String sfPhone) {
        sfPhone = sfPhone.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]-', '');
        sfPhone = sfPhone.replaceAll( '\\s+', '');
        return sfPhone;
    }
*/

    public static String formatphone(String sfPhone) {
        String fphone = sfPhone.replaceAll('\\\\D','');
        if (fphone.length() == 10) {
            fphone = formatphonenum(fphone);
            return fphone;
        }
        else {
            return sfPhone;
        }
    }

    static String formatphonenum (String s) {
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }

    public static string cleanText (String sfText) {
        //sfText = sfText.replaceAll('[^\\x00-\\x7F]', ',');
        return sfText;
    }
}