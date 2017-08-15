@isTest(seeAllData = true)
private class WinningBidRestServiceTest {

    static testMethod void myUnitTest() {
        Asset__c tAst = TestDataProvider.NewAsset();
        tAst.MLH_Global_Property_ID__c = 'RestGPID1234';
        insert tAst; 
        //https://cs9.salesforce.com/services/apexrest/MLHCreateWinningBid
        //String inputJson = '{"AUCTIONID":"aid12","BIDAMOUNT": "17","WINNINGBID": "Yes","ASSETID": "assetId77","BIDDATETIME": "2014-10-10 22:00:00","GLOBALPROPERTYID": "RestGPID1234","MLHBIDID": "bidId03919245","BIDDERID": "bidderId24", "MLHTEAM": "t12", "MLHBIDSTAGE": "s23", "MLHNEXTCONTACTTIME":"2015-10-10 22:00:00", "MLHVENUEID":"mven55", "ADCASSETMGREMAIL":"abc@auction.com", "ADCASSETMGRNAME":"abc",
        //                     "ADCASSETMGRPHONE":"1234567890", "ASSETACTUALRETURNDATE":"2014-10-10 22:00:00", "ASSETRUNS":"45", "ASSETRUNSLEFT":"45", "ASSETSCHEDULEDRETURNDATE":"2014-10-10 22:00:00", "AUCTIONSELLERRESERVE":"100", "LISTINGAGENTEMAIL":"abcF@auction.com", "LISTINGAGENTNAME":"abcd", "LISTINGAGENTPHONE":"9876543210", "MANUALCLERKUSEREMAIL":"abc@auction.com", "ORIGINALRESERVE":"100", "SELLERCONTACTEMAIL":"abcD@auction.com",
        //                     "SELLERCONTACTNAME":"abcdf", "SELLERCONTACTPHONE":"'9876543211", "TYPEOFSALE":"SALES"}';
        
       WinningBidRestService.createNewBid('34','2014-10-10 22:00:00','teampras','stage1','True','RestAUC1234','bidId03919245','2014-10-10 22:00:00','RestGPID1234','s23','testid23','mven55','HTD','O-123', 'abc@auction.com', 'abc', '1234567890', '2014-10-10 22:00:00', '45', '45', '2014-10-10 22:00:00', '100', 'abcF@auction.com', 'abcd', '9876543210', 'abc@auction.com', '100', 'abcD@auction.com', 'abcdf', '9876543211', 'SALES');
       //WinningBidRestService.createNewBid('');
    }
}