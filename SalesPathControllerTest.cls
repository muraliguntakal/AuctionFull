@isTest(SeeAllData=true)
public class SalesPathControllerTest{
    Private Static testmethod void TestSalesPathController(){    
    
 Opportunity Parentopp = [SELECT Id from Opportunity Where RecordTypeId =: Label.Parent_Opportunity LIMIT 1];
               
        ApexPages.currentPage().getParameters().put('id',Parentopp.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(Parentopp);
        SalesPathController OppsCont  = new SalesPathController(stdOpp);
        
        OppsCont.getOpportunity();
        OppsCont.dosave();
    }
}