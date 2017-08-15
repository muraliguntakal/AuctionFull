public interface ModifyBaseObjectInterface {

	// Returns the hashCode for the class implementating the interface
	String getHashCode();

	// Boolean expression to determine whether a validator should perform it's work on a given trigger context
	Boolean validatesOn(ModifyObject.TriggerContext context);

	// Boolean expression to specify whether or not the validator requires a query to perform it's DML
	Boolean requiresQuery();

	// Boolean expression to specify whether a validator should/should not execute recursively
	Boolean shouldExecuteRecursively();

	// Method to validate that a change is required on a given SObject. If so put the amended SObject on the map
	void validate(SObject so, SObject oldSo);

	// When a change requires a query to validate this method is called to gather the records needed to query
	void preValidate(SObject so, SObject oldSo, List<SObject> soToUpdate);

	// When a change requires a query to validate this method will perform the validation in bulk and amended the records
	void validate(List<SObject> soToUpdate);
}