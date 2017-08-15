global class SendCMVaultEmail  implements Database.Batchable<sObject>, Database.AllowsCallOuts, Database.Stateful{
    global   String  query;
    public List<Messaging.SingleEmailMessage> EmailMessages = new List<Messaging.SingleEmailMessage>();
    public List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
    public List<Messaging.SendEmailError> emailErrors = new List<Messaging.SendEmailError>();
    public List<Customer_Communication__c> ccList = new List<Customer_Communication__c>();


    //  ---------------------------------------------------------------------
    //  CONSTRUCTOR
    //  ---------------------------------------------------------------------
    global SendCMVaultEmail  () {
   
        this.query = 'SELECT Id,Contact__c,Contact__r.Email, ' +
                     ' Email_Template__c, ' +
                     ' Opportunity__r.Secondary_Client_Manager__r.Email, ' +
                     ' Opportunity__r.Secondary_Client_Manager__r.Name ' +
                     ' Opportunity__r.Secondary_Client_Manager__c' +
                     ' FROM Vault__c ' +
                     ' WHERE '+
                     ' Email__c!=null ' +
                     ' AND Contact__r.HasOptedOutOfEmail=FALSE '+
                     ' AND Contact__r. Unsubscribe_Ten_x_Commercial__c=FALSE'+                    
                     ' AND Vault_Email_Date__c = LAST_N_DAYS:1';
    }
   
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: start
    //  ---------------------------------------------------------------------
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
   
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: execute
    //  ---------------------------------------------------------------------
    global void execute(Database.BatchableContext bc, List<Vault__c> scope) {
               
        Set<String> EmailTemplates = new Set<String>();
        Map<String,Id> emailTemplateMap = new Map<String, Id>();
        Set<String> TodaysToEmailIds = new Set<String>();     
        Set<String> TodaysSentEmailIds = new Set<String>();        
   
        Schema.DescribeFieldResult fieldResult = Vault__c.Email_Template__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            EmailTemplates.add(f.getLabel());           
        }

        List<EmailTemplate> Templates = new List<EmailTemplate>([Select Id,Name from EmailTemplate WHERE Name IN : EmailTemplates]);
        for(EmailTemplate e : Templates ) {
            emailTemplateMap.put(e.Name,e.Id);
        }
        for (Vault__c v : scope) {
           TodaysToEmailIds.add(v.Contact__r.Email);
        }

        for(EmailMessage em  : [SELECT ToAddress FROM EmailMessage WHERE ToAddress IN :TodaysToEmailIds AND MessageDate = LAST_N_DAYS : 1]) {
            TodaysSentEmailIds.add(em.ToAddress);
        }
                 
        for (Vault__c v : scope) {
            if(!TodaysSentEmailIds.contains(v.Contact__r.Email)) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateID(emailTemplateMap.get(v.Email_Template__c));
                message.WhatId = v.Id;
                message.targetObjectId = v.Contact__c;
                system.debug(' => ' +v.Opportunity__r.Secondary_Client_Manager__r.Email);
                string replymail = v.Opportunity__r.Secondary_Client_Manager__r.Email;
                message.setReplyTo(replymail);
                message.setSenderDisplayName(v.Opportunity__r.Secondary_Client_Manager__r.Name);
                message.setSaveAsActivity(true);
                EmailMessages.add(message);
                
                //Update Vault Email Communication Status to Sent
                v.Email_Communication_Status__c = 'Sent';
    
                //Log Activity in Customer Communication for the Template
                Customer_Communication__c cc= new Customer_Communication__c();
                cc.Contact__c  = v.Contact__c;  
                cc.Vault__c = v.Id;
                cc.Email_Template__c =  v.Email_Template__c;
                cc.Status__c = 'Sent';
                ccList.add(cc);
            }
            else {
                Customer_Communication__c cc= new Customer_Communication__c();
                cc.Contact__c  = v.Contact__c;  
                cc.Vault__c = v.Id;
                cc.Email_Template__c =  v.Email_Template__c;
                cc.Status__c = 'Not Sent - Multiple Emails';
                ccList.add(cc);            
                //Update Vault Email Communication Status to Sent
                v.Email_Communication_Status__c = 'Not Sent - Multiple Emails';
            }
        }
       
        //Send Emails
        results = Messaging.sendEmail(EmailMessages);      
            if (results.get(0).isSuccess()) {
                Database.Insert(ccList,false);
                Update scope;
                System.debug('The email was sent successfully.');
            } else {
                system.debug('Send Email Failed => ' +results.get(0).getErrors()); 
            }         
    }  
    
    //  ---------------------------------------------------------------------
    //  INTERFACE METHOD: finish
    //  ---------------------------------------------------------------------
    global void finish(Database.BatchableContext bc) {   

    }
}