public class AOAWinningBidValidator {

    public Set<String> winningBidGUIDs;
    public Set<String> aoaIds;

    public AOAWinningBidValidator(){
        winningBidGUIDs = new Set<String> ();
        aoaIds = new Set<String> ();
    }   

    public void preValidate(Auction_Opportunity_Assignment__c aoa, Auction_Opportunity_Assignment__c oldAoa){
        String aoaId = (String)aoa.get('Id');
        String propId = (String)aoa.get('MLH_Property_Id__c');
        String winningBidderId = (String)aoa.get('MLH_Winning_Bidder_ID__c');
        String oldWinningBidderId = (String)oldAoa.get('MLH_Winning_Bidder_ID__c');
        String auctionId = (String)aoa.get('MLH_Auction_ID__c');
        String oldAuctionId = (String)oldAoa.get('MLH_Auction_ID__c');
        Decimal salesPrice = (Decimal)aoa.get('MLH_Final_Sale_Price__c');
        Decimal oldSalesPrice = (Decimal)oldAoa.get('MLH_Final_Sale_Price__c');
        String status = (String)aoa.get('Auction_Day_Status__c');
        String oldStatus = (String)oldAoa.get('Auction_Day_Status__c');

        if ((winningBidderId != oldWinningBidderId) || (auctionId != oldAuctionId) || (salesPrice != oldSalesPrice) || (status != oldStatus)){          

            //set of ids to identify the winning bid to be attached to the opportunity
            if(winningBidderId != null && winningBidderId != '-1' && auctionId != null && auctionId != '-1' && salesPrice != null && salesPrice > 0 && propId != null && !CONSTANTS.aoaFalloutStatuses.contains(status)){               
                String guid = winningBidderId + auctionId + propId + String.valueOf(salesPrice);
                winningBidGUIDs.add(guid);
                aoaIds.add(aoaId);
            }else if(CONSTANTS.aoaFalloutStatuses.contains(status)){
                aoaIds.add(aoaId);
            }
        }
    }

    public void validate(){
        if(!aoaIds.isEmpty()){
            AOAWinningBidValidator.validateWinningBidLookup(aoaIds, winningBidGUIDs);
        }
    }

    @Future
    public static void validateWinningBidLookup(Set<String> aoaIds, Set<String> winningBidGUIDs){
        List<Bid__c> bidsForUpdate = new List<Bid__c> ();
        Map<String, Opportunity> oppsForUpdate = new Map<String, Opportunity> ();
        List<Bid__c> winningBidRemovals = new List<Bid__c> ();

        //award winning bids
        Set<String> winningBidAOAs = new Set<String> ();
        for(Bid__c bid : (List<Bid__c>)database.query('SELECT Id, MLH_Bidder_ID__c, MLH_Asset_ID__c, MLH_Team__c, MLH_Auction_ID__c, Bid_Amount__c, Winning_Bid__c, AOA_Auction_Day_Status__c, MLH_Bid_Stage__c, Bid_Registration_Email__c, Bid_Registration_First_Name__c, Bid_Registration_Last_Name__c, Opportunity__c, Auction_Opportunity_Assignment__c, Auction_Opportunity_Assignment__r.Auction_Day_Status__c, Auction_Opportunity_Assignment__r.Stage__c, Auction_Opportunity_Assignment__r.MLH_Team__c FROM Bid__c WHERE Auction_Opportunity_Assignment__c IN: aoaIds AND MLH_Bidder_ID__c!=null AND MLH_Bidder_ID__c!=\'1\' AND MLH_Auction_ID__c!=null AND MLH_Asset_ID__c!=null AND Bid_Amount__c > 0 ORDER BY Auction_Opportunity_Assignment__c,LastModifiedDate DESC')){

            String aoaId = (String)bid.get('Auction_Opportunity_Assignment__c');
            String oppId = (String)bid.get('Opportunity__c');
            String propId = (String)bid.get('MLH_Asset_ID__c') != null ? (String)bid.get('MLH_Asset_ID__c') : (String)bid.get('MLH_Global_Property_ID__c');
            String winningBidderId = (String)bid.get('MLH_Bidder_ID__c');               
            String auctionId = (String)bid.get('MLH_Auction_ID__c');                
            Decimal bidAmount = (Decimal)bid.get('Bid_Amount__c');              
            String status = (String)bid.get('AOA_Auction_Day_Status__c');

            //winning bid udpdates
            String guid = winningBidderId + auctionId + propId + String.valueOf(bidAmount);
            if(winningBidGUIDs.contains(guid) && !CONSTANTS.aoaFalloutStatuses.contains(status)){                   
                String mlhTeam = bid.Auction_Opportunity_Assignment__r.MLH_Team__c;

                bid.put('Winning_Bid__c', true);
                bid.put('True_Winning_bid__c', true);
                bid.put('MLH_Team__c', mlhTeam);

                winningBidAOAs.add(aoaId);
                bidsForUpdate.add(bid);

                if(oppId != null && !oppsForUpdate.containsKey(oppId)){
                    Opportunity opp = stageOpportunityUpdate(bid, true);
                    oppsForUpdate.put(oppId, opp);
                }
            }else{
                winningBidRemovals.add(bid);
            }
        }

        //remove winning bids if new bid has been found
        Set<String> bidRemovalIds = new Set<String> ();
        for(Bid__c bid : winningBidRemovals){
            String aoaId = (String)bid.get('Auction_Opportunity_Assignment__c');
            String oppId = (String)bid.get('Opportunity__c');
            String status = (String)bid.get('AOA_Auction_Day_Status__c');

            //if a new Bid is being flagged as winning set the previous to false or if a bid has fallen out
            if(winningBidAOAs.contains(aoaId) || CONSTANTS.aoaFalloutStatuses.contains(status)){
                bid.put('Winning_Bid__c', false);
                bid.put('True_Winning_bid__c', false);
                bidsForUpdate.add(bid);
                bidRemovalIds.add(bid.Id);

                if(!oppsForUpdate.containsKey(oppId)){
                    Opportunity opp = stageOpportunityUpdate(bid, false);
                    oppsForUpdate.put(oppId, opp);
                }
            }
        }

        //Omit call disposition records for bids that are no longer winning
        if(!bidRemovalIds.isEmpty()){
            String followupDisposition = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;
            List<CallRecord__c> callRecordsForUpdate = new List<CallRecord__c> ();

            for(CallRecord__c cr : (List<CallRecord__c>)database.query('SELECT Id, CallDisposition__c FROM CallRecord__c WHERE Bid__c IN :bidRemovalIds AND CallDisposition__c = :followupDisposition')) {
                cr.CallDisposition__c = CONSTANTS.OMITTED_DISPOISTION;

                callRecordsForUpdate.add(cr);
            }

            if(!callRecordsForUpdate.isEmpty()){
                update callRecordsForUpdate;
            }
        }

        //update bid records
        if(!bidsForUpdate.isEmpty()){
            try{
                update bidsForUpdate;
            }catch(Exception e){
                //exception logic
            }
        }

        //update opportunities
        if(!oppsForUpdate.isEmpty()){
            try{
                update oppsForUpdate.values();
            }catch(Exception e){
                //exception logic
            }
        }       
    }

    public static Opportunity stageOpportunityUpdate(Bid__c bid, Boolean isWinning){
        Opportunity opp = new Opportunity ( Id = (String)bid.get('Opportunity__c') );
        IF(isWinning && bid.Auction_Opportunity_Assignment__r.Auction_Day_Status__c == 'Contract Complete') {
            opp.StageName =  'Closed Won';                       
        }

        opp.Winning_BidLookup__c = (isWinning) ? bid.Id : null;
        opp.Winning_Bid_Amount__c = (isWinning) ? (Decimal)bid.get('Bid_Amount__c') : null;
        opp.Winning_Bidder_Email__c = (isWinning) ? (String)bid.get('Bid_Registration_Email__c') : null;
        opp.Winning_Bidder_First_Name__c = (isWinning) ? (String)bid.get('Bid_Registration_First_Name__c') : null;
        opp.Winning_Bidder_Last_Name__c = (isWinning) ? (String)bid.get('Bid_Registration_Last_Name__c') : null;
        opp.Winning_Bid_AOA__c = (isWinning) ? (String)bid.get('Auction_Opportunity_Assignment__c') : null;

        return opp;
    }
}