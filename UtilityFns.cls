//******************************************************************************************************************************************************************************************
//  ---------------------------------------------------------------------
//  Static Utility/Helper Methods which can be called from other classes. 
//  ---------------------------------------------------------------------
/* Author : Harish Emmadi  on 11/12/13 */
// Modified By                    Modified Date                                    What Changed                                                                Reason

//******************************************************************************************************************************************************************************************  
public without sharing class UtilityFns {
    static final String RANDOM_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    public static final string STR_INBOUND = 'Inbound';
    public static final string STR_OUTBOUND = 'Outbound';
    public enum WebserviceLogStatus {
        Request_Sent,
        Request_Received,
        Success,
        Failed
    }
    
    public Static String ConsolidatedStringof(List<sObject> sObjs, String fieldName, String sep){
        String res = '';
        Integer iterator_position = 1;
        if(sObjs != null)
        {   
            for(sObject obj : sObjs)
            {
                res += obj.get(fieldName) != null ? obj.get(fieldName)+ (iterator_position != sObjs.size() ? sep : '') : '';
                iterator_position++;
            }
        }
        return res; 
    }

    // generate a random ALFANUMERIC value of given length.
    public static String getRandomString(Integer len, Integer mode){
        String retVal = '';
        if (len != null && len >= 1)
        {
            do
            {
                Integer random = Math.round(Math.random() * mode);
                retVal += RANDOM_CHARS.substring(random, random + 1);
             } while (retVal.length() < len);
        }
        return retVal;
    }
  
    //Gets a random integer number between lower (inclusive) and upper (exclusive)
    public static Integer getRandomInt (Integer lower, Integer upper)
    {
        return Math.round(Math.random() * (upper - lower)) + lower;
    }

    //  -----------------------------------------------
    //  triggerLabel: optimized for script statement minimization
    //  -----------------------------------------------
    public static String triggerLabel() {
        if (Trigger.isExecuting) {
            if (Trigger.isUpdate) return (Trigger.isBefore ? 'before' : 'after') + 'Update()';
            if (Trigger.isInsert) return (Trigger.isBefore ? 'before' : 'after') + 'Insert()';
            if (Trigger.isDelete) return (Trigger.isBefore ? 'before' : 'after') + 'Delete()';
            if (Trigger.isBefore) return 'unknown trigger state';
            else          return 'afterUndelete';
        }
        return '';
    }

    //  showauctionIdtoAucOpptyJunMap   : Return string separated by \n for each element in map of String | List of Asset Opp Junction Recs
    public static String showauctionIdtoAucOpptyJunMap(Map<String,List<Auction_Opportunity_Assignment__c>> mapToShow){
        String res = '\n';
        for (String s: mapToShow.keySet()) {
          res = res + '   ' + s + '  : ' + (mapToShow.get(s) == null || mapToShow.get(s).size() == 0 ? ' <no Auction Opportunity Assignments in list>' : '') + '\n';
          if (mapToShow.get(s).size() > 0)
            for (Auction_Opportunity_Assignment__c aoa : mapToShow.get(s))
              res = res + '  Auction Opp Junction :' + aoa.id + ' ' + aoa.name + '\n';
        }
        return res;
    }

    //  showglobalPropIdtoAstOpptyJunMap   : Return string separated by \n for each element in map of String | List of Asset Opp Junction Recs
    public static String showglobalPropIdtoAstOpptyJunMap(Map<String,List<AssetOppJunction__c>> mapToShow){
        String res = '\n';
        for (String s: mapToShow.keySet()) {
          res = res + '   ' + s + '  : ' + (mapToShow.get(s) == null || mapToShow.get(s).size() == 0 ? ' <no Asset Opportunity Junction records in list>' : '') + '\n';
          if (mapToShow.get(s).size() > 0)
            for (AssetOppJunction__c aoj : mapToShow.get(s))
              res = res + '  Asset Opp Junction :' + aoj.id + ' ' + aoj.name + '\n';
        }
        return res;
    }

    //  showbidderIdtoBidRegMap  : Return string separated by \n for each element in map of String | Bidder_Registration__c Rec.
    public static String showbidderIdtoBidRegMap(Map<String,Bidder_Registration__c> mapToShow){
        String res = '\n';
        for (String s: mapToShow.keySet()) {
          Bidder_Registration__c bidreg = mapToShow.get(s);
          res += '   ' + s + '  : ' + (bidreg == null ? ' <no Bidder Registration.>' : '  Bidder Registration :' + bidreg.id + ' ' + bidreg.name ) + '\n';
        }
        return res;
    }

    /***********
        * Method name  : getFieldMetaData
        * Description  : Prepare a map of fieldDescribes.
        * Return Type  : Map<String, Schema.DescribeFieldResult>
        * Parameters   : Schema.DescribeSObjectResult dsor.
    ***********/
    public static Map<String, Schema.DescribeFieldResult> getFieldMetaData(Schema.DescribeSObjectResult dsor) 
    {
          Map<String,Schema.DescribeFieldResult> res            =   new Map<String, Schema.DescribeFieldResult>(); // the map to be returned with the final data
          Map<String, Schema.SObjectField>       objectFields   =   dsor.fields.getMap(); // map of all fields in the object
          for(String field : objectFields.keyset()){
              Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
              res.put(field.toLowerCase(), dr); // add the results to the map to be returned
          }
          return res;
    }

    /***********
        * Method name  : getfieldApiNamesList
        * Description  : Prepare a List of field names for given Labels.
        * Return Type  : List<String{lower}>.
        * Parameters   : List<String> fieldLabelList, Map<String, Schema.DescribeFieldResult> DRfieldDescribeMap.
    ***********/
    public static List<String> getfieldApiNamesList(List<String> fieldLabelList, Map<String, Schema.DescribeFieldResult> fieldDescribeMap)
    {
        List<String>          res            = new List<String>();    
        Map< String, String > labeltoAPIMap  = new Map< String, String >();
        for(String f : fieldDescribeMap.keyset())
                labeltoAPIMap.put( fieldDescribeMap.get(f).getLabel().toLowerCase(), f.toLowerCase() );
        System.debug('Harish'+labeltoAPIMap);
        for( String fl :  fieldLabelList )
            if(labeltoAPIMap.containsKey(fl.replace('\n','').toLowerCase()))
                res.add(labeltoAPIMap.get(fl.toLowerCase()));
        return res;
    }

    // Method to parse the large string and returns a tokens list.
    public static List<List<String>> parseCSV(String contents) 
    {
        List<List<String>> allFields = new List<List<String>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\r\n');
            System.debug('lines'+lines);
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        return allFields; 
    }

    /***********
        * Method name  : FriendlifyErrorMessages
        * Description  : Prepare a single string by consolidating all errors.
        * Return Type  : String.
        * Parameters   : DMLException.
    ***********/
    public static String FriendlifyErrorMessages(DMLException ex)
    {
        String res = '';
        for(Integer i = 0; i < ex.getNumDml(); i++)
        {
            res += ex.getDmlMessage(i)+'\n';
        }
        return res;
    }

    //  flattenDbError : Takes Database.Error[] and flattens to a string
    public static String flattenDbError(Database.Error[] dbErrList) {
        String res = '';
        for (Integer i=0; i< dbErrList.size(); i++)
          res = res + dbErrList[i].getMessage();
        return res;  
    }
    
    //  sendEmail                      : sends email using SFDC outbound email
    public static void sendEmail (String[] toRecipients, String[] ccRecipients, String subject, String body, blob attachments, String attachmentName) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        
        email.setToAddresses(toRecipients);
        email.setCcAddresses(ccRecipients);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        email.setCharset('UTF-8');
        if(attachments != null){
            if(!Test.isRunningTest())
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
            attachment.setFileName(attachmentName);
            attachment.setBody(attachments);
        }
        System.debug(LoggingLevel.INFO,'** entered sendEmail, to:' + toRecipients + ' cc:' + ccRecipients + ' subject:' + subject + ' body:' + body);
        try {
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
          return;
        }
          catch (EmailException e) {throw new AuctionException(e.getMessage());}  
    }
    
    public static boolean checkLoggingEnabled(){
        boolean isLoggingEnabled = false;
        
        if(SystemSettings.getsettingValueof(CONSTANTS.IS_WEBSERVICE_LOG_ENABLED).equalsIgnoreCase('Y'))
        {
            isLoggingEnabled = true;
        }
        return isLoggingEnabled;    
    }
    
    public static String getMessageLogStatus(WebserviceLogStatus status){
        String str_Status;
        
        if(String.isNotBlank(status.name())){
            str_Status = status.name().replace('_', ' ');  
        }
        return str_Status;
    }
    
    public static String createNewOutboundMessageLogWithStatus(String webServiceName, String whatIds, String objname,
                                                                 WebserviceLogStatus status, String notes){
        Webservice_Log__c logMsg = new Webservice_Log__c(Message_Type__c = STR_OUTBOUND, 
                                                        Status__c =  getMessageLogStatus(status),
                                                        Webservice__c = webServiceName,
                                                        WhatIds__c = whatIds,
                                                        Object_Name__c = objname,
                                                        Notes__c = notes);           
        
        database.SaveResult insertResult = database.insert(logMsg, false);
        
        if(insertResult.isSuccess()){
            return insertResult.getId();
        } else {
            return null;
        }
    }
    
        public static Webservice_Log__c createWSLog(String webServiceName, String whatIds, String objname,
                                                                 WebserviceLogStatus status, String notes){
        Webservice_Log__c wsl = new Webservice_Log__c(Message_Type__c = STR_OUTBOUND, 
                                                        Status__c =  getMessageLogStatus(status),
                                                        Webservice__c = webServiceName,
                                                        WhatIds__c = whatIds,
                                                        Object_Name__c = objname,
                                                        Notes__c = notes);                  
        return wsl;
    }
}