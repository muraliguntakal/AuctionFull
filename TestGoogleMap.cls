@isTest 
private class TestGoogleMap {
    @testSetup static void methodName() {
        Brochure_Date_l__c cus_broDate = new Brochure_Date_l__c();
        cus_broDate.Event__c = 'B-160';
        cus_broDate.Brochure_Print_Date__c = Date.newInstance(2099, 11, 10);
        cus_broDate.Name = 'B-160';
        insert cus_broDate;
    }

    @testSetup static void setup_TestData(){
        //Test.startTest();
        Account oddVendor = new Account(Name='oddVendor -- Account Photo', 
                                        BillingStreet='1000 Cayuga Ave', 
                                        BillingCity='san francisco', 
                                        BillingState='CA', 
                                        BillingPostalCode='94112',
                                        BPO_Vendor__c = true,
                                        Phone = '1233123',
                                        ICA_Sent__c = Date.Today(),
                                        ICA_Rec_d__c = Date.Today(),
                                        W_9__c = Date.Today(),
                                        Requested__c = Date.Today(),
                                        Cleared__c = Date.Today(),
                                        Photo_Vendor_Status__c = 'Cleared'
                                        /*Status__c = 'Active'*/);
        insert oddVendor;

        Account oldVendor = new Account(Name='oldVendor -- Account Photo', 
                                        BillingStreet='1000 Cayuga Ave', 
                                        BillingCity='san francisco', 
                                        BillingState='CA', 
                                        BillingPostalCode='94112',
                                        BPO_Vendor__c = true,
                                        Phone = '1233123',
                                        ICA_Sent__c = Date.Today(),
                                        ICA_Rec_d__c = Date.Today(),
                                        W_9__c = Date.Today(),
                                        Requested__c = Date.Today(),
                                        Cleared__c = Date.Today(),
                                        Photo_Vendor_Status__c = 'Cleared'
                                        /*Status__c = 'Active'*/);
        insert oldVendor;

        Account newVendor = new Account(Name='newVendor -- Account Photo', 
                                        BillingStreet='9500 Gilman Dr', 
                                        BillingCity='La Jolla', 
                                        BillingState='CA', 
                                        BillingPostalCode='92093',
                                        BPO_Vendor__c = true,
                                        Phone = '1233123',
                                        ICA_Sent__c = Date.Today(),
                                        ICA_Rec_d__c = Date.Today(),
                                        W_9__c = Date.Today(),
                                        Requested__c = Date.Today(),
                                        Cleared__c = Date.Today(),
                                        Photo_Vendor_Status__c = 'Cleared'
                                        /*Status__c = 'Active'*/);
        insert newVendor;

        Asset__c cusAsset = new Asset__c(Property_Street__c='17310 Red Hill Ave',
                                       Property_City__c='Irvine',
                                       Property_State__c='CA',
                                       Property_Zip_Postal_Code__c='92614');
        insert cusAsset;

        Opportunity opp = new Opportunity(Asset__c=cusAsset.Id);
        opp.Name = 'Comeon dude';
        opp.StageName = 'holy statename';
        opp.CloseDate = Date.newInstance(2015, 07, 15);
        insert opp;

        BPO__c photoOrder = new BPO__c(Opportunity__c=opp.Id, Estimated_Mileage__c=10);
        photoOrder.Order_Requested_Date__c = Date.today();
        photoOrder.Photo_Order_Event_Id__c = 'B-160';
        insert photoOrder; 
        //Test.stopTest();
    }
    
    @isTest static void test_incorrect_ObjectName_FieldName() {
        Integer magicNumber = 100;
        Integer statusCode  = 200;

        String response = getCorrectJson( magicNumber );

        Map<String, String> headers = new Map<String, String>();
        Mock_SingleRequestCallout_GoogleMap fake_response_1 = new Mock_SingleRequestCallout_GoogleMap(
                                                                statusCode,
                                                                'Complete',
                                                                response,
                                                                headers
                                                            );

        Test.setMock(HttpCalloutMock.class, fake_response_1);

        BPO__c bpo = [select Id from BPO__c limit 1];

        try{
            Test.startTest();
            GoogleMap.update_distance(new List<String>{'san francisco'}, 
                                  new List<String>{'san diego'}, 
                                  new List<String>{bpo.Id}, 
                                  new List<String>{''},
                                  'BPO__c', 'estimate mileage', 30, 'jchen@ucinnovation.com', 'hey yo tester');
            Test.stopTest();
        }catch(Exception e){
            System.assert( e.getMessage().contains('When updating distance, the Object name or Field name used to located the record to update ' + 
                                         ' does not match the ones in the Database') );
        }
    }

    @isTest static void test_testNotbalanceList_1() {
        Integer magicNumber = 100;
        Integer statusCode  = 200;

        String response = getCorrectJson( magicNumber );

        Map<String, String> headers = new Map<String, String>();
        Mock_SingleRequestCallout_GoogleMap fake_response_1 = new Mock_SingleRequestCallout_GoogleMap(
                                                                statusCode,
                                                                'Complete',
                                                                response,
                                                                headers
                                                            );

        Test.setMock(HttpCalloutMock.class, fake_response_1);
        Account a = [select Id from Account limit 1];
        Account b = [select Id from Account limit 1];
        try{
            Test.startTest();
            GoogleMap.update_distance(new List<String>{'one'}, new List<String>{'one'},
                                  new List<Id>{a.Id, b.Id}, new List<String>{''},
                                   'BPO__c', 'Estimated_Mileage__c', 30, 'jchen@ucinnovation.com', 'hey yo tester'); 
            Test.stopTest();
        }catch(Exception e){
            System.assert( e.getMessage().contains('The size of origins, destinations and recordIds are not the same') );
        }
    }
    
    @isTest static void test_testNotbalanceList_2() {
        Integer magicNumber = 100;
        Integer statusCode  = 200;

        String response = getCorrectJson( magicNumber );

        Map<String, String> headers = new Map<String, String>();
        Mock_SingleRequestCallout_GoogleMap fake_response_1 = new Mock_SingleRequestCallout_GoogleMap(
                                                                statusCode,
                                                                'Complete',
                                                                response,
                                                                headers
                                                            );

        Test.setMock(HttpCalloutMock.class, fake_response_1);
        Account a = [select Id from Account limit 1];
        try{
            Test.startTest();
            GoogleMap.update_distance(new List<String>{'one'}, new List<String>{'one', 'two'},
                                  new List<Id>{a.Id}, new List<String>{''},
                                  'BPO__c', 'Estimated_Mileage__c', 30, 'jchen@ucinnovation.com', 'hey yo tester');
            Test.stopTest();
        }catch(Exception e){
            System.assert( e.getMessage().contains('The size of origins, destinations and recordIds are not the same') );
        }
    }

    @isTest static void test_testNotbalanceList_3() {
        Integer magicNumber = 100;
        Integer statusCode  = 200;

        String response = getCorrectJson( magicNumber );

        Map<String, String> headers = new Map<String, String>();
        Mock_SingleRequestCallout_GoogleMap fake_response_1 = new Mock_SingleRequestCallout_GoogleMap(
                                                                statusCode,
                                                                'Complete',
                                                                response,
                                                                headers
                                                            );

        Test.setMock(HttpCalloutMock.class, fake_response_1);
        Account b = [select Id from Account limit 1];

        try{
            Test.startTest();
            GoogleMap.update_distance(new List<String>{'one', 'two'}, new List<String>{'one'},
                                  new List<Id>{b.Id}, 
                                  new List<String>{''}, 
                                  'BPO__c', 'Estimated_Mileage__c', 30, 'jchen@ucinnovation.com', 'hey yo tester');
            Test.stopTest();
        }catch(Exception e){
            System.assert( e.getMessage().contains('The size of origins, destinations and recordIds are not the same') );
        }
    }

    @isTest static void test_email_Limit(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        //sendTo.add(email);
        toAddresses.add('1jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('2jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('3jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('4jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('5jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('6jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('7jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('8jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('9jchen@ucinnovation.com');   // TODO: update email later 
        toAddresses.add('0jchen@ucinnovation.com');   // TODO: update email later 

        mail.setToAddresses(toAddresses);
        
        mail.setSenderDisplayName('username');

        mail.setSubject('Unable to provide estimated distance for Value/Reserve ' + 'recordName');

        mail.setHtmlBody('wow');

        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );

        //for(Integer i = 0; i < 20; i++){
            //GoogleMap.sendEmail('jchen@ucinnovation.com', 'test you', 'bilibala', '001d000001bpxv5', 'Estimated_Mileage__c');
            testHelperFunction(false, false, false, true);
        //}
    }

    //@isTest static void test_testInvalidJSON() {
    //  testHelperFunction(false, false, false, true);
    //}
    
    //@isTest static void test_testStatusCodeException() {
    //  testHelperFunction(false, true, false, false);  
    //}
    
    @isTest static void test_testLessthan30Miles() {
        testHelperFunction(false, false, true, false);
    }
    
    /*
    @isTest static void test_testCorrectCalculation() {
        testHelperFunction(true, false, false, false);
    }
    */
    private static void testHelperFunction(boolean testCorrectCalculation, 
                                           boolean testStatusCodeException, 
                                           boolean testLessthan30Miles,     
                                           boolean testInvalidJSON){
        // Implement test code
        // to test the googleMap, we need to update a Vendor in value/reserve 

        // 1. need two accounts for testing an update to a vendor
        // 2. need a BPO object to store the vendor
        // 3. update the vendor in the BPO

        /*
            vendor.BillingStreet    
            vendor.BillingCity      
            vendor.BillingState     
            vendor.BillingPostalCode

            newPOrder.Property_Street__c 
            newPOrder.Property_City__c   
            newPOrder.Property_State__c  
            newPOrder.Property_Zip_Postal_Code__c
        */

        /*----------- set up mock callout response ------------*/
        Integer magicNumber = 100;
        Integer statusCode  = 200;

        String response = getCorrectJson( magicNumber );

        if( testInvalidJSON ) response = getWrongJson( 'not a number' );

        if( testLessthan30Miles ) response = getCorrectJson(25);

        if( testStatusCodeException ) statusCode = 404;

        Map<String, String> headers = new Map<String, String>();
        Mock_SingleRequestCallout_GoogleMap fake_response_1 = new Mock_SingleRequestCallout_GoogleMap(
                                                                statusCode,
                                                                'Complete',
                                                                response,
                                                                headers
                                                            );

        Test.setMock(HttpCalloutMock.class, fake_response_1);

        ///*----------- set up data model for testing ------------*/

        Integer oldDistance = 10;
        Integer newDistance = 10;

        /*----------- perform necessary changes for testing ------------*/
        BPO__c kpo;
        // now, update the order and check that the estimated mileage get updated
        try{
            Test.startTest();
            //kpo = [select Id, Estimated_Mileage__c from BPO__c limit 1];

            //GoogleMap.update_distance(new List<String>{'san francisco'}, 
            //                    new List<String>{'san diego'}, 
            //                    /*new List<String>{kpo.Id}, */
            //                    'BPO__c', 'Estimated_Mileage__c', 30); 
            //Test.startTest();
            Account no_purpose = new Account(Name='heck -- Account Photo');
            insert no_purpose;
            newDistance = GoogleMap.calculate_Individual_Distance('san francisco', 'san diego', 'jchen@ucinnovation.com', 'crazy tester', no_purpose.Id, 'recordname');
            //GoogleMap.calculate_Individual_Distance('san francisco', 'san diego');
            Test.stopTest();

        }catch(Exception e){
            printExceptionMessages(e);
            System.assert( e instanceof GoogleMapException );

            //if( testStatusCodeException ){
            //  System.assert( e.getMessage().contains('Something wrong happened in connecting to GoogleMap Please try again!') );
            //}
            
            //if( testInvalidJSON ){
            //  System.assert( e.getMessage().contains('Please check if addresses are correct and try again!') );   
            //}
            // if testing exception, no need to figure out what the new value is
            return;
        }


        //newDistance = (Integer)([select Estimated_Mileage__c from BPO__c where Id = :(kpo.Id)].Estimated_Mileage__c);

        
        if( testLessthan30Miles ){
            // if calculated distance <= 30, newDistance should be set to null
            System.assert( newDistance <= 30 );
        }
        
        if( testCorrectCalculation ) {
            System.debug('new distance is: ' + newDistance);
            System.debug('magic number is: ' + magicNumber);
            System.assert(newDistance != oldDistance);
            System.assert(newDistance == magicNumber);
        }
    }

    private static String getCorrectJson(Integer expectedMile){
        return '{'+
                  + '"destination_addresses" : [ "Irvine, CA, USA" ],'
                  + '"origin_addresses" : [ "San Francisco, CA, USA" ],'
                  + '"rows" :['
                  +             '{'
                  +                 '"elements" :['
                  +                                 '{'
                  +                                     '"distance" :   {'
                  +                                                     '"text" : "' + expectedMile + ' mi",'
                  +                                                     '"value" : 677880'
                  +                                                 '},'
                  +                                     '"duration" :   {'
                  +                                                     '"text" : "6 hours 25 mins",'
                  +                                                     '"value" : 23092'
                  +                                                 '},'
                  +                                     '"status" : "OK"'
                  +                                 '}'
                  +                             ']'
                  +             '}'
                  +         '],'
                  + '"status" : "OK"'
            + '}';
    }

    private static String getWrongJson(String expectedMile){
        return '{'+
                  + '"destination_addresses" : [ "Irvine, CA, USA" ],'
                  + '"origin_addresses" : [ "San Francisco, CA, USA" ],'
                  + '"rows" :['
                  +             '{'
                  +                 '"elements" :['
                  +                                 '{'
                  +                                     '"no_distance" :    {'
                  +                                                     '"text" : "' + expectedMile + ' mi",'
                  +                                                     '"value" : 677880'
                  +                                                 '},'
                  +                                     '"duration" :   {'
                  +                                                     '"text" : "6 hours 25 mins",'
                  +                                                     '"value" : 23092'
                  +                                                 '},'
                  +                                     '"status" : "OK"'
                  +                                 '}'
                  +                             ']'
                  +             '}'
                  +         '],'
                  + '"status" : "OK"'
            + '}';
    }

    private static void printExceptionMessages(Exception e){
        System.debug('Cause: ' + e.getCause() );
        System.debug('Message: ' + e.getMessage() );
        System.debug('Line number ' + e.getLineNumber());
        System.debug('Stack Traces ' + e.getStackTraceString());
        System.debug('Type Name ' + e.getTypeName());
    }

    @testSetup static void test_googleMapException(){
        GoogleMapException gme = new GoogleMapException(1234567);
    }
}