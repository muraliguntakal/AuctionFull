public class CaseMassUpdateController {
    ApexPages.StandardSetController setCon;
    public String retURL {get; set;}
    public String CaseStatus {get;set;}
    public String CaseReason {get;set;}
    public String selectStatus {get; set;}
    
    public String selectedValue {get; set;}
    public String defaultCategory;
    public String defaultClassification;

    public Boolean PublicComment {get;set;}    
    public Boolean EmailCaseComment {get;set;}
    public String Comment {get;set;}
    //Public case c {get; Private set;}
    public CaseMassUpdateController(ApexPages.StandardSetController controller)  {
                setCon = controller;
                retURL = ApexPages.currentPage().getParameters().get('retURL');
                system.debug('***************'+setcon.getSelected().size());
    }
    
    public integer getMySelectedSize()
    {
        return setCon.getSelected().size();
    }
    
    public integer getMyRecordsSize()
    {
        return setCon.getRecords().size();
    }
    
    public PageReference doCancel()
    {
        return setCon.cancel();
    }
    
    public PageReference doSave() {
        PageReference pg = new pageReference(retURL);
        defaultCategory = 'Bidder Qualification';
        defaultClassification = 'Initial Contact';
        List<sObject> sList=setCon.getSelected();
        if(setCon.getSelected().size() == 0) {
          system.debug('******************no recs selected');
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Oops!...No Case records selected.');
        //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Oops! No records selected.'));
          ApexPages.addMessage(myMsg); 
          pg= null;
        }
        else {
            if(Comment!=null) {
                List<CaseComment> ccList=saveComments();
                System.Debug(Logginglevel.DEBUG,'CASEMASSUPDATECONTROLLER.doSave - List of new Comments: '+ccList);
                if(TriggerSettings__c.getValues('EmailCaseComment').Status__c) {
                    //sendEmail(ccList);
                }
            }    
            system.debug('Current Cases Saved: ' +setCon);         
            //List<sObject> cList=setCon.getSelected();
            for(sObject s:setCon.getSelected()) {
              s.Put('Status','Closed');
              s.Put('Reason',CaseReason);
              s.Put('Disposition_Category__c',defaultCategory);
              s.Put('Disposition_Classification__c',defaultClassification);
              s.Put('Detail_Specifics__c',selectedValue);              
             // s.Put('Topic Detail','Initial Contact');
             // s.Put('Case Topic', 'Bidder Qualification');
              System.debug('current********************** Case' +s);
            }             
            setCon.save();
        }
        return pg;        
    }
  
     
    public List<SelectOption> getCloseStatus()
    {
        List<CaseStatus> csList=[SELECT Id,MasterLabel FROM CaseStatus WHERE IsClosed=TRUE];
        List<SelectOption> options=new List<SelectOption>();
        for(CaseStatus cs:csList) 
        {
            options.add(new SelectOption(cs.MasterLabel, cs.MasterLabel));
        }
        return options;
    }
    public List<SelectOption> getCloseReason()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult=Case.Admin_Close_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
       return options;
    } 
    
    public List<selectOption> getTopicDetail() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '-None-')); 
        options.add(new selectOption('Covered The Transaction Details', 'Covered The Transaction Details')); 
        options.add(new selectOption('No Answer', 'No Answer')); 
        options.add(new selectOption('Left a Message', 'Left a Message')); 
        options.add(new selectOption('Wrong Answer', 'Wrong Answer')); 
        return options;
    }   
    
    public void sendEmail(List<CaseComment> ccList)
    {
        Map<Id,Case> cMap=new Map<Id,Case>([SELECT Id,ContactId FROM Case WHERE Id IN (SELECT ParentId FROM CaseComment WHERE Id IN :ccList)]);
        List<Id> ContactIdList=new List<Id>();
        List<Id> CaseIdList=new List<Id>();
        for(Case c:cMap.Values())
        {
            ContactIdList.Add(c.ContactId);
            CaseIdList.Add(c.Id);
        }

        Messaging.reserveMassEmailCapacity(CaseIdList.Size());

        List<Case> cList=[SELECT Id,ContactId FROM Case WHERE Id IN (SELECT ParentId FROM CaseComment WHERE Id IN :ccList)];

        Messaging.reserveSingleEmailCapacity(cList.Size());

        List<Messaging.SingleEmailMessage> mList = new List<Messaging.SingleEmailMessage>();
        for(Case c:cList)
        {
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(c.ContactId);
            mail.setWhatId(c.Id);
            mail.setTemplateID('00Xd0000000fBVr');
            mail.setReplyTo('noreply@auction.com');
            mail.setSenderDisplayName('Auction.com Support');
            mList.Add(mail);
        }
            Messaging.sendEmail(mList); 
    } 

    
    public List<CaseComment> saveComments()
    {
        List<sObject> sList=setCon.getSelected();
        List<CaseComment> ccList=new List<CaseComment>();
        for(sObject s:sList) {
            s.Put('Status','Closed');
            s.Put('Reason',CaseReason);
           // s.Put('Topic Detail','Initial Contact');
          //  s.Put('Case Topic', 'Bidder Qualification');
            //s.Put('isClosed',TRUE);
           //s.Put('Source',CaseSource);
           //s.Put('disCat',CasedisCat);
           //s.Put('discls',Casediscls);
            system.debug('Current Case push values' +s );
            if(!String.isBlank(Comment)) {
                ccList.Add(new CaseComment(CommentBody=Comment, ParentId=(Id)s.Get('id')));
            }
        }

        if(!ccList.isEmpty()) {
            insert ccList;
        }
        return ccList;
    }
}