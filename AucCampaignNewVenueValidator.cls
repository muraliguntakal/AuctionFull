public class AucCampaignNewVenueValidator {

/*
    public Set<Date> holidays;

    public AucCampaignNewVenueValidator(){
        holidays = new Set<Date> ();
        List<Holiday_Calendar__c> cal = Holiday_Calendar__c.getall().values();      

        for(Holiday_Calendar__c holiday : cal){
            holidays.add((Date)holiday.get('Date__c'));
        }
    }

    public void preValidate(Auction_Campaign__c ac, Auction_Campaign__c old_ac){
        Datetime bidStart = (Datetime)ac.get('Bidding_Start_Time__c');
        Datetime old_bidStart = (!Trigger.isInsert) ? (Datetime)old_ac.get('Bidding_Start_Time__c') : null;
        Datetime bidEnd = (Datetime)ac.get('Bidding_End_Time__c');
        String venueCode = ((String)ac.get('Venue_Number__c') != null) ? (String)ac.get('Venue_Number__c') : '';
        String venueName = ((String)ac.get('Venue_Name__c') != null) ? (String)ac.get('Venue_Name__c') : '';
        String eventId = ((String)ac.get('MLH_Event_Id__c') != null) ? (String)ac.get('MLH_Event_Id__c') : '';
        Boolean isHolidayClone = (Boolean)ac.get('Is_Holiday__c'); 

        if(!isHolidayClone && bidStart != null && bidStart != old_bidStart && venueCode != 'ZZ' && !venueName.contains('Nationwide') && eventId.length() > 2 && eventId.substring(0,2) == 'O-'){
            String venueGroup = AuctionCampaignUtilsHelper.assignVenueGroup(bidStart);
            ac.put('Venue_Group__c', venueGroup);

            if(venueCode.length() > 0){
                ac.put('SF_Calendar_Event_ID__c', eventId+'-'+venueCode+'-'+String.valueOf(bidStart.date())+'-'+venueGroup);
            }

            if(bidEnd != null){
                for(Date holiday : holidays){
                    if(holiday <= bidEnd.date() && holiday >= bidStart){
                        ac.put('Split_Holiday_Venue__c', true);
                        break;
                    }
                }
            } 
        }
    }
*/
}