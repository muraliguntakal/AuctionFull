public class mlhAssetUploadResponse {

    public Status status;
    public List<Result> result;

    public class Result {
        public String  upload_status;
        public String  commit_status;
        public String  global_asset_id;
        public long    listing_id;        
        public String  event_number;
        public String  redc_id;
        public String  asset_address;
        public String  seller_loan_number;
        public String  salesforce_opportunity_id;
        public Integer error_count;
        public List<String> error_msg;
    }

    public class Status {
        public string code;
        public String message;
        public List<Errors> errors; // Replaced List<String> errors for Non-Auction
        public Debug debug;
    }

    public class Debug {
        public String build;
        public String  server_name;
        public Double  duration;
    }

    //Added for Non-Auction
    public class Errors {
        public String code;
        public String message;
        public String trace;
    }    

    public class MLHAuthException extends Exception {}
/*
    public class MLHAuthError {
        private String error {get;set;}
        private String error_description {get;set;}
    }
*/
    public static mlhAssetUploadResponse parse(String json) {
        system.debug('Response JSON => ' +json);
        return (mlhAssetUploadResponse) System.JSON.deserialize(json, mlhAssetUploadResponse.class);
    }
}