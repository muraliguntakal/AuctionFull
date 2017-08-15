@isTest
/**
 * Test class for AddAdditionalContactController
 * 
 * @author      UC Innovation Tonny Xia
 * @version     1.0
 * @since       1.0
 */
public with sharing class Test_AddAdditionalContactController {
	
	/**
     * Test search and save function
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
	static testMethod void Test_SearchAndSave() {
		
		TestSetUp tst = new TestSetup(); 
        tst.CustomSettings();
        
        TriggerSettings__c setting = new TriggerSettings__c(name = 'ContactTriggerAfter', status__c = false);
        insert setting;
		
		Account acc = new Account();
		acc.Name = 'account';
		insert acc;
		
		Contact con1 = new Contact();
		con1.LastName = 'contact1';
		con1.accountId = acc.Id;
		con1.Primary_Status__c = 'Primary';
		insert con1;
		
		Contact con2 = new Contact();
		con2.LastName = 'contact2';
		con2.accountId = acc.Id;
		con2.Primary_Status__c = 'Secondary';
		con2.Primary_Status_Contact__c = con1.Id;
		insert con2;
		
		Contact con3 = new Contact();
		con3.LastName = 'contact3';
		con3.accountId = acc.Id;
		insert con3;
		
		PageReference addpage = page.AddAdditionalContact;
		Test.setCurrentPage(addpage);
		ApexPages.currentPage().getParameters().put('ContactId', con1.Id);
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(con1);
        AddAdditionalContactController Controller = new AddAdditionalContactController(stdController);
        
        
        test.startTest();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        
        Controller.keyword = '123';
        Controller.goSearch();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 0);
        
        Controller.SearchContactName = '';
        Controller.SearchAccountName = 'con';
        Controller.keyword = '';
        Controller.goSearch();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 0);
        
        Controller.SearchContactName = 'con';
        Controller.SearchAccountName = '';
        Controller.keyword = '';
        Controller.goSearch();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        
        Controller.previous();
        Controller.next();
        Controller.getTotalPages();
        Controller.getAdditionalContactShowList();
        Controller.AdditionalContactList[0].IsSecondary = true;
        Controller.AdditionalContactList[1].IsSecondary = true;
        Controller.SaveContact();
        List<Contact> conList = [Select Id, Name, Primary_Status_Contact__c, Primary_Status__c From Contact Where Primary_Status__c = 'Secondary'];
        System.assertEquals(conList[0].Primary_Status_Contact__c, con1.Id);
        System.assertEquals(conList[1].Primary_Status_Contact__c, con1.Id);
        Controller.Cancel();
        test.stopTest();
	}
	
	/**
     * Test update function
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
	static testMethod void Test_update() {
		
		TestSetUp tst = new TestSetup(); 
        tst.CustomSettings();
        
        TriggerSettings__c setting = new TriggerSettings__c(name = 'ContactTriggerAfter', status__c = false);
        insert setting;
		
		Account acc = new Account();
		acc.Name = 'account';
		insert acc;
		
		Contact con1 = new Contact();
		con1.LastName = 'contact1';
		con1.accountId = acc.Id;
		con1.Primary_Status__c = 'Primary';
		insert con1;
		
		Contact con2 = new Contact();
		con2.LastName = 'contact2';
		con2.accountId = acc.Id;
		con2.Primary_Status__c = 'Secondary';
		con2.Primary_Status_Contact__c = con1.Id;
		insert con2;
		
		Contact con3 = new Contact();
		con3.LastName = 'contact3';
		con3.accountId = acc.Id;
		insert con3;
		
		Contact con4 = new Contact();
		con4.LastName = 'contact4';
		con4.accountId = acc.Id;
		con4.Primary_Status__c = 'Primary';
		insert con4;
		
		Contact con5 = new Contact();
		con5.LastName = 'contact5';
		con5.accountId = acc.Id;
		con5.Primary_Status__c = 'Secondary';
		con5.Primary_Status_Contact__c = con4.Id;
		insert con5;
		
		PageReference addpage = page.AddAdditionalContact;
		Test.setCurrentPage(addpage);
		ApexPages.currentPage().getParameters().put('ContactId', con1.Id);
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(con1);
        AddAdditionalContactController Controller = new AddAdditionalContactController(stdController);
        
        
        test.startTest();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 3);
        
        Controller.previous();
        Controller.next();
        Controller.getTotalPages();
        Controller.getAdditionalContactShowList();
        Controller.AdditionalContactList[0].IsSecondary = true;
        Controller.AdditionalContactList[1].IsSecondary = true;
        Controller.AdditionalContactList[2].IsSecondary = true;
        Controller.SaveContact();
        List<Contact> conList = [Select Id, Name, Primary_Status_Contact__c, Primary_Status__c From Contact Where Primary_Status__c = 'Secondary'];
        System.assertEquals(conList[0].Primary_Status_Contact__c, con1.Id);
        System.assertEquals(conList[1].Primary_Status_Contact__c, con4.Id);
        
        Controller.SaveContact();
        List<Contact> conList1 = [Select Id, Name, Primary_Status_Contact__c, Primary_Status__c From Contact Where Primary_Status__c = 'Secondary'];
        System.assertEquals(conList1[0].Primary_Status_Contact__c, con1.Id);
        System.assertEquals(conList1[1].Primary_Status_Contact__c, con1.Id);
        System.assertEquals(conList1[2].Primary_Status_Contact__c, con1.Id);
        Controller.Cancel();
        test.stopTest();
	}
}