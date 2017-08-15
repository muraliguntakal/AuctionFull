public class AOAUtils {

	public static Boolean oppUpdatesComplete = false;
	public static Boolean bidUpdatesComplete = false;
	public static Boolean bpoUpdatesComplete = false;

	public static void validateAoaUpdates(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap){

		if(Trigger.isBefore){
			for(Auction_Opportunity_Assignment__c aoa : newList){				
				String aoaId = (String)aoa.get('Id');
				String line = (String)aoa.get('Line_Of_Business__c');
				String oppId = (String)aoa.get('Opportunity__c');
				String status = (String)aoa.get('Status__c');
				String productType = (String)aoa.get('MLH_Product_Type__c');	
				Auction_Opportunity_Assignment__c oldAoa = (!Trigger.isInsert) ? oldMap.get(aoaId) : null;

				if(Trigger.isInsert){			
					aoa.put('Requires_Processing__c', true);
					if(oppId != null && line != 'Trustee'){
						aoa.put('Process_Run_Count__c', true);
					}
				}
								
				if(Trigger.isUpdate){
					String oldOppId = (!Trigger.isInsert) ? (String)oldAoa.get('Opportunity__c') : null;
					String oldStatus = (!Trigger.isInsert) ? (String)oldAoa.get('Status__c') : null;					
					String oldProductType = (!Trigger.isInsert) ? (String)oldAoa.get('MLH_Product_Type__c') : null;
					Date removedDate = (Date)aoa.get('Removed_Date__c');
					Date oldRemovedDate = (!Trigger.isInsert) ? (Date)oldAoa.get('Removed_Date__c') : null;					

					if(oppId != null && line != 'Trustee' && ( (oppId != oldOppId) || (status != oldStatus) || (productType != oldProductType) || (removedDate != oldRemovedDate) ) ){
						aoa.put('Process_Run_Count__c', true);
					}

					if(status == 'Deleted' && (status != oldStatus) && (Boolean)aoa.get('Most_Recent_AOA__c')){
						aoa.put('Requires_Processing__c', true);
					}
				}
			}
		}
	}


	/*
	*	Queuable Job
	*/

	public static void validateMostRecentAOAUpdates(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap){
		Boolean shouldExecute = Trigger.isInsert ? true : false;

		if(!shouldExecute && Trigger.isUpdate && Trigger.isAfter){			
			for(Auction_Opportunity_Assignment__c aoa : newList){
				String aoaId = (String)aoa.get('Id');
				String status = (String)aoa.get('Status__c');
				String oldStatus = (String)oldMap.get(aoaId).get('Status__c');

				if(status == 'Deleted' && status != oldStatus){
					shouldExecute = true;
					break;
				}
			}
		}

		if(shouldExecute){
			SystemSettings__c ss = null;
	    	Boolean isRunning = false;

	    	if (SystemSettings__c.getAll().containsKey('MostRecentAOAJobId')) {
	    		ss = SystemSettings__c.getAll().get('MostRecentAOAJobId');

	    		if (ss.Value__c != null) {
	    			try {
		    			AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE ID = :ss.Value__c];
		    			isRunning = (job.Status != 'Completed' && job.Status != 'Aborted' && job.Status != 'Failed');
		    		} catch (System.Exception e) {}
	    		}
	  		} else {
	  			ss = new SystemSettings__c(Name = 'MostRecentAOAJobId');
	  			insert ss;
	  		}

	  		if (!isRunning) {
	  			String jobId = System.enqueueJob(new AOAMostRecentUpdatesJob());

	  			ss.Value__c = jobId;
	  			update ss;
	  		}
		}
	}

	/*
	*
	*/

	public static void validateOpportunityUpdates(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap){
		Map<String, Opportunity> oppsForUpdate = new Map<String, Opportunity> ();

		if(Trigger.isUpdate && Trigger.isAfter && !oppUpdatesComplete){
			AOAUpdateOppMlhFieldsValidator oppUpdateValidator = new AOAUpdateOppMlhFieldsValidator ();

			for(Auction_Opportunity_Assignment__c aoa : newList){
				String aoaId = (String)aoa.get('Id');
				Auction_Opportunity_Assignment__c oldAoa = oldMap.get(aoaId);

				oppUpdateValidator.preValidate(aoa, oldAoa, oppsForUpdate);
				oppUpdatesComplete = true;	
			}

			if(!oppsForUpdate.isEmpty()){
				try{
					update oppsForUpdate.values();
				} catch(Exception e){
					//exception logic
				}
			}
		}
	}

	/*
	*
	*/

	public static void validateBidUpdates(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap){
		Map<String, Bid__c> bidsForUpdate = new Map<String, Bid__c> ();

		if(Trigger.isUpdate && Trigger.isAfter && !bidUpdatesComplete){
			AOAWinningBidValidator findWinningBidValidator = new AOAWinningBidValidator();
			AOAUpdateWinningBidValidator updateBidValidator = new AOAUpdateWinningBidValidator();

			for(Auction_Opportunity_Assignment__c aoa : newList){
				String aoaId = (String)aoa.get('Id');
				Auction_Opportunity_Assignment__c oldAoa = oldMap.get(aoaId);

				findWinningBidValidator.preValidate(aoa, oldAoa);
				updateBidValidator.preValidate(aoa, oldAoa);
			}

			findWinningBidValidator.validate();
			updateBidValidator.validate(bidsForUpdate);
			bidUpdatesComplete = true;
		}

		if(!bidsForUpdate.isEmpty()){
			try{
				update bidsForUpdate.values();
			}catch(Exception e){
				//exception logic
			}
		}
	}

	/*
	*
	*/

	public static void validateBpoUpdates(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap){
		
		if(Trigger.isUpdate && Trigger.isAfter && !bpoUpdatesComplete){
			AOAUpdateBPOValidator bpoValidator = new AOAUpdateBPOValidator();

			for(Auction_Opportunity_Assignment__c aoa : newList){
				String aoaId = (String)aoa.get('Id');
				Auction_Opportunity_Assignment__c oldAoa = oldMap.get(aoaId);

				bpoValidator.preValidate(aoa, oldAoa);
			}

			bpoValidator.validate();
			bpoUpdatesComplete = true;
		}
	}


	/**
	* 	Validate if the SellerCode is different on an incoming aoa than the program enrollment on the opportunity. If so update the program enrollment
	* 	on the Opportunity and Asset Management record to reflect the seller code change. BYOB.
	*/

	public static void validateAOASellerCode(List<Auction_Opportunity_Assignment__c> newList, Map<Id, Auction_Opportunity_Assignment__c> oldMap){
		if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
			Map<String, Opportunity> opptyUpdates = new Map<String, Opportunity> ();
			Map<String, Asset_Management__c> amUpdates = new Map<String, Asset_Management__c> ();
			AOASellerCodeValidator.validate(newList, oldMap, opptyUpdates, amUpdates);

			if(!opptyUpdates.isEmpty() && !amUpdates.isEmpty()){
				try{
					update opptyUpdates.values();
					update amUpdates.values();
				}catch(Exception e){
					System.debug(e);
				}
			}
		}
	}
}