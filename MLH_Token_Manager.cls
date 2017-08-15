public with sharing class MLH_Token_Manager {

    //Initialize oAuth Settings Endpoint, Client ID and Client Secret for MLH
    public static oAuthSettings__c oAuthSetting {
        get {
            if (oAuthSetting == null) {
                oAuthSetting = oAuthSettings__c.getInstance('MLH');
                if (oAuthSetting == null) {
                    throw new MLHAuthException('No MLH OAuth Settings Found');
                }
            }
            return oAuthSetting;
        } 
        private set;
    }

    //Initialize Access Token, Access token Expiry DateTime, Refresh Token Expiry DateTime
    private static Auth_Token_Vault__c ADC_OAuth {
        get {
            if (ADC_OAuth == null) {
                ADC_OAuth = [SELECT Name,Auth_Token__c,Auth_Token_Expires__c,jti__c FROM Auth_Token_Vault__c WHERE Name='MLH' LIMIT 1];
            }
            return ADC_OAuth;
        }
        set;
    }

    private static String endPointURL {
        get {
            if(endPointURL==null) {
                if(oAuthSetting.Connection__c == 1) {
                    endPointURL = oAuthSetting.End_Point_Dev__c;
                }
                else if (oAuthSetting.Connection__c == 2) {
                    endPointURL = oAuthSetting.End_Point_QA__c;
                }
                else if (oAuthSetting.Connection__c == 3) {
                    endPointURL = oAuthSetting.End_Point_DOS_QA__c;
                }
                else    {
                    endPointURL = oAuthSetting.AuthEndpoint__c;
                }
            }
            return endPointURL;
        }
    }

    private static String endPointURLPost {
        get {
            if(endPointURLPost==null) {
                if(oAuthSetting.Connection__c == 1) {
                    endPointURLPost = label.MLH_Asset_Post_DEV;
                }
                else if (oAuthSetting.Connection__c == 2) {
                    endPointURLPost = label.MLH_Asset_Post_QA;
                }
                else if (oAuthSetting.Connection__c == 3) {
                    endPointURLPost = label.MLH_Asset_Post_DOSQA;
                }
                else    {
                    endPointURLPost = label.MLH_Asset_Post;
                }
            }
            return endPointURLPost;
        }
    }
    
    public static String getEndPointURL() {
        return endPointURL; 
    }

    public static String getendPointURLPost() {
        return endPointURLPost; 
    }

    public static Auth_Token_Vault__c getToken() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endPointURL+'&client_id=' + oAuthSetting.ClientId__c + '&client_secret=' + oAuthSetting.ClientSecret__c+'&grant_type=client_credentials');
        HttpResponse res = new HttpResponse();
        String jsonString = null;

        if(!Test.isRunningTest()) {
            res = http.send(req);
            jsonString = res.getBody();
        }
        else {
           jsonString = '{"access_token":"606256c8-6122-464f-a9dc-cb90f32a0b20","token_type":"bearer","expires_in":3599,"scope":"read write"}';
        }

        if (res.getStatusCode() > 299) {
            MLHAuthError err = (MLHAuthError)JSON.deserialize(jsonString, MLHAuthError.class);
            throw new MLHAuthException(err.error_description);
        }

        system.debug('Auth => ' +jsonString);
        if (jsonString.length() > 0) {
            ADCAuthResponse ADCAuthResp = (ADCAuthResponse) System.JSON.deserialize(jsonString, ADCAuthResponse.class);
            ADC_OAuth = new Auth_Token_Vault__c(Name = 'MLH');                          // - Common User used for MLH integration 
            ADC_OAuth.Auth_Token__c = ADCAuthResp.access_token;
            ADC_OAuth.Auth_Token_Expires__c = Datetime.now().addSeconds(ADCAuthResp.expires_in);           
            ADC_OAuth.jti__c = ADCAuthResp.jti;
        }
        return ADC_OAuth;
    }

    public class MLHAuthException extends Exception {}

    private class ADCAuthResponse {
        private String access_token {get;set;}
        private Integer expires_in {get;set;}
        private String refresh_token {get;set;}        
        private String jti {get;set;}       
    }

    private class MLHAuthError {
        private String error {get;set;}
        private String error_description {get;set;}
    }
}