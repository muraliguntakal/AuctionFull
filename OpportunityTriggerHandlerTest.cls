@isTest
private Class OpportunityTriggerHandlerTest{
    @testSetup static void testDataSetUp() {
        List<Contact> conList = new List<Contact>();
        List<CampaignMember> memList = new List<CampaignMember>();
        List<Campaign> campList = new List<Campaign>();
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        for(Integer i = 0 ; i < 2 ; i++){
            conList.add(new Contact(LastName='Test Contact' + i,AccountId = acc.Id));    
        }
        insert conList;
        TriggerSettings__c setting = new TriggerSettings__c(Name = 'AssignLeadOwner_Velocify',Status__c = true);
        insert setting;
        
        Campaign camp = new Campaign(Name = 'Test Campaign');
        Campaign camp1 = new Campaign(Name = 'Test Campaign2');
        Campaign camp2 = new Campaign(Name = 'Test Campaign3');
        Campaign camp3 = new Campaign(Name = 'Test Campaign4');
        campList.add(camp);
        campList.add(camp1);
        campList.add(camp2);
        campList.add(camp3);
        insert campList;

        Lead l = new Lead(LastName = 'Test Lead',Status = 'A) New Lead',LeadSource = 'Web Lead',Most_Recent_Campaign1__c =camp3.Id ,Initial_campaign__c =camp.Id);
        insert l;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.id);
        lc.setContactId(conList[0].id);
        lc.setAccountId(acc.Id);
        lc.setConvertedStatus('C) Lead Converted');
        Database.ConvertLead( lc, true ); 
        Lead lFromDb = [SELECT Id, ConvertedContactId FROM Lead WHERE isConverted=true];
        CampaignMember member1 = new CampaignMember(CampaignId = camp.Id,Status='Sent',ContactId = lFromDb.ConvertedContactId);
        memList.add(member1);
        CampaignMember member2 = new CampaignMember(CampaignId = camp1.Id,Status='Sent',ContactId = lFromDb.ConvertedContactId);
        memList.add(member2);
        CampaignMember member3 = new CampaignMember(CampaignId = camp2.Id,Status='Sent',ContactId = lFromDb.ConvertedContactId);
        memList.add(member3);
        CampaignMember member4 = new CampaignMember(CampaignId = camp3.Id,Status='Sent',ContactId = lFromDb.ConvertedContactId);
        memList.add(member4);
        
        insert memList;

        Opportunity opp = new Opportunity(Name = 'Test Opportunity',StageName='Prospecting', CloseDate = date.newInstance(2015,01,01),Seller__c = member1.ContactId);
        insert opp;
        
    }
    
    static testMethod void testProcess(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity where Name = 'Test Opportunity'] ;
        Set<Id> Ids = new set<Id>();
        Ids.add(opp.Id);
        OpportunityTriggerHandler.queryAndProcessCampaignMembers(Ids);
        Test.stopTest();
        Campaign updatedCamp = [SELECT id,Campaign_Influence_Score_Initial__c FROM Campaign where Name='Test Campaign'] ;
        system.assertEquals(updatedCamp.Campaign_Influence_Score_Initial__c, 0.5);        
    }
  
}