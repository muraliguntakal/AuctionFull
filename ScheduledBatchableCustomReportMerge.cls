global class ScheduledBatchableCustomReportMerge implements Schedulable{
      
      global ScheduledBatchableCustomReportMerge() {}
      
      //  ----------------------------------------------------------------------------
      //  INTERFACE METHOD: execute
      //  ----------------------------------------------------------------------------
    
      global void execute(SchedulableContext sc){   
         
              BatchableCustomReportMerge batch = new BatchableCustomReportMerge();
              Id batchProcessId  = Database.executeBatch(batch);
      }
 }