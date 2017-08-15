public with sharing class BidRegistrationTriggerHelper {

    public void UpsertBidderRegContact(List<Bidder_Registration__c> newBidRegs) {        
        Set<string> mlhcontIdSet=new Set<string>();
        Set<string> currentMLHContactIds=new Set<string>();
        Set<String> auctionIdSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> FirstNameSet = new Set<String>();
        Set<String> LastNameSet = new Set<String>();
        
        for(Bidder_Registration__c bidr : newBidRegs) {
            
            //Clean MLH Garbage Data 
            if(bidr.MLH_ContactId__c == '-1' || bidr.MLH_ContactId__c == '-' || bidr.MLH_ContactId__c == '--') {
               bidr.MLH_ContactId__c =null;
            }
            if(bidr.MLH_Email__c == '-1' || bidr.MLH_Email__c == '-' || bidr.MLH_Email__c == '--') {
               bidr.MLH_Email__c = null; 
            }
            if(bidr.MLH_CellPhone__c =='--' || bidr.MLH_CellPhone__c =='-' || bidr.MLH_CellPhone__c =='-1') {
                bidr.MLH_CellPhone__c=null;
            }
    
            //Set Work Phone to Cell Phone if Work Phone is missing
            if(bidr.MLH_WorkPhone__c =='--' || bidr.MLH_WorkPhone__c == null) {
                bidr.MLH_WorkPhone__c=null;
                if(bidr.MLH_CellPhone__c!=null) {
                    bidr.MLH_WorkPhone__c = bidr.MLH_CellPhone__c;                     
                }
            }
            
            //Get Keys to find existing Contacts using MLH Contact ID/Email 
            if(bidr.MLH_ContactId__c !=null) {
                mlhcontIdSet.add(bidr.MLH_ContactId__c);
            }   
        }
    
        List<Contact> listcon =[SELECT Id,FirstName,RecordTypeId,LastName,MLH_Contact_Id__c,MLH_WorkPhone__c,Phone,MobilePhone,Email
                                FROM Contact
                                WHERE (MLH_Contact_Id__c!='-1' AND MLH_Contact_Id__c IN :mlhcontIdSet)
                                ORDER BY CreatedDate Desc];
        
        Map<String, Contact> MLHcontactIdMap = new Map<string, Contact>();
    
        //Update Existing Contact if found, else create new contacts
        if(listcon <> NULL && listcon.size() >0 ) { 
            for(Contact c : listcon) {
                //POPULATE THE CONTACT RECORD IN MLH-CONTACT-MAP WHEN MLH CONATCT ID IS PRESENT 
                if(c.MLH_Contact_Id__c !=null && c.MLH_Contact_Id__c != '-1') {
                    if(!MLHcontactIdMap.containsKey(c.MLH_Contact_Id__c)) {
                        MLHcontactIdMap.put(c.MLH_Contact_Id__c,c);
                    }
                }
            }
        }
    
        system.debug('**********MLH Contact Map'+MLHcontactIdMap);                    
        Map<string, Contact> newconMap = new Map<string, Contact>();
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
    
        Map<String,Id> brMap = new Map<String,Id>();
    
        for(Bidder_Registration__c br : newBidRegs)  {
            system.debug('**********Bidder Info : '+br);
            //Search Contact using Bidder Reg. MLH Contact ID                    
            if(MLHcontactIdMap.KeySet().contains(br.MLH_ContactId__c) && br.MLH_ContactId__c != null && br.MLH_ContactId__c != '-1') {
                Contact cont=new Contact();
                
                br.Contact__c= MLHcontactIdMap.get(br.MLH_ContactId__c).Id;     
                cont.Id = MLHcontactIdMap.get(br.MLH_ContactId__c).Id;                  
                if(br.MLH_WorkPhone__c!=null)  {
                    cont.Phone = br.MLH_WorkPhone__c; 
                    cont.MLH_WorkPhone__c = br.MLH_WorkPhone__c;  // added by rakesh                    
                }
                
                if(br.MLH_CellPhone__c!=null)  {
                    cont.MobilePhone=br.MLH_CellPhone__c;
                    if(br.MLH_WorkPhone__c==null || br.MLH_WorkPhone__c=='' || br.MLH_WorkPhone__c=='-' || br.MLH_WorkPhone__c=='--' )  {
                        cont.MLH_WorkPhone__c = br.MLH_CellPhone__c; 
                    }
                }    
                if(br.MLH_Email__c!=null)  
                    cont.Email=br.MLH_Email__c;
                    
                updatecontactMap.put(br.Contact__c,cont);
                system.debug('**********FOUND CONTACT USING MLH CONTACT ID '+br.Contact__c);                           
            }
            else {
                system.debug('******Creating New Contact: ' +br);                           
                Contact cont=new Contact();
                cont.FirstName = br.MLH_FirstName__c;
                cont.LastName = br.MLH_LastName__c;
                
                if(br.MLH_WorkPhone__c!=null)  {
                    cont.Phone = br.MLH_WorkPhone__c; 
                    cont.MLH_WorkPhone__c = br.MLH_WorkPhone__c;  // added by rakesh       
                }                
                if(br.MLH_CellPhone__c!=null)  
                    cont.MobilePhone=br.MLH_CellPhone__c;
                if(br.MLH_Email__c!=null)  
                    cont.Email=br.MLH_Email__c;  

                if(br.MLH_ContactId__c!=null && br.MLH_ContactId__c!='-1' && br.MLH_ContactId__c!='--' && br.MLH_ContactId__c!='') {
                    cont.MLH_Contact_Id__c = br.MLH_ContactId__c;
                }
                else{
                    cont.MLH_Contact_Id__c = null;
                }
                
                cont.RecordTypeId = Label.Bidder_Registration_Contact;
                //cont.Created_From_Bidder_Registration__c=TRUE;                
                cont.Created_From_Source__c = 'Bidder Registration';
                //Add new Contact to new contact map; Remove duplicates by allowing one contact per MLH Contact ID 
                if(!newconMap.containsKey(br.MLH_ContactId__c) && br.MLH_ContactId__c!=null) {
                    newconMap.put(br.MLH_ContactID__c, cont);                                                                            
                }             
            }
        }

        Map<String,Account> NewAccountMap = new Map<String, Account>();
        for(Contact c : newconMap.values()) {
            Account acc = new Account(Name = c.FirstName+' '+c.LastName+' -- Account',Personalized_Account__c=true,Created_From_Source__c='Bidder Registration');
            //Account acc = new Account(Name = c.FirstName+' '+c.LastName+' -- Account',Personalized_Account__c=true,Created_From_Bidder_Registration__c=TRUE);
            NewAccountMap.put(c.MLH_Contact_ID__c,acc);
        }
        
        Insert NewAccountMap.values();
        
        for(Contact c : newconMap.values()) {
            c.AccountId=NewAccountMap.get(c.MLH_Contact_ID__c).Id;
        }
                
        if(newconMap.values().size()>0) {
            insert newconMap.values(); 
        }

        if(updatecontactMap.values().size() > 0) {
            Update updatecontactMap.values();
        }   

        //Assign contact to Bidder Registration
        for(Bidder_Registration__c bidr: newBidRegs) {
            if(bidr.Contact__c == NULL && newconMap.containsKey(bidr.MLH_FirstName__c+bidr.MLH_LastName__c)) {
                bidr.Contact__c =newconMap.get(bidr.MLH_FirstName__c+bidr.MLH_LastName__c).Id;   
            }    
        }           
    }

    public void CreateNewCaseforNewContact(List<Bidder_Registration__c> newBidRegs) {
    
        Map<String,Id> brContactMap = new Map<String,Id>();
        Set<String> mlhContIdSet = new Set<String>();
        for(Bidder_Registration__c br : newBidRegs) {
            if(br.MLH_ContactID__c!=null && br.MLH_Event_ID__c!=null) {
                if(br.MLH_Event_ID__c.startsWith('O')) {
                    mlhContIdSet.add(br.MLH_ContactID__c);
                    brContactMap.put(br.MLH_ContactID__c,br.Id);
                }
            }            
        }
        system.debug('Contacts => '+mlhContIdSet); 
        List<Contact> contList = new List<Contact>([SELECT Id,Name,MLH_Contact_ID__c,(SELECT Id FROM Cases WHERE RecordTypeId= :Label.Case_Bidder_Qual_RT),(SELECT Id FROM Bids__r) FROM Contact WHERE MLH_Contact_ID__c IN : mlhContIdSet]);

        List<Case> caseList = new List<Case>();    
        for(Contact cont : contList) {
            List<Bid__c> relatedBids = cont.getSObjects('Bids__r');
            List<Case> relatedCases = cont.getSObjects('Cases');
            if(relatedBids==null || relatedBids.size() == 0) {
                if(relatedCases==null || relatedCases.size() == 0) {
                    Case newCase = new Case ( ContactId = cont.Id,   
                                              Subject = 'Bidder Qualification - '+cont.Name,  
                                              Disposition_Category__c = 'Bidder Qualification',
                                              Disposition_Classification__c  = 'Initial Contact',
                                              Line_of_Business__c = 'CRE - BD',
                                              Bidder_Registration__c=brContactMap.get(cont.MLH_Contact_ID__c),  
                                              RecordTypeId= Label.Case_Bidder_Qual_RT 
                                            );
                    caseList.add(newCase);
                }
            }
        }
        Insert CaseList;
    } 

    public void BidUpdateContactPhone (List<Bidder_Registration__c> newbidList, Map<Id,Bidder_Registration__c> oldbidMap) {
        Map<ID, Contact> parentcontact = new Map<ID, Contact>(); //Making it a map instead of list for easier lookup
        List<Id> listIds = new List<Id>();
        List<Bidder_Registration__c> brList = new List<Bidder_Registration__c>();   
        for(Bidder_Registration__c br : newbidList) {
            if( br.MLH_WorkPhone__c!=null && br.MLH_WorkPhone__c != '' && br.MLH_WorkPhone__c != '--') {
                if(oldbidMap.get(br.Id).MLH_WorkPhone__c != br.MLH_WorkPhone__c) {
                   listIds.add(br.Contact__c);
                   brList.add(br);
                }
            }
        }       
        
        parentcontact = new Map<Id, Contact>([SELECT Id,MLH_WorkPhone__c FROM Contact WHERE ID IN :listIds]);         
        for(Bidder_Registration__c br: brList) {
            if(parentContact.get(br.contact__c)!=null) {
                Contact a =  parentContact.get(br.contact__c);
                a.MLH_WorkPhone__c = br.MLH_WorkPhone__c;                     
            }
        }
        Update parentcontact.values(); 
    }    

    public void BidRegistrationRollUp (List<Bidder_Registration__c> newbidList, List<Bidder_Registration__c> oldbidList, Boolean isDelete) {      
      Set<Id> ConId = new Set<Id>();
      Set<Id> BidRegId = new Set<Id>();
            
       if( trigger.isDelete ) {
             for(Bidder_Registration__c oldval: oldbidList) {
                if(oldval.Contact__c!=null) {
                    ConId.add(oldval.Contact__c);
                    BidRegId.add(oldval.Id);
                }   
             }
        }
        else {
            for(Bidder_Registration__c newval: newbidList) {
                ConId.add(newval.Contact__c);
                BidRegId.add(newval.Id);
            }
        }
        
        
             
         List<Contact> CRERegList = new List<Contact>();
         CRERegList = [SELECT Id,(SELECT Id FROM  Bidder_Registrations__r where CRE_Bid_Registration__c = True) FROM Contact WHERE Id IN :ConId];
         
          Map<Id,Boolean> CRERegMap = new Map<Id,Boolean>();         
          if(!CRERegList.isEmpty()){    
             for(Contact con: CRERegList){ 
               List<Bidder_Registration__c> relatedRecords = con.getSObjects('Bidder_Registrations__r');
                                if(relatedRecords!=null){
                                    CRERegMap.put(con.Id, True);
                                 }
                                 else{
                                    CRERegMap.put(con.Id, False);
                                 } 
              }      
          }
          
         List<Contact> ResiRegList = new List<Contact>();
         ResiRegList = [SELECT Id,(SELECT Id FROM  Bidder_Registrations__r where Resi_Bid_Registration__c = True) FROM Contact WHERE Id IN :ConId];       
          Map<Id,Boolean> RESIMap = new Map<Id,Boolean>();
          
          if(!ResiRegList.isEmpty()){    
             for(Contact con: ResiRegList){ 
              List<Bidder_Registration__c> relatedRecords = con.getSObjects('Bidder_Registrations__r');
                                if(relatedRecords!=null){
                                    RESIMap.put(con.Id, True);
                                  }  
                                else{
                                    RESIMap.put(con.Id, False);
                                 } 
              }      
          }                         
                 
           
  
    
        List<Contact> countBidRegs = [SELECT Id,(SELECT Id FROM  Bidder_Registrations__r) FROM Contact WHERE Id IN :ConId];
                    
        for(Contact con: countBidRegs)   {     
        
                   
                List<Bidder_Registration__c> relatedRecords = con.getSObjects('Bidder_Registrations__r');
                if(relatedRecords!=null) {
                        con.of_Bidder_Registrations__c = relatedRecords.size();
                    }
                 else {
                        con.of_Bidder_Registrations__c = 0;   
                     } 
               
                if(CRERegMap.ContainsKey(con.Id)){
                    con.Commercial_Bid_Registration__c = CRERegMap.get(con.Id);
                   } 
                 if(RESIMap.ContainsKey(con.Id)){
                    con.Resi_Bid_Registration__c = RESIMap.get(con.Id);
                   } 
     
                                            
        }
                 
         if(!countBidRegs.IsEmpty())
         {
           update countBidRegs;
         }
     }  
}