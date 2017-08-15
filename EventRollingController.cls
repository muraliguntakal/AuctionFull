public class EventRollingController {

	public static DateTime currentTime = System.now();
	public static String aoaQuery = 'SELECT Id, Assets__c, Opportunity__c, Opportunity__r.Loan_Number__c, Opportunity__r.Cleared_For_Auction__c, Opportunity__r.Return_to_Servicer_Date__c, Opportunity__r.Venue_Group__c, Opportunity__r.Account.Id, Opportunity__r.Account.Name, Assets__r.Property_Street__c, Assets__r.Property_State__c, Assets__r.Property_City__c, Assets__r.Property_Zip_Postal_Code__c, Auction_Campaign__c, Auction_Region__c, Auction_Bidding_Start_Time__c, Auction_Bidding_End_Time__c, Auction_MLH_Event_ID__c, Auction_MLH_Venue_ID__c, Run_Count__c, MLH_Pool_Number__c,Venue_Group__c, MLH_REDC_ID__c FROM Auction_Opportunity_Assignment__c WHERE Assets__c != null AND Most_Recent_AOA__c = true AND (NOT Opportunity__r.StageName LIKE \'%Closed%\')';
	public static RecordType resiRT = [SELECT Id FROM RecordType WHERE Name = 'Residential REO' AND SObjectType = 'Opportunity'];	

	/*
	*
	*/

	@RemoteAction
	public static Map<String, List<Auction_Opportunity_Assignment__c>> getEventsToRoll(){
		Map<String, List<Auction_Opportunity_Assignment__c>> aoaMap = new Map<String, List<Auction_Opportunity_Assignment__c>> ();

		Map<String, Map<String, List<String>>> queryJson = new Map<String, Map<String, List<String>>> ();
		String custFilter = ' AND Opportunity__r.RecordTypeId = \''+resiRT.Id+'\'';

		try {
			String jsonStr = [SELECT Body FROM StaticResource WHERE Name = 'EventRollerData' LIMIT 1].Body.toString();
			queryJson = deserializeData(jsonStr);

			if(!queryJson.isEmpty()){
				String queryStr = buildQueryStringFromJSON('Auction_Opportunity_Assignment__c', custFilter, queryJson);
				aoaMap = buildAOAMap(queryStr);
			}
	      	
	    } catch (System.Exception e) {
	      System.debug(e);
	    }

	    System.debug(aoaMap);
	    return aoaMap;
	}

	/*
	*
	*/

	private static Map<String, Map<String, List<String>>> deserializeData(String jsonStr) {
    	Map<String, Map<String, List<String>>> objMap = new Map<String, Map<String, List<String>>> ();

	    try {
	      objMap = (Map<String, Map<String, List<String>>>)JSON.deserialize(jsonStr, Map<String, Map<String, List<String>>>.class);
	      
	    } catch (System.Exception e) {
	      System.debug(e);
	    }
    	return objMap;
  	}

  	/*
	*
	*/

  	private static String buildQueryStringFromJSON(String baseSobj, String custFilters, Map<String, Map<String, List<String>>> jsonMap){
  		String queryStr = '';
  		Map<String, String> clauseStrMap = new Map<String, String> ();

  		for(String clause : jsonMap.keySet()){
  			Map<String, List<String>> clauseParams = jsonMap.get(clause);
  			String str = '';

  			if(clause != 'WHERE'){
  				for(String obj : clauseParams.keySet()){
  					String lookup = (obj == baseSobj) ? '' : obj+'.';

  					for(String fld : clauseParams.get(obj)){						
  						str += (str.length() == 0) ? lookup+fld : ','+lookup+fld;					
					}  					
  				}
  			}else{
  				if(clauseParams.containsKey('AND')){
  					for(String filter : clauseParams.get('AND')){
  						str += (clauseParams.get('AND')[0] == filter) ? filter : ' AND ' + filter;	
  					}
  					
  				}

  				if(clauseParams.containsKey('OR')){
  					str += ' AND (';
  					for(String filter : clauseParams.get('OR')){
  						str += (clauseParams.get('OR')[0] == filter) ? filter : ' OR ' + filter;
  					}  					
  					str += ')';
  				}
  			}

  			clauseStrMap.put(clause, str);
  		}

  		queryStr = 'SELECT ' + clauseStrMap.get('SELECT') + ' FROM ' + baseSobj + ' WHERE ' + clauseStrMap.get('WHERE') + ' ' + custFilters + ' ORDER BY ' + clauseStrMap.get('ORDER BY') + ' ASC';	

  		return queryStr;
  	}

  	/*
	*
	*/

  	private static Map<String, List<Auction_Opportunity_Assignment__c>> buildAOAMap(String queryStr){
  		Map<String, List<Auction_Opportunity_Assignment__c>> aoaMap = new Map<String, List<Auction_Opportunity_Assignment__c>>{
  			'active' => new List<Auction_Opportunity_Assignment__c> (),
  			'placeholder' => new List<Auction_Opportunity_Assignment__c> (),
  			'unk' => new List<Auction_Opportunity_Assignment__c> ()
  		};

  		if(queryStr.length() > 0){  			
  			for(Auction_Opportunity_Assignment__c aoa : (List<Auction_Opportunity_Assignment__c>)database.query(queryStr)){
  				String eventType = '';

  				if((String)aoa.get('MLH_Pool_Number__c') == 'UNK'){
  					eventType = 'unk';
  				}else if((Boolean)aoa.get('Placeholder_Event__c')){
  					eventType = 'placeholder';
  				}else if((DateTime)aoa.get('Auction_Bidding_End_Time__c') <= currentTime){
  					eventType = 'active';
  				}

  				if(eventType.length() > 0){
  					List<Auction_Opportunity_Assignment__c> aoas = aoaMap.get(eventType);
  					aoas.add(aoa);
  					aoaMap.put(eventType, aoas);
  				}
  			}
  		}

  		return aoaMap;
  	}









	/*
	*
	*/

	//@RemoteAction
	//public static List<Auction_Opportunity_Assignment__c> getActiveAOAs(){
	//	String resiRtId = String.valueOf(resiRT.Id);

	//	List<Auction_Opportunity_Assignment__c> aoas = 
	//		(List<Auction_Opportunity_Assignment__c>)database.query(aoaQuery+' AND Opportunity__r.RecordTypeId =: resiRtId AND Placeholder_Event__c = false AND Auction_Bidding_End_Time__c = Last_N_Days:2 AND Auction_Bidding_End_Time__c <=:currentTime AND Auction_MLH_Event_ID__c LIKE \'O-%\' AND MLH_Pool_Number__c != \'UNK\' ORDER BY Auction_Bidding_Start_Time__c ASC');

	//	return aoas;
	//}

	/*
	*
	*/

	//@RemoteAction
	//public static List<Auction_Opportunity_Assignment__c> getPlaceholderAOAs(){
	//	String resiRtId = String.valueOf(resiRT.Id);

	//	List<Auction_Opportunity_Assignment__c> aoas = 
	//		(List<Auction_Opportunity_Assignment__c>)database.query(aoaQuery+' AND Opportunity__r.RecordTypeId =: resiRtId AND Placeholder_Event__c = true AND Auction_MLH_Event_ID__c LIKE \'O-9%\' AND MLH_Pool_Number__c != \'UNK\' ORDER BY Opportunity__r.Property_State__c ASC');

	//	return aoas;
	//}

	/*
	*
	*/

	//@RemoteAction
	//public static List<Auction_Opportunity_Assignment__c> getUnkAOAs(){		
	//	String resiRtId = String.valueOf(resiRT.Id);

	//	List<Auction_Opportunity_Assignment__c> aoas = 
	//		(List<Auction_Opportunity_Assignment__c>)database.query(aoaQuery+' AND Opportunity__r.RecordTypeId =: resiRtId AND MLH_Pool_Number__c = \'UNK\' AND (Auction_Bidding_End_Time__c = Last_N_Days:10 OR Placeholder_Event__c = true)');

	//	return aoas;
	//}

	/*
	*
	*/	

	@RemoteAction
	public static Map<String, List<SObject>> getAuctionCampaigns(){
		Map<String, List<SObject>> campaigns = new Map<String, List<SObject>> ();
		List<Auction_Campaign__c> venues = (List<Auction_Campaign__c>)database.query('SELECT Id, Auction_Region__c, Auction_State__c, Bidding_Start_Time__c, Bidding_End_Time__c, Venue_Name__c, Venue_Number__c, Venue_Group__c, MLH_Event_Id__c, MLH_Venue_Id__c, MLH_Auction_ID2__c FROM Auction_Campaign__c WHERE (Bidding_Start_Date__c = TODAY OR Bidding_Start_Date__c = NEXT_N_DAYS:28) AND Placeholder_Event__c = false AND MLH_Event_Id__c LIKE \'O-%\' ORDER BY Bidding_Start_Date__c DESC');
		
		if(venues != null && !venues.isEmpty()){
			for(Auction_Campaign__c venue : venues){
				String venueStates = (String)venue.get('Auction_State__c');
				if(venueStates != null && venueStates.length() > 0){
					List<String> states = venueStates.split(';');	

					for(String state : states){
						if(!campaigns.containsKey(state)){
							campaigns.put(state, new List<SObject> ());
						}

						List<SObject> campaignsList = campaigns.get(state);
						campaignsList.add(venue);
						campaigns.put(state, campaignsList);
					}
				}
			}
		}

		return campaigns;
	}

	/*
	*
	*/

	@RemoteAction
	public static void unkAndRollAOAs(List<SObject> aoas, List<SObject> unkAOAs){
		System.debug(unkAOAs);
		
		List<Auction_Opportunity_Assignment__c> upsertAOAs = new List<Auction_Opportunity_Assignment__c> ();

		for(SObject so : aoas){
			Auction_Opportunity_Assignment__c aoa = (Auction_Opportunity_Assignment__c)so;
			upsertAOAs.add(aoa);
		}

		for(SObject so : unkAOAs){
			Auction_Opportunity_Assignment__c aoa = (Auction_Opportunity_Assignment__c)so;
			upsertAOAs.add(aoa);
		}

		if(!upsertAOAs.isEmpty()){
			upsert upsertAOAs;
		}
	}	
}