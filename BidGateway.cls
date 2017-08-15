//******************************************************************************************************************************************************************************************
//  -------------------------------------------------------------------------
//  query all information related bid tobe used within the trigger execution.
//  -------------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance on 11/12/13 */ 
// Modified By                    Modified Date                                    What Changed                                                    Reason

//******************************************************************************************************************************************************************************************  
public without sharing class BidGateway {
  
  private List<Bid__c>                                        bList;                               // bids in trigger list
//  private Set<Id>                                             currentbidIds;                       // bidIds in current trigger
  public  Map<String,List<Auction_Opportunity_Assignment__c>> auctionIdtoAucOpptyJunMap          =  new Map<String,List<Auction_Opportunity_Assignment__c>>();
  public  Map<String,List<AssetOppJunction__c>>               globalPropIdtoAstOpptyJunMap       =  new Map<String,List<AssetOppJunction__c>>();
  public  Map<String,Bidder_Registration__c>                  bidderIdtoBidRegMap                =  new Map<String,Bidder_Registration__c>();
  public  Set<Id>                                             currentWinningBidIds               =  new Set<Id>();
  
  //  --------------------------------------------
  //  CONSTRUCTOR
  //  --------------------------------------------
  public BidGateway(List<Bid__c> bList) {
    this.bList         = bList;        
  }
  
  //  --------------------------------------------
  //  initialize
  //  --------------------------------------------
  public void initialize() {
    System.debug(FlowControl.getLogLevel(),'ENTERING BidGateway.initialize');
    if (Trigger.isExecuting && Trigger.isBefore) // only needed for Before actions.
    {
         this.auctionIdtoAucOpptyJunMap          =  buildauctionIdtoAucOpptyJunMap(); 
         this.bidderIdtoBidRegMap                = buildbidderIdtoBidRegMap();
    }
    else if (Trigger.isExecuting && Trigger.isAfter) // only needed for After actions.
    {  
         this.currentWinningBidIds        = buildWinningBidIds();  
    }
  }

  //  -------------------------------------------
  //  buildauctionIdtoAucOpptyJunMap:  Map of MLH_Auction_ID__c to Auction_Opportunity_Assignment__c List.
  //  -------------------------------------------
  private Map<String,List<Auction_Opportunity_Assignment__c>> buildauctionIdtoAucOpptyJunMap() {
    Set<String>                                         MLHAAIdSet       =    new Set<String> ();
    Map<String,List<Auction_Opportunity_Assignment__c>> res              =    new Map<String,List<Auction_Opportunity_Assignment__c>> ();
    for (Bid__c b : this.bList) 
      if(String.isNotBlank(b.MLH_AuctionID_MLH_AssetID__c) && b.MLH_AuctionID_MLH_AssetID__c!=null ) MLHAAIdSet.add(b.MLH_AuctionID_MLH_AssetID__c);

    for(Auction_Opportunity_Assignment__c aucoppJun : [SELECT Id, Name,Assets__c, Opportunity__c,Opportunity__r.Name, MLH_AuctionID_MLH_AssetID__c FROM Auction_Opportunity_Assignment__c WHERE MLH_AuctionID_MLH_AssetID__c IN :MLHAAIdSet AND MLH_AuctionID_MLH_AssetID__c!=null])
    {   
        List<Auction_Opportunity_Assignment__c> aucOppJunsList = res.containsKey(aucoppJun.MLH_AuctionID_MLH_AssetID__c) ? res.get(aucoppJun.MLH_AuctionID_MLH_AssetID__c) : new List<Auction_Opportunity_Assignment__c>();
        aucOppJunsList.add(aucoppJun);
        res.put(aucoppJun.MLH_AuctionID_MLH_AssetID__c, aucOppJunsList);
    }
    System.debug(FlowControl.getLogLevel(),'LEAVING buildauctionIdtoAucOpptyJunMap, res = ' + UtilityFns.showauctionIdtoAucOpptyJunMap(res));
    return res;    
  }

  //  -------------------------------------------
  //  buildglobalPropIdtoAstOpptyJunMap:  Map of MLH_Global_Property_ID__c to AssetOppJunction__c List.
  //  -------------------------------------------
  private Map<String,List<AssetOppJunction__c>> buildglobalPropIdtoAstOpptyJunMap() {
    Set<String>                   globalPropIdSet       =    new Set<String> ();
    Map<String,List<AssetOppJunction__c>> res                   =    new Map<String,List<AssetOppJunction__c>> ();
    for (Bid__c b : this.bList) 
        if(String.isNotBlank(b.MLH_Global_Property_ID__c)) 
            globalPropIdSet.add(b.MLH_Global_Property_ID__c);
            for(AssetOppJunction__c astOppJun : [select Id, Name, Opportunity__c, Asset_del__c, Asset_del__r.MLH_Global_Property_ID__c, Opportunity__r.StageName, Opportunity__r.Name from AssetOppJunction__c where Asset_del__r.MLH_Global_Property_ID__c IN : globalPropIdSet AND Opportunity__r.IsClosed = false ORDER BY Opportunity__r.LastModifieDdate DESC])
            {
                List<AssetOppJunction__c> astOppJunsList = res.containsKey(astOppJun.Asset_del__r.MLH_Global_Property_ID__c) ? res.get(astOppJun.Asset_del__r.MLH_Global_Property_ID__c) : new List<AssetOppJunction__c>();
                astOppJunsList.add(astOppJun);
                res.put(astOppJun.Asset_del__r.MLH_Global_Property_ID__c, astOppJunsList);
            }
    System.debug(FlowControl.getLogLevel(),'LEAVING buildglobalPropIdtoAstOpptyJunMap, res = ' + UtilityFns.showglobalPropIdtoAstOpptyJunMap(res));
    return res;    
  }

  //  -------------------------------------------
  //  bidderIdtoBidRegMap:  Map of MLH_Auction_Bidder_IDs__c to Bidder_Registration__c.
  //  -------------------------------------------

//************** Needs a Fix  ************************** // 
  private Map<String,Bidder_Registration__c> buildbidderIdtoBidRegMap() {
    Set<String>                           bidderIdSet       =    new Set<String> ();
    Map<String,Bidder_Registration__c>    res               =    new Map<String,Bidder_Registration__c> ();
    for (Bid__c b : this.bList) 
      if(String.valueof(b.MLH_Auction_Bidder_IDs__c)!= ' ' && String.valueof(b.MLH_Auction_Bidder_IDs__c)!=null ) {
          if(!bidderIdSet.contains(b.MLH_Auction_Bidder_IDs__c) && b.MLH_Auction_Bidder_IDs__c!=null && b.MLH_Auction_Bidder_IDs__c!='0' && b.MLH_Auction_Bidder_IDs__c!='') 
              bidderIdSet.add(b.MLH_Auction_Bidder_IDs__c);
           //Murali
           system.debug('Bidder Ids : ' +bidderIdSet); 
      }  
    if(bidderIdSet.size() > 0) {
        for(Bidder_Registration__c bidreg : [select Id, Name, MLH_Auction_Bidder_ID__c, Contact__c from Bidder_Registration__c 
                                             WHERE MLH_Auction_Bidder_ID__c!=' ' AND MLH_Auction_Bidder_ID__c!=null AND MLH_Auction_Bidder_ID__c IN :bidderIdSet ORDER BY LastModifieDdate])
        {
            res.put(bidreg.MLH_Auction_Bidder_ID__c, bidreg);
        }
    }
    System.debug(FlowControl.getLogLevel(),'LEAVING bidderIdtoBidRegMap, res = ' + UtilityFns.showbidderIdtoBidRegMap(res));
    return res;    
  }
//************** Needs a Fix  ************************** // 


  //  -------------------------------------------
  // Returns Current Winning Bids with Winning Bid Call Records 
  //  -------------------------------------------
  private Set<Id> buildWinningBidIds() {
        Set<Id> bidIds = new Set<Id>();
        for (Bid__c b : this.bList) {
            if(b.Id!=null) 
                bidIds.add(b.Id);
        }
        Set<Id> WinningCallRecordsIds = new Set<Id>();
        
        for (CallRecord__c cr : [Select Id, Bid__c From CallRecord__c WHERE Winning_Bid_Call__c=true AND Bid__c IN : bidIds])
        {   
           WinningCallRecordsIds.add(cr.Bid__c);
        }
                  
    System.debug(FlowControl.getLogLevel(),'LEAVING WinningBidIds = ' +WinningCallRecordsIds);
    return WinningCallRecordsIds;   
  }


}