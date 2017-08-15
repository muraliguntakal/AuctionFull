public class ProcurementController{

    private final sObject pt;
    
    public ProcurementController(ApexPages.StandardController Controller) {
        this.pt= (sObject)Controller.getRecord();
    }

    public PageReference saveAndRedirect() {
        Insert this.pt;
        PageReference redirectPage = Page.ViewProcurement;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id',pt.Id);
        return redirectPage;
      }    

    public PageReference newAndRedirect() {
        PageReference redirectPage = Page.CreateProcurement;
        redirectPage.setRedirect(true);
        return redirectPage;
      } 

    public PageReference editAndRedirect() {
        PageReference redirectPage = Page.CreateProcurement;
        redirectPage.getParameters().put('id',pt.Id);
        redirectPage.setRedirect(true);
        return redirectPage;
      }

    public PageReference cancelAndRedirect() {
        PageReference redirectPage = Page.CreateProcurement;
        redirectPage.setRedirect(true);
        return redirectPage;
      }

}