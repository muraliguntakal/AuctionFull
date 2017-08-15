global class AOARunCountBatchable implements Database.Batchable<sObject> {
	
	global AOARunCountBatchable() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Opportunity__c FROM Auction_Opportunity_Assignment__c WHERE (Line_Of_Business__c = \'Residential\' OR Line_Of_Business__c = \'Commercial\') AND Process_Run_Count__c = true AND Opportunity__c != null');
	}

   	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		Map<String, List<Auction_Opportunity_Assignment__c>> aoaMap = new Map<String, List<Auction_Opportunity_Assignment__c>> ();
		List<Auction_Opportunity_Assignment__c> aoasForUpdate = new List<Auction_Opportunity_Assignment__c> ();

		for(SObject so : scope){
			Auction_Opportunity_Assignment__c aoa = (Auction_Opportunity_Assignment__c)so;
			String oppId = (String)aoa.get('Opportunity__c');

			if(oppId != null){
				if(!aoaMap.containsKey(oppId)){
					aoaMap.put(oppId, new List<Auction_Opportunity_Assignment__c>());
				}

				List<Auction_Opportunity_Assignment__c> aoas = aoaMap.get(oppId);			
				aoas.add(aoa);
				aoaMap.put(oppId, aoas);
			}

			//set aoa flag to false so its not included in next batch
			aoa.put('Process_Run_Count__c', false);		
			aoasForUpdate.add(aoa);
		}

		//collect only aoas that should be included in the run count
		List<AggregateResult> runCounts = [SELECT COUNT(Id) runCount, Opportunity__c
											FROM Auction_Opportunity_Assignment__c
											WHERE Opportunity__c IN : aoaMap.keySet() AND Run_Count__c = 1
											GROUP BY Opportunity__c];

		//update the run count on opportunities
		if(!runCounts.isEmpty()){
			List<Opportunity> oppsForUpdate = new List<Opportunity> ();

			for(AggregateResult ar : runCounts){
				Decimal runCount = (Decimal)ar.get('runCount');
				String oppId = (String)ar.get('Opportunity__c');

				Opportunity opp = new Opportunity(Id = oppId);
				opp.put('Run_Number__c', runCount);
				oppsForUpdate.add(opp);
			}

			if(!oppsForUpdate.isEmpty()){
				update oppsForUpdate;
			}
		}

		//update the aoas to exclude them from the following batch;
		if(!aoasForUpdate.isEmpty()){
			update aoasForUpdate;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		AOARunCountBatchable runCountBatch = new AOARunCountBatchable();

		if(!Test.isRunningTest()){
			String cronID = System.scheduleBatch(runCountBatch, 'AOA Run Count Batch', 15);
		}
	}
	
}