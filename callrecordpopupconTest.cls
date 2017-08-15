/*************************************************************************************
* Name          :    callrecordpopupconTest.
* Description   :    Test class for callrecordpopupcon.
* Author        :    Harish Emmadi
 
Modification Log
------------------------------------------------------------------------------------------------------------
Date             Developer                Comments
------------------------------------------------------------------------------------------------------------
12/9/2013       Harish Emmadi            Created
*********************************************************************fy6trre4*****************/
//@isTest(SeeAllData=true)
@isTest
private class callrecordpopupconTest{
    
    private static testmethod void UnitTest1(){
        contact testcon = TestDataProvider.newcontact();// create a new parent contact.
        testcon.Phone   = '(222)222-2222';
        testcon.MLH_WorkPhone__c = '(222)222-2222';
        insert testcon;
        
        bid__c testbid = TestDataProvider.NewBid();
        testbid.Buyer_Name__c  = testcon.Id;
        testbid.Winning_Bid__c = true;
        testbid.MLH_Bidder_ID__c = 'bid 1';
        testbid.MLH_Auction_ID__c = 'auc 1';
        testbid.MLH_Asset_ID__c = 'ass12';
        testbid.Bid_Amount__c  = 123456;
        insert testbid;
        
        callrecord__c testcr = TestDataProvider.NewCallrecord();
        testcr.Contact__c    = testcon.Id;
        testcr.Bid__c        = testbid.Id;
        insert testcr;
        
        List<callrecord__c> testfollowupcrs = new List<callrecord__c>();// list to hold followup callrecords.
        for(Integer i =0; i< 10; i++)
        {    
            callrecord__c cr      = TestDataProvider.NewCallrecord();
            cr.Bid__c = testbid.Id;
            cr.Contact__c         = testcon.Id;
            cr.Calldisposition__c = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;
            cr.followuptime__c    = datetime.now().adddays(i);
            testfollowupcrs.add(cr);
        }
        insert testfollowupcrs;
        
        List<Bid__c> tbids = new List<Bid__c>();
        for(Integer i = 0; i < 10; i++)
        {   
            bid__c tbid = TestDataProvider.NewBid();
            tbid.Buyer_Name__c  = testcon.Id;
            tbid.Winning_Bid__c = true;
            tBid.Bid_Amount__c=21000+i;
            tBid.MLH_Bid_Stage__c='Stage 1';
           // bidstobeinserted.add(tBid);
            tbids.add(tbid);
        }  
        Test.startTest();
        insert tbids;
        Test.stopTest();
        
        Apexpages.standardcontroller controller = new Apexpages.standardcontroller(testcr);
        callrecordpopupcon crcon = new callrecordpopupcon(controller);
        
        //system.assertEquals(false, crcon.needfollowup);
        crcon.crstatus = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;
        crcon.validatecrstatus();
        //system.assertEquals(true, crcon.needfollowup); 
        
        crcon.selectedconId = testcon.Id;
        crcon.processselectedcontact();
        
        //system.assertNotEquals(null, crcon.getbids());
        
        crcon.selectedbidId = crcon.getbids().get(0).Id;
        crcon.processselectedBid();
        
        //test followup bids pagination methods.
        //system.assertEquals(1, crcon.getpageNumber());
        //system.assertNotEquals(0, crcon.getpageSize());
        //system.assertEquals(testbids.size()+1, crcon.getnoOfRecords());
        
        crcon.First();
        //system.assertEquals(true, crcon.gethasNext());
        //system.assertEquals(false, crcon.gethasPrevious());
        
        crcon.Last();
        //system.assertEquals(false, crcon.gethasNext());
        //system.assertEquals(true, crcon.gethasPrevious());
        
        crcon.First();
        crcon.Next();
        crcon.previous();
        
        crcon.poleforbids();
        crcon.getcrStatusOptions();
        
        // testing save method.
        //system.assertEquals(false, crcon.callrecord_issaved);
        crcon.crstatus = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;
        crcon.callrec.followuptime__c = Datetime.now();
        crcon.savecallrecord();
        //system.assertEquals(11, [select count() from callrecord__c where followuptime__c != null]);
        //system.assertEquals(true, crcon.callrecord_issaved);
    }
    
    private static testmethod void UnitTest2(){
        // test inbound scenarios.
        Apexpages.standardcontroller controller = new Apexpages.standardcontroller(new callrecord__c());
        callrecordpopupcon crcon = new callrecordpopupcon(controller);
        crcon.sFields.firstName = 'firstname_wrong_xxx';
        crcon.sFields.Phone = '(222)222-2222';
        crcon.search();
        //system.assertEquals(0, crcon.getnoOfRecords_c());
        //system.assertEquals(0, crcon.getcontacts().size());
        
        List<contact> testcontacts = new List<contact>();
        for(Integer i =0; i<10; i++)
        {
            contact tcon = TestDataProvider.newcontact();// create a new parent contact.
            tcon.Phone   = '(222)222-2222';
            testcontacts.add(tcon);
        }    
        insert testcontacts;
        
        Test.setCurrentPage(Page.callrecordpopup);
        Apexpages.currentPage().getparameters().put('ANI','222');
        crcon = new callrecordpopupcon(controller);
        
        //system.assertNotEquals(0, crcon.getcontacts().size());
        
        //test contact pagination methods.
        //system.assertEquals(1, crcon.getpageNumber_c());
        //system.assertNotEquals(0, crcon.getpageSize_c());
        //system.assertNotEquals(0, crcon.getnoOfRecords_c());
        
        crcon.First_c();
        //system.assertEquals(true, crcon.gethasNext_c());
        //system.assertEquals(false, crcon.gethasPrevious_c());
        
        crcon.Last_c();
        //system.assertEquals(false, crcon.gethasNext_c());
        //system.assertEquals(true, crcon.gethasPrevious_c());
        
        crcon.First_c();
        crcon.Next_c();
        crcon.previous_c();
        
        //system.assertEquals(false, crcon.callrecord_issaved);
        crcon.savecallrecord();//validation check {disposition is required.}
        //system.assertEquals(0, [select count() from callrecord__c]);
        crcon.crstatus   = CONSTANTS.COMPLETED_INFO_DISPOISTION;
        crcon.savecallrecord();
        //system.assertEquals(1, [select count() from callrecord__c]);
        //system.assertEquals(true, crcon.callrecord_issaved);
        
        crcon.selectedconId = testcontacts.get(0).Id;
        crcon.processselectedcontact();
        //system.assertEquals(null, crcon.callrec.Id);
    }
}