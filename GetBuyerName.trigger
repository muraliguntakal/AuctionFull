trigger GetBuyerName on Offer__c (before Insert, before Update) {
//if(TriggerSettings__c.getValues('GetBuyerName').Status__c) { 
TriggerSettings__c ts = TriggerSettings__c.getValues('GetBuyerName');
if (ts != null && ts.Status__c) {


Map<String,Offer__c> offerMap = new Map<String,Offer__c>(); 
Set<Id> AOAId = new Set<Id>(); 

            for(Offer__c offr: Trigger.new)
            { 
                if(offr.Buyer__c == null && offr.Created_from_Bid__c == False)
                { 
                    if(offr.MLH_Bidder_ID__c != null){
                    offerMap.put(offr.MLH_Bidder_ID__c,offr); 
                    } 
                } 
                if(offr.Auction_Opportunity_Assignment__c != null){
                  AOAId.add(offr.Auction_Opportunity_Assignment__c);
                }  
            } 
        
        //Get Bid Registration Details
        List<Bidder_Registration__c> BidRegisList = new List<Bidder_Registration__c>();
        BidRegisList = [SELECT Id,MLH_Bidder_ID__c,Contact__c,MLH_Email__c,MLH_WorkPhone__c,MLH_Street_Address__c,MLH_City__c,MLH_State__c,MLH_ZipCode__c
        FROM Bidder_Registration__c WHERE MLH_Bidder_ID__c IN :offerMap.KeySet()]; 

         Map<String, Bidder_Registration__c> bidRegMap = new Map<String, Bidder_Registration__c>();   
            if(!BidRegisList.isEmpty()) { 
                for (Bidder_Registration__c bidreg: BidRegisList) { 
                    if(offerMap.ContainsKey(bidreg.MLH_Bidder_ID__c)){ 
                    bidRegMap.put(bidreg.MLH_Bidder_ID__c,bidreg); 
                    }
                }
            } 
        
        //Get AOA Details 
        List<Auction_Opportunity_Assignment__c> AOAList = new List<Auction_Opportunity_Assignment__c>();
        AOAList = [SELECT Id,Assets__c FROM Auction_Opportunity_Assignment__c WHERE Id IN :AOAId]; 

         Map<Id, Id> aoaMap = new Map<Id, Id>();   
            if(!AOAList.isEmpty()) { 
                for (Auction_Opportunity_Assignment__c aoa: AOAList) {
                     aoaMap.put(aoa.Id,aoa.Assets__c); 
                }
            } 


        for (Offer__c o: Trigger.new) { 
        
            if(bidRegmap.ContainsKey(o.MLH_Bidder_ID__c)){
                o.Buyer__c = bidRegmap.get(o.MLH_Bidder_ID__c).Contact__c;
                o.Buyer_Email__c = bidRegmap.get(o.MLH_Bidder_ID__c).MLH_Email__c;
                o.Buyer_Office_Phone__c = bidRegmap.get(o.MLH_Bidder_ID__c).MLH_WorkPhone__c;
                o.Buyer_Street_Address__c = bidRegmap.get(o.MLH_Bidder_ID__c).MLH_Street_Address__c;
                o.Buyer_City__c = bidRegmap.get(o.MLH_Bidder_ID__c).MLH_City__c;
                o.Buyer_State_Province__c = bidRegmap.get(o.MLH_Bidder_ID__c).MLH_State__c;
                o.Buyer_Postal_Zip__c = bidRegmap.get(o.MLH_Bidder_ID__c).MLH_ZipCode__c;
            }
            
            if(aoaMap.ContainsKey(o.Auction_Opportunity_Assignment__c)){
               o.Custom_Assets__c = aoaMap.get(o.Auction_Opportunity_Assignment__c);
            }
            
        }
  } 
}