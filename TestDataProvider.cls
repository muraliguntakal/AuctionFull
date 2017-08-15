//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  basic{required fields} testdata creation. NO DML operations will be performed in this class.data should pass all validations.
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 11/13/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public without sharing class TestDataProvider {
    
    public static Asset__c NewAsset(){
        Asset__c ast = new Asset__c();
        ast.Property_Street__c = '123 Test St #123';
        ast.Property_City__c = 'Test City';
        ast.Property_State__c = 'CA';
        ast.Property_Country__c='USA';
        ast.Property_County__c='Test County';        
        return ast;
    }

    //Residential Asset for Bulk Testing
    public static Asset__c bulkAsset(){
        Asset__c ast = new Asset__c();
        ast.Property_Street__c = '100 Mauchly';
        ast.Property_City__c = 'Irvine';
        ast.Property_State__c = 'CA';
        ast.Property_Country__c='USA';
        ast.Property_County__c='Orange';        
        return ast;
    }

    public static Bid__c NewBid(){
        Bid__c bid = new Bid__c();
        bid.MLH_Bid_ID__c = 'BID'+UtilityFns.getRandomString(18,8);
        bid.Bid_Amount__c = 200000;
        return bid;
    }

    public static Lead NewLead() {
        Lead ld     =  new Lead();
        ld.LastName    = 'Last_'+UtilityFns.getRandomString(8,3);
        ld.FirstName   = 'First_'+UtilityFns.getRandomString(8,3);
        ld.Email       =  ld.LastName+'.'+ld.Firstname+'@testing.com';  
        ld.Phone       =  UtilityFns.getRandomInt(100,999)+'-'+UtilityFns.getRandomInt(100,999)+'-'+UtilityFns.getRandomInt(100,999);  
        return ld;
    }

    public static Account NewAccount() {
        Account acc = new Account();
        acc.Name = 'New_Acc_'+UtilityFns.getRandomString(8,3);
        acc.Servicer_Code__c='JPM';
        return acc;
    }

    public static Contact NewContact() {
        Contact con     = new Contact();
        con.LastName    = 'Last'+UtilityFns.getRandomString(8,3);
        con.FirstName   = 'First'+UtilityFns.getRandomString(8,3);
        con.Email       =  con.LastName+'.'+con.Firstname+'@testing.com';  
        con.Phone       =  UtilityFns.getRandomInt(100,999)+'-'+UtilityFns.getRandomInt(100,999)+'-'+UtilityFns.getRandomInt(100,999);  
        return con;
    }

    public static Opportunity NewOpportunity(Id accId){
        Opportunity opp = new Opportunity();
        opp.Name = 'New_Opp_'+UtilityFns.getRandomString(8,3);
        opp.Loan_Number__c='Test1231';  
        opp.Property_Street__c = '1231 Test St #1231';        
        opp.Property_City__c = 'Test City';        
        opp.Property_State__c = 'CA';        
        opp.Property_Country__c='USA';        
        opp.Property_County__c='Test County'; 
        opp.AccountId = accId;
        opp.closeDate = Date.today().addDays(UtilityFns.getRandomInt(1,365));
        opp.StageName = CONSTANTS.OPPTY_STAGE_OPEN_AUCTION;
        return opp;
    }

    public static Auction_Campaign__c NewAuction(){
        Auction_Campaign__c auc = new Auction_Campaign__c();
        //auc.Name =    'New_Auction_'+UtilityFns.getRandomString(9,2);//changed to auto-number.
        return auc;
    }

    public static Auction_Campaign__c bulkAuction(){
        Auction_Campaign__c au = new Auction_Campaign__c();
        au.Auction_Name__c = 'AUC-10';
        au.MLH_Venue_Id__c = 'VENID-10';
        au.MLH_Auction_Id__c = 'AUCID-10';
        au.Bidding_Start_Time__c = system.now()+10;
        au.Bidding_Start_Time__c = system.now()+15;
        return au;
    }

    public static AssetOppJunction__c NewAssetOppJun(Id oppId, Id astId){
        AssetOppJunction__c astOpp_J = new AssetOppJunction__c();
        astOpp_J.Opportunity__c = oppId;
        astOpp_J.Asset_del__c   = astId;
        return astOpp_J;
    }

    public static Auction_Opportunity_Assignment__c NewAuctionOppJun(Id oppId, Id aucId)
    {
        Auction_Opportunity_Assignment__c aucOpp_J  =   new Auction_Opportunity_Assignment__c();
        aucOpp_J.Opportunity__c         =  oppId;
        aucOpp_J.Auction_Campaign__c    =  aucId;
        return aucOpp_J;
    }

    public static Bidder_Registration__c NewBidderRegistration(String bidderId)
    {
        Bidder_Registration__c bidderReg    =   new Bidder_Registration__c();
        bidderReg.MLH_Bidder_ID__c          =   bidderId;
        bidderReg.MLH_ContactID__c          =   'a12332456';
        return bidderReg;
    }
    
    public static callrecord__c NewCallrecord()
    {
        callrecord__c callrec           =   new callrecord__c();
        return callrec;
    }

    public static Case NewCase()
    {
        Case newCase = new Case();
        newCase.Subject = 'Test Case Subject';
        newCase.Origin = 'Web'; 
        newCase.Description = 'This is a new Case ';
        newCase.Disposition_Category__c = 'General';
        newCase.Contact_First_Name__c = 'TestFirstName';
        newCase.Contact_Last_Name__c = 'TestLastName';
        newCase.Contact_Email__c = 'testfirstname.testlastname@example.com';
        newCase.Contact_Phone__c = '111-111-1111';
        return newCase;
    }

    public static PDP__c NewPDP() {
        PDP__c pdp     = new PDP__c();
        pdp.MLH_Last_Name__c    = 'Last'+UtilityFns.getRandomString(8,3);
        pdp.MLH_First_Name__c   = 'First'+UtilityFns.getRandomString(8,3);
        pdp.MLH_Email__c        =  pdp.MLH_First_Name__c+'.'+pdp.MLH_Last_Name__c+'@testing.com';  
        pdp.MLH_Phone__c        =  UtilityFns.getRandomInt(100,999)+'-'+UtilityFns.getRandomInt(100,999)+'-'+UtilityFns.getRandomInt(100,999);  
        pdp.Contact__c = null;
        return pdp;
    }

}