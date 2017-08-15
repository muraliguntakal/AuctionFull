trigger BuyerSellerContactProfile on Contact_Profile__c (after insert) {
 //if(TriggerSettings__c.getValues('BuyerSellerContactProfile').Status__c) { 
   TriggerSettings__c ts = TriggerSettings__c.getValues('BuyerSellerContactProfile');
   if (ts != null && ts.Status__c) {


     Set<Id> conId = new Set<Id>();
     Set<Id> UserIds= new Set<Id>();

     for(Contact_Profile__c conpro:Trigger.new) { 
          conId.add(conpro.Contact__c);
          UserIds.add(conpro.CreatedById);
     }
               
     List<Contact> conlist = new List<Contact>();
     conlist  = [SELECT Id,Contact_Profile_Created_By__c,User_Role_Created_Contact_Profile__c FROM Contact where Id IN:conId];
     Map<Id,String> userRoleMap = new Map<Id,String>();
     Map<Id,User> userRoles = new Map<Id,User>([SELECT UserRoleId,UserRole.Name FROM User WHERE Id IN :UserIds AND isActive=TRUE]); 
     for(user u : userRoles.values()) {
         userRoleMap.put(u.UserRoleId,u.UserRole.Name);         
     }
   
     if(!conlist.isEmpty()) {
         for(Contact con:conlist)  {
             Id urole = UserInfo.getUserRoleId();  
             con.User_Role_Created_Contact_Profile__c =  userRoleMap.get(uRole);
             con.Contact_Profile_Created_By__c = UserInfo.getName();             
         }
     }

     if(!conlist.IsEmpty()) {
         Update conlist;  
     }
 }  
}