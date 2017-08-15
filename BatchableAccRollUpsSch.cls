global class BatchableAccRollUpsSch implements Schedulable{

      //  ---------------------------------------------------------------------------
      //  Constructor
      //  ---------------------------------------------------------------------------
      
      global BatchableAccRollUpsSch() {}
      
      //  ----------------------------------------------------------------------------
      //  INTERFACE METHOD: execute
      //  ----------------------------------------------------------------------------
    
      global void execute(SchedulableContext sc){             
              BatchableAccRollUps batch = new BatchableAccRollUps();
              Id batchProcessId  = Database.executeBatch(batch);
      }
 }