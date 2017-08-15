public class Liveopswrapper{
    public class LiveopsWrapperException extends Exception{}
    //Murali - START
	private List<Webservice_Log__c> CalloutExceptions { get; set; }
    
    public Liveopswrapper() {
        this.CalloutExceptions = new List<Webservice_Log__c>();
    }       
	//Murali - END
    public static boolean isLoggingEnabled = UtilityFns.checkLoggingEnabled();
    
    public String getAuthorizationKey(List<Id> callrecIds){
        String access_token;
        String msgLogId;
        String webServiceName = 'Liveopswrapper.getAuthorizationKey';
        try
        {
            String UName                 =  SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_USERNAME_SSNAME);
            String Pwd                   =  SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_PASSWORD_SSNAME);
            String callcentername        =  SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_CALLCENTERNAME_SSNAME);
            String token_server_uri      =  SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_TOKEN_SERVER_URI_SSNAME);
            if(String.isNotBlank(token_server_uri))
            {    
                HttpRequest req = new HttpRequest();
                req.setEndpoint(token_server_uri);
                req.setMethod('POST');
                
                // Specify the header and header information
                req.setHeader('Content-Type', 'application/json;');
                
                // uncomment when required.
                //req.setHeader('Accept', 'application/json, text/javascript, */*; q=0.01');
                //req.setHeader('Content-Length', '65');
                //req.setHeader('Accept-Encoding', 'gzip,deflate,sdch');
                //req.setHeader('Accept-Language:', 'en-US,en;q=0.8'); 
                //req.setHeader('Accept-Charset:' , 'ISO-8859-1,utf-8;q=0.7,*;q=0.3');*/
                
                String jsonFormattedBody = '{"username":"'+UName+'", "password":"'+Pwd+'", "callcenterName":"'+callcentername+'"}';
                req.setBody(jsonFormattedBody); 
                //req.setBody('{"username":"apiuser","password":"auction123","callcenterName":"Auction_com"}');     
                
                system.debug('getAuthorizationKey request body is: '+req.getBody());
                
                // Create a new http object to send the request object
                // A response object is generated as a result of the request.
                try{
                    Http         http = new Http();
                    HTTPResponse res  = http.send(req);
                    System.debug('getAuthorizationKey response is:  '+res+' \n Body : '+res.getBody());
                    
                    if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) {
                        // Parse entire JSON response.
                        if(String.isNotBlank(res.getBody()))
                            access_token = res.getBody().substringBetween('acs_session=',';Version=');
                    } 
                    else {
                        throw new LiveopsWrapperException(res.getStatus());
                    }
            
                }catch(System.CalloutException ce){

                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ce.getTypeName()+':'+ce.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds,  ce.getTypeName()+':'+ce.getMessage(), msgLogId );
                }catch(Exception ex){
                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+':'+ex.getTypeName()+';'+ex.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
                }
            }// end of IF..endpoint null check        
        }catch(Exception ex){
            if(isLoggingEnabled){
                msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
            }
            sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
        }
        return access_token;
    }
        
    public outboundbatchresp createoutboundbatch(String campaignId, String access_token, List<Id> callrecIds){
        outboundbatchresp resp;
        String msgLogId;
        String webServiceName = 'Liveopswrapper.createoutboundbatch';
        System.debug('Acs_token'+access_token);
        try
        {
            //String campaignId                   =  SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_CAMPAIGNID_SSNAME);
            String description                  =  'sample description';
            String outbound_batch_uri           =  SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_OUTBOUND_BATCH_URI_SSNAME);
            String endpointurl_plus_acstoken    =  outbound_batch_uri+'?acs_session='+access_token;
            if(String.isNotBlank(outbound_batch_uri))
            {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpointurl_plus_acstoken);
                req.setMethod('POST');
                
                // Specify the header and header information
                req.setHeader('Content-Type', 'application/json;');
                
                // uncomment when required.
                //req.setHeader('Accept', 'application/json, text/javascript, */*; q=0.01');
                //req.setHeader('Content-Length', '65');
                //req.setHeader('Accept-Encoding', 'gzip,deflate,sdch');
                //req.setHeader('Accept-Language:', 'en-US,en;q=0.8'); 
                //req.setHeader('Accept-Charset:' , 'ISO-8859-1,utf-8;q=0.7,*;q=0.3');*/
                
                String jsonFormattedBody = '{"campaignId":'+campaignId+', "description":"'+description+'"}';
                req.setBody(jsonFormattedBody);
                //req.setBody('{"campaignId" : 90163,"description" : " Test Campaign in Rest Client "}');     
                
                system.debug('createoutboundbatch request body is: '+req.getBody());
                
                // Create a new http object to send the request object
                // A response object is generated as a result of the request.
                try
                {    
                    Http         http = new Http();
                    HTTPResponse res  = http.send(req);
                    System.debug('createoutboundbatch response is:  '+res+' \n Body : '+res.getBody());
                    
                    if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) {
                        // Parse entire JSON response.
                        JSONParser parser = JSON.createParser(res.getBody());
                        outboundbatchresp   obres   = (outboundbatchresp)parser.readValueAs(outboundbatchresp.class);
                        resp = obres;
                    } else {
                        throw new LiveopsWrapperException(res.getStatus());
                    }
                }catch(System.CalloutException ce){
                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed,  ce.getTypeName()+':'+ce.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds,  ce.getTypeName()+':'+ce.getMessage(), msgLogId );
                }catch(Exception ex){
                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
                }
            }// end of IF..endpoint null check        
        }catch(Exception ex){
            if(isLoggingEnabled){
                msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
            }
            sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
        }    
        return resp;
    }
    
    public Leadresponsewrapper createoutboundLeads(String campaignId, String access_token, List<Id> callrecIds){
        Leadresponsewrapper resp;
        String msgLogId;
        String webServiceName = 'Liveopswrapper.createoutboundLeads';
        outboundbatchresp OBres;
        if(String.isNotBlank(access_token) && callrecIds != null && !callrecIds.isEmpty())
        { 
            OBres = createoutboundbatch(campaignId, access_token, callrecIds); 
        }
        if(OBres == null || OBres.returnObject == null || String.isBlank(OBres.returnObject.id))
        {
            return null;
        }
        try
        {
            String outbound_lead_bulk_uri       = SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_OUTBOUND_LEAD_BULK_URI_SSNAME);
            String endpointurl_plus_acstoken    = outbound_lead_bulk_uri+'?acs_session='+access_token;
            
            List<Callrecord__c> callrecords     = [select Id, Phone_Number__c, Mobile_Phone__c,  FollowupTime__c, 
                                                          bid__r.Opportunity__r.Seller__r.Name, bid__r.MLH_Bid_Stage__c,
                                                          Contact__r.Name, bid__r.REDC_ID__c, bid__r.MLH_Event_ID__c 
                                                        from callrecord__c where Id IN :callrecIds]; 
            if(String.isNotBlank(endpointurl_plus_acstoken))
            {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpointurl_plus_acstoken);
                req.setMethod('POST');
                
                // Specify the header and header information
                
                req.setHeader('Content-Type', 'application/json;');
                
                // uncomment when required.
                //req.setHeader('Accept', 'application/json, text/javascript, */*; q=0.01');
                //req.setHeader('Content-Length', '65');
                //req.setHeader('Accept-Encoding', 'gzip,deflate,sdch');
                //req.setHeader('Accept-Language:', 'en-US,en;q=0.8'); 
                //req.setHeader('Accept-Charset:' , 'ISO-8859-1,utf-8;q=0.7,*;q=0.3');*/
                
                String jsonFormattedBody = '[';
                Integer crcount = 1;
                for(callrecord__c cr : callrecords)
                {
                    if(String.isNotBlank(cr.Phone_Number__c))// requestedCallTime should be changed to current user timezone.
                        jsonFormattedBody += '{'+( cr.FollowupTime__c != null ? '"requestedCallTime":"'+cr.FollowupTime__c.format('yyyy-MM-dd HH:mm:ss')+'", "timezone":"'+UserInfo.getTimeZone().toString()+'",' : '')
                                                +' "phonenum":"'+cr.Phone_Number__c+'", "outboundBatchId":"'
                                                +OBres.returnObject.id+'","params":"Id='+cr.Id+
                                                +'&Contact Name='+cr.contact__r.Name+
                                                +'&Event ID='+cr.bid__r.MLH_Event_ID__c+
                                                +'&REDC ID='+cr.bid__r.REDC_ID__c+
                                                +'&Bid Stage='+cr.bid__r.MLH_Bid_Stage__c+
                                                +'&Seller='+cr.bid__r.Opportunity__r.Seller__r.Name+'"'+'}' 
                                                + (crcount < callrecords.size() ? ',' : '');
                    crcount++;
                }
                jsonFormattedBody += ']';
                System.debug('Jsonformatted body is'+jsonFormattedBody);
                req.setBody(jsonFormattedBody); 
                //req.setBody('{"phonenum" : "3472242255","outboundBatchId" : "5128"}');     
                
                system.debug('createoutboundLeads request body is: '+req.getBody());
                
                // Create a new http object to send the request object
                // A response object is generated as a result of the request.
                try
                {    
                    Http         http = new Http();
                    HTTPResponse res  = http.send(req);
                    System.debug('createoutboundLeads response is:  '+res+' \n Body : '+res.getBody());
                    //List<Callrecord__c> callrecordstobeupdated = new List<callrecord__c>();
                    
                    if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) {
                        // Parse entire JSON response.
                        JSONParser parser = JSON.createParser(res.getBody());
                        Leadresponsewrapper   leadbatchres   = (Leadresponsewrapper)parser.readValueAs(Leadresponsewrapper.class);
                        resp = leadbatchres;
                        UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Success,  '');// create a log on success.
                    } else {
                        throw new LiveopsWrapperException(res.getStatus());
                    }
                }catch(System.CalloutException ce){
                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ce.getTypeName()+';'+ce.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds, ce.getTypeName()+';'+ce.getMessage(), msgLogId );
                }catch(Exception ex){
                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
                }
            }// end of IF..endpoint null check                
        }catch(Exception ex){
            if(isLoggingEnabled){
                msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
            }
            sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
        }   
        return resp;
    }
    
    public Leadresponsewrapper getoutboundLeads(String campaignId, List<Id> callrecIds){
        Leadresponsewrapper resp;
        String msgLogId;
        String webServiceName = 'Liveopswrapper.getoutboundLeads';
        String access_token  = getAuthorizationKey(callrecIds);
        Leadresponsewrapper createLeadBatchresp = createoutboundLeads(campaignId, access_token, callrecIds);
        if(createLeadBatchresp == null || createLeadBatchresp.returnObject == null)
        {
            return null;
        }
        try
        {
            String outbound_lead_bulk_uri       = SystemSettings.getsettingValueof(CONSTANTS.LIVEOPS_OUTBOUND_LEAD_BULK_URI_SSNAME);
            String endpointurl_plus_acstoken    =  outbound_lead_bulk_uri+'/'+createLeadBatchresp.returnObject.requestId+'?acs_session='+access_token;
            
            List<Callrecord__c> callrecords     = [select Id, Phone_Number__c, Mobile_Phone__c, FollowupTime__c from callrecord__c where Id IN :callrecIds]; 
            if(String.isNotBlank(endpointurl_plus_acstoken))
            {    
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpointurl_plus_acstoken);
                req.setMethod('GET');
                
                // Specify the header and header information
                
                req.setHeader('Content-Type', 'application/json;');
                
                // uncomment when required.
                //req.setHeader('Accept', 'application/json, text/javascript, */*; q=0.01');
                //req.setHeader('Content-Length', '65');
                //req.setHeader('Accept-Encoding', 'gzip,deflate,sdch');
                //req.setHeader('Accept-Language:', 'en-US,en;q=0.8'); 
                //req.setHeader('Accept-Charset:' , 'ISO-8859-1,utf-8;q=0.7,*;q=0.3');*/
                
                // Create a new http object to send the request object
                // A response object is generated as a result of the request.
                try
                {    
                    Http         http = new Http();
                    HTTPResponse res  = http.send(req);
                    System.debug('getoutboundLeads response is:  '+res+' \n Body : '+res.getBody());
                    
                    if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) {
                        // Parse entire JSON response.
                        JSONParser parser = JSON.createParser(res.getBody());
                        Leadresponsewrapper   leadbatchres   = (Leadresponsewrapper)parser.readValueAs(Leadresponsewrapper.class);
                        resp = leadbatchres;
                    } else {
                        throw new LiveopsWrapperException(res.getStatus());
                    }
                }catch(System.CalloutException ce) {
                    if(isLoggingEnabled){
            		Webservice_Log__c wsLog = Utilityfns.createWSLog(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed,  ce.getTypeName()+':'+ce.getMessage());    
            		this.CalloutExceptions.add(wsLog);

                        //msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed,  ce.getTypeName()+':'+ce.getMessage());
                    }
                    //sendErrorEmailToAdmin( callrecIds,  ce.getTypeName()+':'+ce.getMessage(), msgLogId );
                }catch(Exception ex){
                    if(isLoggingEnabled){
                        msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
                    }
                    sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
                }    
            }// end of IF..endpoint null check        
        }catch(Exception ex){
            if(isLoggingEnabled){
                msgLogId = UtilityFns.createNewOutboundMessageLogWithStatus(webServiceName, String.valueOf(callrecIds), CONSTANTS.CALLRECORD_OBJ_NAME, UtilityFns.WebserviceLogStatus.Failed, ex.getTypeName()+';'+ex.getMessage());
            }
            sendErrorEmailToAdmin( callrecIds, ex.getTypeName()+';'+ex.getMessage(), msgLogId );
        }
        return resp;
    }
 
 
 
 
    
    public void sendErrorEmailToAdmin(List<Id> crIds, string ErrorDescription, String WebServiceLogId){
        
        if(crIds != null && !crIds.isEmpty()) {
            String []   toRecipients    = Systemsettings__c.getInstance(CONSTANTS.PARM_OUTBOUND_LEAD_CREATION_EMAIL).value__c.split(';');  
            String []   ccRecipients    = new String [] {};
            String wslUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + WebServiceLogId;
            string csvName = null;     
            blob csvFile = null;
            String emailSubject =  'Error creating Outbound Leads in Liveops for# ' + String.valueof(crIds);
            String emailBody    =  'There was an error while creating Outbound Leads to liveops for: ' +  String.valueof(crIds) +'\n'
                                   +'Please create call records manually.'+'\n'
                                   +'Complete callouts log related to this case be found at:' + wslUrl+'\n';
            UtilityFns.sendEmail(toRecipients, ccRecipients, emailSubject, emailBody, csvFile, csvName);
        }
    }
    
    public class outboundbatchresp{
        public batchinfo returnObject;
        public String request_id;
        public string status;
        // Constructor to default values.
        public outboundbatchresp(batchinfo returnObject,String request_id,String status)
        {
            this.returnObject = returnObject;
            this.request_id   = request_id;
            this.status       = status;
        }
    }   
    
    public class batchinfo{
        public String id;
        public String campaignId;
        public String queryParams;
        public String createdTime;
        public String description;
    }   
    
    public class Leadresponsewrapper{
        public Leadreq_returnObject returnObject;
        public String request_id; 
        public String status;
    }
    
    public class Leadreq_returnObject{
        public Leadreq_Status status;
        public String requestId;
        public List<Leadreq_response> responseList;
    }
    
    public class Leadreq_response{
        public Leadreq_resource resource;
        public Leadreq_Status status;
    }
    
    public class Leadreq_Status {
        public String message;
        public String code;
    }
    
    public class Leadreq_resource{
        public String id;
        public String requestedCallTime;
        public String timezone;
        public String campaignId;
        public String expires;
        public String createdTime;
        public String embargoUntil;
        public String params;
        public String phonenum;
        public String outboundBatchId;
    }
}