/*************************************************************************************
* Name          :    callrecordpopupcon.
* Description   :    fetch Bids, contact Info, call record Information for the given Call record Id..
* Author        :    Harish Emmadi
 
Modification Log
------------------------------------------------------------------------------------------------------------
Date             Developer                Comments  
------------------------------------------------------------------------------------------------------------
11/19/2013       Harish Emmadi            Created
**************************************************************************************/
public with sharing class callrecordpopupcon {
    
    private              ApexPages.Standardsetcontroller    Contactcon;
    private              ApexPages.Standardsetcontroller    bidcon;
    private static final Integer                            defaultpgsize       = 5;      // default pageSize of raw related List to be shown.
    private              boolean                            isinbound_request   = false;
    public static final Set<String> ACTIVE_SALES_STAGES     =  new Set<String> {'Contract Complete'};    

    public callrecordpopupcon(Apexpages.standardcontroller controller) {
        callrec = (Callrecord__c)controller.getrecord();
        intializevariables();
        validatecrstatus();        
        search();
    }
    
    public         Callrecord__c             callrec                 { get; set; }
    public         String                    crstatus                { get; set; }
    public         Id                        selectedbidId           { get; set; }
    public         Id                        selectedconId           { get; set; }
    public         searchfields              sFields                 { get; set; }
    public         boolean                   callrecord_issaved      { get; private set; }  
    public         boolean                   needfollowup            { get; private set; }
    //public         Callrecord__c             followupcr              { get; private set; }    
    public         String                    propId                  { get; private set; }
    public         String                    venueId                 { get; private set; }
    public         String                    itemId                  { get; private set; }
    public         String                    auctionID               { get; private set; }
    public         String                    utoken                  { get; private set; }
    
    private void intializevariables() {
        contactcon     = new Apexpages.standardsetcontroller(new List<contact>());
        bidcon         = new Apexpages.standardsetcontroller(new List<bid__c>());
        sFields = new searchfields();
        callrecord_issaved = false;        
        crstatus = callrec.Calldisposition__c;
        String phonenum_param = system.currentpagereference().getparameters().get('ANI');
        String crId = system.currentpagereference().getparameters().get('id');
        //Debug Block
        //**************************************************
        system.debug('Call Record Disposition : ' +callrec.Calldisposition__c);
        system.debug('ANI =  ' +phonenum_param);
        system.debug('CRID =  ' +crId);
        system.debug('BIDID = ' +selectedbidId);
        //*************************************************
        if(String.isNotBlank(phonenum_param) && crId==null)
        if(String.isNotBlank(phonenum_param))
        { 
            isinbound_request     = true;
            sFields.phone = phonenum_param;
        }
        if(String.isNotBlank(callrec.Phone_Number__c))
            sFields.phone = callrec.Phone_Number__c;
        //selectedbidId = null;
          selectedconId = null;           
    }
    
    private void loadBids(){
        if(String.isNotblank(selectedconId))
        {
           bidcon = new Apexpages.standardsetcontroller(Database.getquerylocator([
                                                        SELECT Id, Name, Bid_Date_Time__c, MLH_Event_ID__c, MLH_Team__c,  REDC_ID__c, 
                                                               MLH_Bid_Stage__c, Buyer_Name__c,  Asset_Address__c, Missing_Docs_New__c, 
                                                               Auction_Opportunity_Assignment__r.MLH_Seller_Code__c 
                                                        FROM Bid__c 
                                                        WHERE Buyer_Name__c = :selectedconId AND Winning_Bid__c = true AND MLH_Bid_Stage__c NOT IN :ACTIVE_SALES_STAGES
                                                              AND MLH_Team__c!='error'  
                                                        ORDER BY LastmodifiedDate DESC]));
           bidcon.setPageSize(defaultpgsize);
           /*if(bidcon!= null && !getbids().isEmpty())
               selectedbidId = getbids().get(0).Id;
           else
               selectedbidId = null;   */ 
        }
        else
        {
            //selectedbidId = null;
            bidcon  = new Apexpages.standardsetcontroller(new List<bid__c>());
        }
    }
    
    private void runquery(String qryStr){
      try{
           List<contact> contactsList = Database.query(qryStr);
           if(contactsList != null && !contactsList.isEmpty())
           {   
               contactcon = new Apexpages.standardsetcontroller(contactsList);
               contactcon.setPageSize(defaultpgsize);
               /*if(contactcon!= null && !getcontacts().isEmpty())
                   selectedconId = getcontacts().get(0).Id;
               else
                    selectedconId = null; */   
           }
           else
           {
               //selectedconId = null;
               contactcon = new Apexpages.standardsetcontroller(new List<contact>());
           }
           
          system.debug('Selected Contacts : '+contactsList);
      }
      catch(DMLException e){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! Something is wrong with query..Please Inform your Administrator.'));
      }  
    }
    
    private String addquerycondition(String FieldName,String FieldValue,boolean isExactMatch ){
      String queryExtension = ' '+FieldName+' !=null';
      if(string.isNotEmpty(FieldValue)&&string.isNotEmpty(FieldName)){
           queryExtension += isExactMatch? ' and '+FieldName+ '='+'\'' + String.escapeSingleQuotes(FieldValue) + '\'' : ' and '+FieldName+' like '+'\'%' + String.escapeSingleQuotes(FieldValue) + '%\'' ;
        return queryExtension;   
      }
      return null;
    }
    
    public PageReference search() {
       System.debug('field values are'+sFields.firstName+sFields.lastName+sFields.email+sFields.phone);
       String qryStr = 'Select Id, AccountId, Name, Email, phone, MLH_WorkPhone__c, OwnerId'+ ' from Contact where';
       if(string.isNotBlank(sFields.firstName) || string.isNotBlank(sFields.lastName) || string.isNotBlank(sFields.email) || string.isNotBlank(sFields.phone)){
              String cleanPhone = sFields.Phone;

              cleanPhone = cleanPhone.replaceAll('\\(', '');
              cleanPhone = cleanPhone.replaceAll('\\) ', '');
              cleanPhone = cleanPhone.replaceAll('\\)', '');
              cleanPhone = cleanPhone.replaceAll('-','');
              cleanPhone = cleanPhone.trim();
              //cleanPhone = '1'+cleanPhone;    
              sFields.Phone = cleanPhone;
              String phonefieldtosearch = string.isNotEmpty(sFields.phone) && (sFields.phone.containsAny('-') || sFields.phone.containsAny('(')) ? 'MLH_WorkPhone__c' : 'LiveOps_Phone_Formatted__c';
              
              qryStr+= string.isNotEmpty(sFields.firstName)? addquerycondition('FirstName',sFields.firstName,sFields.exactMatch): '';
              qryStr+= string.isNotEmpty(sFields.lastName) ? (qryStr.endsWithIgnoreCase('where') ? addquerycondition('LastName',sFields.lastName,sFields.exactMatch) : ' and '+addquerycondition('LastName',sFields.lastName,sFields.exactMatch)):'';
              qryStr+= string.isNotEmpty(sFields.email)    ? (qryStr.endsWithIgnoreCase('where') ? addquerycondition('Email',sFields.email,sFields.exactMatch) : ' and '+addquerycondition('Email',sFields.email,sFields.exactMatch)):'';
              qryStr+= string.isNotEmpty(sFields.phone)    ? (qryStr.endsWithIgnoreCase('where') ? addquerycondition(phonefieldtosearch,sFields.phone,sFields.exactMatch) : ' and '+addquerycondition(phonefieldtosearch, sFields.phone,sFields.exactMatch)):'';
              //qryStr+= ' AND RecordTypeId=\'' + String.escapeSingleQuotes(Label.Bidder_Registration_Contact) + '\'';
              //qryStr+= ' AND Id  IN (SELECT Buyer_Name__c FROM Bid__c WHERE Winning_Bid__c=TRUE AND MLH_Bid_Stage__c NOT IN :ACTIVE_SALES_STAGES)';
              qryStr+= ' AND Id  IN (SELECT Buyer_Name__c FROM Bid__c WHERE Winning_Bid__c=TRUE AND MLH_Bid_Stage__c NOT IN :ACTIVE_SALES_STAGES'+' )';
              qryStr+= ' ORDER BY Name LIMIT 100';
              System.debug('Complete Contact Search query is:'+qryStr);
              runquery(qryStr);
              selectedconId = null;
              loadBids();
       }
       else{return null;}
       return null;
    }
    
    public void poleforbids(){
        loadBids();
    }
    
    public pagereference savecallrecord(){
        //validations
        //1. Call disposition is required to save call record.
        if(String.isBlank(crstatus))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Call  disposition is required.'));
            return null;
        }
        callrec.Calldisposition__c = crstatus;
        if(isinbound_request == false && callrec.FollowupTime__c != null) {
            if(callrec.bid__c != null)
            {
                Bid__c bidtobeupdated = new bid__c(Id = callrec.bid__c, Call_Record_notes__c = callrec.Notes__c, 
                                                   MLH_Next_Contact_Time__c = callrec.FollowupTime__c);
                update bidtobeupdated;
            }    

            callrec.FollowupTime__c = null;
            //callrec.Notes__c = null;
            callrec.Calldisposition__c = 'Completed Information';
            callrec.Call_Status__c = CONSTANTS.CR_STATUS_CLOSED;
        }    
        upsert callrec;
        callrec = [select Id, Name, FollowupTime__c, contact__c, bid__c, Notes__c , Calldisposition__c  
                          from callrecord__c where Id = :callrec.Id limit 1];
        callrecord_issaved = true;
        return null;
    }
    
    public List<SelectOption> getcrStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption(CONSTANTS.ANSWERING_MACHINE_DISPOISTION,CONSTANTS.ANSWERING_MACHINE_DISPOISTION)); 
        //options.add(new SelectOption(CONSTANTS.BUSY_DISPOISTION,CONSTANTS.BUSY_DISPOISTION)); 
        options.add(new SelectOption(CONSTANTS.COMPLETED_INFO_DISPOISTION,CONSTANTS.COMPLETED_INFO_DISPOISTION)); 
        options.add(new SelectOption(CONSTANTS.NEED_FOLLOWUP_DISPOISTION,CONSTANTS.NEED_FOLLOWUP_DISPOISTION)); return options; 
    }
    
    public void processselectedcontact(){
        System.debug('********inside processselectedcontact - con **********selectedconId is:'+selectedconId);
        System.debug('********inside processselectedcontact - Bid **********selectedconId is:'+selectedBidId);
        if(isinbound_request == true)// reinitialize call record on select of different contact, if old call record is already saved.
        {    
            if(callrecord_issaved == true)
            {
                callrec = new callrecord__c();
                callrecord_issaved = false;
                crstatus = null;
            }
            callrec.contact__c = selectedconId;// change contact of callrecord in inbound scenario only. 
        }
        loadBids();
        system.debug('Call Record Disposition : ' +callrec.Calldisposition__c);
        //system.debug('ANI =  ' +phonenum_param);
        //system.debug('CRID =  ' +crId);
        system.debug('BIDID = ' +selectedbidId);
        selectedbidId = null;
        processselectedbid();
    }
    
    public void processselectedBid(){
        System.debug('********inside processselectedBid**********selectedconId is:'+selectedbidId);
        System.debug('********Inbound? = ' +isinbound_request);
        if(isinbound_request == true)// change bid of callrecord in inbound scenario only.
        {
            callrec.bid__c = selectedbidId;
        }
        if(String.isNotblank(selectedbidId))
        {   
            bid__c currentbid = [select Id, MLH_Venue_Id__c, MLH_Auction_ID__c, MLH_Asset_ID__c, 
                                        MLH_Global_Property_ID__c from bid__c 
                                            where Id = :selectedbidId limit 1];
            propId    = currentbid.MLH_Asset_ID__c;
            venueId   = currentbid.MLH_Venue_Id__c;
            itemId    = currentbid.MLH_Asset_ID__c;
            auctionID = currentbid.MLH_Auction_ID__c;
            System.debug('********inside processselectedBid**********propId is:'+propId+'\n*****venueId is:'+venueId+'\n*****itemId is:'+itemId+'\n*****auctionID is:'+auctionID+'\n');
        }
    }
    
    public List<Bid__c> getbids(){
        return bidcon.getrecords();
    }
    
    public List<Contact> getcontacts(){
        return contactcon.getrecords();
    }
    
    public void validatecrstatus(){
        if(CONSTANTS.NEED_FOLLOWUP_DISPOISTION.equalsIgnorecase(crstatus))
            needfollowup = true;
        else
            needfollowup = false;
    }
    
    public class searchfields{
        public String   firstName     { get; set; }
        public String   lastName      { get; set; }
        public String   email         { get; set; }
        public String   phone         { get; set; }
        public boolean  exactMatch    { get{ return exactMatch == null ? false : exactMatch; } set; }
    }
    
    Public Integer getpageNumber() { return bidcon.getpageNumber(); }
    Public Integer getpageSize()   { return bidcon.getpagesize(); }
    public Integer getnoOfRecords(){ return bidcon.getResultsize(); }
    public Boolean gethasNext()    { return bidcon.gethasnext(); }
    public Boolean gethasPrevious(){ return bidcon.gethasprevious();}
    
    Public void Next()    { bidcon.next(); }
    Public void Previous(){ bidcon.previous(); }
    Public void First()   { bidcon.first(); }
    Public void Last()    { bidcon.last(); }
    
    Public Integer getpageNumber_c() { return contactcon.getpageNumber(); }
    Public Integer getpageSize_c()   { return contactcon.getpagesize(); }
    public Integer getnoOfRecords_c(){ return contactcon.getResultsize(); }
    public Boolean gethasNext_c()    { return contactcon.gethasnext(); }
    public Boolean gethasPrevious_c(){ return contactcon.gethasprevious();}
    
    Public void Next_c()    { contactcon.next(); }
    Public void Previous_c(){ contactcon.previous(); }
    Public void First_c()   { contactcon.first(); }
    Public void Last_c()    { contactcon.last(); }
}