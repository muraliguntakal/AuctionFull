public with sharing class LeadConversionTrigger {
    
    public void CreateConversionInfo(List<Lead> newLead, Boolean isBefore) {        
        // create person account    
        List<Account> accountsToAdd = new List<Account>();
        List<Contact> contactsToAdd = new List<Contact>();
        Map<Id, Id> opportunityContacts = new Map<Id, Id>();
        //Map<Id, Id> parentOpportunityMap = new Map<Id, Id>();
        Map<Id, String> opportunityRoles = new Map<Id, String>();
        Set<String> leadPropertyKeySet = new Set<String>();
        Set<String> lastNames = new Set<String>();
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        Set<String> accountNames = new Set<String>();
        
        //Id personAccountRecordType = null; //Murali 7/26/3016 - Lead Conversion Errors (Private Org Changes)
        //Id businessAccountRecordType = null;
        Id existAccount = null;
        Id existContact = null;
        
        //Murali 7/26/3016 - Lead Conversion Errors (Private Org Changes)
        //List<RecordType> AccountRecordTypes = [select id, Name, isPersonType from RecordType where SobjectType='Account'];
        /*
        for (RecordType rt :  AccountRecordTypes) {
            if (rt.IsPersonType  == true)
                personAccountRecordType = rt.Id;
            else if (rt.Name == 'Business Account')
                businessAccountRecordType = rt.Id;
        }
        */
        //Murali 7/26/3016 - Lead Conversion Errors (Private Org Changes)
        
        for (Lead curLead : newLead) {
            if (curLead.IsConverted) {
                if (curLead.Seller_Last_Name__c != null && curLead.Seller_Last_Name__c != '' && curLead.Seller_First_Name__c != null && curLead.Seller_Last_Name__c != '' ) {
                    lastNames.add(curLead.Seller_Last_Name__c);
                    if (curLead.Seller_Email__c != null && curLead.Seller_Email__c != '') emails.add(curLead.Seller_Email__c);
                    if (curLead.Seller_Phone__c != null && curLead.Seller_Phone__c != '') phones.add(curLead.Seller_Phone__c);
                    accountNames.add(curLead.Seller_Account__c!=null? curLead.Seller_Account__c :   curLead.Seller_First_Name__c+ ' '+ curLead.Seller_Last_Name__c+' -- Account');                    
                } else if (curLead.Broker_Agent_Last_Name__c != null && curLead.Broker_Agent_Last_Name__c != '') {
                    lastNames.add(curLead.Broker_Agent_Last_Name__c);
                    if (curLead.Broker_Agent_Phone__c != null && curLead.Broker_Agent_Phone__c != '') phones.add(curLead.Broker_Agent_Phone__c);
                    if (curLead.Broker_Agent_Email__c != null && curLead.Broker_Agent_Email__c != '') emails.add(curLead.Broker_Agent_Email__c);
                    if (curLead.Brokerage__c != null && curLead.Brokerage__c != '') accountNames.add(curLead.Brokerage__c);
                }               
                if(curLead.Property_Street__c != null && curLead.Property_Zip_Postal_Code__c != null && curLead.Property_City__c != null) {
                    leadPropertyKeySet.add(curLead.Property_Street__c+' '+curLead.Property_Zip_Postal_Code__c);
                }
            }
        }

        List<Asset__c> newAssetsList = new List<Asset__c>();
        List<Asset__c> existingAssetsList = new List<Asset__c> ([SELECT  Asset_SF_Unique_ID__c FROM Asset__c WHERE Asset_SF_Unique_ID__c IN :leadPropertyKeySet AND Asset_SF_Unique_ID__c !=null]);
        Set<String> existingAssetsSet = new Set<String>();
        for(Asset__c ast : existingAssetsList) {
            existingAssetsSet.add(ast.Asset_SF_Unique_ID__c);
        }                 

        //List<Account> existingPersonAccounts = [select Id, LastName, PersonEmail, Phone from Account where LastName =: lastNames and (PersonEmail =: emails or Phone =: phones)];
        List<Account> existingAccounts = [select Id, Name from Account where Name =: AccountNames];
        List<Contact> existingContacts = [select Id, LastName, Email, Phone, Account.Name from Contact where LastName =: lastNames and (Email =: emails or Phone =: phones) and Account.Name =: AccountNames];
        
        //System.Debug(Logginglevel.DEBUG ,'existingPersonAccounts :' + existingPersonAccounts);
        System.Debug(Logginglevel.DEBUG ,'existingAccounts :' + existingAccounts);
        System.Debug(Logginglevel.DEBUG ,'existingContacts :' + existingContacts);
                
        for (Lead curLead : newLead) {
            if (curLead.IsConverted) {
                
                if (curLead.Is_Lead_Info_Broker_Agent_or_Seller__c == 'Broker/Agent')
                {
                    if (curLead.Seller_Last_Name__c != null && curLead.Seller_Last_Name__c != '') {
                        Account seller = null;
                        Contact sellerContact = null;
                        existContact = DoesObjectExist(existingContacts, curLead.Seller_Email__c, curLead.Seller_Phone__c, curLead.Seller_Last_Name__c, curLead.Seller_Account__c, false);
                        System.Debug(Logginglevel.DEBUG ,'existAccount seller :' + existAccount);
                        if (existContact == null) {
                            seller = new Account(
                                Name=curLead.Seller_Account__c!=null? curLead.Seller_Account__c : curLead.Seller_First_Name__c+ ' '+ curLead.Seller_Last_Name__c+' -- Account',
                                Main_Email__c = curLead.Seller_Email__c,
                                Phone= curLead.Seller_Phone__c,
                                BillingState = curLead.Seller_State__c,
                                BillingStreet = curLead.Seller_Street_Address__c,
                                BillingPostalCode = curLead.Seller_Zip_Postal_Code__c,
                                BillingCity = curLead.Seller_City__c,
                                BillingCountry = curLead.Seller_Country__c,
                                ShippingState = curLead.Seller_State__c,
                                ShippingStreet = curLead.Seller_Street_Address__c,
                                ShippingPostalCode = curLead.Seller_Zip_Postal_Code__c,
                                ShippingCity = curLead.Seller_City__c,
                                ShippingCountry = curLead.Seller_Country__c,
                                Converted_as_Lead_Seller__c = True,
                                //Created_From_Lead__c=TRUE,
                                Created_From_Source__c = 'Lead',
                                RecordTypeId =Label.Standard_Account,
                                Opportunity__c = curLead.ConvertedOpportunityId
                            );

                           sellerContact = new Contact(
                                Converted_as_Lead_Seller__c =TRUE,
                                //Created_From_Lead__c=TRUE,
                                Created_From_Source__c = 'Lead',
                                FirstName = curLead.Seller_First_Name__c,
                                LastName = curLead.Seller_Last_Name__c,
                                Phone= curLead.Seller_Phone__c,
                                Phone_Extension__c =curLead.Seller_Phone_Extension__c,
                                MobilePhone= curLead.Seller_Mobile_Number__c,
                                Email= curLead.Seller_Email__c,
                                MailingState = curLead.Seller_State__c,
                                MailingStreet = curLead.Seller_Street_Address__c,
                                MailingPostalCode = curLead.Seller_Zip_Postal_Code__c,
                                MailingCity = curLead.Seller_City__c,
                                MailingCountry = curLead.Seller_Country__c,
                                RecordTypeId =Label.Commercial_Contact
                            );

                            contactsToAdd.add(sellerContact);
                            
                        } else {
                            System.Debug(Logginglevel.DEBUG ,'Found seller');
                            sellerContact = new Contact(
                                Id = existContact,
                                Phone= curLead.Seller_Phone__c,
                                Phone_Extension__c =curLead.Seller_Phone_Extension__c,
                                MobilePhone= curLead.Seller_Mobile_Number__c,
                                Email= curLead.Seller_Email__c,
                                MailingState = curLead.Seller_State__c,
                                MailingStreet = curLead.Seller_Street_Address__c,
                                MailingPostalCode = curLead.Seller_Zip_Postal_Code__c,
                                MailingCity = curLead.Seller_City__c,
                                MailingCountry = curLead.Seller_Country__c
                            );
                            contactsToAdd.add(sellerContact);
                        }
                        system.debug('Adding Seller Account : ' +seller);
                        if(seller!=null) {
                            accountsToAdd.add(seller);
                        }
                    }
                } else { 
                    if (curLead.Broker_Agent_Last_Name__c != null && curLead.Broker_Agent_Last_Name__c != '') {
                        Account brokerAgent = null;
                        Contact brokerAgentContact = null;

                        if (curLead.Brokerage__c != null && curLead.Brokerage__c != '') {
                            existAccount = DoesObjectExist(existingAccounts, null, null, null, curLead.Brokerage__c, true);
                            existContact = DoesObjectExist(existingContacts, curLead.Broker_Agent_Email__c, curLead.Broker_Agent_Phone__c, curLead.Broker_Agent_Last_Name__c, curLead.Brokerage__c, false);
                        } 
                        
                        System.Debug(Logginglevel.DEBUG ,'existAccount broker :' + existAccount);
                        System.Debug(Logginglevel.DEBUG ,'existContact broker :' + existContact);
                        if (existAccount == null) {
                            brokerAgent = new Account(
                                Phone = curLead.Broker_Agent_Phone__c,  
                                Main_Email__c = curLead.Broker_Agent_Email__c,
                                BillingState = curLead.Broker_Agent_State__c,
                                BillingStreet = curLead.Broker_Agent_Street_Address__c,
                                BillingPostalCode = curLead.Broker_Agent_Zip_Postal__c,
                                BillingCity = curLead.Broker_Agent_City__c, 
                                Converted_as_Lead_Broker__c = True,
                                //Created_From_Lead__c=TRUE,
                                Created_From_Source__c = 'Lead',
                                BillingCountry = curLead.Broker_Agent_Country__c,
                                ShippingState = curLead.Broker_Agent_State__c,
                                ShippingStreet = curLead.Broker_Agent_Street_Address__c,
                                ShippingPostalCode = curLead.Broker_Agent_Zip_Postal__c,
                                ShippingCity = curLead.Broker_Agent_City__c,    
                                ShippingCountry = curLead.Broker_Agent_Country__c,
                                //RecordTypeId = businessAccountRecordType,
                                Opportunity__c = curLead.ConvertedOpportunityId 
                            );                           
                                if(curLead.Brokerage__c!=null)
                                    brokerAgent.Name = curLead.Brokerage__c;
    
                        } else {
                            System.Debug(Logginglevel.DEBUG ,'Found broker');
                            brokerAgent = new Account(
                                Id = existAccount,
                                Opportunity__c = curLead.ConvertedOpportunityId,
                                Phone = curLead.Broker_Agent_Phone__c,  
                                BillingState = curLead.Broker_Agent_State__c,
                                BillingStreet = curLead.Broker_Agent_Street_Address__c,
                                BillingPostalCode = curLead.Broker_Agent_Zip_Postal__c,
                                BillingCity = curLead.Broker_Agent_City__c, 
                                BillingCountry = curLead.Broker_Agent_Country__c,
                                ShippingState = curLead.Broker_Agent_State__c,
                                Converted_as_Lead_Broker__c = True,
                                ShippingStreet = curLead.Broker_Agent_Street_Address__c,
                                ShippingPostalCode = curLead.Broker_Agent_Zip_Postal__c,
                                ShippingCity = curLead.Broker_Agent_City__c,    
                                ShippingCountry = curLead.Broker_Agent_Country__c
                            );

                            
                        }
                        
                        if (existContact == null) {
                            brokerAgentContact = new Contact(
                                Email = curLead.Broker_Agent_Email__c,
                                FirstName = curLead.Broker_Agent_First_Name__c,
                                LastName = curLead.Broker_Agent_Last_Name__c,   
                                Phone = curLead.Broker_Agent_Phone__c,
                                MailingState = curLead.Broker_Agent_State__c,
                                MailingStreet = curLead.Broker_Agent_Street_Address__c,
                                MailingPostalCode = curLead.Broker_Agent_Zip_Postal__c,
                                MailingCity = curLead.Broker_Agent_City__c, 
                                County__c = curLead.Broker_Agent_County__c, 
                                Broker_RE_License_Number__c = curLead.Broker_RE_License_Number__c,
                                Broker_RE_License_State__c = curLead.Broker_RE_License_State__c,
                                Converted_as_Lead_Broker__c = True,
                                //Created_From_Lead__c=TRUE,
                                Created_From_Source__c = 'Lead',
                                MailingCountry = curLead.Broker_Agent_Country__c,   
                                AccountId = existAccount != null ? existAccount : null,
                                Brokerage__c = curLead.Brokerage__c
                            );
                            
                        }
                        
                        accountsToAdd.add(brokerAgent);
                        system.debug('Upserted Brooker Agent Account : ' +brokerAgent); 
                        
                        if (brokerAgentContact != null)  {
                            contactsToAdd.add(brokerAgentContact);
                            system.debug('Upserted Broker Agent contact : ' +contactsToAdd); 
                        }
                    }
                }
                opportunityRoles.put(curLead.ConvertedOpportunityId, curLead.Is_Lead_Info_Broker_Agent_or_Seller__c);
                opportunityContacts.put(curLead.ConvertedOpportunityId, curLead.ConvertedContactId);

                if(curLead.Property_Street__c != null && curLead.Property_Zip_Postal_Code__c != null && curLead.Property_City__c != null) {
                    newAssetsList.add(new Asset__c(                                                  
                                                    Accrual_Method__c=curLead.Accrual_Method__c,
                                                    Additional_Information__c=curLead.Additional_Information__c,
                                                    Amortization__c=curLead.Amortization__c,
                                                    Amortization_Period_years__c=curLead.Amortization_Period__c,
                                                    APN__c=curLead.Assessor_Parcel_Number__c,
                                                    Average_Daily_Rate__c=curLead.Average_Daily_Rate__c,
                                                    Borrower__c=curLead.Borrower__c,
                                                    Borrower_Bankruptcy_Y_N__c=curLead.Borrower_Bankruptcy__c,
                                                    Coupon_Rate__c=curLead.Coupon_Rate__c,
                                                    Current_Balance__c=curLead.Current_Balance__c,
                                                    Current_Listing_Price__c=curLead.Current_List_Price__c,
                                                    Foreclosure_Attorney__c=curLead.Foreclosure_Attorney__c,
                                                    FSBO__c=curLead.FSBO__c,
                                                    Gross_Square_Footage_SF__c=curLead.Gross_Square_Footage__c,
                                                    Impound_Balance_Field__c=curLead.Impound_Balance_Field__c,
                                                    Impounds__c=curLead.Impounds__c,
                                                    Offer_Amount__c=curLead.Offer_Amount__c,
                                                    Offer_Date__c=curLead.Offer_Date__c,
                                                    Lien_Position__c=curLead.Lien_Position__c,
                                                    Listing_Agreement_Date__c=curLead.Listing_Agreement_Date__c,
                                                    Listing_Agreement_Expiration_Date__c=curLead.Listing_Agreement_Expiration_Date__c,
                                                    Listing_Agreement__c = curLead.Listing_Agreement__c,
                                                    Loan_Balloon_Payment__c=curLead.Loan_Balloon_Payment__c,
                                                    Loan_IO_Term_years__c=curLead.Loan_IO_Term_years__c,
                                                    Loan_Last_Payment_Date__c=curLead.Loan_Last_Payment_Date__c,
                                                    Loan_Maturity_Date__c=curLead.Loan_Maturity_Date__c,
                                                    Loan_Monthly_Payment_Amount__c=curLead.Loan_Monthly_Payment_Amount__c,
                                                    Loan_Original_Balance__c=curLead.Loan_Original_Balance__c,
                                                    Loan_Original_Term__c=curLead.Loan_Original_Term_years__c,
                                                    Loan_Origination_Date__c=curLead.Loan_Origination_Date__c,
                                                    Loan_Participation__c=curLead.Loan_Participation__c,
                                                    Loan_Prepayment_Provision__c=curLead.Loan_Prepayment_Provision__c,
                                                    Loan_Remaining_Term_years__c=curLead.Loan_Remaining_Term_years__c,
                                                    Loan_Status__c=curLead.Loan_Status__c,
                                                    Lot_Size_Acres__c=curLead.Lot_Size__c,
                                                    Net_Rentable_Area_SF__c=curLead.Net_Rentable_Area__c,
                                                    NOD_Date__c=curLead.NOD_Date__c,
                                                    NOI__c=curLead.NOI__c,
                                                    NOI_Date__c=curLead.NOI_date__c,
                                                    NOI_Period_months__c=curLead.NOI_Period__c,
                                                    Baths__c=curLead.Number_of_Baths__c,
                                                    Bedrooms__c=curLead.Number_of_Bedrooms__c,
                                                    Number_of_Buildings__c=curLead.Num_of_Buildings__c,
                                                    Number_of_Keys__c=curLead.Number_Of_Keys__c,
                                                    Number_of_Stories__c=curLead.Number_Of_Stories__c,
                                                    Number_of_Units__c=curLead.Number_Of_Units__c,
                                                    Occupancy__c=curLead.Occupancy__c,
                                                    Occupancy_as_of_Date__c=curLead.Occupancy_as_of_Date__c,
                                                    Pool_Number__c=curLead.Pool_Number__c,
                                                    Product_Type__c=curLead.Product_Type__c,
                                                    Property_Street__c=curLead.Property_Street__c,
                                                    Property_City__c=curLead.Property_City__c,
                                                    Property_County__c=curLead.Property_County__c,
                                                    Property_Description__c=curLead.Property_Description__c,
                                                    Property_Name__c=curLead.Property_Name__c,
                                                    Property_State__c=curLead.Property_State__c,
                                                    Property_Sub_Type__c=curLead.Property_Sub_Type__c,
                                                    Property_Type__c=curLead.Property_Type__c,
                                                    Property_Zip_Postal_Code__c=curLead.Property_Zip_Postal_Code__c,
                                                    Rate_Adjustment_Frequency__c=curLead.Rate_Adjustment_Frequency_months__c,
                                                    Rate_Ceiling__c=curLead.Rate_Ceiling__c,
                                                    Rate_First_Adjustment_Date__c=curLead.Rate_First_Adjustment_Date__c,
                                                    Rate_Floor__c=curLead.Rate_Floor__c,
                                                    Rate_Index__c=curLead.Rate_Index__c,
                                                    Rate_Initial_Fixed_Period__c=curLead.Rate_Initial_Fixed_Period__c,
                                                    Rate_Interest_Margin__c=curLead.Rate_Interest_Margin__c,
                                                    Rate_Next_Adjustment_Date__c=curLead.Rate_Next_Adjustment_Date__c,
                                                    Rate_Periodic_Adjustment_Amount__c=curLead.Rate_Periodic_Adjustment_Amount__c,
                                                    Rate_Type__c=curLead.Rate_Type__c,
                                                    Receiver__c=curLead.Receiver__c,
                                                    Recourse__c=curLead.Recourse__c,
                                                    SBA_Loan_Y_N__c=curLead.SBA_Loan__c,
                                                    System_Add_Date__c=curLead.System_Add_Date__c,
                                                    Year_Built__c=curLead.Year_Built__c,
                                                    Brochure_Photos__c=curLead.Brochure_Photos__c,
                                                 //   Ownership_Type__c=curLead.Ownership_Type__c,
                                                    Unit_Type_Reference__c=curLead.Unit_Type_Reference__c,
                                                    Brochure_Marketing_Description__c=curLead.Brochure_Marketing_Description__c,
                                                    Brochure_Photo_Path__c=curLead.Brochure_Photo_Path__c,
                                                    Rental_Revenue__c=curLead.Rental_Revenue__c,
                                                    Operational_Expenses__c=curLead.Operational_Expenses__c,
                                                    Updated_Reserve__c=curLead.Updated_Reserve__c,
                                                    BOV_One_Value__c=curLead.BOV_One_Value__c,
                                                  //  BOV_Two_Value__c=curLead.BOV_Two_Value__c,
                                                  //  BOV_Three_Value__c=curLead.BOV_Three_Value__c,
                                                  //  BOV_Four_Value__c=curLead.BOV_Four_Value__c,
                                                 //   BOV_Five_Value__c=curLead.BOV_Five_Value__c,
                                                    Appraisal_Cap_Rate__c=curLead.Appraisal_Cap_Rate__c,
                                                    Largest_Tenant_SF__c=curLead.Largest_Tenant_SF__c,
                                                    X2nd_Largest_Tenant_SF__c=curLead.X2nd_Largest_Tenant_SF__c,
                                                    X3rd_Largest_Tenant_SF__c=curLead.X3rd_Largest_Tenant_SF__c,
                                                    Appraisal_NOI__c=curLead.Appraisal_NOI__c,
                                                    Remaining_Amortization__c=curLead.Remaining_Amortization__c,
                                                    Year_Renovated__c=curLead.Year_Renovated__c,
                                                 //   Contract_Signer_Zip__c=curLead.Contract_Signer_Zip__c,
                                                 //   Second_Contract_Signer_Zip__c=curLead.Second_Contract_Signer_Zip__c,
                                                    Land_Parcels__c=curLead.Land_Parcels__c,
                                                    Number_of_Elevators__c=curLead.Number_of_Elevators__c,
                                                    Number_of_Parking_Spaces__c=curLead.Number_of_Parking_Spaces__c,
                                                    Remaining_IO_Term__c=curLead.Remaining_IO_Term__c,
                                                    Loan_First_Payment_Date__c=curLead.Loan_First_Payment_Date__c,
                                                    Largest_Tenant_Lease_Exp__c=curLead.Largest_Tenant_Lease_Exp__c,
                                                    X2nd_Largest_Tenant_Lease_Exp__c=curLead.X2nd_Largest_Tenant_Lease_Exp__c,
                                                    X3rd_Largest_Tenant_Lease_Exp__c=curLead.X3rd_Largest_Tenant_Lease_Exp__c,
                                                    Borrower_Bankruptcy_Filed_Date__c=curLead.Borrower_Bankruptcy_Filed_Date__c,
                                                //    NOS_Date__c=curLead.NOS_Date__c,
                                                    Appraisal_Report_Date__c=curLead.Appraisal_Report_Date__c,
                                                    Signage_Requested_Date__c=curLead.Signage_Requested_Date__c,
                                                 //   Signage_Installed_Date__c=curLead.Signage_Installed_Date__c,
                                                 //   Broker_Addendum_Date__c=curLead.Broker_Addendum_Date__c,
                                                 //   Shop_One_Date__c=curLead.Shop_One_Date__c,
                                                 //   Shop_Two_Date__c=curLead.Shop_Two_Date__c,
                                                 //   Shop_Three_Date__c=curLead.Shop_Three_Date__c,
                                                    BOV_One_Date__c=curLead.BOV_One_Date__c,
                                                 //   BOV_One_Approved_Date__c=curLead.BOV_One_Approved_Date__c,
                                                 //   BOV_Two_Date__c=curLead.BOV_Two_Date__c,
                                                 //   BOV_Two_Approved_Date__c=curLead.BOV_Two_Approved_Date__c,
                                                  //  BOV_Three_Date__c=curLead.BOV_Three_Date__c,
                                                  //  BOV_Three_Approved_Date__c=curLead.BOV_Three_Approved_Date__c,
                                                  //  BOV_Four_Date__c=curLead.BOV_Four_Date__c,
                                                  //  BOV_Four_Approved_Date__c=curLead.BOV_Four_Approved_Date__c,
                                                  //  BOV_Five_Date__c=curLead.BOV_Five_Date__c,
                                                  //  BOV_Five_Approved_Date__c=curLead.BOV_Five_Approved_Date__c,
                                                    Property_Condition_Report_Date__c=curLead.Property_Condition_Report_Date__c,
                                                    Environmental_Assessment_Date__c=curLead.Environmental_Assessment_Date__c,
                                                 //   Contract_Signer_Email__c=curLead.Contract_Signer_Email__c,
                                                 //   Second_Contract_Signer_Email__c=curLead.Second_Contract_Signer_Email__c,
                                                 //   Contract_Signer_Phone__c=curLead.Contract_Signer_Phone__c,
                                                  //  Second_Contract_Signer_Phone__c=curLead.Second_Contract_Signer_Phone__c,
                                                   // Auction_Item_Portfolio__c=curLead.Auction_Item_Portfolio__c,
                                                    Loan_Purpose__c=curLead.Loan_Purpose__c,
                                                    Cross_Collateralized_Defaulted__c=curLead.Cross_Collateralized_Defaulted__c,
                                                    Largest_Tenant__c=curLead.Largest_Tenant__c,
                                                    X2nd_Largest_Tenant__c=curLead.X2nd_Largest_Tenant__c,
                                                    X3rd_Largest_Tenant__c=curLead.X3rd_Largest_Tenant__c,
                                                    Sponsor__c=curLead.Sponsor__c,
                                                    Loan_Securitization__c=curLead.Loan_Securitization__c,
                                                    Appraisal_Firm_Name__c=curLead.Appraisal_Firm_Name__c,
                                                 //   Seller_Vesting_Name__c=curLead.Seller_Vesting_Name__c,
                                                  //  Contract_Signer_Company__c=curLead.Contract_Signer_Company__c,
                                                  //  Contract_Signer_Name__c=curLead.Contract_Signer_Name__c,
                                                    Contract_Signer_Title__c=curLead.Contract_Signer_Title__c,
                                                 //   Contract_Signer_Street__c=curLead.Contract_Signer_Street__c,
                                                 //   Contract_Signer_City__c=curLead.Contract_Signer_City__c,
                                                 //   Second_Contract_Signer_Name__c=curLead.Second_Contract_Signer_Name__c,
                                                //    Second_Contract_Signer_Title__c=curLead.Second_Contract_Signer_Title__c,
                                                  //  Second_Contract_Signer_Street__c=curLead.Second_Contract_Signer_Street__c,
                                                  //  Second_Contract_Signer_City__c=curLead.Second_Contract_Signer_City__c,
                                                    Signage_Comments__c=curLead.Signage_Comments__c,
                                                  //  Shop_One_Comments__c=curLead.Shop_One_Comments__c,
                                                 //   Shop_Two_Comments__c=curLead.Shop_Two_Comments__c,
                                                 //   Shop_Three_Comments__c=curLead.Shop_Three_Comments__c,
                                                  //  BOV_One_Firm_Name__c=curLead.BOV_One_Firm_Name__c,
                                                    BOV_One_Broker_Name__c=curLead.BOV_One_Broker_Name__c,
                                                  //  BOV_One_Comments__c=curLead.BOV_One_Comments__c,
                                                  //  BOV_Two_Firm_Name__c=curLead.BOV_Two_Firm_Name__c,
                                                 //   BOV_Two_Broker_Name__c=curLead.BOV_Two_Broker_Name__c,
                                                  //  BOV_Two_Comments__c=curLead.BOV_Two_Comments__c,
                                                  //  BOV_Three_Firm_Name__c=curLead.BOV_Three_Firm_Name__c,
                                                  //  BOV_Three_Broker_Name__c=curLead.BOV_Three_Broker_Name__c,
                                                  //  BOV_Three_Comments__c=curLead.BOV_Three_Comments__c,
                                                  //  BOV_Four_Firm_Name__c=curLead.BOV_Four_Firm_Name__c,
                                                    BOV_Four_Broker_Name__c=curLead.BOV_Four_Broker_Name__c,
                                                  //  BOV_Four_Comments__c=curLead.BOV_Four_Comments__c,
                                                  //  BOV_Five_Firm_Name__c=curLead.BOV_Five_Firm_Name__c,
                                                   // BOV_Five_Broker_Name__c=curLead.BOV_Five_Broker_Name__c,
                                                   // BOV_Five_Comments__c=curLead.BOV_Five_Comments__c,
                                                    Property_Tour_Dates__c=curLead.Property_Tour_Dates__c,
                                                    Largest_Tenant_SF_Pct__c=curLead.Largest_Tenant_SF_Pct__c,
                                                    X2nd_Largest_Tenant_SF_Pct__c=curLead.X2nd_Largest_Tenant_SF_Pct__c,
                                                    X3rd_Largest_Tenant_SF_Pct__c=curLead.X3rd_Largest_Tenant_SF_Pct__c,
                                                //    Shop_One_Grade__c=curLead.Shop_One_Grade__c,
                                                //    Shop_Two_Grade__c=curLead.Shop_Two_Grade__c,
                                                 //   Shop_Three_Grade__c=curLead.Shop_Three_Grade__c,
                                                 //   Contract_Signer_State__c=curLead.Contract_Signer_State__c,
                                                 //   Second_Contract_Signer_State__c=curLead.Second_Contract_Signer_State__c,
                                                    Market_Information__c=curLead.Market_Information__c,
                                                    Loan_Description__c=curLead.Loan_Description__c,
                                                    Investment_Opportunity__c=curLead.Investment_Opportunity__c,
                                                    Property_Overview__c=curLead.Property_Overview__c,
                                                 //   Website_Feature_Order__c=curLead.Website_Feature_Order__c,
                                                    Utilities_Paid_By_Tenant__c=curLead.Utilities_Paid_By_Tenant__c,
                                                //    PSA_Template_Received__c=curLead.PSA_Template_Received__c,
                                                //    Item_Specific_PSA_Received__c=curLead.Item_Specific_PSA_Received__c,
                                                //    Property_Due_Diligence_Received__c=curLead.Property_Due_Diligence_Received__c,
                                                //    Loan_Due_Diligence_Received__c=curLead.Loan_Due_Diligence_Received__c,
                                                //    Other_Due_Diligence_Received__c=curLead.Other_Due_Diligence_Received__c,
                                                //    Lender_Owned_Property__c=curLead.Lender_Owned_Property__c,
                                                    Property_Signage_Permitted__c=curLead.Property_Signage_Permitted__c,
                                                 //   Broker_Registered_in_MLH__c=curLead.Broker_Registered_in_MLH__c,
                                                 //   Second_Broker_Registered_in_MLH__c=curLead.Second_Broker_Registered_in_MLH__c,
                                                 //   Third_Broker_Registered_in_MLH__c=curLead.Third_Broker_Registered_in_MLH__c,
                                                 //   Broker_Attended_Webinar__c=curLead.Broker_Attended_Webinar__c,
                                                 //   Second_Broker_Attended_Webinar__c=curLead.Second_Broker_Attended_Webinar__c,
                                                 //   Third_Broker_Attended_Webinar__c=curLead.Third_Broker_Attended_Webinar__c,
                                                 //   Introduction_Call_Made__c=curLead.Introduction_Call_Made__c,
                                                 //   PSA_Place_Holders_POSTED__c=curLead.PSA_Place_Holders_POSTED__c,
                                                    PSA_Word_Received__c=curLead.PSA_Word_Received__c,
                                                    PSA_WEB_Received__c=curLead.PSA_WEB_Received__c,
                                                    PSA_UPLOADED__c=curLead.PSA_UPLOADED__c,
                                                 //   PSA_Revision_Recd__c=curLead.PSA_Revision_Recd__c,
                                                 //   PSA_Revision_Uploaded__c=curLead.PSA_Revision_Uploaded__c,
                                                    Certified_Diligence__c = curLead.Certified_Diligence__c,
                                                    Free_Clear_Title__c = curLead.Free_Clear_Title__c, 
                                                    Building_Class__c = curLead.Building_Class__c,
                                                    Investment_Class__c = curLead.Investment_Class__c,
                                                    Ownership_Sold__c = curLead.Ownership_Sold__c,
                                                    Tenancy__c = curLead.Tenancy__c,
                                                    Minimum_BP__c = curLead.Minimum_BP__c,
                                                    DOM_CRE__c = curLead.DOM_CRE__c,
                                                    Lease_Service__c  = curLead.Lease_Service__c,    
                                                    Second_Property_Type__c = curLead.Second_Property_Type__c,
                                                    Asset_SF_Unique_ID__c =curLead.Property_Street__c +' '+ curLead.Property_Zip_Postal_Code__c, 
                                                    Opportunity__c = curLead.ConvertedOpportunityId) 
                                                    );                                   
                }
            }        
        }
        
        Upsert newAssetsList Asset_SF_Unique_ID__c;
        System.Debug(Logginglevel.DEBUG ,'Upserted Assets  :' + newAssetsList);
        System.Debug(Logginglevel.DEBUG ,'accountsToAdd :' + accountsToAdd);
        System.Debug(Logginglevel.DEBUG ,'contactsToAdd :' + contactsToAdd);
        System.Debug(Logginglevel.DEBUG ,'opportunityRoles :' + opportunityRoles);
        System.Debug(Logginglevel.DEBUG ,'opportunityContacts :' + opportunityContacts);
                
        if(!accountsToAdd.isEmpty()){
            Upsert accountsToAdd Id;           
            system.debug('Upserted Accounts : ' +accountsToAdd);
        }
        List<Contact> contactList = new List<Contact>();
        
        for (Contact c : contactsToAdd) {
            if (c.AccountId == null) {
                Id acct = null;
                if(c.Converted_as_Lead_Seller__c)
                    acct = DoesObjectExist(accountsToAdd, null, null, null, c.FirstName +' '+c.LastName+' -- Account', true);
                else {   
                    acct = DoesObjectExist(accountsToAdd, null, null, null, c.Brokerage__c, true);
                }
                c.AccountId = acct;
            } 
            contactList.add(c);
        }
        
        if(!contactList.isEmpty()){
            Upsert contactList Id;
            system.debug('Upserted Contacts : ' +contactList);
        }        
        // change the broker into a broker/agent contact role
        List<OpportunityContactRole> ocr = [select Id, ContactId, Role, IsPrimary, OpportunityId from OpportunityContactRole where OpportunityId = : opportunityRoles.keySet()];
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        for (OpportunityContactRole curOcr : ocr) {
            System.Debug(Logginglevel.DEBUG ,'role :' + opportunityRoles.get(curOcr.OpportunityId));
            curOcr.Role = opportunityRoles.get(curOcr.OpportunityId);
            curOcr.IsPrimary = true;
            ocrList.add(curOcr);
        }
        
        System.Debug(Logginglevel.DEBUG ,'ocrList :' + ocrList);
        
        // add the person account into a seller or Broker/agent contact role
        //contactsToAdd = [select Account.Opportunity__c, Id from Contact where Account.Opportunity__c =: opportunityRoles.keySet()];
        // 7/22/2013 - Split query into two to utilize indices
        List<Account> acctIds = new List<Account>();
        
        if(!opportunityRoles.KeySet().isEmpty()) {
            acctIds = [Select Id From Account Where Opportunity__c =: opportunityRoles.keySet() AND Opportunity__c!=null Limit 1000];  //limit added to test soql query... remove later
        }  
        if(!acctIds.isEmpty()){
            contactsToAdd = [select Account.Opportunity__c, Id from Contact where AccountId In:acctIds Limit 1000 ];  // limit added to test soql query... remove later
        }
        
        Map<Id, Id> opportunities = new Map<Id, Id>();
        
        for (Contact ct : contactsToAdd)
            opportunities.put(ct.Account.Opportunity__c, ct.Id);
        
        System.Debug(Logginglevel.DEBUG ,'opportunities :' + opportunities);
            
        List<Opportunity> oppoList = [SELECT Id, Broker_Agent__c, Seller__c, Primary_Contact__c FROM Opportunity WHERE Id = : opportunityRoles.keySet()];

        for (Opportunity curOppo : oppoList) {
            OpportunityContactRole ocrPa = null;
            
            System.Debug(Logginglevel.DEBUG ,'opportunities role :' + opportunityRoles.get(curOppo.Id) );
            System.Debug(Logginglevel.DEBUG ,'opportunities contact :' + opportunityContacts.get(curOppo.Id) );
            System.Debug(Logginglevel.DEBUG ,'opportunities role :' + opportunities.get(curOppo.Id) );

            //if(parentOpportunityMap.get(curOppo.Id) != null)   {
            //    curOppo.Parent_Opportunity__c = parentOpportunityMap.get(curOppo.Id);                
            //}
            
            curOppo.Primary_Contact__c = opportunityRoles.get(curOppo.Id);
            if (opportunityRoles.get(curOppo.Id) == 'Broker/Agent') {
                curOppo.Broker_Agent__c = opportunityContacts.get(curOppo.Id);
                if (opportunities.get(curOppo.Id) != null) {
                    curOppo.Seller__c = opportunities.get(curOppo.Id);
                    ocrPa = new OpportunityContactRole(
                                    ContactId = opportunities.get(curOppo.Id),
                                    OpportunityId = curOppo.Id,
                                    Role = 'Seller' );
                }
            } else {
                curOppo.Seller__c = opportunityContacts.get(curOppo.Id);
                if (opportunities.get(curOppo.Id) != null) {
                    curOppo.Broker_Agent__c = opportunities.get(curOppo.Id);
                    ocrPa = new OpportunityContactRole(
                                    ContactId = opportunities.get(curOppo.Id),
                                    OpportunityId = curOppo.Id,
                                    Role = 'Broker/Agent' );
                }
            }
            
            if (ocrPa != null) 
                ocrList.add(ocrPa);
        }
        
        if (oppoList.size() > 0) 
            update oppoList;   
        
    }
    
    private Id DoesObjectExist(List<sObject> existingObjects, String email, String phone, String lastname, string accountName, Boolean isAccount) {
        System.Debug(Logginglevel.DEBUG ,'email :' + email);
        System.Debug(Logginglevel.DEBUG ,'phone :' + phone);
        System.Debug(Logginglevel.DEBUG ,'lastname :' + lastname);
        System.Debug(Logginglevel.DEBUG ,'AccountName :' + accountName);
        
        Account curAccount = null;
        Contact curContact = null;
        
        for (sObject obj : existingObjects) {
            if (isAccount) {
                curAccount = (Account) obj;
                if (accountName != null && accountName != '') {
                    if (curAccount.Name  == accountName) return curAccount.Id;
                } else {
                    if ((curAccount.LastName == lastname && curAccount.PersonEmail != null && curAccount.PersonEmail == email) || (curAccount.LastName == lastname && curAccount.Phone != null && curAccount.Phone == phone))
                        return curAccount.Id;
                }
            } else {
                curContact = (Contact) obj;
                if ((curContact.LastName == lastname && curContact.Email != null && curContact.Email == email) || (curContact.LastName == lastname && curContact.Phone != null && curContact.Phone == phone))
                    return curContact.Id;
            }
            
        }
        return null;        
    }

 @future
    public static void setLeadDMLOptions(Set<Id> leadSet)
    {
       List<Lead> LeadList = new List<Lead>([SELECT Id,IsConverted,CreatedById FROM Lead WHERE Id IN :leadSet]);  
       List<Lead> Leads = new List<Lead>(); 
       for (Lead ld : LeadList) {        
          if(!ld.IsConverted && CONSTANTS.apiUsers.contains(ld.CreatedById)) { 
           Database.DMLOptions dmo = new Database.DMLOptions();
           dmo.assignmentRuleHeader.useDefaultRule = true;
           dmo.EmailHeader.triggerAutoResponseEmail  = true;
           dmo.EmailHeader.triggerUserEmail  = true;
           ld.setOptions(dmo);                         
           Leads.add(ld); 
          }
       }
       if(Leads.size() > 0) 
           database.Update(Leads);
    }

    public void getAuctionDetails(List<Lead> leadList) {
       system.debug('getAuctionDetails');
       Map<String,Id> VenueAuctionIdMap = new Map<String,Id>();        
       Set<String> eventSet = new Set<String>();
       Set<String> VenueNumberSet = new Set<String>();

       for (Lead ld : leadList) {        
           if(ld.Event_ID__c!= null && ld.MLH_REDC_ID__c!=null) {
               eventSet.add(ld.Event_ID__c);
               VenueNumberSet.add(ld.MLH_REDC_ID__c.substring(0,2));            
               system.debug('Venue Number Set : '  +VenueNumberSet);
           }  
       }

       List<Auction_Campaign__c> auctionList = new List<Auction_Campaign__c>([SELECT Id,MLH_Event_Id__c,Venue_Number__c,MLH_Auction_Id__c 
                                                                  FROM Auction_Campaign__c 
                                                                  WHERE MLH_Event_Id__c IN :eventSet AND Venue_Number__c IN :VenueNumberSet AND
                                                                        MLH_Event_Id__c !=null AND Venue_Number__c != null]);    
    
       system.debug('auctionList : ' +auctionList); 
       Map<String,Id> AuctionMap = new Map<String,Id>();        
       for(Auction_Campaign__c ac : auctionList) {
           AuctionMap.put(ac.MLH_Event_Id__c+ac.Venue_Number__c,ac.Id);
       }  
       system.debug(' Auction Map: ' +AuctionMap); 
       for (Lead ld : leadList) {        
           if(ld.Event_ID__c!= null && ld.MLH_REDC_ID__c!=null) {
               if(AuctionMap.containsKey(ld.Event_ID__c+ld.MLH_REDC_ID__c.substring(0,2)))
                  ld.Auction__c = AuctionMap.get(ld.Event_ID__c+ld.MLH_REDC_ID__c.substring(0,2));             
                  system.debug('  ld.Auction__c  = ' +ld.Auction__c );
           }  
           if(ld.Parent_Opportunity_ID__c!=null) {
              ld.Parent_Opportunity__c = id.valueof(ld.Parent_Opportunity_ID__c); 
           } 
       } 

    }
}