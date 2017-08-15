public class BDEmailComponentController {
    private final string bio;

    public BDEmailComponentController() {
        bio = [SELECT BD_Bio__c FROM User WHERE Id = :UserInfo.getUserId()].BD_Bio__c;
    }

    public String getbio() {
        return bio;
    }
}