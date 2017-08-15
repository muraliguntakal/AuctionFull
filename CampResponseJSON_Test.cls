@IsTest
public class CampResponseJSON_Test {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"responses\": ['+
        '    {'+
        '      \"salesforce_intake_id\": \"TEST\",'+
        '      \"asset_id\": 11'+
        '    },'+
        '    {'+
        '      \"salesforce_intake_id\": \"TEST\",'+
        '      \"error_details\": {'+
        '        \"title\": \"Internal Server Error\",'+
        '        \"status\": 500,'+
        '        \"message\": \"Error calling Asset microservice\",'+
        '        \"date_time\": \"2016-05-12T20:40:01.115\",'+
        '        \"developer_message\": \"412 PRECONDITION_FAILED\"'+
        '      }'+
        '    }'+
        '  ]'+
        '}';
        CampResponseJSON obj = CampResponseJSON.parse(json);
        System.assert(obj != null);
    }
}