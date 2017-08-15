public with sharing class MLHAPIv2 {
 
    private static string MLHendpoint = MLHAuth.isSandbox()? Label.MLH_Asset_Post_QA : Label.MLH_Asset_Post;
    //private static mlhAssetUploadResponse.mlhAuthError respError;    

    //Upload Single Asset
    public static mlhAssetUploadResponse UploadListAsset(Set<Id> OppIds) {      
        return AssetUploadResponse('POST', null, MLH_Asset.AssetJSON(OppIds));
    }

    //Get MLH POST Response
    private static mlhAssetUploadResponse AssetUploadResponse(String method, String access_token, String payload) {

        Auth_Token_Vault__c  mlhTokenVault = MLH_Token_Manager.getToken();  
        system.debug('EndPoint URL => ' +MLH_Token_Manager.getEndPointURL());    
        system.debug('Token => ' +mlhTokenVault.Auth_Token__c);    
    
        if(mlhTokenVault==null) {
            throw new MLHAuthException('Connection error! Please contact your Salesforce Administrator');
        }

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //Initialize and set the request
        req.setEndpoint(MLH_Token_Manager.getendPointURLPost());
        req.setHeader('Authorization', 'Bearer ' +mlhTokenVault.Auth_Token__c);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setMethod(method);
        req.setTimeout(120000);

        if (payload != null) {
            req.setBody(payload);
        }
        
        HttpResponse res = h.send(req);               

        //Now that we are done with callouts, we can update the oauth tokens if they changed.
        Upsert mlhTokenVault Name;
    
        String jsonMlhStringResp = res.getBody();
        //The MLH API returns some reserved words. Find and replace them so we can deserialize
        jsonMlhStringResp = jsonMlhStringResp.replace('"limit":', '"limit_x":');
        system.debug('MLH Response Raw => ' + jsonMlhStringResp);
        mlhAssetUploadResponse mlhresp = mlhAssetUploadResponse.parse(jsonMlhStringResp);
        return mlhresp;
    
    }

    public class MLHAuthException extends Exception {}

}