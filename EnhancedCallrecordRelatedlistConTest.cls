/*************************************************************************************
* Name          :    EnhancedCallrecordRelatedlistConTest
* Description   :    Test class for EnhancedCallrecordRelatedlistCon.
* Author        :    Harish Emmadi
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
12/09/2013       Harish Emmadi            Created
**************************************************************************************/
@isTest(SeeAllData=true)
private class EnhancedCallrecordRelatedlistConTest{
    private static testMethod void  UnitTest1(){
        EnhancedCallrecordRelatedlistCon crcon = new EnhancedCallrecordRelatedlistCon();//new instance with no parentContactId
        System.assertNotEquals(null, crcon.callrecords);
        
        contact con = TestDataProvider.newcontact();// create a new parent contact.
        insert con;

        bid__c testbid = TestDataProvider.NewBid();
        testbid.Buyer_Name__c  = con.Id;
        testbid.Winning_Bid__c = true;
        testbid.MLH_Bidder_ID__c = 'bid 1';
        testbid.MLH_Auction_ID__c = 'auc 1';
        testbid.MLH_Asset_ID__c = 'ass12';
        testbid.Bid_Amount__c  = 11234567;
        insert testbid;
        

        List<callrecord__c> testcallrecords_gooddata = new List<callrecord__c>();// list to hold test callrecords.
        for(Integer i =0; i< 10; i++)
        {    
            callrecord__c cr = TestDataProvider.NewCallrecord();
			cr.Bid__c = testbid.Id;
            cr.Contact__c         = con.Id;
            cr.Calldisposition__c = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;
            cr.followuptime__c    = datetime.now().adddays(i);
            testcallrecords_gooddata.add(cr);
        }
        insert testcallrecords_gooddata;
        List<callrecord__c> testcallrecords_baddata = new List<callrecord__c>();// list to hold test callrecords.
        for(Integer i =0; i< 50; i++)
        {    
            callrecord__c cr      = TestDataProvider.NewCallrecord();
			cr.Bid__c = testbid.Id;
            cr.Contact__c         = con.Id;
            cr.Calldisposition__c = CONSTANTS.COMPLETED_INFO_DISPOISTION;
            testcallrecords_baddata.add(cr);
        }
        crcon.ParentContactId = con.Id;
        crcon.defaultPgsize   = 5; // should be less than testcallrecords_gooddata.size().
        
        crcon.donothing();
        
        //test pagination methods.
        System.assertEquals(crcon.defaultPgsize, crcon.callrecords.size());
        System.assertEquals(1, crcon.getpageNumber());
        System.assertEquals(crcon.defaultPgsize, crcon.getpageSize());
        System.assertEquals(testcallrecords_gooddata.size(), crcon.getnoOfRecords());
        
        crcon.First();
        System.assertEquals(true, crcon.gethasNext());
        System.assertEquals(false, crcon.gethasPrevious());
        
        crcon.Last();
        System.assertEquals(false, crcon.gethasNext());
        System.assertEquals(true, crcon.gethasPrevious());
        
        crcon.First();
        crcon.Next();
        crcon.previous();
        
        //test save and cancel functions.
        System.assertEquals(false, crcon.doMassEdit);
        crcon.doMassEdit();
        System.assertEquals(true, crcon.doMassEdit);
        crcon.callrecords.get(0).Calldisposition__c = CONSTANTS.COMPLETED_INFO_DISPOISTION;
        crcon.MassSave();
        System.assertEquals(false, crcon.ErrorwithPAList);
        System.assertEquals(testcallrecords_gooddata.size()-1, crcon.getnoOfRecords());
        System.assertEquals(false, crcon.doMassEdit);
     
        crcon.doMassEdit();
        System.assertEquals(true, crcon.doMassEdit);
        crcon.cancelMassEdit();
        System.assertEquals(false, crcon.doMassEdit);
        
        // test DML Exception handling.
        Account acc = TestDataProvider.newAccount();
        insert acc;
        crcon.doMassEdit();
        System.assertEquals(true, crcon.doMassEdit);
        crcon.callrecords.get(0).contact__c = acc.Id;//wrong contact rec Id...."cross reference Id error."
        crcon.MassSave();
        System.assertEquals(true, crcon.ErrorwithPAList);
        
    }
}