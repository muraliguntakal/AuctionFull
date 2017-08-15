//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  Wraps the call record object so we can have methods on it 
//  --------------------------------------------------------------------
/* Author : Harish Emmadi	  on 11/25/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public without sharing class callrecordwrapper {
  //  ------------------------------------------------
  //  Properties
  //  ------------------------------------------------
  public   callrecord__c          cr        { get; set; }
  private  callrecord__c          crOld;
  private  Boolean         isValid    = true;          // passed validation checks?

  
  //  -------------------------------------------
  //  Constructor
  //  -------------------------------------------
  public callrecordwrapper(callrecord__c cr) {
    this.cr     = cr;
    this.crOld  = null;
  }
  
  public callrecordwrapper(callrecord__c cr, callrecord__c crOld) {
    this.cr     = cr;
    this.crOld  = crOld;
  }
  //  ---------------------------------------------------------------------
  //  debug 
  //  ---------------------------------------------------------------------
  public String debug() {
    return   '\nName                     : ' + this.cr.Name;
  }
  
  
  //  -------------------------------------------
  //  derive:      Field derivations
  //  -------------------------------------------
  public void derive(callrecordGateway crGw) {
    if (!this.isValid) {}
    else {
        
    }
    System.debug(FlowControl.getLogLevel(),'LEAVING derive ' + debug());
  }  

  //  -------------------------------------------
  //  validate:    Does Validations undoable by Force.com Validation Rules; sets instance Vbl isValid
  // Validation 1 :
  //  -------------------------------------------
  public void validate(callrecordGateway crGw) {
    if (!validationsEnabled()) {}
    else {
      //if (!validation1(crGw)) this.isValid = false;
    }
    System.debug(FlowControl.getLogLevel(),'LEAVING validate, isValid=' + this.isValid);
  }

  /*//  -----------------------------------------
  //  validation1 (Trigger aware) {}
  //  -----------------------------------------
  private Boolean  validation1(callrecordGateway crGw) {
    Boolean       res   = true;
   
    return res;
  }*/

  //  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //  addTocrIds_tobeinsertedinLiveops : send callrecord information to liveops.
  //  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  public List<callrecord__c> addTocrstobeinsertedinLiveops(callrecordGateway crGw, List<callrecord__c> crstobeinsertedinLiveopsToDate) {
    List<callrecord__c> res            = crstobeinsertedinLiveopsToDate;
    if(this.crOld == null && this.cr.FollowupTime__c == null && this.cr.Calldisposition__c != CONSTANTS.NEED_FOLLOWUP_DISPOISTION)
    {
      res.add(this.cr);
    }
    return res;
  }

  //  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //  Get Bids of all Follow-up Call Records to CallRecordTriggerHandler to update Follow-up Flag on Bid.
  //  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
  public List<Id> updatefollowupflagonBids(callrecordGateway crGw, List<callrecord__c> crstobeinsertedinLiveopsToDate) {
    List<Id> bidIds = new List<Id>();
    if(this.crOld == null && this.cr.FollowupTime__c != null && this.cr.Calldisposition__c == CONSTANTS.NEED_FOLLOWUP_DISPOISTION)
    {
      bidIds.add(this.cr.Bid__c);
    }
    return bidIds;
  }
  
  //  -----------------------------------------
  //  validationsEnabled
  //  -----------------------------------------
  private Boolean validationsEnabled() {
    return FlowControl.runcallrecordTriggerHandler();
  }

}