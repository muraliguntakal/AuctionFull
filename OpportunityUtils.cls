public class OpportunityUtils {

	public static void validateBPOUpdates(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
		if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
			OpportunityCreateValuationValidator oppValuationValidator = new OpportunityCreateValuationValidator();

			for(Opportunity opp : newList){			
				Opportunity oldOpp = (!Trigger.isInsert) ? oldMap.get(opp.Id) : null;

				oppValuationValidator.preValidate(opp, oldOpp);
			}
			
			oppValuationValidator.validate();						
		}
	}
}