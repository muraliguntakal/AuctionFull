global class AOAMostRecentUpdatesJob implements Queueable {


    global void execute(QueueableContext bc) {      
        Map<String, Opportunity> oppsForUpsert = new Map<String, Opportunity> ();
        Map<String, Asset__c> assetsForUpdate = new Map<String, Asset__c> ();
        Map<String, Auction_Opportunity_Assignment__c> aoasForUpdate = new Map<String, Auction_Opportunity_Assignment__c> ();

        /*
        *   Collect AOA, Opportunity, and Property Ids to query asset details and AOA history from the Opportunity as well
        */

        Set<String> aoaIds = new Set<String> ();
        Set<String> oppIds = new Set<String> ();
        Set<String> propIds = new Set<String> ();

        //List<Auction_Opportunity_Assignment__c> scope = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Opportunity__c, Assets__c, MLH_Global_Property_Id__c, Status__c, Most_Recent_AOA__c, Line_Of_Business__c, MLH_Loan_Number__c, Auction_Campaign__c, MLH_Seller_Code__c, MLH_Outsourcer_Code__c, MLH_Pool_Number__c, MLH_Product_Type__c, Property_Auction_Date__c, Trustor__c, MLH_Venue_ID__c, Auction_Test_Event__c, MLH_File_Received_Date__c, Seller_Name__c FROM Auction_Opportunity_Assignment__c WHERE (Requires_Processing__c = TRUE AND Most_Recent_AOA__c = FALSE) OR (Status__c = \'Deleted\' AND Most_Recent_AOA__c = TRUE) ORDER BY MLH_Global_Property_Id__c, CreatedDate DESC LIMIT 3000');
        List<Auction_Opportunity_Assignment__c> scope = (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Opportunity__c, Assets__c, MLH_Global_Property_Id__c, Status__c, Most_Recent_AOA__c, Line_Of_Business__c, MLH_Loan_Number__c, Auction_Campaign__c, MLH_Seller_Code__c, MLH_Outsourcer_Code__c, MLH_Pool_Number__c, MLH_Product_Type__c, Property_Auction_Date__c, Trustor__c, MLH_Venue_ID__c, Auction_Test_Event__c, MLH_File_Received_Date__c, Seller_Name__c FROM Auction_Opportunity_Assignment__c WHERE Requires_Processing__c = TRUE AND LastModifiedDate = Last_N_Days:2 AND Opportunity__r.Initial_Auction__r.Test_Event_Flag__c=FALSE ORDER BY MLH_Global_Property_Id__c, CreatedDate DESC LIMIT 500');
          
        if(!scope.isEmpty()){
            for(Auction_Opportunity_Assignment__c aoa : scope) {
                aoaIds.add(aoa.Id);

                if((String)aoa.get('Opportunity__c') != null) {
                    oppIds.add((String)aoa.get('Opportunity__c'));
                }

                if((String)aoa.get('MLH_Global_Property_Id__c') != null){
                    propIds.add((String)aoa.get('MLH_Global_Property_Id__c'));
                }
            }       

            //query parent opportunities and 2 most recent AOAs
            Map<String, Opportunity> auctionHistory = new Map<String, Opportunity> ();
            if(!oppIds.isEmpty()){
                auctionHistory = getAuctionHistory(oppIds);
            }
            
            //group parent assets by property id
            Map<String, Asset__c> assetsByPropId = new Map<String, Asset__c> ();
            if(!propIds.isEmpty()){
                assetsByPropId = getAssetsByPropId(propIds);
            }

            /*
            *   OPPORTUNITY + ASSET UPDATES
            *   Loop through scoped AOAs, if Opportunity is missing stage a new record for insert.
            *   If the Opportunity and Asset is not missing update the Most Recent Auction information on both records
            */

            for(Auction_Opportunity_Assignment__c aoa : scope) {

                String aoaId = (String)aoa.get('Id');
                String oppId = (String)aoa.get('Opportunity__c');              
                String propId = (String)aoa.get('MLH_Global_Property_Id__c');
                String line = (String)aoa.get('Line_Of_Business__c');
                String sellerName = (String)aoa.get('Seller_Name__c');
                Asset__c asset = (assetsByPropId.containsKey(propId)) ? assetsByPropId.get(propId) : null;
              if(aoa.Line_of_Business__c != 'Commercial'){
                    //stage a blank opportunity and populate information once asset details have been queried
                    if(oppId == null && (sellerName == NULL || (sellerName != NULL && !sellerName.contains('CWCOT')))) {
                        Opportunity newOpp = stageOpportunity(aoa, asset);
                        oppsForUpsert.put(aoaId, newOpp);
                    }
               } 

                //set the most recent fields on Opportunity and Asset
                if(oppId != null && auctionHistory.containsKey(oppId)){
                    Opportunity opp = auctionHistory.get(oppId);

                    if(opp.Auction_Opportunity_Assignments__r != null && opp.Auction_Opportunity_Assignments__r.size() > 0){
                        Auction_Opportunity_Assignment__c mostRecentAOA = opp.Auction_Opportunity_Assignments__r[0];                                            
                        opp.put('Most_Recent_Auction__c', (String)mostRecentAOA.get('Auction_Campaign__c'));
                        opp.put('Auction_Opportunity_Assignment__c', (String)mostRecentAOA.get('Id'));

                        if((String)mostRecentAOA.get('MLH_Seller_Code__c') != null){
                            opp.put('MLH_Seller_Code__c', (String)mostRecentAOA.get('MLH_Seller_Code__c'));
                        }

                        if((String)mostRecentAOA.get('MLH_Outsourcer_Code__c') != null){
                            opp.put('Outsourcer__c', (String)mostRecentAOA.get('MLH_Outsourcer_Code__c'));
                        }
                        
                        opp.put('Winning_BidLookup__c', null);
                        opp.put('Winning_Bid_Amount__c', null);
                        opp.put('Winning_Bid_AOA__c', null);
                        opp.put('Winning_Bidder_Email__c', null);
                        opp.put('Winning_Bidder_First_Name__c', null);
                        opp.put('Winning_Bidder_Last_Name__c', null);

                        if(asset != null){
                            asset.put('Most_Recent_AOA__c', (String)mostRecentAOA.get('Id'));
                        }

                        if(opp.Auction_Opportunity_Assignments__r.size() > 1){                          
                            opp.put('Next_Most_Recent_Auction__c', (String)opp.Auction_Opportunity_Assignments__r[1].get('Auction_Campaign__c'));

                            if(asset != null){
                                asset.put('Next_Most_Recent_AOA__c', (String)opp.Auction_Opportunity_Assignments__r[1].Id);
                            }
                        }

                        oppsForUpsert.put(oppId, opp);

                        if(asset != null){
                            assetsForUpdate.put(asset.Id, asset);
                        }
                    }
                }
            }

            if(!oppsForUpsert.isEmpty()){
                upsert oppsForUpsert.values();
            }

            if(!assetsForUpdate.isEmpty()){
                update assetsForUpdate.values();
            }

            /*
            *   AOA UPDATES
            *   Query all historical AOAs attached to the Opportunity that are flagged as most recent and set them to false
            *   Loop through scoped AOAs and set the most recent AOA flag as well as the Asset and Opportunity lookup if necessary.
            */

            //query past most recent aoas and set the most recent flag to false
            Map<String, Auction_Opportunity_Assignment__c> previousMostRecentAOAs = getRecentAOAs(aoaIds, oppIds);
            aoasForUpdate.putAll(previousMostRecentAOAs);

            //
            for(Auction_Opportunity_Assignment__c aoa : scope){
                String status = (String)aoa.get('Status__c');               
                Opportunity opp = (oppsForUpsert.containsKey((String)aoa.get('Id'))) ? oppsForUpsert.get((String)aoa.get('Id')) : oppsForUpsert.get((String)aoa.get('Opportunity__c'));

                if(opp != null){
                    if(status == 'Deleted'){
                        aoa.put('Most_Recent_AOA__c', false);
                        String newMostRecentAOAID = (String)opp.get('Auction_Opportunity_Assignment__c');
                        Auction_Opportunity_Assignment__c newMostRecentAOA = (aoasForUpdate.containsKey(newMostRecentAOAID)) ? aoasForUpdate.get(newMostRecentAOAID) : new Auction_Opportunity_Assignment__c( Id = newMostRecentAOAID );
                        newMostRecentAOA.put('Most_Recent_AOA__c', true);
                        aoasForUpdate.put(newMostRecentAOAID, newMostRecentAOA);

                    }else{
                        String assetId = assetsByPropId.containsKey((String)aoa.get('MLH_Global_Property_Id__c')) ? assetsByPropId.get((String)aoa.get('MLH_Global_Property_Id__c')).Id : null;
                        if(assetId != null){
                            aoa.put('Assets__c', assetId);
                        }

                        aoa.put('Opportunity__c', opp.Id);

                        if((String)opp.get('Auction_Opportunity_Assignment__c') == (String)aoa.get('Id')){
                            aoa.put('Most_Recent_AOA__c', true);                        
                        }
                    }
                }

                aoa.put('Requires_Processing__c', false);
                aoasForUpdate.put((String)aoa.get('Id'), aoa);
            }
        
            if(!aoasForUpdate.isEmpty()){
                update aoasForUpdate.values();
            }

            if(!Test.isRunningTest()){
                String jobId = System.enqueueJob(new AOAMostRecentUpdatesJob());

                SystemSettings__c ss = SystemSettings__c.getAll().get('MostRecentAOAJobId');
                ss.Value__c = jobId;
                update ss;
            }
        }
    }

    /**
        UTIL CLASSES
    */


    /*
    *   Query parent Opportunities and the 2 most recent AOAs that do not have a status of Deleted
    */

    public Map<String, Opportunity> getAuctionHistory(Set<String> oppIds){

        Map<String, Opportunity> oppMap = new Map<String, Opportunity> ();
        if(!oppIds.isEmpty()){
            for(Opportunity opp : (List<Opportunity>)database.query('SELECT Id, Most_Recent_Auction__c, Next_Most_Recent_Auction__c, Auction_Opportunity_Assignment__c, (SELECT Id, Assets__c, Status__c, Auction_Campaign__c, MLH_Seller_Code__c, MLH_Outsourcer_Code__c, Most_Recent_AOA__c FROM Auction_Opportunity_Assignments__r WHERE Auction_Campaign__c != null AND Status__c != \'Deleted\' ORDER BY CreatedDate DESC LIMIT 2) FROM Opportunity WHERE Id IN : oppIds')){
                oppMap.put((String)opp.get('Id'), opp);
            }
        }

        return oppMap;
    }

    /*
    *   Query all Assets matching the property ids on the AOAs and group the list by the Global Property Id
    */

    public static Map<String, Asset__c> getAssetsByPropId(Set<String> propIds){
        Map<String, Asset__c> assetMap = new Map<String, Asset__c> ();

        for(Asset__c asset : (List<Asset__c>)database.query('SELECT Id, MLH_Global_Property_ID__c,Property_Street__c,Property_City__c,Property_State__c,Property_Zip_Postal_Code__c,Occupancy_Status__c,Home_Square_Footage__c,Bedrooms__c,Baths__c,Property_Type__c,Occupancy__c FROM Asset__c WHERE MLH_Global_Property_ID__c IN : propIds')){
            String propId = (String)asset.get('MLH_Global_Property_ID__c');
            assetMap.put(propId, asset);
        }

        return assetMap;
    }

    /*
    *   Query all previous AOAs that have the most recent AOA set to TRUE so they can be flagged to false
    */

    public Map<String, Auction_Opportunity_Assignment__c> getRecentAOAs(Set<String> aoaIds, Set<String> oppIds){
        Map<String, Auction_Opportunity_Assignment__c> aoas = new Map<String, Auction_Opportunity_Assignment__c> ();

        if(!aoaIds.isEmpty() && !oppIds.isEmpty()){
            for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query('SELECT Id, Opportunity__c FROM Auction_Opportunity_Assignment__c WHERE Most_Recent_AOA__c = TRUE AND Opportunity__c IN : oppIds AND Id NOT IN : aoaIds')){
                aoa.put('Most_Recent_AOA__c', false);
                aoas.put((String)aoa.get('Id'), aoa);
            }
        }

        return aoas;
    }

    /*
    *   For new AOAs missing an Opportunity lookup stage a new Opportunity with details from the AOA and Asset
    */

    public Opportunity stageOpportunity(Auction_Opportunity_Assignment__c aoa, Asset__c asset){
        Opportunity opp = new Opportunity ();
        opp.put('Name','Dummy Opp');
        opp.put('StageName','Stage 2. Opportunity Development');
        opp.put('CloseDate',System.today());                    
        opp.put('Most_Recent_Auction__c', (String)aoa.get('Auction_Campaign__c'));
        opp.put('Loan_Number__c', (String)aoa.get('MLH_Loan_Number__c'));       
        opp.put('Auction_Opportunity_Assignment__c', aoa.Id);
        opp.put('MLH_Seller_Code__c', (String)aoa.get('MLH_Seller_Code__c'));
        opp.put('Outsourcer__c', (String)aoa.get('MLH_Outsourcer_Code__c'));
        opp.put('Auction__c', (String)aoa.get('Auction_Campaign__c'));
        opp.put('MLH_Pool_Number__c', (String)aoa.get('MLH_Pool_Number__c'));
        opp.put('MLH_File_Received_Date__c', (Date)aoa.get('MLH_File_Received_Date__c'));

        if(asset != null){
            //opp.put('Occupancy__c',(String)asset.get('Occupancy__c'));
            opp.put('Square_Feet__c',(Decimal)asset.get('Home_Square_Footage__c'));
            opp.put('Bedrooms__c',(Decimal)asset.get('Bedrooms__c'));
            opp.put('Baths__c', (Decimal)asset.get('Baths__c'));
            opp.put('Property_Type__c', (String)asset.get('Property_Type__c'));
            opp.put('MLH_Seller_Name__c', (String)aoa.get('Seller_Name__c'));
            opp.put('Property_Street__c', (String)asset.get('Property_Street__c'));
            opp.put('Property_City__c', (String)asset.get('Property_City__c'));
            opp.put('Property_State__c', (String)asset.get('Property_State__c'));
            opp.put('Property_Zip_Postal_Code__c', (String)asset.get('Property_Zip_Postal_Code__c'));
            opp.put('Asset__c', asset.Id);
        }

        String productType = (String)aoa.get('MLH_Product_Type__c');
        if (Opportunity_Product_Type_Mapping__c.getValues(productType) !=null){
            opp.put('RecordTypeID', Opportunity_Product_Type_Mapping__c.getValues(productType).RecordTypeId__c);
        }

        if(productType == 'Trustee' || productType == 'FCL Marketing'){
            opp.put('Auction_Status__c', (String)aoa.get('Status__c'));
            opp.put('MLH_Bid_Start_Date__c', (Date)aoa.get('Property_Auction_Date__c'));
            opp.put('First_Last_Name_Homeowner__c', (String)aoa.get('Trustor__c'));
            opp.put('MLH_Venue_ID__c', (String)aoa.get('MLH_Venue_ID__c'));
            opp.put('Outsourcer_Code__c', (String)aoa.get('MLH_Outsourcer_Code__c'));
            opp.put('Auction_Test_Event__c', (Boolean)aoa.get('Auction_Test_Event__c')); 
        }

        return opp;
    }
    
}