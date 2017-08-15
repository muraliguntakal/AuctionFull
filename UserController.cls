//******************************************************************************************************************************************************************************************
//  --------------------------------------------------------------------
//  To display all the Online Auction Agent users in a Page. Manager can activate/inactivate users
//  --------------------------------------------------------------------
/* Author : Ganesh Vinnakota Created  on 02/12/14 */
// Test Class : TestUserController
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public class UserController 
{
    
    public String sortOrder {get; set;}
    public Integer activeCount {get; set;}
    public List<User> usrList {get; set;}
    Public Integer NumOfActiveRec{Get;Set;}
    
    public UserController() 
    {
        onLoad();              
    }
    

    public void onLoad() {
        sortOrder = 'ASC';
        usrList = [Select id, Name, UserName, ProfileId, IsActive  from User where Profile.Name = :Label.Online_Auction_Agent order by Name];
        activeCount = 0;
        for(User u :usrList) {
            if(u.isActive) {
                activeCount++;
            }
        }        
        sortList();
    }
    
    public PageReference onSave() 
    {
         try 
         {
          update usrList;
          NumOfActiveRec = [Select Count() from User where IsActive= :true and Profile.Name = :Label.Online_Auction_Agent];       
        
               if(NumOfActiveRec > integer.valueof(Label.Max_Active_Users))
                {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Number of Active users are more than ' + Label.Max_Active_Users + '. The Maximum number of active users should not exceed more than ' + Label.Max_Active_Users + '.'));                    
                } 
               else
                {
                   ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.CONFIRM, 'Records successfully saved.'));
                }   
        } catch(Exception e) 
         {
            ApexPages.addMessages(e);
         }
        return null;
    }    

    public PageReference sortList() {
        List<User> activeList = new List<User>();
        List<User> inActiveList = new List<User>();
         
        for(User u :usrList) {
            if(u.isActive) {
                activeList.add(u);
            } else {
                inActiveList.add(u);
            }
        }
        if(sortOrder == 'ASC') {
             usrList.clear();
            usrList.addAll(inActiveList);
            usrList.addAll(activeList);
            sortOrder = 'DESC';
            return null;
        }
        if(sortOrder == 'DESC') {
             usrList.clear();
            usrList.addAll(activeList);
            usrList.addAll(inActiveList);
            sortOrder = 'ASC';
            return null;
        }
        return null;
     }
      
  }