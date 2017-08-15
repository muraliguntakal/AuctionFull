@isTest
public class CampMockTestUtil {
    
    public static void RestOrderManagerMockTests() {
    
        system.debug('Mock');    
        string ALT_TOKEN_RESOURCE_TEST_RESPONSE ='Camp_Response';
        string ALT_TOKEN_SERVICE_URL = 'https://api.auction.com/salesforce/v1/asset';

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(ALT_TOKEN_SERVICE_URL,ALT_TOKEN_RESOURCE_TEST_RESPONSE);
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
    }

}