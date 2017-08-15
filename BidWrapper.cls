//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  Wraps the Bid object so we can have methods on it 
//  --------------------------------------------------------------------
/* Author : Harish Emmadi from Centerstance  on 11/12/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public without sharing class BidWrapper {
  //  ------------------------------------------------
  //  Properties
  //  ------------------------------------------------
  public   Bid__c          bid      { get; set; }
  private  Bid__c          bidOld;
  private  Boolean         isValid    = true;          // passed validation checks?

  //  -------------------------------------------
  //  Constructor
  //  -------------------------------------------
  public BidWrapper(Bid__c bid) {
    this.bid     = bid;
    this.bidOld  = null;
  }
  
  public BidWrapper(Bid__c bid, Bid__c bidOld) {
    this.bid     = bid;
    this.bidOld  = bidOld;
  }
  //  ---------------------------------------------------------------------
  //  debug 
  //  ---------------------------------------------------------------------
  public String debug() {
    return   '\nName                     : ' + this.bid.Name;
  }
  
  
  //  -------------------------------------------
  //  derive:      Field derivations
  //  derivation 1 : associate Bid record with Asset based on the MLH_Global_Property_ID__c.
  //  derivation 2 : associate Bid record with Opportunity based on the MLH_Global_Property_ID__c.
  //  derivation 3 : associate Bid record with Auction Opportunity Assignment based on the MLH_Auction_Id__c.
  //  derivation 4 : associate Bid record with Contact based on the MLH_Auction_Bidder_IDs__c.
  //  derivation 5 : associate Bid record with Bidder Registration based on the MLH_Auction_Bidder_IDs__c.
  //  -------------------------------------------
  public void derive(BidGateway bidGw) {
    if (!this.isValid) {}
    else {
        System.debug(FlowControl.getLogLevel(),'ENTERING derive ' + debug());         
        //Populate AOA, Opportunity and Asset Lookup fields on Bid using Record MLH_AuctionID_MLH_AssetID__c
        if(this.bidOld == null && String.isNotBlank(this.bid.MLH_AuctionID_MLH_AssetID__c) && bidGw.auctionIdtoAucOpptyJunMap.containsKey(this.bid.MLH_AuctionID_MLH_AssetID__c)) {
            for(Auction_Opportunity_Assignment__c aucOppJun : bidGw.auctionIdtoAucOpptyJunMap.get(this.bid.MLH_AuctionID_MLH_AssetID__c)) {
                if(aucOppJun.MLH_AuctionID_MLH_AssetID__c == this.bid.MLH_AuctionID_MLH_AssetID__c) {
                    this.bid.Auction_Opportunity_Assignment__c     =  aucOppJun.Id; // Derivation 3// changed from MLH Auction id to MLH venue id
                    //this.bid.Assets__c     = aucOppJun.Assets__c; // Derivation 1
                    this.bid.Opportunity__c = aucOppJun.Opportunity__c; // Derivation 2    
                }
            }
        }
        
        // Populate Bidder Registration and Contact lookup fields on Bid Records using using MLH_Auction_Bidder_IDs__c field
        if(this.bidOld == null && String.isNotBlank(this.bid.MLH_Auction_Bidder_IDs__c) && bidGw.bidderIdtoBidRegMap.containsKey(this.bid.MLH_Auction_Bidder_IDs__c)) {
            Bidder_Registration__c bidreg   =   bidGw.bidderIdtoBidRegMap.get(this.bid.MLH_Auction_Bidder_IDs__c);
            this.bid.Bidder_Registration__c     =   bidreg.Id;
            this.bid.Buyer_Name__c              =   bidreg.Contact__c;
        }   
    }
    System.debug(FlowControl.getLogLevel(),'LEAVING derive ' + debug());
  }  

  //  -------------------------------------------
  //  validate:    Does Validations undoable by Force.com Validation Rules; sets instance Vbl isValid
  //  Validation 1 :
  //  -------------------------------------------
  public void validate(BidGateway bidGw) {
    if (!validationsEnabled()) {}
    else {
      //if (!validation1(bidGw)) this.isValid = false;
    }
    System.debug(FlowControl.getLogLevel(),'LEAVING validate, isValid=' + this.isValid);
  }
  
  //  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //  addToTcallrecordstobeinsertedList : create a callrecord when new Winning bid is inserted/Updated and when followuptime is updated.
  //  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  public List<CallRecord__c> addTocallrecordstobeinsertedList(BidGateway bGw, List<CallRecord__c> callrecordstobeinsertedListListToDate) {
    List<CallRecord__c> res             = callrecordstobeinsertedListListToDate;



    if( this.bid.Bidder_Registration__c!=null && 
        (
            (
               (this.bid.MLH_Event_ID__c != null && this.bid.MLH_Event_ID__c != '' && this.bid.Winning_Bid__c == true)
                &&                
               (this.bid.MLH_Event_ID__c.startsWith('T') || this.bid.MLH_Event_ID__c.startsWith('O')||this.bid.MLH_Event_ID__c.startsWith('X')||this.bid.MLH_Event_ID__c.startsWith('L')||this.bid.MLH_Event_ID__c.startsWith('H')) 
                &&
               (this.bidOld == null) 
            )
            || 
            (
               (this.bidold != null &&  
                   ( (this.bidold.MLH_Next_Contact_Time__c != this.bid.MLH_Next_Contact_Time__c && this.bid.MLH_Next_Contact_Time__c!=null ) 
                      || 
                     (this.bidOld.Winning_Bid__c != this.bid.Winning_Bid__c && this.bid.Winning_Bid__c == true && !bGw.currentWinningBidIds.contains(this.bid.Id))
                   )
               )
            )
        )
      )             
    {
        CallRecord__c   newCallRecord    = new CallRecord__c();// create new Call Record.
        newCallRecord.Bid__c             = this.bid.Id;
        newCallRecord.Opportunity__c     = String.isNotBlank(this.bid.Opportunity__c) ? this.bid.Opportunity__c :null;
        newCallRecord.Contact__c         = String.isNotBlank(this.bid.Buyer_Name__c) ? this.bid.Buyer_Name__c : null;
        newCallRecord.FollowupTime__c    = this.bid.MLH_Next_Contact_Time__c;
        if(this.bidOld == null && this.bid.Winning_Bid__c == true)         
            newCallRecord.Notes__c           =  'Winning Bid Notes';
        else
            newCallRecord.Notes__c           = this.bid.Call_Record_notes__c;        
        newCallRecord.Calldisposition__c = null;
        if( this.bidOld != null ) {
            if (this.bidold.MLH_Next_Contact_Time__c != this.bid.MLH_Next_Contact_Time__c && this.bid.MLH_Next_Contact_Time__c!=null )        
                newCallRecord.Calldisposition__c = CONSTANTS.NEED_FOLLOWUP_DISPOISTION;            
        }
        newCallRecord.Winning_Bid_Call__c= newCallRecord.Calldisposition__c!=null? false: this.bid.Winning_Bid__c;

        system.debug('Call Disposition : ' +newCallRecord.Calldisposition__c);
        res.add(newCallRecord);
    }
    return res;
  }
  
    //  -----------------------------------------
  //  validationsEnabled
  //  -----------------------------------------
  private Boolean validationsEnabled() {
    return FlowControl.runBidTriggerHandler();
  }

}