public with sharing class OpportunityTriggerHelper {
    
    public static Boolean isTriggerUpdate = false;

//***************************************************************************************//
    public void Create_Assets(List<Opportunity> newOpportunities) {    
              //Create Asset Before Opportunity is created
              Set<string> uniqueIds = new Set<string>();   
               // Asset and AssetOppJunction Creation - Start
              for (Opportunity newOpp: newOpportunities) {
                  if(newOpp.Unique_Asset_Field__c != null && newOpp.Unique_Asset_Field__c != ' ' && newOpp.Unique_Asset_Field__c != '') { 
                       if(newOpp.Property_Street__c!=null  && newOpp.Property_Zip_Postal_Code__c!=null) {
                             newOpp.Unique_Asset_Field_New__c=newOpp.Property_Street__c+newOpp.Property_Zip_Postal_Code__c;      
                             uniqueIds.add(newOpp.Unique_Asset_Field__c);
                       }
                  }          
              }
      
              List<asset__c> AssetList = New List<asset__c>(); 
              if(uniqueIds.size() > 0) {
                  AssetList = New List<Asset__c> ([SELECT Id,Asset_SF_Unique_ID__c,Property_Street__c,Property_City__c,Property_State__c,Property_Zip_Postal_Code__c,
                                                          Occupancy_Status__c,Home_Square_Footage__c,Bedrooms__c,Baths__c,Property_Type__c
                                                   FROM Asset__c 
                                                   WHERE Asset_SF_Unique_ID__c IN :uniqueIds AND Asset_SF_Unique_ID__c!=null AND Asset_SF_Unique_ID__c!=' ']);
              }
                      
              //Create AssetUniqueId and Asset Map 
              Map<String, Asset__c> AssetMap = new Map<String, Asset__c>();
              for(Asset__c ast : AssetList) {
                  if(ast.Asset_SF_Unique_ID__c!=null)
                     AssetMap.put(ast.Asset_SF_Unique_ID__c,ast);
              } 
          
              List<Asset__c> CreateAssets = new List<Asset__c>();
              // For Loop 1 - Start 
              for (Opportunity newOpp: newOpportunities) {                     
                  system.debug('*****     1. Check for Existing Asset; if Asset not in Existing Asset list create new Asset      *****');
                  if(newOpp.Unique_Asset_Field__c!=null && newOpp.RecordTypeId!=label.Parent_Opportunity) {
                      if(!AssetMap.KeySet().contains(newOpp.Unique_Asset_Field__c)) {
                          Asset__c ast = new Asset__c( Opportunity__c = newOpp.Id, Property_City__c = newOpp.Property_City__c, Listing_Agreement_Date__c = newOpp.Listing_Agreement_Date_Listing_Date__c , Listing_Agreement_Expiration_Date__c = newOpp.Listing_Agreement_Date_Expiration_Date__c,
                                           Current_Listing_Price__c = newOpp.Current_Listing_Price__c, Offer_Date__c = newOpp.Offer_Date__c, Offer_Amount__c = newopp.Offer_Amount__c, Net_Offer_Amount__c = newOpp.Net_Offer_Amount__c, Financing_Type__c = newOpp.Financing_Type__c, 
                                           Property_State__c = newOpp.Property_State__c, Property_County__c = newOpp.Property_County__c, Property_Street__c = newOpp.Property_Street__c, Property_Zip_Postal_Code__c = newOpp.Property_Zip_Postal_Code__c);                            
                          
                          CreateAssets.add(ast);
                          AssetMap.put(newOpp.Unique_Asset_Field__c,ast);
                            
                      }
                  }                 
             }                // For Loop 1 - End 

             if(!CreateAssets.isEmpty())      
                 Insert CreateAssets;
             //*************************************************************************************//
                    
             for(Opportunity newOpp: newOpportunities) {
                   if (newOpp.RecordTypeId!=label.Parent_Opportunity) {
                       //newOpp.Asset__c = AssetMap.get(newOpp.Unique_Asset_Field__c).Id;
                       newOpp.Asset__c = (newOpp.RecordTypeId == Label.Residential_Oppty_RT && newOpp.Asset__c == null) ? newOpp.Asset__c : AssetMap.get(newOpp.Unique_Asset_Field__c).Id;
                       newOpp.Property_Street__c          = AssetMap.get(newOpp.Unique_Asset_Field__c).Property_Street__c;
                       newOpp.Property_City__c            = AssetMap.get(newOpp.Unique_Asset_Field__c).Property_City__c;
                       newOpp.Property_State__c           = AssetMap.get(newOpp.Unique_Asset_Field__c).Property_State__c;
                       newOpp.Property_Zip_Postal_Code__c = AssetMap.get(newOpp.Unique_Asset_Field__c).Property_Zip_Postal_Code__c;  
                       newOpp.Occupancy__c                = AssetMap.get(newOpp.Unique_Asset_Field__c).Occupancy_Status__c; 
                       newOpp.Square_Feet__c              = AssetMap.get(newOpp.Unique_Asset_Field__c).Home_Square_Footage__c;
                       newOpp.Bedrooms__c                 = AssetMap.get(newOpp.Unique_Asset_Field__c).Bedrooms__c;
                       newOpp.Baths__c                    = AssetMap.get(newOpp.Unique_Asset_Field__c).Baths__c;
                       newOpp.Property_Type__c            = AssetMap.get(newOpp.Unique_Asset_Field__c).Property_Type__c;     
                       newOpp.Latest_Opportunity__c = True;
                       if(newOpp.Parent_Opportunity__c!=null) {
                           newOpp.RecordTypeId = Label.Commercial_Opportunity_Rectype_Id;
                       }
                       /*
                       if(newOpp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id) {
                           newOpp.StageName= Label.Opportunity_Stage3; //'Stage 4. Pre-Auction';                       
                       }
                       */
                   }
                   else {
                       User OppOwnerManager = UserUtil.getUser(newOpp.OwnerId);                    
                       if(OppOwnerManager!=null) {
                           if(OppOwnerManager.ManagerId!=null) {                           
                               newOpp.Split_Owner_Regional_Manager__c = OppOwnerManager.ManagerId;
                           }
                       }
                   }                   
              }               
      } 
      //***************************************************************************************//
      
    
    Public Void CreateAOAfromOpp(Map<Id, Opportunity> newOpportunities, Map<Id,Opportunity> oldOpportunities, Boolean isInsert, Boolean isUpdate) {
    
        Set<Id> oppSet = new Set<Id>();
        Set<Id> oppAuctionSet = new Set<Id>();
        List<Opportunity> selectedOpps = new List<Opportunity>();

        for(Opportunity opp : newOpportunities.values()) {
            if(opp.Initial_Auction__c!=null && (opp.RecordTypeId == Label.Short_Sale_Opp_Rectype_Id || opp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id)) {
                oppSet.add(opp.Id);
                oppAuctionSet.add(opp.Initial_Auction__c);
                selectedOpps.add(opp);
            }
        } 
        system.debug('Selected AOAs-oppSet : ' +oppSet);
        system.debug('Selected AOAs-oppAuctionSet : ' +oppAuctionSet);
        List<Auction_Opportunity_Assignment__c> oppinaoa = [SELECT Id,Name,Opportunity__c,Auction_Campaign__c from Auction_Opportunity_Assignment__c WHERE Opportunity__c IN:oppSet AND Auction_Campaign__c IN:oppAuctionSet];    
        Set<String> existingOppAuction = new Set<String>();
        for(Auction_Opportunity_Assignment__c aoa : oppinaoa ) {
            existingOppAuction.add(String.valueof(aoa.Opportunity__c)+String.valueof(aoa.Auction_Campaign__c));
        }
 
        List<Auction_Opportunity_Assignment__c> aoalist = new List<Auction_Opportunity_Assignment__c>();
        for(Opportunity opp:selectedOpps) { 
            if(!existingOppAuction.contains(String.valueof(opp.Id)+String.valueof(opp.Initial_Auction__c))) {
                if(opp.RecordTypeId == Label.Short_Sale_Opp_Rectype_Id) {
                    aoalist.add(new Auction_Opportunity_Assignment__c(Opportunity__c=opp.Id, Auction_Campaign__c=opp.Initial_Auction__c, Assets__c=opp.Asset__c, Company_Code__c=opp.Servicer1__c,User_Created_AOA__c=TRUE));                          
                }
                if(opp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id){    
                    aoalist.add(new Auction_Opportunity_Assignment__c(Opportunity__c=opp.Id, Auction_Campaign__c=opp.Initial_Auction__c, Assets__c=opp.Asset__c, Status__c='Auction',User_Created_AOA__c=TRUE));                          
                }
           }         
        }
        system.debug('Selected AOAs-2 : ' +aoaList);
        if(!aoalist.isEmpty())
            Insert aoalist;
    
    }  


  public void CreateOppTeamAndOppSplit(Map<Id,Opportunity> newOppMap, Boolean isInsert) {
      Map<Id,List<Opportunity>> parentOppMap = new Map<Id,List<Opportunity>>();
      Map<Id,Id> OppTeamMemberMap = new Map<Id,Id>();
      for(Opportunity opp : newOppMap.values()) {
          //Add Opporutunity Owner's Manager as Opportunity Team Member with Regional Manager as Role. 
          OppTeamMemberMap.put(Opp.Id,opp.OwnerId);
          if(parentOppMap.containsKey(opp.Parent_Opportunity__c)) {
              List<Opportunity> OppIds = parentOppMap.get(opp.Parent_Opportunity__c);
              OppIds.add(Opp);
              parentOppMap.put(opp.Parent_Opportunity__c, OppIds);
          } 
          else {
            parentOppMap.put(opp.Parent_Opportunity__c, new List<Opportunity> { Opp });
          }    
      }
      
      //Calculate Total Revenue Amount for Parent Opportunity based on Commercial Child Opportunities
          AggregateResult[] groupedResults = [SELECT Parent_Opportunity__c,SUM(Amount), SUM(Winning_Bid_Amount__c) wba FROM Opportunity WHERE Parent_Opportunity__c != null AND Parent_Opportunity__c IN :parentOppMap.KeySet() GROUP BY Parent_Opportunity__c];      

          system.debug('groupedResults  : ' +groupedResults);
          List<Opportunity> parentOppList = new List<Opportunity>();
          for (AggregateResult ar : groupedResults)  {          
              System.debug('Parent ID' + ar.get('Parent_Opportunity__c'));
              System.debug('Revenue Amount' + ar.get('expr0'));
              parentOppList.add(new Opportunity(Id = String.valueof(ar.get('Parent_Opportunity__c')), Sum_of_Child_Opp_Revenue__c = double.valueof(ar.get('expr0')),Winning_Bid_Amount__c = double.valueof(ar.get('wba'))));                  
          }
          
          if(!parentOppList.isEmpty()) {  
              try {  
                  Update parentOppList;    
                  system.debug('Opp List = ' +parentOppList);            
              } catch (dmlexception e) {
                  system.debug('DML Exception ' +e);
              }
          }  
          CreateoppTeam(OppTeamMemberMap);
    }

    // Add Opportunity Team Member 
    //@future
    public static void CreateoppTeam(Map<Id,Id> OppTeamMemberMap) {
          List<OpportunityTeamMember> OptyTeamMembers = new  List<OpportunityTeamMember>([SELECT Id,TeamMemberRole,OpportunityId,Opportunity.Owner.Lego_ID_18__c,UserId FROM OpportunityTeamMember WHERE OpportunityId IN :OppTeamMemberMap.KeySet()]); 

          Set<String> existingTeamMembers = new Set<String>();
          Set<Id> existingLegoTeams = new Set<Id>();

          for(OpportunityTeamMember otm : OptyTeamMembers) {          
              existingTeamMembers.add(String.Valueof(otm.OpportunityId)+String.Valueof(otm.UserId));
              existingLegoTeams.add(otm.Opportunity.Owner.Lego_ID_18__c);
          }

          Map<Id,Set<Id>> LegoUsersMap = new Map<Id,Set<Id>>(UserUtil.getLegoAllTeamMembers(existingLegoTeams));

          List<OpportunityTeamMember> newOppTeamMembers = new  List<OpportunityTeamMember>(); 
          for(OpportunityTeamMember otm : OptyTeamMembers) {          
               if(otm.Opportunity.Owner.Lego_ID_18__c!=null) {
                  for(Id UserId : LegoUsersMap.get(otm.Opportunity.Owner.Lego_ID_18__c)) {
                      if(!existingTeamMembers.contains(String.Valueof(otm.OpportunityId)+String.Valueof(UserId))) {
                          User LegoMember = UserUtil.getUser(OppTeamMemberMap.get(otm.OpportunityId));                    
                          OpportunityTeamMember newotm = new OpportunityTeamMember();
                          newotm.OpportunityId = otm.OpportunityId;         
                          newotm.UserId = UserId;
                          newotm.TeamMemberRole = Label.Opportunity_Owner_Manager_Role;
                          newotm.Team_Member_Area__c= LegoMember.Area__c;
                          newOppTeamMembers.add(newotm);
                          existingTeamMembers.add(String.Valueof(otm.OpportunityId)+String.Valueof(UserId));
                      }
                  }
              }
          }
                               
            Database.SaveResult[] srList = Database.Insert(newOppTeamMembers,false);
            /*
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted TM. Team ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
             */    
    }  
   // When child opp of Commercial Record Type is created from Lead change the parent opp id on valuation to child opp 
      public void UpdateParentOpptoChildonValuation(Map<Id,Opportunity> newOppsMap) {
      
       Map<String, Opportunity> OppsMap = new Map<String, Opportunity>();   
       Set<Id> parentopp = new Set<Id>();
       Set<Id> oppAsset = new Set<Id>();
       List<Valuation__c> createCREValuations = new List <Valuation__c>();
          
        for(Opportunity newOpp : newOppsMap.values()) {                    
           if(newOpp.Created_From_Lead__c == 1 && newOpp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && newOpp.Parent_Opportunity__c != null && newOpp.Asset__c != null){                         
                 OppsMap.put(newOpp.Parent_Opp_Asset_unique_Key__c, newOpp);
                 parentopp.add(newOpp.Parent_Opportunity__c);
                 oppAsset.add(newOpp.Asset__c);             
              }
         }
                 
          List<Valuation__c> VALList = new List<Valuation__c>();         
          VALList = [Select Id,Parent_Opp_Asset_unique_Key__c,Opportunity__c from Valuation__c where Opportunity__c IN :parentopp AND Asset__c IN :oppAsset AND Opportunity__c != null AND Asset__c != null];         
          List<Valuation__c> updateval = new List<Valuation__c>();
          
       if(!VALList.isEmpty()){   
              for(Valuation__c val: VALList){              
                         if(OppsMap.ContainsKey(val.Parent_Opp_Asset_unique_Key__c)){ 
                                 val.Opportunity__c = OppsMap.get(val.Parent_Opp_Asset_unique_Key__c).Id;
                          }                                  
                          updateval.add(val);                  
                 }                         
                      if(!updateval.isEmpty()){
                          Update updateval;
                         } 
        }                        
        if(VALList.size() == 0) {
             for(Opportunity newOpp : newOppsMap.values()) {
                   if(newOpp.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id) {
                                  createCREValuations.add(new Valuation__c(Opportunity__c = newOpp.Id,Asset__c=newOpp.Asset__c,Value_REDC_Date__c=newOpp.Value_REDC_Date__c,Value_Seller_Date__c=newOpp.Value_Seller_Date__c,
                                                                        Value_REDC_High__c = newOpp.Value_REDC_High__c,Value_REDC_Low__c = newOpp.Value_REDC_Low__c,Value_REDC_Mod__c = newOpp.Value_REDC_Mod__c,
                                                                        Value_Seller_High__c = newOpp.Value_Seller_High__c,Value_Seller_Low__c = newOpp.Value_Seller_Low__c,Value_Seller_Mod__c=newOpp.Value_Seller_Mod__c
                                                                        ));
                  }
              }
                  if(!createCREValuations.isEmpty()){
                      Insert createCREValuations;  
                    }           
          } 
          
                                   
      
 }
 // Update Number of child opps on Parent 
  public void ChildOppRollUpCountOnParent(Map<Id,Opportunity> newChildMap, Map<Id,Opportunity> oldOppsMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
  
  Set<Id> ParentOppIds = new Set<Id>();  
        if(isDelete){  
                for (Opportunity opps: oldOppsMap.Values()) {
                        if(opps.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && opps.Parent_Opportunity__c != null) {       
                            ParentOppIds.add(opps.Parent_Opportunity__c);  
                          }  
                    }        
          }   
        if(isUpdate){
               for (Opportunity opps: oldOppsMap.Values()) {
                        if(opps.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && opps.Parent_Opportunity__c != null && oldOppsMap.get(opps.Id).Parent_Opportunity__c != newChildMap.get(opps.Id).Parent_Opportunity__c) {       
                            ParentOppIds.add(opps.Parent_Opportunity__c);  
                          }  
                    }  
         } 
        if(isInsert){
               for (Opportunity opps: newChildMap.Values()) {  
                      if(opps.RecordTypeId == Label.Commercial_Opportunity_Rectype_Id && opps.Parent_Opportunity__c != null) {          
                            ParentOppIds.add(opps.Parent_Opportunity__c);  
                          }  
                   } 
         }             
        
        List<Opportunity> countChildOppsList = [SELECT Id,(SELECT Id,CreatedDate FROM Opportunities__r) FROM Opportunity WHERE Id IN :ParentOppIds];       
        List<Opportunity> UpdateParentOpp = new List<Opportunity>();
     
        if(!countChildOppsList.isEmpty()){      
                for(Opportunity ParentOpps: countChildOppsList)   {                
                            List<Opportunity> relatedRecords = ParentOpps.getSObjects('Opportunities__r');
                            if(relatedRecords!=null) {                
                                 ParentOpps.Number_of_Child_Opportunities__c = relatedRecords.size();                    
                              }  
                            else {
                                 ParentOpps.Number_of_Child_Opportunities__c = 0;
                              }  
                      UpdateParentOpp.add(ParentOpps);              
                }
           }     
               
                     try{
                         if(!UpdateParentOpp.IsEmpty()){
                              update UpdateParentOpp;
                            } 
                       System.Debug('Update successful on Opportunity');
                       }
                    catch (Exception e){
                       for (Opportunity opp: newChildMap.values()) {                   
                            // opp.addError('Could not update Parent Opportunity due to custom Validation rules' + ' DETAIL: '+e.getMessage());
                            opp.addError('You cannot save your changes on this Child Opportunity due to '+' "'+opp.StageName+'"'+' custom validation rules on the Parent Opportunity. Please contact the BD or BD Associate to update the missing fields on the Parent Opportunity.');
                       }
                     }  
  }



}