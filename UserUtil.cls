public class UserUtil {
    //Protected Members
    private static final UserUtil instance = new UserUtil();
    private Map<Id, User> mapUsers;
    
    //Properties
    public static User CurrentUser {
        get { return getUser(UserInfo.getUserId()); }
    }
    
    //Constructor
    private UserUtil() {
        mapUsers = new Map<Id, User>(queryUsers());
    }
    
    //Public Methods
    public static User getUser(Id userId) {
        if (instance.mapUsers.containsKey(userId)) {
            return instance.mapUsers.get(userId);
        }
        else {
//            throw new InvalidUserIdException('Unable to locate user id: ' + userId);
            return null;
        }

    }
    
    //Private Methods
    private List<User> queryUsers() {
        return [SELECT 
                    Id
                    , Name
                    , UserName
                    , Email
                    , ManagerId
                    , UserRole.Name
                    , Area__c
                FROM 
                    User WHERE isActive=true];
    }

    public static Map<Id,Set<Id>> getLegoAllTeamMembers(Set<Id> existingLegoTeams) {
        Map<Id,Set<Id>> legoMap = new Map<Id,Set<Id>>();
        List<user> users = [SELECT Id,Lego_Team_Id__c,Lego_ID_18__c FROM User WHERE isActive=TRUE AND Lego_Team_Id__c!=null AND Lego_ID_18__c IN :existingLegoTeams ORDER BY Lego_Team_Id__c];
        system.debug('===> ' +users);
        for(User u : users) {
            Set<Id> userSet = new Set<Id>();            
            if(legoMap.containsKey(u.Lego_ID_18__c)) {
                userSet = legoMap.get(u.Lego_ID_18__c);
                userSet.add(u.Id);
            } else {
                userSet.add(u.Id);
            }
            legoMap.put(u.Lego_Team_Id__c,userSet);
        }
        return legoMap;    
    }   


}