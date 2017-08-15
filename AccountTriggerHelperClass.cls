public class AccountTriggerHelperClass {
private static boolean flagvalue = false;

public static boolean hasAlreadyfired() {
return flagvalue;
}

public static void setAlreadyfired() {
flagvalue = true;
}

public static void ResetAlreadyfired() {
flagvalue = false;
}

}