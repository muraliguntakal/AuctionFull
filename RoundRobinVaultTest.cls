@isTest (SeeAllData=TRUE)
private class RoundRobinVaultTest {

    static testMethod void myTest1() {
        // This code runs as the system user
        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'Sys Admin'  LIMIT 1];
        } catch (QueryException qe){

            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                  u1 = u;
                  break;
                }
            }
        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Vault__c';
       insert testQueue;

       // Second Queue       
       Group testGroup2 = new Group ();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Vault__c';
       insert testQueue2;

       test.starttest();
        
        System.runAs(u1) {    
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Vault');
            insert ag1;

            //Add bad queue name
            Assignment_Group_Queues__c agqBad = new Assignment_Group_Queues__c(name='Bad Queue',Assignment_Group_Name__c = ag1.id );
    
            try {
                insert agqBad; 
            } catch (DmlException e) {
                 System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage());             
            } //catch

            Id conId = [SELECT Id FROM Contact WHERE MLH_Contact_Id__c!=null ORDER BY CreatedDate DESC LIMIT 1].Id;            
            //Assign Vault with out any Assignment Groups
            Vault__c c1 = new Vault__c (tempOwnerID__c=testGroup2.id, OwnerID=u1.id,Contact__c=conId); //tempOwnerID__c=testGroup2.id,  
            insert c1;
            update c1;            
        }
        test.stoptest();        
    }
    
    static testMethod void myTest2() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'Sys Admin'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue        
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Vault__c';
       insert testQueue;

       // Second Queue       
       Group testGroup2 = new Group ();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Vault__c';
       insert testQueue2;


       test.starttest();
       //Run test
        System.runAs(u1) {
               
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Vault');
            insert ag1;        
    
            //Add Good Queue to Assignment Group
            Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
            insert agq1;
            
            
            //Add User to Assignment Groups Users
            Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
            insert agu1;
    
    
            Id conId = [SELECT Id FROM Contact WHERE MLH_Contact_Id__c!=null ORDER BY CreatedDate DESC LIMIT 1].Id;            

            //Assign Vault with out any Assignment Groups
            Vault__c c1 = new Vault__c (tempOwnerID__c=testGroup2.id ,OwnerID=testGroup.id,Contact__c=conId); //tempOwnerID__c=testGroup2.id,  
            insert c1;
            update c1;
        }    
        test.stoptest();
        
    }

    static testMethod void myTest3() {

        // This code runs as the system user
        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'Sys Admin'  LIMIT 1];
        } catch (QueryException qe){
            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                  u1 = u;
                  break;
                }
            }
        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Vault__c';
       insert testQueue;

       test.starttest();
        
        //Run test        
        System.runAs(u1) {                         
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Vault');
            insert ag1;        
    
            //Add Good Queue to Assignment Group
            Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
            insert agq1;
            
            
            //Add User to Assignment Groups Users
            Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
            insert agu1;      
    
    
            Id conId = [SELECT Id FROM Contact WHERE MLH_Contact_Id__c!=null ORDER BY CreatedDate DESC LIMIT 1].Id;            
                
            //Assign Vault with out any Assignment Groups
            Vault__c c1 = new Vault__c (OwnerID=testGroup.id,Contact__c=conId); //tempOwnerID__c=testGroup2.id,  
            insert c1;
            update c1;
        }    
        test.stoptest();
        
    }

    static testMethod void myTest4() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'Sys Admin'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Vault__c';
       insert testQueue;
      
       test.starttest();
        
        //Run test
        System.runAs(u1) {    
            
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Vault');
            insert ag1;        
    
            //Add Good Queue to Assignment Group
            Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
            insert agq1;
            
              //Test for AG-Queues already assigned to another Assignment Group
            Assignment_Group_Queues__c agq2 = new Assignment_Group_Queues__c(name=testGroup.Name,Assignment_Group_Name__c = ag1.id );
            try {
                insert agq2;
            } catch (DmlException e){
                 System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
            } //catch
        }    
        test.stoptest();        
    }

    static testMethod void myTest5() {

        // This code runs as the system user

        User u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'Sys Admin'  LIMIT 1];

        test.starttest();
        //Run test
        System.runAs(u1) {   
            Id conId = [SELECT Id FROM Contact WHERE MLH_Contact_Id__c!=null ORDER BY CreatedDate DESC LIMIT 1].Id;
            //Assign Vault with out any Assignment Groups
            Vault__c c1 = new Vault__c (OwnerID=Label.RoundRobinVaultQID,Contact__c=conId); //tempOwnerID__c=testGroup2.id,  
            insert c1;
            c1.OwnerId=Label.RoundRobinDoNotDelete;
            update c1;
        }    
        test.stoptest();
        
    }
}