public class redirectController {
  
    public PageReference CaseRedirect() {
        String URL = '/500/e?retURL=%2F500%2Fo&RecordType=012d0000000SyFl&CF00Nd0000007Zt8C='+Userinfo.getName()+'&CF00Nd0000007Zt8C_lkid='+userinfo.getUserId()+'&00Nq0000000PzQz=1';
        PageReference pageRef = new PageReference(URL);
        pageRef.setRedirect(true);
        return pageRef;
    }    
}