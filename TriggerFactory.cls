//******************************************************************************************************************************************************************************************
/* Author : Harish Emmadi from Centerstance on 11/12/13 */
// Modified By                    Modified Date                                    What Changed                                                    Reason

//******************************************************************************************************************************************************************************************  
public without sharing class TriggerFactory {
// Class TriggerFactory:   Used to instantiate and execute Trigger Handlers associated with sObjects.


  //  -------------------------- 
  // PUBLIC STATIC METHOD:   createHandlerAndExecute 
  //  -------------------------- 
  public static void createHandlerAndExecute(Schema.sObjectType soType){
    
    ITrigger handler = getHandler(soType);        // Get a handler appropriate to the object being processed    
    if (handler == null)                 // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
      throw new HandlernotFoundException('No Trigger Handler registered for Object Type: ' + soType);
    execute(handler);                    // 
  }

  //  -------------------------- 
  // PUBLIC STATIC METHOD:  execute
  //  --------------------------
  public static void execute(ITrigger handler)  {
    // Before Trigger
    if (Trigger.isBefore) {
      handler.bulkBefore();        // Call the bulk before to handle any caching of data and enable bulkification
      if (Trigger.isDelete)        // Iterate through the records to be deleted passing them to the handler.
        for (SObject so : Trigger.old)
          handler.beforeDelete(so);
      
      else 
      if (Trigger.isInsert)        // Iterate through the records to be inserted passing them to the handler.
        for (SObject so : Trigger.new)
          handler.beforeInsert(so);
      
      else 
      if (Trigger.isUpdate)        // Iterate through the records to be updated passing them to the handler.
        for (SObject so : Trigger.old)
          handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
          
    }
    else {    // After triggers
      
      handler.bulkAfter();        // Call the bulk after to handle any caching of data and enable bulkification      
      if (Trigger.isDelete)         // Iterate through the records deleted passing them to the handler.
        for (SObject so : Trigger.old)
          handler.afterDelete(so);
      
      else 
      if (Trigger.isInsert)        // Iterate through the records inserted passing them to the handler. 
        for (SObject so : Trigger.new)
          handler.afterInsert(so);
      
      else 
      if (Trigger.isUpdate)        // Iterate through the records updated passing them to the handler.
        for (SObject so : Trigger.old)
          handler.afterUpdate(so, Trigger.newMap.get(so.Id));
      
      else 
      if (Trigger.isUndelete)
        for (SObject so : Trigger.new)
          handler.afterUndelete(so);    
    }
    
    
    handler.andFinally();          // Perform any post processing including updates to related records
  }
  
  /**
   * private static method to get the appropriate handler for the object type.
   * Modify this method to add any additional handlers.
   *
   * Arguments:  Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
   *
   * Returns:    ITrigger - A trigger handler if one exists or null.
   */
  //  -------------------------- 
  // PRIVATE STATIC METHOD:  getHandler (modify to provide additional strongly-typed handlers)  
  //  --------------------------   
  private static ITrigger getHandler(Schema.sObjectType sobjType){
    if (sobjType == Bid__c.sObjectType)
        return new BidTriggerHandler();
    else if (sobjType == callrecord__c.sObjectType)
        return new callrecordTriggerHandler();    
    //else if (sobjType == <some SObject>.sObjectType)   
	//    return new <someSObjectTriggerHandler>;    
    
    return null;
  }
  
  public  class HandlernotFoundException extends Exception{

  }
}