public class OpportunityClone {
/*
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    private Opportunity opp {get;set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}
 
    // initialize the controller
    public OpportunityClone (ApexPages.StandardController controller) {
 
        //initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        opp = (Opportunity)controller.getRecord();
 
    }
 
    // method called from the VF's action attribute to clone the po
    public PageReference setFields() { 
         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         Opportunity newOpp;
 
         try {
             //Clone Current Opportunity
             opp = [ SELECT Id, ADC_AMA_Sign_Off_Date__c,SS_Unique_Opp__c, ADC_Pricing_High_Value_Range__c, ADC_Pricing_Low_Value_Range__c, ADC_Pricing__c, AMA_Agreement_Docs_Ready__c, AMA_SSAI_Received_Date__c, AMA_Status_Change_Date__c, APN__c, AVM_Date__c, AVM__c, AccountId, Actual_BTS__c, Additional_terms__c, Agent_Affiliation__c, Agent_Reception__c, Amount, Analyst__c, Appraisal_BPO_Date__c, Appraisal_Order_Approval_Status__c, Appraisal_or_BPO_Value__c, Asset_Manager_Email__c, Asset_Manager_Name__c, Asset_Manager_Phone__c,Asset_Manager_Comments__c,Asset__c, Auction_2_Bid_End__c, Auction_2_Bid_Start__c, Auction_2nd_Run__c, Auction_3_Bid_End__c, Auction_3_Bid_Start__c, Auction_3rd_Run__c, Auction_4_Bid_End__c, Auction_4_Bid_Start__c, Auction_4th_Run__c, Auction_Active__c, Auction_Day_DOM__c, Auction_Day_Status__c, Auction_End_Date_2__c, Auction_End_Date_3__c, Auction_End_Date_4__c, Auction_End_Date__c, Auction_Opportunity_Assignment__c, Auction__c, Auctioned__c, Authorized_3rd_Party_Emaiil__c, Authorized_3rd_Party_Mobile_Number__c, Authorized_3rd_Party_Name__c, Authorized_3rd_Party_Phone_Extension__c, Authorized_3rd_Party_Phone_Number__c, Avg_Carrying_Costs__c, Avg_DOM_of_Listings__c, Avg_DOM_of_S_S_in_12ms__c, Avg_DOM_of_S_S_in_3ms__c, BAC_SF_Auction_ID__c, BAC_Salesforce_CTID__c, BPO_Order_Type__c, BTS_Date__c, Bankruptcy__c, Batch_ID__c, Batch_Received_Date__c, Baths__c, Bedrooms__c, Bid_End__c, Bid_Start__c, Borrower_Address__c, Borrower_City__c, Borrower_County1__c, Borrower_County__c, Borrower_State__c, Borrower_Zip_Code__c, Brand_Treatment__c, Broker_Agent_Address__c, Broker_Agent_Authorized__c, Broker_Agent_City__c, Broker_Agent_Email_F__c, Broker_Agent_Email__c, Broker_Agent_Fax_No__c, Broker_Agent_First_Name__c, Broker_Agent_Last_Name__c, Broker_Agent_Mobile_Number__c, Broker_Agent_Phone_Extension__c, Broker_Agent_Phone__c, Broker_Agent_Postal_Zip__c, Broker_Agent_State__c, Broker_Agent_Street__c, Broker_Agent_Title__c, Broker_Agent_Welcome_Email_Sent__c, Broker_Agent__c, Broker_RE_License_Number__c, Broker_RE_License_State__c, Brokerage__c, CMBS_Loan__c, CRE_Category_O__c, CRE_Sub_Category_O__c, CRE_or_Notes__c, CampaignId, Cap_Rate__c, Clear_Title__c, Client_Manager__c, CloseDate, Combined_Borrower_Names__c, Comments__c, Commission_Buyer__c, Commission_Listing_W_O_Coop_Broker__c, Commission_Listing__c, Conforming_Style__c, Create_Agreement_C2C__c, Create_Agreement_Sold_com__c, Create_Agreements_AMA__c, Create_Agreements_Arizona_AMA__c, Create_Agreements_NSM_HUD__c, Create_Agreements_SS__c, Create_Date_is_This_Week__c, CreatedById, CreatedDate, Created_From_Contact__c, Created_From_Lead__c, Current_Listing_Price__c, Current_MLS_Status__c, Current_NOI__c, Current_Revenue__c, Current_SP_LP_Ratio__c, Current_Seller_Re__c, Current_Seller_Reserve_Received_Date__c, DB_Competitor__c, DOM__c, Date_Asset_Submitted_Ready_For_Auction__c, Day_One__c, Day_of_the_Week__c, Debt__c, Deferred_Maintenance__c, Description, Escalation_Caused_by__c, Escalation_Reason__c, Estimated_BTS__c, Estimated_Delivery_Date__c, Estimated_Flow_per_Month__c, Exceptions_to_Seller_Warranties__c, Featured__c, Fee_Leasehold_Interest__c, Finance_Notes__c, First_Auction_Assignment__c, Fiscal, FiscalQuarter, FiscalYear, Fixtures_to_be_Excluded_in_Sale__c, Fixtures_to_be_Excluded_in_Sales__c, Flex__c, Foot_Traffic__c, For_Appraisal_Order_Approval__c, For_Reserve_Price_Approval__c, For_Title_Approval__c, For_Valuation_Approval__c, ForecastCategory, ForecastCategoryName, Frequency_of_Assets__c, GMV__c, HA_Vendor_Email__c, HOA_Name__c, HOA_Phone__c, HasOpportunityLineItem, Has_All_Market_Validation_Info__c, Highest_Bid__c, Highest_Offer_To_Date__c, Home_Assessment_Date__c, Home_Assessment_Order_Status__c, Home_Warranty_Available__c, How_much_is_the_HOA__c, IVG_Date__c, IVG__c, Import_ID__c, Open_House_Lookup_1__c,Open_House_Lookup_2__c,Open_House_Lookup_3__c,Open_House_3__c, Internal_Appraisal_Predominant_Tract__c, Internal_Appraisal_Value__c, Internal_Finance_Status__c, Internal_Notes__c, Investor_Loan_Number__c, IsClosed, IsDeleted, IsPrivate, IsSplit, IsWon, Is_it_financeable__c, Is_there_an_HOA__c, Kickoff_Call_Date__c, LOA_Status_Change_Date__c, LOA_Status__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Latest_Auction_End_Date__c, Latest_Auction_Run_Date__c, Latest_Auction_Run_Number__c, Latest_Auction_Run__c, Latest_Opportunity__c, LeadSource, Lead_Provider__c, Lead_Record_Type__c, Lead_Source_Filename__c, Lease_Expiration_Date__c, Lease_Terms_Months__c, Liquid_Market__c, List_Agent_Preferred_Closing_Co_Contact__c, List_Agent_Preferred_Closing_Co_Email__c, List_Agent_Preferred_Closing_Co_Phone__c, List_Agent_Preferred_Closing_Co__c, List_Agent__c, List_Assist_Agent__c, Listing_Agent_Account__c, Listing_Agent_Address__c, Listing_Agent_Email__c, Listing_Agent_Phone__c, Listing_Agent__c, Listing_Agreement_Date_Expiration_Date__c, Listing_Agreement_Date_Listing_Date__c, Listing_Expiration__c, Listing_Start_Date__c, Loan_Last_3__c, Loan_Number__c, Location_Ok__c, Lockbox_Barcode__c, Lockbox_Sent_Date__c, Lockbox__c, Lot_Size_Acres__c, Lot_Size__c, MI_Company_Name__c, MI_Flag__c, MLH_Bid_Start_Date__c, MLH_Financing_Type__c, MLH_REDC_Finance__c, MLH_Seller_Finance__c, MLS_Auction_Update_Date__c, MLS_ID__c, MLS_Printout_Reviewed_By__c, MLS_Printout_Reviewed_Date__c, MR_Property_ID__c, MR_Redc_ID__c, Marketing_Plan__c, Max_Acceptable_Variation_Percentage__c, Median_SP_Change_in_12ms__c, Median_SP_Change_in_3ms__c, Monthly_Rent__c,Most_Recent_Valuation__c,MLS_Comments__c,
                            NSM_Freddie_Docs_Ready__c, NSM_HUD_Docs_Ready__c, NSM_NonFreddie_Doc_Display_Name__c, NSM_NonFreddie_Doc_TNC__c, NSM_Non_Freddie_Doc_Template_ID__c, NSM_Non_Freddie_Docs_Ready__c, Name, Net_Offer_Amount__c, Net_Rentable_Area_SF__c, New_Investor__c, NextStep, Next_Contact_Date__c, Note_Balance_Existing_Debt__c, Notice_of_Default_Date__c, Num_Units_Rooms__c, Num_of_Assets__c, Num_of_Competing_Listings__c,
                            Num_of_Similar_Sales_in_12ms__c, Num_of_Similar_Sales_in_3ms__c, Num_of_Units__c, Occupancy__c, Offer_Amount__c, Open_House_Status__c, Opp_Age__c, Opp_Owner__c, Opportunity_Recycled__c, Oracle_Lead_Row_ID__c, Original_Listing_Price__c, Original_MLS_List_Price__c, Original_offer_MLS_Status__c, Override_Revenue_Amount__c, OwnerId, Parent_SFDC_Oppty_ID__c, Pre_MLH_Integration__c, Predominate_Tract_Value__c, Prepayment_Defeasement__c, Prev_Valued_To__c,Previous_Listing_Price__c, Price_SF__c, Price_Seller_Purchased_Home__c, Price_Unit__c, Pricebook2Id, Pricing_Guidance__c, Primary_Contact__c, Prior_Stage__c, Probability, Product_Sub_Type__c, Product_Type_Value__c, Product_Type__c, Property_Address__c, Property_City_St_Zip__c, Property_City__c, Property_Condition__c, Property_Country__c, Property_County__c, Property_ID__c, Property_Locations__c, Property_Name__c, Property_Reserve_Price__c, Property_State__c, Property_Street__c, Property_Type__c, Property_Zip_Postal_Code__c, Purchase_Offer__c, Rating__c, Ready_for_Sold_com_ALA__c, Reason_for_ADC_Other__c, Reason_for_ADC__c, Recapture__c, RecordTypeId, Referral__c, Referred_By__c, Referring_URL__c, Reject_Comments__c, Reject_Reason__c, Rejection_Approval__c, Related_Opportunity__c, Removal_Reason__c, Removal_Request_By__c, Reserve_Price_Approval_Approved_Rejected__c, Reserve_Price_Approval_Status__c, Reserve_Price_Approval_Submitted_Date__c, Reserve_Price_Rejected_Date__c, Rockwood_Revenue__c,SFDC_Oppty_ID__c,SSAI_Status_Change_Date__c, SSAI_Status__c, SS_Doc_Age__c, SS_Doc_Rec_Turnaround__c, SS_Pre_Auction_Manager_Email__c, SS_Pre_Auction_Manager_Phone__c, Sale_Type__c, Same_as_Property_Address__c, SellerReserveAgreeDate__c, Seller_AMA_Sign_Off_Date__c, Seller_Access_Code__c, Seller_Address__c, Seller_City_St_Zip__c, Seller_City__c, Seller_Closing_Company_Rep_Email__c, Seller_Closing_Company_Rep_Phone__c, Seller_Closing_Company_Rep__c, Seller_Closing_Company__c, Seller_Code__c, Seller_Email_F__c, Seller_Email__c, Seller_First_Name__c, Seller_Last_Name__c, Seller_Mobile_Number__c, Seller_Mobile_Number_old__c, Seller_Phone__c, Seller_Postal_Zip__c, Seller_Profile__c, Seller_Requested_Reserve__c, Seller_State__c, Seller_Street__c, Seller_Suggested_Reserve__c, Seller_Vesting__c, Seller_Welcome_Email_Sent__c, Seller__c, Seller_or_Vesting_Seller__c, Sent_to_Asset_Consideration__c, Servicer1__c, Servicer_BPO_Date__c, Servicer_BPO__c, Servicer_Code__c, Servicer_Finance_Status__c, Sold_Date__c, Sold__c, Special_Situation__c,SS_Account_Executive__c,SS_Pre_Auction_Manager__c,Square_Feet__c, StageName, Stage_2_Email__c, Stage_4_Email__c, Stage_5_Email__c, Stage_Change_Date__c, Status_Change_Date__c, Status_Change_Time__c, Status_Changed_Yesterday__c, Status__c, Survey_Sent__c, SystemModstamp, Taxes_Current__c, Tenant_Type__c, Third_Party_Type__c, This_Week_Monday_start_date__c, This_Week_Sunday_end_date__c, TitleReceivedDate__c, Title_Approval_Approved_Rejected_Date__c, Title_Approval_Status__c, Title_Approval_Submitted_Date__c, TotalOpportunityQuantity, Total_Commission__c, Total_Debt_on_Property__c, Total_Invested__c, Total_Purchase_Price__c, Trustee_Sale_Date__c, Type, Type_of_AMA__c, UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Name__c, UTM_Source__c, UTM_Term__c, Unique_Asset_Field__c, Unique_Asset_Field_new__c, Valuation_Approval_Approved_Rejected_Dat__c, Valuation_Approval_Status__c, Valuation_Approval_Submitted_Date__c, Valuation_Effective_Date__c, Valuation_Executive__c, Valuation_Rejected_Date__c, Web_Lead_Create_Date__c, Web_Lead_ID__c, Winning_BidLookup__c, Winning_Bid_Stage__c, Workflow_ID__c, X1_Per_Rebate_Addendum__c, X3rd_Party_BPO_Date__c, X3rd_Party_BPO_Order_Date__c, X3rd_Party_BPO_Order_ID__c, X3rd_Party_BPO_Order_Type__c, X3rd_Party_BPO_Quick_Sale_Value__c, X3rd_Party_BPO_Received_Date__c, X3rd_Party_BPO_Status__c, X3rd_Party_BPO_Uploaded_to_Equator_Date__c, X3rd_Party_BPO_Value__c, X3rd_Party_Solicitor__c, Year_Built__c, Year_Renovated__c, Year_Seller_Purchased_Home__c, Year_Since_Major_Remodel__c, Zillow_DOM__c, Zillow_Estimate__c, num_of_days_between_auctions__c, 
                            X2nd_Co_Borrower_Email__c,  X2nd_Co_Borrower_Mobile_Number__c, X2nd_Co_Borrower_Name__c, X2nd_Co_Seller_Phone_Extension__c, X2nd_Co_Borrower_Phone_Number__c,  X3rd_Co_Borrower_Email__c, X3rd_Co_Borrower_Mobile_Number__c, X3rd_Co_Borrower_Name__c, X3rd_Co_Seller_Phone_Extension__c, X3rd_Co_Borrower_Phone_Number__c
             FROM Opportunity WHERE Id=:opp.Id];
             
             newOpp = opp.clone(false);
             newOpp.Winning_BidLookup__c=null; 
             newOpp.Offer_Amount__c=null;
             newOpp.List_Agent_Preferred_Closing_Co__c=null;
             newOpp.List_Agent_Preferred_Closing_Co_Contact__c=null;
             newOpp.List_Agent_Preferred_Closing_Co_Email__c=null;
             newOpp.List_Agent_Preferred_Closing_Co_Phone__c=null;
             //**** As per Sally's Email 4/10/2014
             newOpp.Most_Recent_Valuation__c = null;
             newOpp.Winning_Bid_AOA__c = null;             
             newOpp.Auction_Opportunity_Assignment__c = null;             
       newOpp.Initial_Auction__c=null;
       newOpp.Most_Recent_Auction__c=null;
       newOpp.Open_House_Lookup_1__c=null;
       newOpp.Open_House_Lookup_2__c=null;
       newOpp.Open_House_Lookup_3__c=null;
       newOpp.Open_House_3__c=null;
       newOpp.StageName= 'Stage 2. Opportunity Development';
       newOpp.Opportunity_Recycled__c= True;
       //**** 
             newOpp.OwnerId=UserInfo.getUserId();        
             if(newOpp.RecordTypeId == Label.Short_Sale_Opp_Rectype_Id &&  newOpp.Servicer_Code__c!=null)
                newOpp.Latest_Opportunity__c=TRUE;
             else
                newOpp.Latest_Opportunity__c=FALSE;    
             newOpp.SFDC_Oppty_ID__c=null;
             newOpp.SS_Unique_Opp__c=null;
             system.debug('Creating New Opp : ' +newOpp);
             insert newOpp;

         } catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
        return new PageReference('/'+newOpp.id+'/e?retURL=%2F'+newOpp.id);
    } */
}