@isTest
(SeeAllData=TRUE)
private class OpportunityStageUpdateJobTest {
    @isTest static void ChangeCurrentAuctionFlag() {
        List<Opportunity> sObjList = new List<Opportunity>([SELECT Id,StageName,Most_Recent_Auction__c,Auction_Date_Today__c   
                                                            FROM Opportunity 
                                                            WHERE 
                                                            Most_Recent_Auction__r.Active_Auction_Event__c = TRUE AND
                                                            RecordTypeId = '012d0000000t0iC' AND  
                                                            (StageName = :Label.Opportunity_Stage3 OR StageName = :Label.Opportunity_Stage4)
                                                            LIMIT 100
                                                           ]);

        Set<Id> AuctionIds = new Set<Id>();
        List<Auction_Campaign__c> auctionList = new List<Auction_Campaign__c>();
        for(Opportunity o: sObjList) {            
            if(!AuctionIds.contains(o.Most_Recent_Auction__c)) {
                Auction_Campaign__c a = new Auction_Campaign__c();
                a.Id  =  o.Most_Recent_Auction__c;
                a.Active_Auction_Event__c = false;
                auctionList.add(a);
                AuctionIds.add(o.Most_Recent_Auction__c);
            }
        }
        Update auctionList;
        Integer i = 0;
        for(Auction_Campaign__c a : auctionList) {
            i = i + 1;
            if(math.mod(i,5) == 0) {            
                a.Bidding_Start_Time__c = system.now()-1;
                a.Bidding_End_Time__c = system.now()+1;
            }
            a.Active_Auction_Event__c = TRUE;        
        }

        Test.startTest();
            Update auctionList;
        Test.stopTest();
    }
}