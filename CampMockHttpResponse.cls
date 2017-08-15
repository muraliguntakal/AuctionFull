@isTest
global class CampMockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.qa.auction.com/salesforce/v1/asset', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"salesforce_intake_id":"a0O110000082g7oEAA","asset_id":1024,"listing_id":29}]}');
        res.setStatusCode(200);
        return res;
    }
}