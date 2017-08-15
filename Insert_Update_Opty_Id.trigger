trigger Insert_Update_Opty_Id on Auction_Opportunity_Assignment__c (before insert) {
/*

  //if(TriggerSettings__c.getValues('InsertUpdateOptyId').Status__c){ 
   TriggerSettings__c ts = TriggerSettings__c.getValues('InsertUpdateOptyId');
   if (ts != null && ts.Status__c) {
      // Set for Asset ids
      Set<ID> assetSet=new Set<ID>();
      Set<String> gpropidSet=new Set<String>();
  
      List<Auction_Opportunity_Assignment__c> aoaListwithNoOpp = new List<Auction_Opportunity_Assignment__c>();
  
      for(Auction_Opportunity_Assignment__c  aoa:Trigger.New){

        if(aoa.MLH_Auction_ID__c!=null  && aoa.MLH_Property_Id__c!=null) {
          aoa.MLH_AuctionID_MLH_AssetID__c=aoa.MLH_Auction_ID__c+aoa.MLH_Property_Id__c;
        }  
        if(aoa.Opportunity__c == null && aoa.Line_of_Business__c != 'Residential') {
          assetSet.add(aoa.Assets__c);
          aoaListwithNoOpp.add(aoa);  
          system.debug('Current Opportunity Id : ' +aoa.Opportunity__c);   
        }  
        if(aoa.MLH_Global_Property_ID__c!=null) {            
          gpropidSet.add(aoa.MLH_Global_Property_ID__c);
        } 
      }
  
      Map<String, Asset__c> AssetaddMap = new Map<String, Asset__c>();
  
  //********************** Murali - Start
      for(Asset__c ca : [SELECT Id, MLH_Global_Property_ID__c,Property_Street__c,Property_City__c,Property_State__c,Property_Zip_Postal_Code__c,Occupancy_Status__c,Home_Square_Footage__c,Bedrooms__c,Baths__c,Property_Type__c  
                 FROM Asset__c 
                         WHERE MLH_Global_Property_ID__c 
                         IN :gpropidSet AND MLH_Global_Property_ID__c!=null]) {
          AssetaddMap.put(ca.MLH_Global_Property_ID__c, ca);    
        system.debug('assetSet# '+AssetaddMap);
      }
  //********************** Murali - End
  
      Map<String, Opportunity> newOppMap = new Map<String, Opportunity>();
      for (Auction_Opportunity_Assignment__c  aoa : aoaListwithNoOpp ) {   
            Opportunity opty=new Opportunity();
            opty.Name='Dummy Opp';
            opty.StageName ='Stage 2. Opportunity Development';
            opty.CloseDate=system.today();
            if (Opportunity_Product_Type_Mapping__c.getValues(aoa.MLH_Product_Type__c)!=null)
                opty.RecordTypeID=Opportunity_Product_Type_Mapping__c.getValues(aoa.MLH_Product_Type__c).RecordTypeId__c;
          
            // Populate Property Address on the Opportunity; Map MLH Auction-Asset Id fields to create opportunity for each AOA.   
            if(AssetaddMap.get(aoa.MLH_Global_Property_Id__c)!=null) {
               opty.Property_Street__c=AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Property_Street__c;
               opty.Property_City__c=AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Property_City__c;
               opty.Property_State__c=AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Property_State__c;
               opty.Property_Zip_Postal_Code__c=AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Property_Zip_Postal_Code__c;
               opty.Occupancy__c = AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Occupancy_Status__c; 
               opty.Square_Feet__c = AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Home_Square_Footage__c; 
                opty.Bedrooms__c = AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Bedrooms__c; 
               opty.Baths__c  = AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Baths__c ; 
               opty.Property_Type__c  = AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Property_Type__c ;                
               opty.Asset__c=AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Id;
            } 
  
  
            if(aoa.Auction_Campaign__c!=null) {
                opty.Auction__c=string.valueof(aoa.Auction_Campaign__c); 
            }    
            if(aoa.MLH_Loan_Number__c!=null){
                opty.Loan_Number__c = aoa.MLH_Loan_Number__c;
            }
            if(aoa.MLH_Seller_Code__c!=null){
                opty.MLH_Seller_Code__c = aoa.MLH_Seller_Code__c; 
            }
            else if(aoa.MLH_Pool_Number__c!=null)
            {
                opty.MLH_Pool_Number__c = aoa.MLH_Pool_Number__c.SubString(0,3); 
            }
            
            if(aoa.MLH_Product_Type__c == 'Trustee' || aoa.MLH_Product_Type__c == 'FCL Marketing'){
                opty.Auction_Status__c = aoa.Status__c;
                opty.MLH_Bid_Start_Date__c = aoa.Property_Auction_Date__c;
                opty.First_Last_Name_Homeowner__c = aoa.Trustor__c;    
                opty.MLH_Venue_ID__c = aoa.MLH_Venue_ID__c;    
                opty.Outsourcer_Code__c = aoa.MLH_Outsourcer_Code__c;       
                opty.Auction_Test_Event__c = aoa.Auction_Test_Event__c;    
            }
      
            newOppMap.put(aoa.MLH_AuctionID_MLH_AssetID__c,Opty);
       }  
  
       insert newOppMap.values();   
       system.debug(' New AOA Opportunities Map ' +newOppMap); 
       //Assign Dummy Opp to Auction_Opportunity_Assignment
       for(Auction_Opportunity_Assignment__c  aoa:Trigger.New) {
           if(aoa.Opportunity__c == null && aoa.Line_of_Business__c != 'Residential') {
              if(newOppMap.containsKey(aoa.MLH_AuctionID_MLH_AssetID__c) && newOppMap.get(aoa.MLH_AuctionID_MLH_AssetID__c) != null){
                aoa.Opportunity__c=newOppMap.get(aoa.MLH_AuctionID_MLH_AssetID__c).Id;  
              }
           } 
  
          //Populate Asset field on AOA based using Asset Map
          if(AssetaddMap.containsKey(aoa.MLH_Global_Property_Id__c)){
            if(AssetaddMap.get(aoa.MLH_Global_Property_Id__c)!=null){
              aoa.Assets__c = AssetaddMap.get(aoa.MLH_Global_Property_Id__c).Id;
            }
          }
          //************* Murali - End      
      }
      
      
          //Create Trustee Valuation  
      OpportunityTriggerHelper oct = new OpportunityTriggerHelper();
      oct.Create_Trustee_Valuation(newOppMap.values());  

      
      //Ganesh Vinnakota - Checking the Most Recent Auction Flag to True
      if(Trigger.isInsert && Trigger.isBefore) {
          set <id> OpportunityIDSet= new set<id>();
          for(Auction_Opportunity_Assignment__c aoa : trigger.new) { 
             if(aoa.MLH_Product_Type__c != 'Trustee' && aoa.MLH_Product_Type__c != 'FCL Marketing')
                {
                  if(!OpportunityIDSet.contains(aoa.Opportunity__c)) {
                      aoa.Most_Recent_AOA__c= true;
                      OpportunityIDSet.add(aoa.Opportunity__c);
                  }
                }
          }
      }   
  }
*/
}