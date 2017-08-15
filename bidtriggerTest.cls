//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  Testclass for all Bid functionality like derivations, validations.
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 11/13/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
@isTest()
private class bidtriggerTest {

    
    // Variables and properties.
    private static final Integer BULKLOAD_SIZE = 201;

    // Test Bulk loads of Data.
    private static testmethod void BulkloadTest() {
    
    TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        //System.assertEquals(0,[select count() from Bid__c]);
        List<Bid__c> bidstobeinserted = new List<Bid__c>();
        for(Integer i = 0; i < BULKLOAD_SIZE; i++) {
            Bid__c tBid = TestDataProvider.NewBid();
            tBid.Bid_Amount__c=20000+i;
            bidstobeinserted.add(tBid);
        }
        Test.startTest();
        insert bidstobeinserted;
        Test.stopTest();
        //System.assertEquals(BULKLOAD_SIZE,[select count() from Bid__c]);
    }

    // Test pleain insert, delete, update.
    private static testmethod void allDMLoperations() {
        //System.assertEquals(0,[select count() from Bid__c]);
        
        Bid__c tBid = TestDataProvider.NewBid();
        insert tBid;
        //System.assertEquals(1,[select count() from Bid__c]);

        tBid.Bid_Amount__c  =   100000;
        update tBid;
        //System.assertEquals(100000,[select Bid_Amount__c from Bid__c where Id =: tbid.Id limit 1].Bid_Amount__c);

        Delete tBid;
        //System.assertEquals(0,[select count() from Bid__c]);

        undelete tBid;
        //System.assertEquals(1,[select count() from Bid__c]);
    }

    // Test Case 1. derivation of Opportunity__c, Related_Opportunities__c.
    /* on insert of new Bid if there is a match for opportunity with MLH_Global_Property_ID__c then
    //      1a : Opopulate Opportunity__c if there is only one match.
    //      1b : populate Related_Opportunities__c with related oppty names if multiple opptys.
    */
    private static testmethod void validateOpportunityUDerivation() {
        String mlhglobalId = 'MLHGlobal_30005';

        //testcase 1a
        Account tAcc = TestDataProvider.newAccount();
        insert tAcc;
        
        Opportunity tOpp = TestDataProvider.NewOpportunity(tAcc.Id);
        insert tOpp;

        Asset__c tAst = TestDataProvider.NewAsset();
        tAst.MLH_Global_Property_ID__c = mlhglobalId;
        insert tAst;

        Bid__c tBid = TestDataProvider.NewBid();
        tBid.MLH_Global_Property_ID__c = mlhglobalId;
        
        Test.startTest();
        insert tBid;
        Test.stopTest();

        //testcase 1b.
        Opportunity tOpp_r2 = TestDataProvider.NewOpportunity(tAcc.Id);
        insert tOpp_r2;

        AssetOppJunction__c tAstOpp_r2 = TestDataProvider.NewAssetOppJun(tOpp_r2.Id, tAst.Id);
        insert tAstOpp_r2;

        Bid__c tBid_r2 = TestDataProvider.NewBid();
        tBid_r2.MLH_Global_Property_ID__c = mlhglobalId;
        tBid_r2.Bid_Amount__c=120003;
        insert tBid_r2;

        //System.assertNotEquals(null,tBid_r2.Id); // successful insert.
        //System.assertNotEquals(null,[select Related_Opportunities__c from Bid__c where Id = :tBid_r2.Id limit 1].Related_Opportunities__c); //Related_Opportunities__c derivation is working.
    }

    // Test Case 2 . derivation of Auction_Opportunity_Assignment__c
    private static testmethod void validateAuctionOpportunityAssignmentDerivation() {
    
        TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        String mlhglobalId  = UtilityFns.getRandomString(10,8);
        String mlhauctionId = UtilityFns.getRandomString(10,7);
        String mlhbidderId = UtilityFns.getRandomString(10,6);
        Account tAcc = TestDataProvider.newAccount();
        insert tAcc;

        Asset__c tAst = TestDataProvider.NewAsset();
        tAst.MLH_Global_Property_ID__c = mlhglobalId;
        insert tAst;        

        Opportunity tOpp = TestDataProvider.NewOpportunity(tAcc.Id);
        insert tOpp;

        Auction_Campaign__c tAuc =  TestDataProvider.NewAuction();
        tAuc.MLH_Auction_Id__c   =  mlhauctionId;
        insert tAuc;

        Auction_Opportunity_Assignment__c tAucOpp = TestDataProvider.NewAuctionOppJun(tOpp.Id, tAuc.Id);
        tAucOpp.Auction_Day_Status__c = 'Sold';
        insert tAucOpp;
        
        
        Bid__c tBid1 = TestDataProvider.NewBid();
        tBid1.MLH_Global_Property_ID__c = mlhglobalId;
        tBid1.MLH_Asset_ID__c = mlhglobalId;
        tBid1.MLH_Auction_ID__c         = mlhauctionId;
        tBid1.MLH_Bidder_ID__c          = '534545';
        tBid1.Bid_Amount__c             = 1000.10;
        tBid1.Winning_Bid__c            = true;
        tBid1.Auction_Opportunity_Assignment__c = tAucOpp.Id;

        Bid__c tBid = TestDataProvider.NewBid();
        tBid.MLH_Global_Property_ID__c = mlhglobalId;
        tBid.MLH_Asset_ID__c = mlhglobalId;
        tBid.MLH_Auction_ID__c         = mlhauctionId;
        tBid.MLH_Bidder_ID__c          = mlhbidderId;
        tBid.Bid_Amount__c             = 1000.11;
        tBid.Auction_Opportunity_Assignment__c = tAucOpp.Id;
                
        insert tBid1;
        insert tBid;         
        
        List<Auction_Opportunity_Assignment__c> aoasForUpdate = new List<Auction_Opportunity_Assignment__c> ();
        tAucOpp.MLH_Final_Sale_Price__c =  1000.11;                             
        tAucOpp.MLH_Auction_ID__c = mlhauctionId;                                  
        tAucOpp.MLH_Winning_Bidder_ID__c = mlhbidderId;                   
        aoasForUpdate.add(tAucOpp);
 
        tAucOpp.Auction_Day_Status__c = CONSTANTS.AUCTION_DAY_FALLOUT;                              
        tAucOpp.MLH_Final_Sale_Price__c =  1000.11;                             
        tAucOpp.MLH_Auction_ID__c = mlhauctionId;                                  
        tAucOpp.MLH_Winning_Bidder_ID__c = mlhbidderId;
        aoasForUpdate.add(tAucOpp);                

        Test.startTest();
            update tAucOpp;
        Test.stopTest();
 
        
        //System.assertEquals(tAucOpp.Id, [select Id, Auction_Opportunity_Assignment__c from Bid__c where Id = :tBid.Id].Auction_Opportunity_Assignment__c);
    }

    // Test Case 3 . derivation of Bidder Registration
    private static testmethod void validateBidderRegistrationDerivation() {
    
    TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        
        String mlhBidderId  = UtilityFns.getRandomString(10,8);
        
        Bidder_Registration__c  tBidreg = TestDataProvider.NewBidderRegistration(mlhBidderId);
        tBidreg.MLH_FirstName__c = 'TestLast3 Name';
        tBidreg.MLH_LastName__c = 'TestLast3 Name';
        insert tBidreg;

        Bid__c tBid = TestDataProvider.NewBid();
        tBid.MLH_Bidder_ID__c = mlhBidderId;
        
        Test.startTest();
        insert tBid;
        Test.stopTest();

        //System.assertEquals(tBidreg.Id, [select Id, Bidder_Registration__c from Bid__c where Id = :tBid.Id].Bidder_Registration__c);
    }

    // Test Case 4 . derivation of Contact
    private static testmethod void validateContactDerivation() {
    
    TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        String mlhBidderId  = UtilityFns.getRandomString(10,8);
        String mlhContactId  = UtilityFns.getRandomString(10,8);
        
        Contact     tCon    = TestDataProvider.NewContact();
        tCon.LastName = 'TestLast1 Name';
        tCon.FirstName = 'TestFirst1 Name';
        tCon.MLH_Contact_ID__c = mlhContactId;
        insert tCon;

        Bidder_Registration__c  tBidreg = TestDataProvider.NewBidderRegistration(mlhBidderId);
        tBidreg.Contact__c  = tCOn.Id;
        tBidreg.MLH_ContactID__c = mlhContactId;
        tBidreg.MLH_FirstName__c = 'TestLast3 Name';
        tBidreg.MLH_LastName__c = 'TestLast3 Name';
        insert tBidreg;

        Bid__c tBid = TestDataProvider.NewBid();
        tBid.MLH_Bidder_ID__c = mlhBidderId;
        
        Test.startTest();
        insert tBid;
        Test.stopTest();

        //System.assertEquals(tBidreg.Id, [select Id, Bidder_Registration__c from Bid__c where Id = :tBid.Id].Bidder_Registration__c);
        //System.assertEquals(tCon.Id, [select Id, Buyer_Name__c from Bid__c where Id = :tBid.Id].Buyer_Name__c);
    }

    // Test Case 5 . CallRecord Creation....when new winning bid gets created new Call Record has to be created.
    private static testmethod void validateCallrecordCreationonBidInsert() {
    
    TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        Account tAcc = TestDataProvider.newAccount();
        insert tAcc;
        
        Opportunity tOpp = TestDataProvider.NewOpportunity(tAcc.Id);
        insert tOpp;

        Contact tCon    = TestDataProvider.NewContact();
        insert tCOn;

        Bid__c tBid = TestDataProvider.NewBid();
        tBid.Opportunity__c            = tOpp.Id;
        tBid.Buyer_Name__c             = tCon.Id;
        tBid.Winning_Bid__c            = true;

        Test.startTest();
        insert tBid;
        Test.stopTest();

        //System.assertEquals(1, [select count() from CallRecord__c]);
        //System.assertEquals(tCon.Id, [select Contact__c from CallRecord__c limit 1].Contact__c);
        //System.assertEquals(tOpp.Id, [select Opportunity__c from CallRecord__c limit 1].Opportunity__c);
    }

    // Test Case 6 . CallRecord Creation....if the winning flag is updated on Bid from false to true.
    private static testmethod void validateCallrecordCreationonBidUpdate() {
    
    TestSetUp ts = new TestSetup(); 
        ts.CustomSettings();
        
        Account tAcc = TestDataProvider.newAccount();
        insert tAcc;
        
        Opportunity tOpp = TestDataProvider.NewOpportunity(tAcc.Id);
        insert tOpp;

        Contact tCon    = TestDataProvider.NewContact();
        tCon.LastName = 'TestLast2 Name';
        tCon.FirstName = 'TestFirst2 Name';
        insert tCon;

        Bid__c tBid = TestDataProvider.NewBid();
        tBid.Opportunity__c     = tOpp.Id;
        tBid.Buyer_Name__c      = tCon.Id;
        tBid.Winning_Bid__c     = false;
        
        Test.startTest();
        insert tBid;
        Test.stopTest();

        //System.assertEquals(0, [select count() from CallRecord__c]);
        
        tBid.Winning_Bid__c     = true;
        update tBid;

        //System.assertEquals(1, [select count() from CallRecord__c]);
        //System.assertEquals(tCon.Id, [select Contact__c from CallRecord__c limit 1].Contact__c);
        //System.assertEquals(tOpp.Id, [select Opportunity__c from CallRecord__c limit 1].Opportunity__c);
    }
}