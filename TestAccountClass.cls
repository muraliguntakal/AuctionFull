@isTest(SeeAllData=True)
public class TestAccountClass {
static testmethod void ValidateAccountClass() {

    
            User u = [SELECT Id FROM User WHERE Profile.Name='Sys Admin' and IsActive=True Limit 1]; 
            User u2 = [SELECT Id FROM User WHERE Profile.Name='Sys Admin' and IsActive=True and Id != :u.Id Limit 1]; 
     
            Account Acc = new Account();
            Acc.Name = 'Test';
            Acc.CRE_BD_Rep__c = u.Id;
            Acc.CRE_Inside_Sales__c = u.Id;
            insert Acc;  
            
            Contact con = new Contact();
            con.FirstName = 'tes1';
            con.LastName = 'tes2';
            con.MLH_Contact_Id__c = 'CT12119';
            con.RecordTypeId = Label.Bidder_Registration_Contact;
            con.AccountId = Acc.Id;
            Insert con; 
            
             AccountTriggerHelperClass.ResetAlreadyfired();   
            
            Acc.CRE_BD_Rep__c = u2.Id;
            Acc.CRE_Inside_Sales__c = u2.Id;
            update Acc;         

   }
  }