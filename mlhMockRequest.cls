public class mlhMockRequest implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public mlhMockRequest(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
                system.debug('HTTP callout not supported for test methods');
            return null;
        }
    }
}