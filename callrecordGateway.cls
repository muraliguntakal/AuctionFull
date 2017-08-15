//******************************************************************************************************************************************************************************************
//  -------------------------------------------------------------------------
//  query all information related call record tobe used within the trigger execution.
//  -------------------------------------------------------------------------
/* Author : Harish Emmadi on 11/25/13 */ 
// Modified By                    Modified Date                                    What Changed                                                    Reason

//******************************************************************************************************************************************************************************************  
public without sharing class callrecordGateway {
  
  private List<callrecord__c>              		 		 		  crList;                               // bids in trigger list
  
  //  --------------------------------------------
  //  CONSTRUCTOR
  //  --------------------------------------------
  public callrecordGateway(List<callrecord__c> crList) {
    this.crList         = crList;    
  }
  
  //  --------------------------------------------
  //  initialize
  //  --------------------------------------------
  public void initialize() {
    System.debug(FlowControl.getLogLevel(),'ENTERING BidGateway.initialize');
    if (Trigger.isExecuting && Trigger.isBefore) // only needed for Before actions.
    {
     	
    }
    else if (Trigger.isExecuting && Trigger.isAfter) // only needed for After actions.
    {  
    	 
    }
  }
}