global class AOAResiRunCountSchedulable implements Schedulable {
	global void execute(SchedulableContext sc) {

		AOAResiRunCountBatchable b = new AOAResiRunCountBatchable(Datetime.now(), Datetime.now() - 1);
		database.executebatch(b);
	}
}