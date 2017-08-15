@isTest()
public class TestActivity {

static testmethod void validateActivity() {

     //Setup all Custom Settings
      TestSetUp cts = new TestSetup(); 
      cts.CustomSettings();
      
      Profile p1 = [SELECT Id FROM Profile WHERE Name='Sys Admin']; 
            
      Account acc = new Account(Name='Test 1'); 
      insert acc;
      
      Contact con = new Contact(LastName='LastNM', Account=acc);
      insert con;
 
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = Label.Opportunity_Stage2;
        opp.CloseDate = system.today();
        opp.Property_Reserve_Price__c = 100;
        opp.Seller__c = con.Id;
         //Test.Starttest();
         insert opp;
         //Test.Stoptest();
                                 
       /*     Bid__c bd = new Bid__c();
            bd.Bid_Amount__c = 10000;
            bd.Winning_Bid__c = true;
            bd.Buyer_Name__c = con.Id;
            insert bd;
                                   
            Bidder_Registration__c bdr = new Bidder_Registration__c();
            bdr.MLH_Bidder_ID__c = 'BD3243';
            bdr.MLH_FirstName__c = 'Test';
            bdr.MLH_LastName__c = 'Contact1';
            bdr.MLH_Workphone__c = '111-111-1111';
            bdr.MLH_cellphone__c = '111-111-1111';
            bdr.Contact__c = con.Id;
            insert bdr;  */

      Test.StartTest();            
         /*   bdr.MLH_Workphone__c = '222-222-2222';
            bdr.MLH_cellphone__c = '111-111-3333';
            Update bdr;  */
            
            Vault__c val = new Vault__c();
            val.Contact__c = con.Id;
            insert val;
                       
            Contact_Profile__c conp = new Contact_Profile__c();
            conp.Contact__c = con.Id;
            conp.Buyer_Seller__c = 'Sell';
            insert conp;
            
            conp.Buyer_Seller__c = 'Buy';
            update conp;
            
            conp.Buyer_Seller__c = 'Both';
            update conp;           
            
             Campaign camp = new Campaign(Name = 'Test Campaign');
             insert camp;
                   
            PDP__c pdp = new PDP__c();
            pdp.Contact__c = con.Id;
            insert pdp;
            
            List<Task> taskList = new List<Task>();
            taskList.add(new Task( whoId = con.Id, whatId = acc.Id,type='Outbound Call',Status='Completed'));
            taskList.add(new Task( whoId = con.Id, whatId = pdp.Id,campaign__c = camp.Id,type='Outbound Call',Status='Completed'));
            Insert taskList;
                                       
            Delete opp; 
            Delete conp;
            Delete val;                 
         //   Delete bd;
         //   Delete bdr;       
      Test.StopTest();   
      
      }       
            
 static testmethod void validateActivity2() {  
 
         TestSetUp cts = new TestSetup(); 

         Profile p = [SELECT Id FROM Profile WHERE Name='Sys Admin']; 

         cts.CustomSettings();
         Account acc = new Account(Name='Test 1'); 
         insert acc;
         
         Contact con1 = new Contact(LastName='LastNM1', Account=acc, Email='assetconsideration@auction.com');
         insert con1;
         
         Vault__c v1 = new Vault__c(Contact__c=con1.Id,Broker_3_Email__c=Label.TestClassEmail);           
         Insert v1;
          
         Test.StartTest();
            Lead testLd = new Lead();
            testLd.FirstName = 'Test First';
            testLd.LastName = 'Test Last';
            testLd.Company = 'Test Co';
            testLd.Email = 'test122@test.com';
            testLd.Status = 'New Lead';
            Insert testLd;
            
            List<Task> taskList = new List<Task>();
            taskList.add(new Task( whoId = testLd.Id, type='Outbound Call',Status='Completed'));
            taskList.add(new Task( whoId = con1.Id, whatId = v1.Id,type='Email',Status='Completed'));
            Insert taskList;            
          Test.stopTest();                        
 }

 static testmethod void validateActivity3() {  
 
     //Setup all Custom Settings
      TestSetUp cts = new TestSetup(); 
      cts.CustomSettings();
         
            Offer__c offs = new Offer__c();
            offs.MLH_Offer_ID__c = '1233TEST';
            insert offs;

            Task tasc3 = new Task();
            tasc3.WhatId = offs.Id;     
            insert tasc3;

            Lead testLd = new Lead();
            testLd.FirstName = 'Test First11';
            testLd.LastName = 'Test Last11';
            testLd.Company = 'Test11 Co';
            testLd.Email = 'test1212@test.com';
            testLd.Status = 'New Lead';
            Insert testLd;
            Delete tasc3;
            Delete offs;
          
  }          
}