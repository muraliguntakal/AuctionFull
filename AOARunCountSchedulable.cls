global class AOARunCountSchedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		AOARunCountBatchable b = new AOARunCountBatchable();
		database.executebatch(b);
	}
}