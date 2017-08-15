@isTest(SeeAllData=true)
private class NewCaseContactTest {
    
    // Variables and properties.
    private static testmethod void TestNewCaseContact() {
        Case cs = TestDataProvider.NewCase();
        Insert cs;    
        
        ApexPages.CurrentPage().getparameters().put('pid', cs.id);
        ApexPages.StandardController sc = new ApexPages.standardController(cs);
        NewCaseContact sic = new NewCaseContact(sc);
        sic.setFields();

        NewCaseContact sic1 = new NewCaseContact(sc);
        sic1.setFields();

        redirectController caseRedirectTest = new redirectController();
        caseRedirectTest.CaseRedirect();
        
    }

}