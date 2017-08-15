@isTest
private class ProcurementControllerTests {
  
  @isTest static void validateRecordsAreUnkedAfterButtonClick() {

    List<Map<String, Object>> params = null;

    Procurement_Tracking__c pt = new Procurement_Tracking__c(Project_Name__c='Test Procurement-1');
    Test.setCurrentPage(Page.CreateProcurement);

    ApexPages.StandardController sc = new ApexPages.StandardController(pt);
    ProcurementController pc = new ProcurementController(sc);
    pc.saveAndRedirect();
    pc.newAndRedirect();
    pc.cancelAndRedirect();
    pc.editAndRedirect();
  }
  
}