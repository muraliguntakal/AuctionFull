public class CampWebServiceCallout {

public static Boolean IsSandbox() {
      return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
  }

  private static string CAMPendpoint = MLHAuth.isSandbox()? Label.Camp_Post_QA : Label.Camp_Post_Prod;
      
    @future (callout=true)
    public static void sendNotification(set<Id> setOFAssets) {
    
    if(!setOFAssets.isEmpty())
    {
        
        list<AssetOppJunction__c> lstAsstOppJunction = new list<AssetOppJunction__c>();
              lstAsstOppJunction = [select Asset_del__c, Primary_Campaign_Id__c, Re_auction_deal__c, Opportunity__c, Id,Property_Name__c, Property_Type__c, Sub_Type__c,
                                                              Property_Address__c, Property_City__c, Property_State__c, Property_Zip__c, Property_County__c, Property_Country__c,
                                                              Seller__c,Seller_First_Name__c, Seller_Last_Name__c, Seller_Email__c, Seller_Phone__c, Seller_Account_Name__c, Signer_Name__c,
                                                              Broker__c,Brokerage_Company_Name__c, Broker_First_Name__c, Broker_Last_Name__c, Broker_Phone__c, Broker_Email__c,
                                                              Brokerage_Street_Address__c, Brokerage_City__c, Brokerage_State__c, Brokerage_Zip__c, Broker_County__c, Broker_Country__c, 
                                                              Broker_License__c, Listing_Broker__c, CRE_or_Notes__c,Type_of_Sale__c,MLH_Global_Property_ID__c,Opportunity_Owner_First_Name__c,
                                                              Opportunity_Owner_Last_Name__c,Opportunity_Owner_Email__c,Opportunity_Owner_Phone__c from AssetOppJunction__c where id in: setOFAssets];
                                                              
                        
         CampRequestJSON cc = new CampRequestJSON();               
         for(AssetOppJunction__c aoj: lstAsstOppJunction)
         {
            
            CampRequestJSON.assets cca = new CampRequestJSON.assets(); 
            
            cca.parent_opportunity_status = (aoj.Re_auction_deal__c==True? 'Re-auction':''); 
            
            cca.Asset_fields.salesforce_asset_id = aoj.Asset_del__c;
            cca.Asset_fields.asset_id = aoj.MLH_Global_Property_ID__c;     
            cca.Asset_fields.asset_name = aoj.Property_Name__c; 
            cca.Asset_fields.primary_asset_type = aoj.Property_Type__c; 
            cca.Asset_fields.primary_asset_sub_type = aoj.Sub_Type__c; 
            cca.Asset_fields.line_of_business = (aoj.CRE_or_Notes__c=='CRE'? (aoj.CRE_or_Notes__c=='CRE'? 'Commercial':'') : (aoj.CRE_or_Notes__c=='Notes'? 'Note':''));                                      
            cca.Parties.sales_channel_id = (aoj.Type_of_Sale__c=='Offer Select'? 102:101); 
          //  cca.Parties.sales_channel_id = 101;                   
            cca.Parties.Listing_salesforce_reference.salesforce_primary_campaign_id = aoj.Primary_Campaign_Id__c;
            cca.Parties.Listing_salesforce_reference.salesforce_parent_opportunity_id = aoj.Opportunity__c; 
            cca.Parties.Listing_salesforce_reference.salesforce_intake_id = aoj.Id;
    
            cca.Asset_fields.Asset_address.street_name = aoj.Property_Address__c;
            cca.Asset_fields.Asset_address.municipality= aoj.Property_City__c;
            cca.Asset_fields.Asset_address.country_subdivision = aoj.Property_State__c;
            cca.Asset_fields.Asset_address.postal_code = aoj.Property_Zip__c;
            cca.Asset_fields.Asset_address.country_secondary_subdivision = aoj.Property_County__c; 
            cca.Asset_fields.Asset_address.country_code = 'US';  
            
            CampRequestJSON.Listing_sellers sellerObj = new  CampRequestJSON.Listing_sellers();           
            sellerObj.first_name = aoj.Seller_First_Name__c;
            sellerObj.last_name = aoj.Seller_Last_Name__c;
            sellerObj.email = aoj.Seller_Email__c;
            if(aoj.Seller_Phone__c != null) {
                sellerObj.phone = CampforceFormat.formatPhone(aoj.Seller_Phone__c);
            }
            else {
                sellerObj.phone = null;
            }
            sellerObj.salesforce_contact_id = aoj.Seller__c;         
            sellerObj.seller_company = aoj.Seller_Account_Name__c;    
            cca.Parties.Listing_sellers.add(sellerObj);
            
            CampRequestJSON.Listing_party_roles RolesObj = new  CampRequestJSON.Listing_party_roles();  
            RolesObj.role_type_id = 49;        
            RolesObj.first_name = aoj.Opportunity_Owner_First_Name__c;
            RolesObj.last_name = aoj.Opportunity_Owner_Last_Name__c;
            RolesObj.email = aoj.Opportunity_Owner_Email__c;
            if(aoj.Opportunity_Owner_Phone__c != null) {
                RolesObj.phone = CampforceFormat.formatPhone(aoj.Opportunity_Owner_Phone__c);
            } 
            else {
                RolesObj.phone = null;
            }
            cca.Parties.Listing_party_roles.add(RolesObj);
            
            if(aoj.Broker__c != null){
            CampRequestJSON.Listing_brokers brokerObj = new  CampRequestJSON.Listing_brokers();
                        
            brokerObj.listing_broker_company = aoj.Brokerage_Company_Name__c;
            brokerObj.first_name = aoj.Broker_First_Name__c;
            brokerObj.last_name = aoj.Broker_Last_Name__c;        
            if(aoj.Broker_Phone__c != null) {
                brokerObj.phone = CampforceFormat.formatPhone(aoj.Broker_Phone__c);
            }
            else {
                brokerObj.phone = null;
            }
            brokerObj.email = aoj.Broker_Email__c;
            brokerObj.license_number = aoj.Broker_License__c;
            brokerObj.license_state = aoj.Brokerage_State__c;
            brokerObj.salesforce_contact_id = aoj.Broker__c;
            
            if(aoj.Brokerage_Street_Address__c != null){
            brokerObj.address = new CampRequestJSON.Asset_address();
            brokerObj.address.street_name = aoj.Brokerage_Street_Address__c;
            brokerObj.address.municipality = aoj.Brokerage_City__c;
            brokerObj.address.country_subdivision = aoj.Brokerage_State__c;
            brokerObj.address.postal_code = aoj.Brokerage_Zip__c;
            brokerObj.address.country_secondary_subdivision = aoj.Broker_County__c; 
            brokerObj.address.country_code = aoj.Broker_Country__c;    
            }        
           
            cca.Parties.Listing_brokers.add(brokerObj); 
            }
           
            cc.assets.add(cca);
         }

        String CampJSON = System.JSON.Serialize(cc);      
        system.debug('CampJSON-->'+CampJSON);
        
        Auth_Token_Vault__c  mlhTokenVault = MLH_Token_Manager.getToken(); 

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(CAMPendpoint);
        req.setHeader('Authorization', 'Bearer ' +mlhTokenVault.Auth_Token__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(CampJSON);
        
         System.debug('future call123'); 
        
        try {          
                res = http.send(req);
                System.debug('responseBody: '+res.getBody()); 
                String JsonclosureResp = res.getBody();    
                
           //Now that we are done with callouts, we can update the oauth tokens if they changed.
           Upsert mlhTokenVault Name;
            
            CampResponseJSON CampResponse = CampResponseJSON.parse(JsonclosureResp); 
            Map<Id,CampResponseJSON.Responses> campMap = new Map<Id,CampResponseJSON.Responses>();
            List<AssetOppJunction__c> UpdateIntakes = new List<AssetOppJunction__c>();
            List<Webservice_Log__c> wsList = new List<Webservice_Log__c>();
            
             system.debug('CampResponse-->'+CampResponse);
           
             // Get Salesforce IntakeIds        
             if(CampResponse.Responses!=null) {        
                 for (integer i = 0 ; i < CampResponse.Responses.size(); i++) {                  
                    campMap.put(CampResponse.Responses[i].salesforce_Intake_id,CampResponse.Responses[i]);          
                 }
                 
                 Map<Id,AssetOppJunction__c> IntakesMap = new Map<Id,AssetOppJunction__c>([SELECT Id FROM AssetOppJunction__c WHERE Id IN : campMap.KeySet()]);
                 
                 for(AssetOppJunction__c intakes : IntakesMap.values()) {
                     if(campMap.containsKey(intakes.Id)) {                                    
                        if(CampResponse.Responses[0].error_details == null && res.getStatusCode() == 200) {
                                  Intakes.Camp_Integration_Status__c = 'Success'; 
                                  Intakes.Camp_Asset_Id__c = campMap.get(intakes.Id).asset_id;
                                  Intakes.Camp_Listing_Id__c = campMap.get(intakes.Id).listing_id; 
                                  Intakes.Camp_Error_Message__c = null;
                        }  
                        else if(CampResponse.Responses[0].error_details != null) {
                                  Intakes.Camp_Integration_Status__c = 'Failed';  
                                  Intakes.Camp_Error_Message__c = campMap.get(intakes.Id).Error_details.message;                                  
                                  system.debug('ERROR => ' +campMap.get(intakes.Id).Error_details.message);
                                  system.debug('Dump => ' +campMap.get(intakes.Id));

                        }                                       
                        UpdateIntakes.add(intakes);   
                     }                                
                 }
             }              
                       
             if(CampResponse.Responses!=null) {        
                         for (integer i = 0 ; i < CampResponse.Responses.size(); i++) {                    
                             Webservice_Log__c wsl = new Webservice_Log__c(); 
                             wsl.Webservice__c =  Label.MLH_Asset_Post;
                             wsl.Object_Name__c = 'AssetOppJunction__c';
                             wsl.Message_Type__c = 'Outbound';
                             wsl.HTTP_Request__c = CampJSON;
                             wsl.HTTP_Response__c = res.getBody();
                             wsl.Intake_Submission_Forms__c = CampResponse.Responses[i].salesforce_Intake_id; 
                             if(CampResponse.Responses[0].error_details != null) {
                                 wsl.Status__c = 'Failed';  
                             }
                            else {
                                 wsl.Status__c = 'Success';
                             }
                                 wsList.add(wsl);
                         }
              }
                     
                                 
                 if(wsList.size() > 0) {
                   Database.Insert(wsList,false);   
                 }
                 
                                     
                 if(UpdateIntakes.size() > 0) {
                   Database.Update(UpdateIntakes,false);   
                 }  
            
        } catch(System.CalloutException e) {
            throw new MLHAuthException('Connection error! Please contact your Salesforce Administrator'+e);
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

    }
  
    }
                                        
       public class MLHAuthException extends Exception {}                              

}