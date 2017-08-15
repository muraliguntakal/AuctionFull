public class OpportunityCreateValuationValidator {
    
    Map<String, String> oppsToAssets;
    RecordType trusteeRT;

    public OpportunityCreateValuationValidator() {
        oppsToAssets = new Map<String, String> ();
        trusteeRT = [SELECT Id FROM RecordType WHERE Name = 'Trustee' AND SobjectType = 'Opportunity' Limit 1];
    }

    public void preValidate(Opportunity opp, Opportunity oldOpp){
        String oppId = (String)opp.get('Id');
        String assetId = (String)opp.get('Asset__c');
        String oldAssetId = (!Trigger.isInsert) ? (String)oldOpp.get('Asset__c') : null;        
        String sellerCode = (String)opp.get('MLH_Seller_Code__c');
        String oldSellerCode = (!Trigger.isInsert) ? (String)oldOpp.get('MLH_Seller_Code__c') : null;
        String pool = (String)opp.get('MLH_Pool_Number__c');
        String oldPool = (!Trigger.isInsert) ? (String)oldOpp.get('MLH_Pool_Number__c') : null;
        Date startDate = (Date)opp.get('MLH_Bid_Start_Date__c');
        Date oldStartDate = (!Trigger.isInsert) ? (Date)oldOpp.get('MLH_Bid_Start_Date__c') : null;
        String status = (String)opp.get('Auction_Status__c');
        String oldStatus = (!Trigger.isInsert) ? (String)oldOpp.get('Auction_Status__c') : null;
        Boolean testEvent = (Boolean)opp.get('Auction_Test_Event__c');
        String rtId = (String)opp.get('RecordTypeId');

        System.debug(opp);
        
        if(!testEvent && assetId != null && rtId == trusteeRT.Id && status == 'Auction' && ((sellerCode != null && !Photo_Seller_Code_Exclusions__c.getAll().keySet().contains(sellerCode)) || (pool != null && !Photo_Seller_Code_Exclusions__c.getAll().keySet().contains(pool))) && startDate >= System.today()){
            if( (assetId != oldAssetId) || (sellerCode != oldSellerCode) || (pool != oldPool) || (startDate != oldStartDate) || (status != oldStatus) ){
                oppsToAssets.put(oppId, assetId);
            }           
        }
    }

    public void validate(){
        if(!oppsToAssets.isEmpty()){
            System.debug('Trigger execution Insert? ' + Trigger.isInsert +'Trigger execution Update? '+ Trigger.isUpdate);
            OpportunityCreateValuationValidator.createValuationRecords(oppsToAssets);           
        }
    }

    @Future
    public static void createValuationRecords(Map<String, String> oppsToAssets){

        List<Valuation__c> valuations = new List<Valuation__c>();
        Set<String> valAssetIds = new Set<String> ();
        Set<String> assetIds = new Set<String> ();
        assetIds.addAll(oppsToAssets.values());     

        valuations  = (List<Valuation__c>)database.query('SELECT Id, Asset__c FROM Valuation__c WHERE Asset__c IN :assetIds AND (Order_Status_BPO__c = \'Received\' OR Order_Status_BPO__c = \'Completed\' OR Order_Status_BPO__c = \'Awaiting Corrections\' OR Order_Status_BPO__c = \'Review\' OR Order_Status_BPO__c = \'Requested\' OR Order_Status_BPO__c = \'Ordered\') AND (X3rd_Party_BPO_Value__c!=null OR Completed_Date_BPO__c!=null OR Order_Received_Date__c!=null OR Order_Requested_Date__c!=null)');
        if(!valuations.isEmpty()){
            for(Valuation__c val : valuations){
                String assetId = (String)val.get('Asset__c');
                valAssetIds.add(assetId);
            }
        }

        List<Valuation__c> valuationsForInsert = new List<Valuation__c> ();

        for(String oppId : oppsToAssets.keySet()){
            String assetId = oppsToAssets.get(oppId);
            if(!valAssetIds.contains(assetId)){
                Valuation__c val = new Valuation__c();
                val.put('Asset__c', assetId);
                val.put('Opportunity__c', oppId);

                valuationsForInsert.add(val);
            }
        }

        if(!valuationsForInsert.isEmpty()){
            try{
                System.debug('Vals created On Insert?');
                insert valuationsForInsert;
            }catch(Exception e){
                //exception logic
            }
        }
    }
}