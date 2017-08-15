@isTest(SeeAllData=true)
public class LeadTriggerTest {
    
    static testMethod void testLeadAssignments() {

        User apiUser = [SELECT Id,Name FROM User WHERE Name = 'Integration User' LIMIT 1];
        System.RunAs(apiUser){ 
            Lead testLead = new Lead();
            testLead.FirstName = 'Test First';
            testLead.LastName = 'Test Last';
            testLead.Company = 'Test Co';
            testLead.Email = 'test@test.com';
            testLead.Is_Lead_Info_Broker_Agent_or_Seller__c = 'Broker/Agent';
            testLead.Seller_Email__c = 'test@test.com';
            testLead.Seller_First_Name__c = 'Test';
            testLead.Seller_Last_Name__c = 'Test';
            testLead.Seller_Phone__c = '123456789'; 
            testLead.Seller_State__c = 'CA';
            testLead.Seller_Street_Address__c = '123 Test';
            testLead.Seller_Zip_Postal_Code__c = '12345';
            testLead.Seller_City__c = 'Test';
            testLead.Seller_Country__c = 'USA';
            testLead.Property_Street__c = '123 Test';
            testLead.Property_City__c = 'Test';
            testLead.Property_State__c = 'Test';
            testLead.Listing_Price__c  = 1200 ;
            testLead.Property_Type__c  = 'Other';
            testLead.Property_Zip_Postal_Code__c = '12345';
            testLead.Property_Name__c = 'Test';    
            testLead.Lead_Qualified_Source__c = 'Velocify';
            testLead.Lead_Qualified_Owner__c = 'Integration User';             
            testLead.Loan_Number__c='12384454322';
            testLead.RecordTypeId='012d0000000tJNK'; 
            testLead.Lead_Source_Filename__c = 'CommercialSell';    
            Database.LeadConvert lc; 
            LeadStatus  convertStatus; 
            Database.LeadConvertResult lcr;
                
            Insert testLead;
        
            //lc = new database.LeadConvert();
            //lc.setLeadId(testLead.Id);
        
            //convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            //lc.setConvertedStatus(convertStatus.MasterLabel);
        
            //lcr = Database.convertLead(lc);
            //System.assert(lcr.isSuccess());     
             }
    }


}