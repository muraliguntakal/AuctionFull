public class RecursionHelper {

    private static Map<String, Boolean> doProcess = new Map<String, Boolean>();
    
    public static void BlockProcess(String triggerName) {
        doProcess.put(triggerName, false);
    }
    
    public static void AllowProcess(String triggerName) {
        doProcess.put(triggerName, true);
    }
    
    public static Boolean CanProcess(String triggerName) {
        return doProcess.get(triggerName) == null ? true : doProcess.get(triggerName);
    }   
}