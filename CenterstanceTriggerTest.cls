/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /*------------------------------------------------------------------------------------------------------
 * Author      Centerstance - Tia Xuan
 * Date        January 2013
 * Description This class test the Lead Conversion Trigger
 * @class      CenterstanceTriggerTest
 *-----------------------------------------------------------------------------------------------------*/

@isTest(SeeAllData=true)
public class CenterstanceTriggerTest {
    
    static testMethod void testLeadConversionTrigger() {
        
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.FirstName = 'Test First11';
        testLead.LastName = 'Test Last11';
        testLead.Company = 'Test Co11';
        testLead.Email = 'test11@test.com';
        testLead.Is_Lead_Info_Broker_Agent_or_Seller__c = 'Broker/Agent';
        testLead.Brokerage__c = 'Test Broker11';
        testLead.Seller_Email__c = 'test12@test.com';
        testLead.Seller_First_Name__c = 'Test First12';
        testLead.Seller_Last_Name__c = 'Test Last12';
        testLead.Seller_Phone__c = '123456789'; 
        testLead.Seller_State__c = 'CA';
        testLead.Seller_Street_Address__c = '123 Test St 12';
        testLead.Seller_Zip_Postal_Code__c = '12345';
        testLead.Seller_City__c = 'Test';
        testLead.Seller_Country__c = 'USA';
        testLead.Property_Street__c = '123 Test';
        testLead.Property_City__c = 'Test';
        testLead.Property_State__c = 'CA';
        testLead.Listing_Price__c  = 1200 ;
        testLead.Property_Type__c  = 'Other';
        testLead.Property_Zip_Postal_Code__c = '12345';
        testLead.Property_Name__c = 'Test';    
        testLead.Lead_Qualified_Owner__c = 'Integration User';             
        testLead.Lead_Source_Filename__c = 'CommercialSell';
        insert testLead;

        LeadTriggerHelperClass.flagvalue=false;  
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setConvertedStatus('C) Lead Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        testLead = [select id, ConvertedOpportunityId from Lead where Id =: testLead.Id limit 1];
            
        Opportunity opportunity = [select id, Seller__c, Broker_Agent__c from Opportunity where Id = : testLead.ConvertedOpportunityId limit 1];
        
//        System.AssertNotEquals(opportunity.Seller__c, null);
//        System.AssertNotEquals(opportunity.Broker_Agent__c, null);
        
        List<OpportunityContactRole> opportunityCR = [select Id, ContactId, Role from OpportunityContactRole where OpportunityId = : testLead.ConvertedOpportunityId];
        
        //System.AssertEquals(opportunityCR.size(), 2);
        //for (OpportunityContactRole ocr : opportunityCR)
        //    System.AssertNotEquals(ocr.Role, null);
        
        testLead = new Lead();
        testLead.FirstName = 'Test First11';
        testLead.LastName = 'Test Last11';
        testLead.Company = 'Test Co1';
        testLead.Email = 'test@test.com';
        testLead.Is_Lead_Info_Broker_Agent_or_Seller__c = 'Seller';
        testLead.Broker_Agent_Email__c = 'test11@test.com';
        testLead.Broker_Agent_First_Name__c = 'Test First11';
        testLead.Broker_Agent_Last_Name__c = 'Test Last11';
        testLead.Brokerage__c = 'Test Broker11'; 
        testLead.Broker_Agent_Phone__c = '123456789';   
        testLead.Broker_Agent_State__c = 'CA';
        testLead.Broker_Agent_Street_Address__c = '123 Test11 St';
        testLead.Broker_Agent_Zip_Postal__c = '12345';
        testLead.Broker_Agent_City__c = 'Test';
        testLead.Broker_Agent_Country__c = 'USA';
        testLead.Property_Street__c = '123 Test11 St1';
        testLead.Property_City__c = 'Test123';
        testLead.Property_State__c = 'CA';
        testLead.Listing_Price__c  = 1200000 ;
        testLead.Property_Type__c  = 'Other';
        testLead.Property_Zip_Postal_Code__c = '12345';
        testLead.Property_Name__c = 'Test';
        testLead.Lead_Source_Filename__c = 'CommercialSell';
        insert testLead;
        
         LeadTriggerHelperClass.flagvalue=false;
        lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        
        
        
        convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true AND MasterLabel = 'C) Lead Converted' limit 1];
        system.debug('Loead Record Type Id ' +convertStatus.MasterLabel);
        system.debug('Converted Status' +testLead.RecordTypeId);
        
        lc.setConvertedStatus(convertStatus.MasterLabel);

        lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        testLead = [select id, ConvertedOpportunityId from Lead where Id =: testLead.Id limit 1];
        
        opportunity = [select id, Seller__c, Broker_Agent__c from Opportunity where Id = : testLead.ConvertedOpportunityId limit 1];
        
//        System.AssertNotEquals(opportunity.Seller__c, null);
//        System.AssertNotEquals(opportunity.Broker_Agent__c, null);
        
        opportunityCR = [select Id, ContactId, Role from OpportunityContactRole where OpportunityId = : testLead.ConvertedOpportunityId];
                    
        testLead = new Lead();
        testLead.FirstName = 'Test First22';
        testLead.LastName = 'Test Last22';
        testLead.Company = 'Test Co22';
        testLead.Email = 'test22@test.com';
        testLead.Is_Lead_Info_Broker_Agent_or_Seller__c = 'Seller';
        testLead.Broker_Agent_Email__c = 'test11@test.com';
        testLead.Broker_Agent_First_Name__c = 'Test First11';
        testLead.Broker_Agent_Last_Name__c = 'Test Last11';
        testLead.Brokerage__c = 'Test Broker11'; 
        testLead.Broker_Agent_Phone__c = '123456789';   
        testLead.Broker_Agent_State__c = 'CA';
        testLead.Broker_Agent_Street_Address__c = '123 Test';
        testLead.Broker_Agent_Zip_Postal__c = '12345';
        testLead.Broker_Agent_City__c = 'Test';
        testLead.Broker_Agent_Country__c = 'USA';
        testLead.Property_Street__c = '123 Test';
        testLead.Property_City__c = 'Test';
        testLead.Property_State__c = 'CA';
        testLead.Listing_Price__c  = 1200000 ;
        testLead.Property_Type__c  = 'Other';
        testLead.Property_Zip_Postal_Code__c = '12345';
        testLead.Property_Name__c = 'Test';
        
        insert testLead;
        LeadTriggerHelperClass.flagvalue=false;  

        Test.stopTest();
    }
    
    
    static testMethod void testOpportunityContactTrigger() {
        
        Test.startTest();
        
        Account a1 = new Account(
                        Name = 'Test-Account--11'
                    );
        insert a1;
        
        
        Contact c1 = new Contact(
                FirstName = 'Agent11',
                LastName = 'Broker11',
                Email = 'agent11@broker.com'
            );
        insert c1;
        
        Contact c2 = new Contact(
                FirstName = 'Seller11',
                LastName = 'Seller11',
                Email = 'seller11@seller.com'
            );
        insert c2;
        
        Opportunity oppo = new Opportunity(
                                Name = 'Test',
                                AccountId  = a1.Id,
                                StageName = 'Test',
                                CloseDate = Date.Today()
                                
                    ); 
        
        insert oppo;
        
        oppo.Seller__c = c1.Id;
        oppo.Broker_Agent__c = c2.Id;
        
        update oppo;
        
        List<OpportunityContactRole> opportunityCR = [select Id, ContactId, Role from OpportunityContactRole where OpportunityId = : oppo.Id];
        
        //System.AssertEquals(opportunityCR.size(), 2);
        //for (OpportunityContactRole ocr : opportunityCR)
        //    System.AssertNotEquals(ocr.Role, null);
        
        Test.stopTest();
    }
}