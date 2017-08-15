@isTest 
public class AssignDGRControllerTest 
{
    static testMethod void testMethod1() 
    {
    
          //Setup all Custom Settings
          TestSetUp ts = new TestSetup(); 
          ts.CustomSettings();
          
        Campaign CP = new Campaign();
        CP.Name ='AssignDGR';
        CP.Type ='Contact';
        insert CP;
        
        Contact c = new Contact(LastName = 'TestCon', Email = 'test@test.com');
        insert c;
        
        Lead l = new Lead(LastName = 'TestLead', Status = 'A) New Lead', Email = 'test@test.com');
        insert l;
        
        CampaignMember campMem1 = new CampaignMember(CampaignId = CP.Id,Status = 'Sent',ContactId = c.Id);
        insert campMem1;
        
        CampaignMember campMem2 = new CampaignMember(CampaignId = CP.Id,Status = 'Sent',LeadId = l.Id);
        insert campMem2;
        
        ApexPages.StandardController sc = new ApexPages.standardController(CP);
        AssignDGR a = new AssignDGR(sc);

        Test.StartTest();         
        PageReference track = a.DGRAssignment();
        Test.StopTest();
    }
}