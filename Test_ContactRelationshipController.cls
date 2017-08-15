@istest
private class Test_ContactRelationshipController {

    static testmethod void test1(){
    
          //Setup all Custom Settings
        TestSetUp tst = new TestSetup(); 
        tst.CustomSettings();
        
        TriggerSettings__c setting = new TriggerSettings__c(name = 'ContactTriggerAfter', status__c = false);
        insert setting;
            
        Contact con1 = new Contact(lastname='con1 test');
        insert con1;
        
        Contact con2 = new Contact(lastname='con2 test');
        insert con2;
        
        Contact_Relationship__c cr1 = new Contact_Relationship__c(contact1__c = con1.id, relationship1__c = 'broker', contact2__c = con2.id, relationship2__c = 'buyer');
        insert cr1;
        // Reverse the relationships
        Contact_Relationship__c cr2 = new Contact_Relationship__c(contact1__c = con2.id, relationship1__c = 'buyer', contact2__c = con1.id, relationship2__c = 'broker');
        insert cr2;            
        
        Test.startTest();
        ContactRelationshipController controller = new ContactRelationshipController(con1.id);
        
        for (ContactRelationshipController.RelationshipWrapper wrap :controller.relationshipWraps){
            // All relationships should have the selected contact on the left side of the relationship,
            // so the second relationship should be flipped.
            system.assertEquals(con1.id, wrap.contact1_id);
        }
        
        Test.stopTest();
    }
}