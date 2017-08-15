public class clientPlanController {

    public Action_Plan__c ap {get;set;}
    List<Contact> decisionMakers {get;set;}
    List<Contact> tenxUsers  {get;set;}
    
    public clientPlanController (ApexPages.StandardController sc) {
        this.ap = (Action_Plan__c)sc.getRecord();
    }
    
    public List<Contact> getdecisionMakers () {
        decisionMakers = [SELECT Id,Name, Title, MailingCity
                          FROM Contact 
                          WHERE AccountId = :this.ap.Account__c AND Decision_Maker__c=TRUE];
        return decisionMakers;
    }

    public List<Contact> gettenxUsers () {
        tenxUsers    =   [SELECT Id,Name, Title, MailingCity
                          FROM Contact 
                          WHERE AccountId = :this.ap.Account__c AND Potential_Ten_X_User__c=TRUE];
        return tenxUsers;
    }
}