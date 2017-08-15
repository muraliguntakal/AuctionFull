global class AOAResiRunCountBatchable implements Database.Batchable<SObject>{

	global final DateTime upper;
	global final DateTime lower;
	//global String resiRtId;

	global AOAResiRunCountBatchable(DateTime upperBound, DateTime lowerBound){
		upper = upperBound;
		lower = lowerBound;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id, Opportunity__c FROM Auction_Opportunity_Assignment__c WHERE Line_Of_Business__c = \'Residential\' AND Auction_Bidding_End_Time__c <= :upper AND Auction_Bidding_End_Time__c >= :lower');
	}

	global void execute(Database.BatchableContext bc, List<Auction_Opportunity_Assignment__c> scope) {

		Map<String, List<Auction_Opportunity_Assignment__c>> aoaMap = MapUtils.groupByString(scope, 'Opportunity__c');
		Set<String> oppIds = aoaMap.keySet();

		//collect only aoas that should be included in the run count
		Map<String, Auction_Opportunity_Assignment__c> aoas = new Map<String, Auction_Opportunity_Assignment__c> ();
		List<Auction_Opportunity_Assignment__c> deleteAoas = new List<Auction_Opportunity_Assignment__c> ();
		for(Auction_Opportunity_Assignment__c aoa : database.query('SELECT Id, MLH_Auction_ID__c, Auction_Campaign__c, Opportunity__c FROM Auction_Opportunity_Assignment__c WHERE Opportunity__c IN : oppIds AND Included_in_Run_Count__c = TRUE AND Auction_Bidding_End_Time__c <= :upper')){			

			String mlhId = (String)aoa.get('MLH_Auction_ID__c');
			String campaign = (String)aoa.get('Auction_Campaign__c');
			String oppId = (String)aoa.get('Opportunity__c');
			String uid = oppId+'-'+campaign;

			if(!aoas.containsKey(uid)){
				if(mlhId != null && campaign != null){
					aoas.put(uid, aoa);
				}
			}else{
				if(mlhId == null){
					deleteAoas.add(aoa);
				}
			}
		}

		//update the run count on opportunities
		if(!aoas.isEmpty()){
			List<Opportunity> oppsForUpdate = new List<Opportunity> ();
			Map<String, List<Auction_Opportunity_Assignment__c>> oppToAoas = MapUtils.groupByString(aoas.values(), 'Opportunity__c');

			for(String oppId : oppToAoas.keySet()){
				Decimal runCount = oppToAoas.get(oppId).size();

				Opportunity opp = new Opportunity(Id = oppId);
				opp.put('Run_Number__c', runCount);
				oppsForUpdate.add(opp);
			}

			if(!oppsForUpdate.isEmpty()){
				update oppsForUpdate;
			}
		}

		//remove duplicate aoas
		if(!deleteAoas.isEmpty()){
			delete deleteAoas;
		}
	}

	global void finish(Database.BatchableContext bc) {
	}
}