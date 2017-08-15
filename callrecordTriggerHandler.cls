//******************************************************************************************************************************************************************************************
/* Author : Harish Emmadi on 11/25/13 */
// Modified By                    Modified Date                                    What Changed                                                    Reason

//******************************************************************************************************************************************************************************************  
public without sharing class callrecordTriggerHandler implements ITrigger{
  
    //  -----------------------------
    //  PRIVATE VARIABLES
    //  -----------------------------

    private callrecordGateway            crGw;            // Reference to object containing related records collected prior to pass through each triggered crs
    private List<callrecord__c>          crstobeinsertedinLiveops = new List<callrecord__c>();
    private List<Id>                     updatefollowupflagonBids = new List<Id>();
    //  -----------------------------
    //  CONSTRUCTOR
    //  -----------------------------
    public callrecordTriggerHandler() {}

    // -------------------------------
    // bulkBefore: This method is called prior to execution of a BEFORE trigger. Use this to cache any data required into maps prior execution of the trigger.   
    // -------------------------------
    public void bulkBefore() {
      this.crGw          =     new callrecordGateway(Trigger.isUpdate || Trigger.isInsert? Trigger.new : Trigger.old );
      if (FlowControl.runcallrecordTriggerHandler())
        this.crGw.initialize();
    }

    // -------------------------------
    // bulkAfter: This method is crlled prior to execution of an AFTER trigger. Use this to cache any data required into maps prior execution of the trigger.
    // ------------------------------- 
    public void bulkAfter() {
      this.crGw          =     new callrecordGateway(Trigger.isUpdate || Trigger.isInsert || Trigger.isUndelete? Trigger.new : Trigger.old );
      if (FlowControl.runcallrecordTriggerHandler())
        this.crGw.initialize();
    }

    // -------------------------------
    // beforeInsert: This method is called iteratively for each record to be inserted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.  
    // ------------------------------- 
    public void beforeInsert(SObject sobj) {
      callrecord__c         cr         =    (callrecord__c) sobj;
      sharedBefore(cr,null);
    }

    // -------------------------------
    // beforeUpdate: This method is called iteratively for each record to be updated during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    // -------------------------------   
    public void beforeUpdate(SObject oldSobj, SObject sobj) {
      callrecord__c         cr         =    (callrecord__c) sobj;
      callrecord__c         crOld      =    (callrecord__c) oldSobj;
      sharedBefore(cr,crOld);
    }

    //  --------------------------------
    //  sharedBefore
    //  --------------------------------
    private void sharedBefore(callrecord__c  cr, callrecord__c  crOld) {
      callrecordWrapper crW       =     new callrecordWrapper(cr,crOld);
      System.debug(FlowControl.getLogLevel(),'\n\n***ENTERING callrecordTriggerHandler ' + UtilityFns.triggerLabel() );    // validate has the debug statement
      crW.validate(this.crGw);
      crW.derive(this.crGw);
      System.debug(FlowControl.getLogLevel(),'\n\n***LEAVING callrecordTriggerHandler ' + UtilityFns.triggerLabel() );    // validate has the debug statement
    }


    // -------------------------------
    // beforeDelete: This method is called iteratively for each record to be deleted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    // -------------------------------   
    public void beforeDelete(SObject sobj) {
      callrecord__c       cr       =     (callrecord__c) sobj;
    }

    // -------------------------------
    // afterInsert: This method is called iteratively for each record inserted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterInsert(SObject sobj) {
      callrecord__c             cr      =     (callrecord__c) sobj;
      callrecordWrapper         crW     =     new callrecordWrapper(cr,null);
      this.crstobeinsertedinLiveops     =     crW.addTocrstobeinsertedinLiveops(crGw,this.crstobeinsertedinLiveops);
      this.updatefollowupflagonBids     =     crW.updatefollowupflagonBids(crGw,this.crstobeinsertedinLiveops);      
    }

    // -------------------------------
    // afterUpdate: This method is called iteratively for each record updated during an AFTER trigger. The record is 'read only' by this point. 
    // -------------------------------
    public void afterUpdate(SObject oldSobj, SObject sobj){
      callrecord__c       cr           =     (callrecord__c) sobj;
      callrecord__c       crOld        =     (callrecord__c) oldSobj;
      callrecordWrapper   crW          =     new callrecordWrapper(cr,crOld);
    }

    // -------------------------------
    // afterDelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterDelete(SObject sobj) {
      callrecord__c      cr       =     (callrecord__c) sobj;
    }

    // -------------------------------
    // afterUndelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterUndelete(SObject sobj) {
      callrecord__c      cr       =     (callrecord__c) sobj;
    }

    // -------------------------------
    // andFinally: This method is called once all records have been processed by the trigger. Use this method to accomplish any final operations such as creation or updates of other records.
    // -------------------------------   
    public void andFinally() {
       FlowControl.setRuncallrecordTriggerHandler(false);        // turn off triggers on call record.

       //Collect all Call Records to be sent to LiveOps for Allowed Campaigns - Based on Custom Settings, TriggerSettings__c
       Map<String,List<Id>> campaignIdtocrListMap = new Map<String,List<Id>>();
       for(callrecord__c cr : this.crstobeinsertedinLiveops) {
            //Stop VIP Call Records going to LiveOps
            if(!cr.Created_By_Batch__c && TriggerSettings__c.getValues('SendCallsToLiveOps').Status__c && (TriggerSettings__c.getValues(cr.LiveOps_Outbound_Campaign__c).Status__c)) {
                List<Id> crIds = campaignIdtocrListMap.containsKey(cr.LiveOps_Outbound_Campaign__c) ? 
                                campaignIdtocrListMap.get(cr.LiveOps_Outbound_Campaign__c) : new List<Id>();
                crIds.add(cr.Id);
                campaignIdtocrListMap.put(cr.LiveOps_Outbound_Campaign__c, crIds);
            }            
       }    
       //Collect all Call Records to be sent to LiveOps for Allowed Campaigns - Based on Custom Settings, TriggerSettings__c
	   system.debug('Call Records to be Sent to LiveOps :' +campaignIdtocrListMap);
       for(String campaginId : campaignIdtocrListMap.keySet())     
       { 
           if(!campaignIdtocrListMap.get(campaginId).isEmpty() && !Test.isRunningTest())
           {
               createcallrecordsinliveops(campaginId, campaignIdtocrListMap.get(campaginId));
           }
       }

      // Update Bid Follow-up Created Flag 
       List<Bid__c> updatedBid = new List<Bid__c>();
       for(Id id : this.updatefollowupflagonBids) {
		   if(id!=null) {
           	   updatedBid.add(new Bid__c(Id=id, Follow_up_Created__c=true));
		   }
       }                       
       if(updatedBid.size() > 0) 
          Update updatedBid;

       FlowControl.resetAll();
    }//end of andFinally method.

    @future(callout=true)
    private static void createcallrecordsinliveops(String campaignId, List<Id> crIds){
      Liveopswrapper OutboundLeadCreationHelper = new Liveopswrapper();
      OutboundLeadCreationHelper.getoutboundLeads(campaignId, crIds);
    }
}