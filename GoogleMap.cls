public class GoogleMap {
    private static final String key = 'AIzaSyD6UCZpSF4PqM72XorODKr4EBwPVHmADeE';
    private static final Integer timeout = 3000;

    @Future(callout=true) 
    public static void update_distance(List<String> origins, List<String> destinations, List<Id> recordIds, List<String> recordNames, String sobj, 
                                       String need_update_field, Integer cutoff, String emailAddress, String username) {
        if (   origins.size() != destinations.size() 
            || origins.size() != recordIds.size() 
            || destinations.size() != recordIds.size()) {
            throw new GoogleMapException('The size of origins, destinations and recordIds are not the same');
            // this should only show up if not using this library properly
        }
 
        // the Google map server doesn't accept address that contains spaces in it
        // so, first convert spaces between English words in the String to +

        // the map that maps a Vendor to a newly calcualted distance
        Map<Id, String> id_to_errMsg = new Map<Id, String>();
        Map<Id, Integer> id_to_distance = new Map<Id, Integer>();

        // calculate all distance, and fill the map
        for ( Integer i = 0; i < recordIds.size(); i++) {
            Id recordId = recordIds[i];
            String origin = origins[i];
            String destination = destinations[i];
            String recordName  = recordNames[i];

            Integer distance;

            
            distance = calculate_Individual_Distance(origin, destination, emailAddress, username, recordId, recordName);

            if ( distance != -1 ) {

                // otherwise, succeed, store into the map
                id_to_distance.put( recordId, distance );
            } 
        }

        // now the map is ready, call update to update it
        updateRecords(id_to_distance, recordIds, sobj, need_update_field, cutoff);
    }


    // (Id from id_to_distance) + (Id from id_to_errMsg) = recordIds
    public static void updateRecords(Map<Id, Integer> id_to_distance, List<Id> recordIds, String sobj, String fieldName, Integer cutoff) {
        List<sObject> updateList = new List<sObject>();
        
        for (Id id_number : recordIds) {
            Integer miles = id_to_distance.get(id_number);
            SObject s_obj = id_number.getSobjectType().newSObject(id_number);

            try {
                if (miles > cutoff) {
                    List<Profile> selectedProfileList = [Select Id from Profile Where Name = 'CRE Photo Order Team'];
                    Photo_Order_Cost_Setting__c cs = Photo_Order_Cost_Setting__c.getInstance(selectedProfileList.get(0).Id);
                    s_obj.put(fieldName, miles*(cs.Cost_Per_Mile__c)*2);
                } else {
                    //s_obj.put(fieldName, null);
                    s_obj.put(fieldName, 0);
                }
            } catch (Exception e) {
                System.debug(Logginglevel.ERROR, e.getMessage());
                throw new GoogleMapException('When updating distance, the Object name or Field name used to located the record to update ' + 
                                         ' does not match the ones in the Database');
            }

            updateList.add(s_obj);
        }

        update updateList;
        
    }


    // need a function to calculate the distances between two list of addresses
    public static Integer calculate_Individual_Distance(String origin, String destination, String email, 
                                                        String username, Id recordId, String recordName) {
        origin = replace_spaces_with_Plus( origin.trim() );
		origin = origin.replace('#', '%23');
		
        destination = replace_spaces_with_Plus( destination.trim() );
		destination = destination.replace('#', '%23');	
		
        Integer miles = -1;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?'
                    +'origins='+origin+'&'
                    +'destinations='+destination+'&'
                    +'mode=driving&'
                    +'language=en&'
                    +'units=imperial&'
                    +'key='+key;

        req.setTimeout(timeout);
        req.setMethod('GET');    
        req.setEndPoint(url);

        try {
            HTTPResponse resp = http.send(req);
            JSONParser parser = JSON.createParser( resp.getBody() );
            String mileage;

            // get the distance field value
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
            
                    String fieldName = parser.getText();
                    parser.nextToken();
            
                    if (fieldName == 'distance') {
                        parser.nextToken();
                        fieldName = parser.getText();
                        if ( fieldName == 'text' ) {
                            parser.nextToken();
                            mileage = parser.getText();
                            break;
                        }
                    } 
                }
            }

            Decimal tem_miles = Decimal.valueOf((mileage.replace('mi', '').replace(',', '').trim())); 
            tem_miles = tem_miles.round(System.RoundingMode.UP);
            miles = tem_miles.intValue();

        } catch(Exception e) {

            printExceptionMessages(e);

            String msg =  '<p>We are unable to calculate the estimated distance because at least one of the following addresses is invalid: </p>'
                        + '<p>property address: '+ '&lt; ' + origin.replace('+', ' ') + ' &gt; </p>'
                        + '<p>vendor address: ' + '&lt; ' + destination.replace('+', ' ') + ' &gt; </p>'
                        + 'Please verify the addresses are correct.';
            sendEmail(email, msg, username, recordId, recordName);
            return -1;
        }
        return miles;
    }


    private static String replace_spaces_with_Plus(String input) {
        return input.replaceAll('\\s+', '+');
    }

    private static void printExceptionMessages(Exception e) {
        System.debug('Cause: ' + e.getCause() );
        System.debug('Message: ' + e.getMessage() );
        System.debug('Line number ' + e.getLineNumber());
        System.debug('Stack Traces ' + e.getStackTraceString());
        System.debug('Type Name ' + e.getTypeName());
    }

    // so if someone update N BPOs, and they all need to recalculated distance
    // the user who make this change will receive N emails.
    public static void sendEmail(String email, String message, String username, Id recordId, String recordName) {

        // reserve capacity for sending this email, if fail in reservation, then an exception will show up
        Messaging.reserveSingleEmailCapacity(2);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        toAddresses.add(email);

        mail.setToAddresses(toAddresses);
        
        mail.setSenderDisplayName(username);

        mail.setSubject('Unable to provide estimated distance for Value/Reserve ' + recordName);

        mail.setHtmlBody( '<b>' + message + '</b>' + ' </br></br></br> ' 
                        + '<b>You can view the associated record via the link below: </b>'
                        + URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId );

        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
    }
    
}