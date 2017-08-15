@istest
public class TestTriggerHelperClass {
private static boolean flagvalue = false;

static testmethod boolean hasAlreadyfired() {
return flagvalue;
}

static testmethod void setAlreadyfired() {
flagvalue = true;
}

}