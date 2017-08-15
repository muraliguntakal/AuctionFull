@RestResource(urlMapping='/MLHCreateWinningBid/*')
global class WinningBidRestService {
    
    global class BidCreatedResult {
        public String status;
        public Boolean success;
        public String errorcode;
        public String errorMessage;
    }
    
    global class BidService{
        public String BIDAMOUNT;
        public String WINNINGBID;
        public String AUCTIONID;
        public String ASSETID;
        public String BIDDATETIME;
        public String GLOBALPROPERTYID;
        public String MLHBIDID;
        public String MLHBIDSTAGE;
       public String MLHNEXTCONTACTTIME;
        public String MLHTEAM;
        public String MLHVENUEID; // added on 12/2/13
        public String MLHEVENTID; 
        // Bid Registration Fields
        public String BIDDERID;         
        public String CONTACTID; 
  //Ganesh Vinnakota added 10/20/2014      
public String ADCASSETMGREMAIL;
public String ADCASSETMGRNAME;
public String ADCASSETMGRPHONE;
public String ASSETACTUALRETURNDATE;
public String ASSETRUNS;
public String ASSETRUNSLEFT;
public String ASSETSCHEDULEDRETURNDATE;
public String AUCTIONSELLERRESERVE;
public String LISTINGAGENTEMAIL;
public String LISTINGAGENTNAME;
public String LISTINGAGENTPHONE;
public String MANUALCLERKUSEREMAIL;
public String ORIGINALRESERVE;
public String SELLERCONTACTEMAIL;
public String SELLERCONTACTNAME;
public String SELLERCONTACTPHONE;
public String TYPEOFSALE;
        
        public BidService(String BIDAMOUNT, String MLHNEXTCONTACTTIME,String MLHTEAM,String MLHBIDSTAGE,String WINNINGBID,String AUCTIONID,String ASSETID,String BIDDATETIME,String GLOBALPROPERTYID,
                          String MLHBIDID, String BIDDERID,String CONTACTID,String MLHVENUEID,String MLHEVENTID, String ADCASSETMGREMAIL, String ADCASSETMGRNAME, String ADCASSETMGRPHONE, String ASSETACTUALRETURNDATE, 
                          String ASSETRUNS, String ASSETRUNSLEFT,String ASSETSCHEDULEDRETURNDATE, String AUCTIONSELLERRESERVE,String LISTINGAGENTEMAIL, String LISTINGAGENTNAME, String LISTINGAGENTPHONE,String MANUALCLERKUSEREMAIL,
                          String ORIGINALRESERVE, String SELLERCONTACTEMAIL, String SELLERCONTACTNAME, String SELLERCONTACTPHONE, String TYPEOFSALE){
            this.BIDAMOUNT = BIDAMOUNT;
            this.WINNINGBID = WINNINGBID;
            this.AUCTIONID = AUCTIONID;
            this.ASSETID = ASSETID;
            this.BIDDATETIME = BIDDATETIME;
            this.GLOBALPROPERTYID = GLOBALPROPERTYID;
            this.MLHBIDID = MLHBIDID;
            this.BIDDERID = BIDDERID;
            this.CONTACTID = CONTACTID;
            this.MLHNEXTCONTACTTIME = MLHNEXTCONTACTTIME;
            this.MLHTEAM = MLHTEAM;
            this.MLHBIDSTAGE = MLHBIDSTAGE;
            this.MLHVENUEID = MLHVENUEID;
            this.MLHEVENTID = MLHEVENTID;   
            this.ADCASSETMGREMAIL = ADCASSETMGREMAIL;
            this.ADCASSETMGRNAME = ADCASSETMGRNAME; 
            this.ADCASSETMGRPHONE = ADCASSETMGRPHONE; 
            this.ASSETACTUALRETURNDATE = ASSETACTUALRETURNDATE; 
            this.ASSETRUNS = ASSETRUNS;
            this.ASSETRUNSLEFT = ASSETRUNSLEFT;
            this.ASSETSCHEDULEDRETURNDATE = ASSETSCHEDULEDRETURNDATE;
            this.AUCTIONSELLERRESERVE = AUCTIONSELLERRESERVE;
            this.LISTINGAGENTEMAIL = LISTINGAGENTEMAIL;
            this.LISTINGAGENTNAME = LISTINGAGENTNAME; 
            this.LISTINGAGENTPHONE = LISTINGAGENTPHONE;
            this.MANUALCLERKUSEREMAIL = MANUALCLERKUSEREMAIL;
            this.ORIGINALRESERVE = ORIGINALRESERVE;
            this.SELLERCONTACTEMAIL = SELLERCONTACTEMAIL;
            this.SELLERCONTACTNAME = SELLERCONTACTNAME;
            this.SELLERCONTACTPHONE = SELLERCONTACTPHONE;
            this.TYPEOFSALE = TYPEOFSALE;
                            
        }      
    }
    
    @HttpPost    
    global static string createNewBid(String BIDAMOUNT,String MLHNEXTCONTACTTIME,String MLHTEAM,String MLHBIDSTAGE,String WINNINGBID,String AUCTIONID,String ASSETID,String BIDDATETIME,String GLOBALPROPERTYID,
                                      String MLHBIDID,String BIDDERID,String CONTACTID,String MLHVENUEID,String MLHEVENTID, String ADCASSETMGREMAIL, String ADCASSETMGRNAME, String ADCASSETMGRPHONE, String ASSETACTUALRETURNDATE, 
                                      String ASSETRUNS, String ASSETRUNSLEFT,String ASSETSCHEDULEDRETURNDATE, String AUCTIONSELLERRESERVE,String LISTINGAGENTEMAIL, String LISTINGAGENTNAME, String LISTINGAGENTPHONE,String MANUALCLERKUSEREMAIL,
                                      String ORIGINALRESERVE, String SELLERCONTACTEMAIL, String SELLERCONTACTNAME, String SELLERCONTACTPHONE, String TYPEOFSALE) {
        
        String returnJson;
        List<Bid__c> lBids = new List<Bid__c>();
        RestResponse res = RestContext.response;
        String jsonResponse = '';
        Bid__c bidObject = new Bid__c();
        
       // Bidder_Registration__c bidRegObject1 = new Bidder_Registration__c();
        System.Savepoint savePoint = Database.setSavepoint();
        BidCreatedResult bResult = new BidCreatedResult(); 
        
         try {
            
            bidObject = new Bid__c();
           
            BidService bService = new BidService(BIDAMOUNT,MLHNEXTCONTACTTIME,MLHTEAM,MLHBIDSTAGE,WINNINGBID,AUCTIONID,ASSETID,BIDDATETIME,GLOBALPROPERTYID,MLHBIDID,BIDDERID,CONTACTID,MLHVENUEID,MLHEVENTID,
            ADCASSETMGREMAIL,ADCASSETMGRNAME,ADCASSETMGRPHONE,ASSETACTUALRETURNDATE,ASSETRUNS,ASSETRUNSLEFT,ASSETSCHEDULEDRETURNDATE,AUCTIONSELLERRESERVE,LISTINGAGENTEMAIL,LISTINGAGENTNAME, LISTINGAGENTPHONE,
            MANUALCLERKUSEREMAIL,ORIGINALRESERVE,SELLERCONTACTEMAIL,SELLERCONTACTNAME,SELLERCONTACTPHONE,TYPEOFSALE);   
            system.debug('********* bService: '+bService);
            if(bservice.MLHNEXTCONTACTTIME != Null && bservice.MLHNEXTCONTACTTIME != '' ) {
                if(!(bservice.MLHNEXTCONTACTTIME.equals('null'))) {
                    bidObject.MLH_Next_Contact_Time__c = datetime.valueof(bservice.MLHNEXTCONTACTTIME); 
                }
            }
            
            if(bservice.MLHBIDID != Null && bservice.MLHBIDID != '')  {
                if(!(bservice.MLHBIDID.equals('null'))) {
                    system.debug('#######');
                    bidObject.MLH_Bid_ID__c = string.valueof(bservice.MLHBIDID);
                }
            }


            if(bservice.GLOBALPROPERTYID != Null && bservice.GLOBALPROPERTYID != '')  {
                if(!(bservice.GLOBALPROPERTYID.equals('null'))) {
                    system.debug('#######');
                    //bidObject.Assets__c.MLH_Global_Property_ID__c = string.valueof(bservice.GLOBALPROPERTYID);
                    bidObject.putSObject('Assets__r', new Asset__c(MLH_Global_Property_ID__c=string.valueof(bservice.GLOBALPROPERTYID)));
                }
            }

            if(!bService.BIDAMOUNT.contains('.'))
            bService.BIDAMOUNT = bService.BIDAMOUNT+'.00';            
            bidObject.Bid_Amount__c = decimal.valueof(bService.BIDAMOUNT);
            bidObject.Winning_Bid__c = boolean.valueof(bService.WINNINGBID);
            bidObject.Bid_Date_Time__c = datetime.valueofGmt(bService.BIDDATETIME);
            system.debug('Current Bid DateTime : ' +bidObject.Bid_Date_Time__c);
            bidObject.MLH_Global_Property_ID__c = string.valueof(bService.GLOBALPROPERTYID);
            bidObject.MLH_Bid_ID__c = string.valueof(bservice.MLHBIDID);
            bidobject.MLH_Bidder_ID__c = bservice.BIDDERID;
            bidObject.MLH_Asset_ID__c = string.valueof(bservice.ASSETID);
            bidObject.MLH_Auction_ID__c = string.valueof(bservice.AUCTIONID);
            
            bidObject.MLH_Team__c = string.valueof(bservice.MLHTEAM);
            bidObject.MLH_Bid_Stage__c = string.valueof(bservice.MLHBIDSTAGE);
            bidObject.MLH_Venue_Id_1__c = string.valueof(bservice.MLHVENUEID);
            bidObject.MLH_Event_Id__c = string.valueof(bservice.MLHEVENTID);
            bidObject.Created_From_Rest_API__c=TRUE;
            
            
          if(bservice.ADCASSETMGREMAIL != Null && bservice.ADCASSETMGREMAIL != '' ) {
              if(!(bservice.ADCASSETMGREMAIL.equals('null'))) {
                 bidObject.ADC_Asset_Manager_Email__c = string.valueof(bservice.ADCASSETMGREMAIL);
                } 
            }
            bidObject.ADC_Asset_Manager_Name__c = string.valueof(bservice.ADCASSETMGRNAME);
            bidObject.ADC_Asset_Manager_Phone__c = string.valueof(bservice.ADCASSETMGRPHONE);
           if(bservice.ASSETACTUALRETURNDATE != Null && bservice.ASSETACTUALRETURNDATE != '' && bservice.ASSETACTUALRETURNDATE != '0000-00-00' ) {
              if(!(bservice.ASSETACTUALRETURNDATE.equals('null'))) {
                    bidObject.Asset_Actual_Return_Date__c = date.valueof(bservice.ASSETACTUALRETURNDATE); 
                 }       
             }        
           if(bservice.ASSETRUNS != Null && bservice.ASSETRUNS != '' ) {
               if(!(bservice.ASSETRUNS.equals('null'))) {
                    bidObject.Asset_Runs__c = decimal.valueof(bservice.ASSETRUNS); 
                  }  
             }
           if(bservice.ASSETRUNSLEFT != Null && bservice.ASSETRUNSLEFT != '' ) {
              if(!(bservice.ASSETRUNSLEFT.equals('null'))) {
                    bidObject.Asset_Runs_Left__c = decimal.valueof(bservice.ASSETRUNSLEFT); 
                 }   
             }
           if(bservice.ASSETSCHEDULEDRETURNDATE != Null && bservice.ASSETSCHEDULEDRETURNDATE != '' && bservice.ASSETSCHEDULEDRETURNDATE != '0000-00-00' ) {
               if(!(bservice.ASSETSCHEDULEDRETURNDATE.equals('null'))) {
                    bidObject.Asset_Scheduled_Return_Date__c = Date.valueof(bservice.ASSETSCHEDULEDRETURNDATE); 
                 }   
              }
           if(bservice.AUCTIONSELLERRESERVE != Null && bservice.AUCTIONSELLERRESERVE != '' ) {
              if(!(bservice.AUCTIONSELLERRESERVE.equals('null'))) {
                    bidObject.Auction_Seller_Reserve__c = decimal.valueof(bservice.AUCTIONSELLERRESERVE); 
                 }    
              }
           if(bservice.LISTINGAGENTEMAIL != Null && bservice.LISTINGAGENTEMAIL != '' ) {
              if(!(bservice.LISTINGAGENTEMAIL.equals('null'))) {
                    bidObject.Listing_Agent_Email__c = string.valueof(bservice.LISTINGAGENTEMAIL);
                }    
            }
            bidObject.Listing_Agent_Name__c = string.valueof(bservice.LISTINGAGENTNAME);
            bidObject.Listing_Agent_Phone__c = string.valueof(bservice.LISTINGAGENTPHONE);
           if(bservice.MANUALCLERKUSEREMAIL != Null && bservice.MANUALCLERKUSEREMAIL != '' ) {
              if(!(bservice.MANUALCLERKUSEREMAIL.equals('null'))) {
                    bidObject.Manual_Clerk_User_Email__c = string.valueof(bservice.MANUALCLERKUSEREMAIL);
                 }
             } 
          /* if(bservice.MANUALCLERKUSEREMAIL != Null && bservice.MANUALCLERKUSEREMAIL != '')  {
              if(!(bservice.MANUALCLERKUSEREMAIL.equals('null'))) {
                    bidObject.putSObject('Clerked_By_User__r', new User(External_Id_Email__c=string.valueof(bservice.MANUALCLERKUSEREMAIL)));
                }
            } 
          */
           if(bservice.ORIGINALRESERVE != Null && bservice.ORIGINALRESERVE != '' ) {
              if(!(bservice.ORIGINALRESERVE.equals('null'))) {
                    bidObject.Original_Reserve__c = decimal.valueof(bservice.ORIGINALRESERVE); 
                }    
             }                
           if(bservice.SELLERCONTACTEMAIL != Null && bservice.SELLERCONTACTEMAIL != '' ) {
              if(!(bservice.SELLERCONTACTEMAIL.equals('null'))) {     
                   bidObject.Seller_Contact_Email__c = string.valueof(bservice.SELLERCONTACTEMAIL);
                }
             }   
            bidObject.Seller_Contact_Name__c = string.valueof(bservice.SELLERCONTACTNAME);
            bidObject.Seller_Contact_Phone__c = string.valueof(bservice.SELLERCONTACTPHONE);
            bidObject.Type_of_Sale__c = string.valueof(bservice.TYPEOFSALE);

            if(bidObject.MLH_Bidder_ID__c !='1' && bidObject.MLH_Bidder_ID__c!=null && bidObject.MLH_Auction_ID__c!=null && bidObject.MLH_Asset_ID__c!=null && bidObject.Bid_Amount__c > 0 ) {
                bidObject.DBNext_BidID__c = bidObject.MLH_Bidder_ID__c+bidObject.MLH_Auction_ID__c+bidObject.MLH_Asset_ID__c+String.valueof(bidObject.Bid_Amount__c);            
            }

            system.debug('********* bidObject: '+bidObject);
            //system.debug('********* DBNext_BidID__c: '+DBNext_BidID__c);
            
            // bidobject.Bidder_Registration__c = bidRegObject.id;
            Upsert bidObject DBNext_BidID__c ;// MLH_Global_Property_ID__c;
            //  }
            
            // adding JSON input values to the Bidder Registration object.
                       
            bResult.status = 'Success';
            bResult.success = true;
            returnJson = JSON.Serialize(bResult);
            
           return returnJson; 
         }
         catch(Exception e) {
            
            Database.rollback(savePoint);    
          
            res.statusCode = 500;
            jsonResponse = '{"response": {"status": "Failure", "message": "' + e + '"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            return jsonResponse; 
                      
         }        
    } 
  
}