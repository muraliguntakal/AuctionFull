//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  Testclass for UtilityFns.
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 12/13/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
@isTest(SeeAllData=true)
private class UtilityFnsTest{
    private static testmethod void testparseCSV(){
        String csvfilebody = '"row1Column1","row1,Column2","row1Column3","row1Column4","row1Column5"';
        csvfilebody += '\r\n'+'"row2Column1","row2Column2","row2"extraquote"Column3","row2,a,Column4","row2Column5",""';
        List<List<String>> result = UtilityFns.parseCSV(csvfilebody);
        //system.assertNotEquals(null, result);
        //system.assertEquals(2, result.size());
        //system.assertEquals(5, result.get(0).size());// count should match the comma seperated tokens count.
        
        //test getRandomString method.
        String randomstring = UtilityFns.getRandomString(5, 10);
        //system.assertEquals(5, randomstring.length());
        
        //test ConsolidatedStringof method
        List<Account> accs = new List<Account>();
        for(Integer i=0; i<10; i++)
        {
            accs.add(TestDataProvider.NewAccount());
        }
        String consolidatedaccnames = UtilityFns.ConsolidatedStringof(accs, 'Name', ';');
        //system.assertEquals(9, consolidatedaccnames.countMatches(';'));
        
        //test getRandomInt method
        Integer randomInt = UtilityFns.getRandomInt(1, 100);
        //system.assert(randomInt < 100 && randomInt > 0);
        
        //test getMessageLogStatus
        String msglog = UtilityFns.getMessageLogStatus(UtilityFns.WebserviceLogStatus.Request_Received);
        ////system.assert(!msglog.containsAny('_'));
        
        //test FriendlifyErrorMessages method.
        try{
            Account acc = new Account();
            insert acc;
            //system.assertEquals(0, [select count() from Account]);
        }catch(DmlException dl){
            String errors = UtilityFns.FriendlifyErrorMessages(dl);
        }
        
        // test flattenDbError method.
        List<Account> taccs = new List<Account>{new Account(), new Account(), new Account()};
        Database.SaveResult[]  srList = Database.insert(taccs ,false);
        //system.assertEquals(0, [select count() from Account]);
        Database.SaveResult     sr = srList.get(0);
        String dberrors = UtilityFns.flattenDbError(sr.getErrors());
        
        //test getfieldApiNamesList, getFieldMetaData methods.
        Schema.SObjectType  accsobj  =  Schema.getGlobalDescribe().get('Account');
        Map<String, Schema.DescribeFieldResult> accfieldDescribeMap = UtilityFns.getFieldMetaData(accsobj.getDescribe());
        List<String> accountfieldlabels = new List<String>{'account id'};
        List<String> accountfieldnames = UtilityFns.getfieldApiNamesList(accountfieldlabels, accfieldDescribeMap);
        //system.assertEquals(accountfieldlabels.size(), accountfieldnames.size());
        
        // test checkLoggingEnabled method.
        //SystemSettings__c ss = new SystemSettings__c(name = CONSTANTS.IS_WEBSERVICE_LOG_ENABLED, value__c = 'Y');
        //insert ss;//enable logs.
        boolean logsenabled = UtilityFns.checkLoggingEnabled();
        //system.assertEquals(true, logsenabled);
        
        //test createNewOutboundMessageLogWithStatus method.
        String weblogId = UtilityFns.createNewOutboundMessageLogWithStatus('TestingUtilityFns', '', 'Testobj',
                                                                 UtilityFns.WebserviceLogStatus.Success, '');
        //system.assertNotEquals(null, weblogId);
        //system.assertEquals(1, [select count() from Webservice_Log__c]);
        AuctionException ae = new AuctionException();
        
        //test sendEmail method
        UtilityFns.sendEmail(new LIST<String>{'testuser@test.com'}, new LIST<String>(), 'Subject', 'body', blob.valueof('test'), 'Attachment Name');
        try{
            UtilityFns.sendEmail(new LIST<String>(), new LIST<String>(), '', '', blob.valueof('test'), 'Attachment Name');//should throw exception
        }catch(Exception e){
            //system.assertEquals('AuctionException', e.getTypeName());
        }
        
        //test showbidderIdtoBidRegMap method
        bid__c tbid = TestDataProvider.NewBid();
        insert tbid;
        List<Bidder_Registration__c> tbidregs = new List<Bidder_Registration__c>();
        for(Integer i=0; i<10; i++)
        {
            tbidregs.add(TestDataProvider.NewBidderRegistration(tbid.Id));
        }
        insert tbidregs;
        Map<String,Bidder_Registration__c> bigregsmap = new Map<String,Bidder_Registration__c>([select Id,name from Bidder_Registration__c ORDER BY CreatedDate DESC LIMIT 5]);
        String resultstr = UtilityFns.showbidderIdtoBidRegMap(bigregsmap);
        //system.assertEquals(11, resultstr.countMatches('\n'));
        
        // test showauctionIdtoAucOpptyJunMap method
        Map<String,List<Auction_Opportunity_Assignment__c>> auctooppassmap = new Map<String,List<Auction_Opportunity_Assignment__c>>{'str1' => new List<Auction_Opportunity_Assignment__c>()};
        resultstr = UtilityFns.showauctionIdtoAucOpptyJunMap(auctooppassmap);
        
        //test showglobalPropIdtoAstOpptyJunMap method
        Map<String,List<AssetOppJunction__c>> proptooppassmap = new Map<String,List<AssetOppJunction__c>>{'str1' => new List<AssetOppJunction__c>()};
        resultstr = UtilityFns.showglobalPropIdtoAstOpptyJunMap(proptooppassmap);
    }

}