@isTest(SeeAllData=TRUE)
private class BatchableAccRollUpsSchTest {
    private static testMethod void testscheduler() {
               
        Test.StartTest();
        BatchableAccRollUpsSch sch = new BatchableAccRollUpsSch();
        String schtime = '0 0 11 * * ?';
        system.schedule('BatchableAccRollUpsSch', schtime, sch);
        Test.stopTest();
    }
 }