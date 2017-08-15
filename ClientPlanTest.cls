@isTest 
public class ClientPlanTest 
{
    static testMethod void ClientPlanTest1() 
    {

        //TestDataProvider tp = new TestDataProvider();

        Account testAccount = TestDataProvider.NewAccount();
        testAccount.Phone='123-999-1299';
        testAccount.BillingStreet = '123 TestAccount';
        testAccount.BillingCity = 'Irvine';
        testAccount.BillingState = 'California';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '92991';
        insert testAccount;

        List<Contact> cList = new List<Contact>();
        Contact c1 = TestDataProvider.NewContact();        
        c1.Decision_Maker__c = TRUE;
        Contact c2 = TestDataProvider.NewContact();        
        c2.Potential_Ten_X_User__c = TRUE;
        cList.add(c1);
        cList.add(c2);
        Insert cList;
        
        Action_Plan__c ap = new Action_Plan__c();
        ap.Account__c = testAccount.Id;
        Insert ap;
                
        Test.StartTest(); 
            ApexPages.StandardController sc = new ApexPages.StandardController(ap);
            clientPlanController  apc = new clientPlanController(sc);
            apc.getdecisionMakers();
            apc.gettenxUsers();          
        Test.StopTest();
    }
}