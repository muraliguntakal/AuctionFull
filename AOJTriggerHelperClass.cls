public class AOJTriggerHelperClass {

private static boolean flagvalue = false;

public static boolean hasAlreadyfiredAOJ() {
return flagvalue;
}

public static void setAlreadyfiredAOJ() {
flagvalue = true;
}

public static void ResetAlreadyfiredAOJ() {
flagvalue = false;
}

}