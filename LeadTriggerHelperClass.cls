public class LeadTriggerHelperClass {
    public static boolean flagvalue = false;

    public static boolean hasAlreadyfired() {
    return flagvalue;
    }
    
    public static void setAlreadyfired() {
    flagvalue = true;
    }

}