@isTest(SeeAllData=true)
public class ContactCampControllerTest{
    Private Static testmethod void TestContactCampController(){    
    
 Contact ConId = [SELECT Id from Contact LIMIT 1];
               
        ApexPages.currentPage().getParameters().put('id',ConId.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(ConId);
        ContactCampController Conts  = new ContactCampController(stdOpp);
        
        Conts.getCampaignMember();

    }
}