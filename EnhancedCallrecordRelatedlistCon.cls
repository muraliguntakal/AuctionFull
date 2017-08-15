/*************************************************************************************
* Name          :    EnhancedCallrecordRelatedlistCon
* Description   :    Controller for EnhancedCallrecordRelatedlist component, controls sorting and pagination logic.
* Author        :    Harish Emmadi
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
12/05/2013       Harish Emmadi            Created
**************************************************************************************/

public with sharing class EnhancedCallrecordRelatedlistCon{
    
    public boolean doMassEdit       { get; private set; }
    public string  ParentContactId  { get; set; }//set by Component.
    public Integer defaultPgsize    { get; set; }//set by Component.
    public Boolean ErrorwithPAList  { get; private set; }
    
    public EnhancedCallrecordRelatedlistCon(){
        doMassedit = false;
        callrecordcon = null;
    }
    
    public List<callrecord__c> callrecords{
        get { return callrecordcon.getrecords(); }
        set;
    }
    
    private ApexPages.StandardSetController callrecordcon{
        get {
            if(ParentContactId != null && (callrecordcon == null || callrecordcon.getrecords().isEmpty())) {
                String Query = 'SELECT Id, Name, Contact__c, Bid__c, Followuptime__c, Calldisposition__c, Notes__c, Winning_Bid_Call__c '+
     //                          'from callrecord__c where followuptime__c != null AND contact__c = '+'\''+ParentContactId+'\''+
                               'FROM callrecord__c WHERE contact__c = '+'\''+ParentContactId+'\''+
                               +'AND Failed__c = FALSE '+                               
                               +'AND Call_Status__c = '+'\''+CONSTANTS.CR_STATUS_OPEN+'\''+
                               +'AND (Calldisposition__c = '+'\''+CONSTANTS.NEED_FOLLOWUP_DISPOISTION+'\' OR Calldisposition__c = NULL ) ORDER BY CreatedDate DESC';
                callrecordcon = new ApexPages.StandardSetController(Database.getQueryLocator(Query));
                callrecordcon.setpagesize(defaultPgsize);
            }
            if(callrecordcon == null || ParentContactId == null)
               callrecordcon  = new Apexpages.standardsetcontroller(new List<callrecord__c>());
            return callrecordcon;
        }
        private set;
    }
    
    /***********
    * Method name  : doMassEdit
    * Description  : set MassEdit.
    * Return Type  : void
    * Parameters   : none
    ***********/
    public void doMassEdit(){doMassEdit = true;}
    
    /***********
    * Method name  : cancelMassEdit
    * Description  : reset MassEdit and nullify setCon.
    * Return Type  : void
    * Parameters   : none
    ***********/
    public void cancelMassEdit(){doMassEdit = ErrorwithPAList = false;nullifysetcon();}
    
    /***********
    * Method name  : Refresh
    * Description  : nullify setCon.
    * Return Type  : void
    * Parameters   : none
    ***********/
    public void Refresh(){nullifysetcon();}
    
    /***********
    * Method name  : MassSave
    * Description  : do Commit and reset massedit.
    * Return Type  : void
    * Parameters   : none
    ***********/
    public void MassSave(){
        docommit();
        if(!ApexPages.hasMessages(ApexPages.Severity.Error) || ApexPages.hasMessages(ApexPages.Severity.FATAL))    
        {    
            doMassEdit = false;
            nullifysetCon();
        }
    }
    
    /***********
    * Method name  : nullifysetCon
    * Description  : set the standardsetcontroller(setCon) to null.
    * Return Type  : void
    * Parameters   : none
    ***********/
    public void nullifysetCon(){callrecordcon = null;}
    
    /***********
    * Method name  : docommit
    * Description  : Save list of records/add error to pagemessages exception occurs. 
    * Return Type  : void
    * Parameters   : none
    ***********/
    private void docommit()
    {
        try{
            update callrecords;
            ErrorwithPAList = false;
        }
        catch(DMLException DMLex){
            ErrorwithPAList = true;
            for(Integer i = 0; i< DMLex.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,callrecords.get(DMLex.getDmlIndex(i)).Name +' : '+DMLex.getDmlMessage(i)));
        }
        catch(Exception ex){
            ErrorwithPAList = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage()));
        }
    }
    
    
    /***********
    * Method name  : donothing
    * Description  : do nothing.
    * Return Type  : void
    * Parameters   : none
    ***********/
    public void donothing(){}
    
    //Pagination Methods.
    Public Integer getpageNumber() { return callrecordcon.getpageNumber(); }
    Public Integer getpageSize()   { return callrecordcon.getpagesize(); }
    public Integer getnoOfRecords(){ return callrecordcon.getResultsize(); }
    public Boolean gethasNext()    { return callrecordcon.gethasnext(); }
    public Boolean gethasPrevious(){ return callrecordcon.gethasprevious();}
    
    Public void Next()    { callrecordcon.next(); }
    Public void Previous(){ callrecordcon.previous(); }
    Public void First()   { callrecordcon.first(); }
    Public void Last()    { callrecordcon.last(); }
}