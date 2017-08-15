//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  Testclass for all call record functionality like derivations, validations.
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 12/12/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
@isTest(SeeAllData=true)
private class callrecordtriggerTest{
    // Variables and properties.
    private static final Integer BULKLOAD_SIZE = 201;

    // Test Bulk loads of Data.
    private static testmethod void BulkloadTest() {
        ////system.assertEquals(0,[select count() from callrecord__c]);
        List<callrecord__c> crstobeinserted = new List<callrecord__c>();
        for(Integer i = 0; i < BULKLOAD_SIZE; i++)
            crstobeinserted.add(TestDataProvider.NewCallrecord());
        Test.startTest();
        insert crstobeinserted;
        Test.stopTest();
        //system.assertEquals(BULKLOAD_SIZE,[select count() from callrecord__c]);
    }
    
    // Test pleain insert, delete, update.
    private static testmethod void allDMLoperations() {
        //system.assertEquals(0,[select count() from callrecord__c]);
        
        callrecord__c testcr = TestDataProvider.NewCallrecord();
        insert testcr;
        //system.assertEquals(1,[select count() from callrecord__c]);
        callrecord__c cr1 = TestDataProvider.NewCallrecord();
        Insert cr1;

        callrecord__c cr2 = TestDataProvider.NewCallrecord();
        Insert cr2;
        
        WebService_Log__c wsl = new WebService_Log__c (WebService__c='Liveopswrapper.createoutboundLeads',WhatIds__c= '('+cr1.Id+','+cr2.Id+')',Status__c='Failed',Message_Type__c='Outbound');                    
        Insert wsl;        

        testcr.Calldisposition__c = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;
        update testcr;
        //system.assertEquals(CONSTANTS.NEED_FOLLOWUP_DISPOISTION,[select Id, Calldisposition__c from callrecord__c where Id =: testcr.Id limit 1].Calldisposition__c);

        Delete testcr;
        //system.assertEquals(0,[select count() from callrecord__c]);

        undelete testcr;
        //system.assertEquals(1,[select count() from callrecord__c]);
    }
}