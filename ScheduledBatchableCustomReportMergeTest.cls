@isTest(SeeAllData=TRUE)
private class ScheduledBatchableCustomReportMergeTest{
    private static testMethod void testscheduler() {
               
        Test.StartTest();
        ScheduledBatchableCustomReportMerge sch = new ScheduledBatchableCustomReportMerge();
        String schtime = '0 0 11 * * ?';
        system.schedule('Test Custom Reporting Merge', schtime, sch);
        Test.stopTest();
    }
}