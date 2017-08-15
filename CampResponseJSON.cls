public class CampResponseJSON{

    public List<Responses> responses;

    public class Error_details {
        public String title;
        public Integer status;
        public String message;
        public String date_time;
        public String developer_message;
    }

    public class Responses {
        public String salesforce_intake_id;
        public Integer asset_id;
        public Integer listing_id;
        public Error_details error_details;
    }
    
    public static CampResponseJSON parse(String json) {
        return (CampResponseJSON) System.JSON.deserialize(json, CampResponseJSON.class);
    }
}