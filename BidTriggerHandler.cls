//******************************************************************************************************************************************************************************************
/* Author : Harish Emmadi from Centerstance  on 11/12/13 */
// Modified By                    Modified Date                                    What Changed                                                    Reason

//******************************************************************************************************************************************************************************************  
public without sharing class BidTriggerHandler implements ITrigger{
  
    //  -----------------------------
    //  PRIVATE VARIABLES
    //  -----------------------------

    private BidGateway            bidGw;            // Reference to object containing related records collected prior to pass through each triggered Bids
    private List<CallRecord__c>   callrecordstobeinsertedList   =   new List<CallRecord__c>();

    //  -----------------------------
    //  CONSTRUCTOR
    //  -----------------------------
    public BidTriggerHandler() {}

    // -------------------------------
    // bulkBefore: This method is called prior to execution of a BEFORE trigger. Use this to cache any data required into maps prior execution of the trigger.   
    // -------------------------------
    public void bulkBefore() {
      this.bidGw          =     new BidGateway(Trigger.isUpdate || Trigger.isInsert? Trigger.new : Trigger.old );
      if (FlowControl.runBidTriggerHandler())
        this.bidGw.initialize();
    }

    // -------------------------------
    // bulkAfter: This method is bidlled prior to execution of an AFTER trigger. Use this to cache any data required into maps prior execution of the trigger.
    // ------------------------------- 
    public void bulkAfter() {
      this.bidGw          =     new BidGateway(Trigger.isUpdate || Trigger.isInsert || Trigger.isUndelete? Trigger.new : Trigger.old );
      if (FlowControl.runBidTriggerHandler())
        this.bidGw.initialize();
    }

    // -------------------------------
    // beforeInsert: This method is called iteratively for each record to be inserted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.  
    // ------------------------------- 
    public void beforeInsert(SObject sobj) {
      Bid__c        bid         =    (Bid__c) sobj;
      sharedBefore(bid,null);
    }

    // -------------------------------
    // beforeUpdate: This method is called iteratively for each record to be updated during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    // -------------------------------   
    public void beforeUpdate(SObject oldSobj, SObject sobj) {
      Bid__c        bid         =    (Bid__c) sobj;
      Bid__c        bidOld      =    (Bid__c) oldSobj;
      sharedBefore(bid,bidOld);
    }

    //  --------------------------------
    //  sharedBefore
    //  --------------------------------
    private void sharedBefore(Bid__c  bid, Bid__c  bidOld) {
      BidWrapper bidW       =     new BidWrapper(bid,bidOld);
      System.debug(FlowControl.getLogLevel(),'\n\n***ENTERING BidTriggerHandler ' + UtilityFns.triggerLabel() );    // validate has the debug statement
      bidW.validate(this.bidGw);
      bidW.derive(this.bidGw);
      System.debug(FlowControl.getLogLevel(),'\n\n***LEAVING BidTriggerHandler ' + UtilityFns.triggerLabel() );    // validate has the debug statement
    }


    // -------------------------------
    // beforeDelete: This method is called iteratively for each record to be deleted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    // -------------------------------   
    public void beforeDelete(SObject sobj) {
      Bid__c      bid       =     (Bid__c) sobj;
    }

    // -------------------------------
    // afterInsert: This method is called iteratively for each record inserted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterInsert(SObject sobj) {
      Bid__c      bid       =     (Bid__c) sobj;
      BidWrapper  bidW      =     new BidWrapper(bid,null);
      this.callrecordstobeinsertedList  = bidw.addTocallrecordstobeinsertedList(bidGw, this.callrecordstobeinsertedList);
    }

    // -------------------------------
    // afterUpdate: This method is called iteratively for each record updated during an AFTER trigger. The record is 'read only' by this point. 
    // -------------------------------
    public void afterUpdate(SObject oldSobj, SObject sobj){
      Bid__c      bid       =     (Bid__c) sobj;
      Bid__c      bidOld    =     (Bid__c) oldSobj;
      BidWrapper  bidW      =     new BidWrapper(bid,bidOld);
      this.callrecordstobeinsertedList  = bidw.addTocallrecordstobeinsertedList(bidGw, this.callrecordstobeinsertedList);
    }

    // -------------------------------
    // afterDelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterDelete(SObject sobj) {
      Bid__c      bid       =     (Bid__c) sobj;
    }

    // -------------------------------
    // afterUndelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterUndelete(SObject sobj) {
      Bid__c      bid       =     (Bid__c) sobj;
    }


    // -------------------------------
    // andFinally: This method is called once all records have been processed by the trigger. Use this method to accomplish any final operations such as creation or updates of other records.
    // -------------------------------   
    public void andFinally() {
      //  1. insert New call records when winning bid is inserted/updated.

      FlowControl.setRunBidTriggerHandler(false);        // turn off triggers on Bid
      if(!this.callrecordstobeinsertedList.isEmpty())
      {
        Database.SaveResult[] srList  = Database.insert(this.callrecordstobeinsertedList,false);      // allow for partial successes
        for (Integer i = 0; i < srList.size(); i++) 
        {
          if (!srList[i].isSuccess()) 
          {
            String err  = srList[i].getErrors()[0].getMessage();  
            Trigger.newMap.get(this.callrecordstobeinsertedList[i].Bid__c).addError(err);
          }
        }
      }//end of callrecordstobeinsertedList processing.
      FlowControl.resetAll();
    }//end of andFinally method
}