public with sharing class MLHAuth {

    //Added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    private ApexPages.StandardSetController ListController {get; set;}

    //Add the instance for the variables being passed by id on the url
    public Id oppId{get;set;}
    public sObject obj{get;set;}
    public List<sObject> objList{get;set;}
    public Set<Id> objIds {
        get {
            if(objIds == null)
               objIds = new Set<Id>(); 
            return objIds;    
        }
        set;
    }

    public List<Webservice_log__c> wsList{
        get {
            if(wsList==null)
                wsList= new List<Webservice_log__c>();
            return wsList; 
        }
        set;
    }
    
    //Initialize the controller
    public MLHAuth(ApexPages.StandardSetController ListController) {
        //Initialize the stanrdard List controller
        this.ListController = ListController;

        // Get List of records selected from the list.        
        objList = (List<sObject>) ListController.getSelected();
        if(!objList.isEmpty())
            objIds = (new Map<Id,SObject>(objList)).keySet();
        else {        
            String GBString = apexPages.currentPage().getParameters().get('id');
            List<String> GBIds = null;
            if(GBString!=null ) {
                if(GBString.length() > 18) {
                   GBIds = GBString.split(',');   
                   for(String s : GBIds)
                       objIds.add(s);
                }
                else {
                    objIds.add(apexPages.currentPage().getParameters().get('id'));                
                }
            }           
        }
    }

    private List<Integration_Mapping__c> imList {
        get {
            if (imList == null) imList = [SELECT Third_Party_API_Name__c,Salesforce_Field_Label__c FROM Integration_Mapping__c WHERE Integration_Name__c = 'MLH'];
            return imList;
        }
        set;
    }

    private Map<String,String> imMap { 
        get {
            if (imMap == null) {
                imMap = new Map<String,String>();
                for( Integration_Mapping__c im : imList) {
                    system.debug(' IM => ' +im);
                    imMap.put(im.Third_Party_API_Name__c,im.Salesforce_Field_Label__c);                                                                
                 }
             }
            return imMap;
        }
        set;
    }        

    public PageReference SyncToMLH() {        
         integer successCount = 0;
         integer failCount = 0;    
         Map<Id,String> OppGPIdMap = new Map<Id,String>();
         List<Asset__c> UpsertAssetList = new List<Asset__c>();            
         List<Opportunity> SyncedOppList = new List<Opportunity>();            
         String success_status = null;
         String success_gpID = null;
         Boolean error = false;
         Boolean success = false;
         ApexPages.Message myMsg = null;
         wsList = new List<Webservice_Log__c>();
         
         //Upload Asset and get response using mlhAssetUploadResponse class
         mlhAssetUploadResponse mlhresp = MLHAPIv2.UploadListAsset(objIds);          
         system.debug('MLH Response => ' +mlhresp);

         if(mlhresp.Status.message != 'failed' && mlhresp.Status.message != 'failure') {
             system.debug('Message => ' +mlhresp.Status.message);   
             // Get Salesforce AssetIds        
             if(mlhresp.result!=null) {        
                 for (integer i = 0 ; i < mlhresp.result.size(); i++) {                                 
                     OppGPIdMap.put(mlhresp.result[i].salesforce_opportunity_id,String.valueof(mlhresp.result[i].global_asset_id)); 
                 }
             }
    
             Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>([SELECT Id, Type_of_Sale__c, Synced_To_MLH__c,Listing_ID__c,Asset__c FROM Opportunity WHERE Id IN : OppGPIdMap.KeySet()]);
             Set<Id> AssetIds = new Set<Id>();
    
             for(Opportunity opp : OppMap.values()) {
                 if(OppGPIdMap.containsKey(opp.Id)) {
                     if(!AssetIds.contains(opp.Asset__c) && opp.Asset__c!=null && opp.Type_of_Sale__c!='Offer Select') {
                         UpsertAssetList.add(new Asset__c(Id=opp.Asset__c,MLH_Global_Property_ID__c=OppGPIdMap.get(Opp.Id)));
                         AssetIds.add(opp.Asset__c);
                     }
                     else {
                         UpsertAssetList.add(new Asset__c(Id=opp.Asset__c,NAF_Global_Property_ID__c=OppGPIdMap.get(Opp.Id)));
                         AssetIds.add(opp.Asset__c);
                     }
                 }
             }
             
             if(mlhresp.result!=null) {
                 for (integer i = 0 ; i < mlhresp.result.size(); i++) {
                     Webservice_Log__c wsl = new Webservice_Log__c(); 
                     wsl.Webservice__c =  isSandbox()? Label.MLH_Asset_Post_QA : Label.MLH_Asset_Post;
                     wsl.Object_Name__c = 'Opportunity';
                     wsl.Message_Type__c = 'Outbound';
                     if(mlhresp.result[i].error_count > 0 ) {
                         wsl.Status__c = 'Failed';
                         failCount = failCount + 1;
                         if(OppMap.get(mlhresp.result[i].salesforce_opportunity_id) != null) {  
                             SyncedOppList.add(new Opportunity(Id=mlhresp.result[i].salesforce_opportunity_id,Synced_To_MLH__c=FALSE));
                         }
                     }
                     else {
                         wsl.Status__c = 'Success';
                         if(OppMap.get(mlhresp.result[i].salesforce_opportunity_id) != null && OppMap.get(mlhresp.result[i].salesforce_opportunity_id).Asset__c!=null) {  
                             wsl.Asset__c = OppMap.get(mlhresp.result[i].salesforce_opportunity_id).Asset__c;
                             SyncedOppList.add(new Opportunity(Id=mlhresp.result[i].salesforce_opportunity_id,Synced_To_MLH__c=TRUE,Listing_ID__c=String.valueof(mlhresp.result[i].listing_id)));
                         }
                         successCount = successCount + 1;
                     }
                     wsl.Opportunity__c = mlhresp.result[i].salesforce_opportunity_id; 

                     List<String> error_messages = mlhresp.result[i].error_msg;     
                     if(error_messages!=null) {
                         for(String err : error_messages) {
                             for( String field : imMap.KeySet()) {
                                 system.debug(' Checking Field ' +field+ ' for error message ' +err);  
                                 if(err.containsIgnoreCase('"'+field+'"') || err.containsIgnoreCase('\''+field+'\''))  {
                                     err = err.replace('"'+field+'"',imMap.get(field));
                                     err = err.replace('\''+field+'\'',imMap.get(field));
                                     wsl.Notes__c = wsl.Notes__c!=null? wsl.Notes__c+'\n'+err :err;
                                 }
                             }
                         }
                     }
                     wsList.add(wsl);
                 }
             }
    
             //Database.Upsert(UpsertAssetList,Asset__c.MLH_Global_Property_ID__c,false);
             Update SyncedOppList; 
             Update UpsertAssetList;
             Database.Insert(wsList,false);
    
             if(failCount == 0 )  {
                 myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, '('+mlhresp.result.size()+') Record(s) successfully uploaded.');
                 ApexPages.addMessage(myMsg);
             }
             else if(failCount > 0 && successCount > 0)  {
                 myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, '('+successCount+') Record(s) successfully uploaded and ('+failCount +') failed. Please check the Web Service Logs.');
                 ApexPages.addMessage(myMsg);
             }         
             else {
                 myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, '('+failCount+') records failed. Please check the Web Service Logs');
                 ApexPages.addMessage(myMsg);
             }
        }
        else {
             myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Data Error - ('+mlhresp.Status.code+') - '+mlhresp.Status.errors);
             ApexPages.addMessage(myMsg);             
         }
            return null;
    }

    public static Boolean IsSandbox() {
      return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}