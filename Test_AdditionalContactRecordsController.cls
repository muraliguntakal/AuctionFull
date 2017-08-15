@isTest

/**
 * Test class for AdditionalContactRecordsController
 * 
 * @author      UC Innovation Tonny Xia
 * @version     1.0
 * @since       1.0
 */
public with sharing class Test_AdditionalContactRecordsController {
	
	/**
     * Test save
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
	static testMethod void Test_save() {
		
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
		
		PageReference addpage = page.AdditionalContactRecordsPage;
		Test.setCurrentPage(addpage);
		ApexPages.currentPage().getParameters().put('ContactId', con1.Id);
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(con1);
        AdditionalContactRecordsController Controller = new AdditionalContactRecordsController(stdController);
        
        test.startTest();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        
        Controller.EditChanged();
        Controller.CancelButton();
        Controller.AddAdditionalContact();
        Controller.getAdditionalContactShowList();
        Controller.AdditionalContactList[0].IsPrimary = false;
        Controller.AdditionalContactList[1].IsPrimary = true;
        Controller.SaveButton();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        test.stopTest();
	}
	
	/**
     * Test error
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
	static testMethod void Test_saveError() {
		
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
		
		PageReference addpage = page.AdditionalContactRecordsPage;
		Test.setCurrentPage(addpage);
		ApexPages.currentPage().getParameters().put('ContactId', con1.Id);
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(con1);
        AdditionalContactRecordsController Controller = new AdditionalContactRecordsController(stdController);
        
        test.startTest();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        
        Controller.EditChanged();
        Controller.CancelButton();
        Controller.AddAdditionalContact();
        Controller.getAdditionalContactShowList();
        Controller.AdditionalContactList[0].IsPrimary = false;
        Controller.AdditionalContactList[1].IsPrimary = false;
        Controller.SaveButton();
        Controller.getAdditionalContactShowList();
        Controller.AdditionalContactList[0].IsPrimary = true;
        Controller.AdditionalContactList[1].IsPrimary = true;
        Controller.SaveButton();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        test.stopTest();
	}
	
	/**
     * Test remove
     *
     * @param       None
     * @return      None
     * @since       1.0
     */
	static testMethod void Test_remove() {
		
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
		
		PageReference addpage = page.AdditionalContactRecordsPage;
		Test.setCurrentPage(addpage);
		ApexPages.currentPage().getParameters().put('ContactId', con1.Id);
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(con1);
        AdditionalContactRecordsController Controller = new AdditionalContactRecordsController(stdController);
        
        test.startTest();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 2);
        
        Controller.EditChanged();
        Controller.CancelButton();
        Controller.AddAdditionalContact();
        Controller.getAdditionalContactShowList();
        Controller.AdditionalContactList[0].IsRemoved = true;
        Controller.AdditionalContactList[1].IsRemoved = true;
        Controller.SaveButton();
        Controller.getAdditionalContactShowList();
        System.assertEquals(controller.AdditionalContactList.size(), 1);
        test.stopTest();
	}
}