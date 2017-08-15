@isTest(SeeAllData=TRUE)
public class mlhMockRequestsTest {
    public static testmethod void testAssetIntegrationCallout1() {
        String authResp = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        String mlhRespSuccessQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespSuccessPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","listing_id":123456788,"event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespFailQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}';
        String mlhRespFailPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}'; 
        String AuthQA = 'https://api.qa.auction.com/security/oauth/token?';
        String AuthPROD = 'https://api.auction.com/security/oauth/token?';

        String auth = MLH_Token_Manager.getendPointURL();                 
        String postURL = MLH_Token_Manager.getendPointURLPost();  

        String mlhRespSuccess = MLHAuth.isSandbox()? mlhRespSuccessQA: mlhRespSuccessPROD;  
        String mlhRespFail = MLHAuth.isSandbox()? mlhRespFailQA: mlhRespFailPROD;  
                       
        mlhSingleRequestMock fakeAuthResp = new mlhSingleRequestMock(200,
                                                         'Complete',
                                                         authResp,
                                                         null);

        mlhSingleRequestMock fakeMLHResp = new mlhSingleRequestMock(200,
                                                  'Complete',
                                                  mlhRespFail,
                                                   null);
                                                   
        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
                                         
        endpoint2TestResp.put(auth,fakeAuthResp);
        endpoint2TestResp.put(postURL,fakeMLHResp);
        
        HttpCalloutMock multiCalloutMock =
                                   new mlhMockRequest(endpoint2TestResp);


        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        List<Opportunity> oppList = new List<Opportunity>([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL AND Synced_to_MLH__c=TRUE LIMIT 1]);
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(oppList);
        OppSetCon.setSelected(oppList);
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
        mlhauthController.SyncToMLH();    

        PageReference pageRef = Page.MLHPropertySync;
        pageRef.getParameters().put('id', oppList[0].Id);
        mlhAssetUploadResponse.parse(mlhRespFail);
    }

    public static testmethod void testAssetIntegrationCallout2() {
        String authResp = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        String mlhRespSuccessQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespSuccessPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespFailQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}';
        String mlhRespFailPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}'; 
        String AuthQA = 'https://api.qa.auction.com/security/oauth/token?';
        String AuthPROD = 'https://api.auction.com/security/oauth/token?';

        String auth = MLH_Token_Manager.getendPointURL();                 
        String postURL = MLH_Token_Manager.getendPointURLPost();  

        String mlhRespSuccess = MLHAuth.isSandbox()? mlhRespSuccessQA: mlhRespSuccessPROD;  
        String mlhRespFail = MLHAuth.isSandbox()? mlhRespFailQA: mlhRespFailPROD;  

        mlhSingleRequestMock fakeAuthResp = new mlhSingleRequestMock(200,
                                                         'Complete',
                                                         authResp,
                                                         null);

        mlhSingleRequestMock fakeMLHResp = new mlhSingleRequestMock(200,
                                                  'Complete',
                                                  mlhRespSuccess,
                                                   null);
                                                   
        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(auth,fakeAuthResp);
        endpoint2TestResp.put(postURL,fakeMLHResp);
        
        HttpCalloutMock multiCalloutMock =
                                   new mlhMockRequest(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=null  AND Asset__c!=null LIMIT 1]);
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(oppList);
        OppSetCon.setSelected(oppList);
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
        mlhauthController.SyncToMLH();    
        
        Map<Id,Opportunity> opps = new Map<Id,Opportunity>([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null LIMIT 1]);
        PageReference pageRef = Page.MLHPropertySync;
        //pageRef.getParameters().put('id', oppList[0].Id);
        MLH_Asset.AssetJSON(opps.KeySet());
    }

    public static testmethod void testAssetIntegrationCallout3() {
        String authResp = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        String mlhRespSuccessQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespSuccessPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespFailQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}';
        String mlhRespFailPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}'; 
        String AuthQA = 'https://api.qa.auction.com/security/oauth/token?';
        String AuthPROD = 'https://api.auction.com/security/oauth/token?';

        String auth = MLH_Token_Manager.getendPointURL();                 
        String mlhRespSuccess = MLHAuth.isSandbox()? mlhRespSuccessQA: mlhRespSuccessPROD;  
        String mlhRespFail = MLHAuth.isSandbox()? mlhRespFailQA: mlhRespFailPROD;  
        String postURL = MLH_Token_Manager.getendPointURLPost();  

        List<Auth_Token_Vault__c> mlhoauth = new List<Auth_Token_Vault__c>([SELECT Id,Auth_Token__c,Auth_Token_Expires__c FROM Auth_Token_Vault__c WHERE Name='MLH' LIMIT 1]);
        mlhoauth[0].Auth_Token_Expires__c = system.now().addMinutes(-2); 
        Update mlhoauth;
        mlhSingleRequestMock fakeAuthResp = new mlhSingleRequestMock(200,
                                                         'Complete',
                                                         authResp,
                                                         null);                                                   
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(auth,fakeAuthResp);
        HttpCalloutMock multiCalloutMock = new mlhMockRequest(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL LIMIT 1]));
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
    }

    public static testmethod void testAssetIntegrationCallout4() {

        String authResp = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        String mlhRespSuccessQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespSuccessPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespFailQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}';
        String mlhRespFailPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}'; 
        String AuthQA = 'https://api.qa.auction.com/security/oauth/token?';
        String AuthPROD = 'https://api.auction.com/security/oauth/token?';

        String auth = MLH_Token_Manager.getendPointURL();                 
        String mlhRespSuccess = MLHAuth.isSandbox()? mlhRespSuccessQA: mlhRespSuccessPROD;  
        String mlhRespFail = MLHAuth.isSandbox()? mlhRespFailQA: mlhRespFailPROD;  
        String postURL = MLH_Token_Manager.getendPointURLPost();  

        List<Auth_Token_Vault__c> mlhoauth = new List<Auth_Token_Vault__c>([SELECT Id,Auth_Token__c,Auth_Token_Expires__c FROM Auth_Token_Vault__c WHERE Name='MLH' LIMIT 1]);
        mlhoauth[0].Auth_Token_Expires__c = system.now().addMinutes(-2); 
        Delete mlhoauth;
        
        mlhSingleRequestMock fakeAuthResp = new mlhSingleRequestMock(200,
                                                         'Complete',
                                                         authResp,
                                                         null);                                                   
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(auth,fakeAuthResp);
        HttpCalloutMock multiCalloutMock = new mlhMockRequest(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL LIMIT 1]));
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
    }

    public static testmethod void testAssetIntegrationCallout5() {
        String authResp = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        String mlhRespSuccessQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespSuccessPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespFailQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}';
        String mlhRespFailPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}'; 
        String AuthQA = 'https://api.qa.auction.com/security/oauth/token?';
        String AuthPROD = 'https://api.auction.com/security/oauth/token?';

        String auth = MLH_Token_Manager.getendPointURL();                 
        String mlhRespSuccess = MLHAuth.isSandbox()? mlhRespSuccessQA: mlhRespSuccessPROD;  
        String mlhRespFail = MLHAuth.isSandbox()? mlhRespFailQA: mlhRespFailPROD;  
        String postURL = MLH_Token_Manager.getendPointURLPost();  
        
        mlhSingleRequestMock fakeAuthResp = new mlhSingleRequestMock(200,
                                                         'Complete',
                                                         authResp,
                                                         null);

        mlhSingleRequestMock fakeMLHResp = new mlhSingleRequestMock(401,
                                                  'Forbidden',
                                                  mlhRespFail,
                                                   null);
                                                   
        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(auth,fakeAuthResp);
        endpoint2TestResp.put(postURL,fakeMLHResp);
        
        HttpCalloutMock multiCalloutMock =
                                   new mlhMockRequest(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL LIMIT 1]));
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
        mlhauthController.SyncToMLH();    
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL LIMIT 1]);
        PageReference pageRef = Page.MLHPropertySync;
        pageRef.getParameters().put('id', oppList[0].Id);
        mlhAssetUploadResponse.parse(mlhRespFail);
    }

    public static testmethod void testAssetIntegrationCallout6() {
        String authResp = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        String mlhRespSuccessQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespSuccessPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"UPDATED","commit_status":"COMMITED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG"}]}';
        String mlhRespFailQA = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.qa.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}';
        String mlhRespFailPROD = '{"status":{"code":200,"message":"success","debug":{"build":1,"server_name":"mws.mylandhome.com","duration":1}},"result":[{"upload_status":"FAILED","global_asset_id":"193061683","event_number":"B-125","redc_id":"NC3100","asset_address":"3100 SF2MLH St","seller_loan_number":"SF2MLH3100","salesforce_opportunity_id":"00655000002YKsiAAG","error_count":1,"error_msg":["\'seller_code\' is required"]}]}'; 
        String AuthQA = 'https://api.qa.auction.com/security/oauth/token?';
        String AuthPROD = 'https://api.auction.com/security/oauth/token?';

        String auth = MLH_Token_Manager.getendPointURL();                 
        String postURL = MLH_Token_Manager.getendPointURLPost();  

        String mlhRespSuccess = MLHAuth.isSandbox()? mlhRespSuccessQA: mlhRespSuccessPROD;  
        String mlhRespFail = MLHAuth.isSandbox()? mlhRespFailQA: mlhRespFailPROD;  
        
        mlhSingleRequestMock fakeAuthResp = new mlhSingleRequestMock(200,
                                                         'Complete',
                                                         authResp,
                                                         null);

        mlhSingleRequestMock fakeMLHResp = new mlhSingleRequestMock(401,
                                                  'Forbidden',
                                                  mlhRespFail,
                                                   null);
                                                   
        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(auth,fakeAuthResp);
        endpoint2TestResp.put(postURL,fakeMLHResp);
        
        HttpCalloutMock multiCalloutMock =
                                   new mlhMockRequest(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ApexPages.StandardSetController OppSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL LIMIT 1]));
        MLHAuth mlhauthController  = new MLHAuth(OppSetCon);        
        mlhauthController.SyncToMLH();    
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id FROM Opportunity WHERE RecordTypeId = :Label.Commercial_Opportunity_Rectype_Id AND Auction_Opportunity_Assignment__c!=null AND Asset__r.MLH_Global_Property_ID__c!=NULL LIMIT 2]);
        String multiOpp = oppList[0].Id +','+oppList[1].Id;
        PageReference pageRef = Page.MLHPropertySync;
        pageRef.getParameters().put('id', multiOpp);
        mlhAssetUploadResponse.parse(mlhRespFail);
    }
}