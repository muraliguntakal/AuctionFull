public class CampRequestJSON {

public CampRequestJSON()
{
assets = new list<Assets>();
}

    public class Asset_address {

        public String street_name;
        public String postal_code;
        public String municipality;
        public String country_secondary_subdivision;
        public String country_subdivision;
        public String country_code;
        
        public Asset_address()
        {
            street_name ='';
            postal_code='';
            municipality='';
            country_secondary_subdivision='';
            country_subdivision='';
            country_code='';
        }
    }

    public List<Assets> assets;

    public class Assets {
        public String parent_opportunity_status;
        public Asset_fields asset_fields;
        public Parties parties;
        
        public Assets()
        {
            parent_opportunity_status ='';
            asset_fields = new Asset_fields();
            parties = new Parties();
        }
    }

    public class Asset_fields {
        public String asset_id;
        public String salesforce_asset_id;
        public String asset_name;
        public String primary_asset_type;
        public String primary_asset_sub_type;
        public String line_of_business;
        public Asset_address asset_address;
                
         public Asset_fields()
        {
         salesforce_asset_id ='';
         asset_name ='';
         primary_asset_type ='';
         primary_asset_sub_type ='';
         line_of_business ='';
         asset_address= new Asset_address();
            
        }
    }
    
     public class Parties {
        public Integer sales_channel_id;
        public Listing_salesforce_reference listing_salesforce_reference;
        public List<Listing_brokers> listing_brokers;
        public List<Listing_sellers> listing_sellers;
        public List<Listing_party_roles> listing_party_roles;
        
       public Parties ()
        {
            listing_salesforce_reference = new Listing_salesforce_reference();
            listing_brokers = new list<Listing_brokers>();
            listing_sellers = new list<Listing_sellers>();
            Listing_party_roles = new list<Listing_party_roles>();
        }

    }

    public class Listing_brokers {
        public String listing_broker_company;
        public String first_name;
        public String last_name;
        public String phone;
        public String email;
        public String license_number;
        public String license_state;
        public String salesforce_contact_id;
        public Asset_address address;
        
        public Listing_brokers()
        {
            listing_broker_company ='';
            first_name ='';
            last_name= '';
            phone='';
            email='';
            license_number ='';
            license_state='';
            salesforce_contact_id='';
           // address= new Asset_address(); 
            address= null;          
        }

    }

    public class Listing_sellers {
        public String first_name;
        public String last_name;
        public String email;
        public String phone;
        public String salesforce_contact_id;
        public String seller_company;
        
        public Listing_sellers()
         {
             first_name = '';
             last_name= '';
             email= '';
             phone='';
             salesforce_contact_id='';   
             seller_company='';       
         }
    }
    
        public class Listing_party_roles 
         {
                public Integer role_type_id;
                public String first_name;
                public String last_name;
                public String phone;
                public String email;
                
            public Listing_party_roles()
             {
                 first_name= '';
                 last_name= '';
                 phone='';
                 email='';          
              }
          }


    public class Listing_salesforce_reference {
        public String salesforce_parent_opportunity_id;
        public String salesforce_intake_id;
        public String salesforce_primary_campaign_id;
        
        public Listing_salesforce_reference()
        {
         salesforce_parent_opportunity_id='';
         salesforce_intake_id='';
         salesforce_primary_campaign_id='';         
        }
     }
    
  public static CampRequestJSON parse(String json) {
        return (CampRequestJSON) System.JSON.deserialize(json, CampRequestJSON.class);
    }
}