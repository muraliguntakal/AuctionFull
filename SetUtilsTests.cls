@isTest
private class SetUtilsTests {

  private static final Integer NUM_OF_ACCOUNTS = 2;
  private static final Integer NUM_OF_CONTACTS = 1;
  
  @isTest static void validateGetIdsForIdFieldIsSuccessful() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    insert accounts;
    
    Set<Id> accountIds = SetUtils.getIds(accounts, 'Id');
    System.assertEquals(accounts.size(), accountIds.size());
  }
  
  @isTest static void validateGetIdsForFakeIdFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<Id> accountIds = SetUtils.getIds(accounts, 'FakeId');
    System.assertEquals(0, accountIds.size());
  }
  
  @isTest static void validateGetIdsForNonIdFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<Id> accountIds = SetUtils.getIds(accounts, 'Name');
    System.assertEquals(0, accountIds.size());
  }

  @isTest static void validateGetStringsForStringFieldIsSuccessful() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<String> accountIds = SetUtils.getStrings(accounts, 'Name');
    System.assertEquals(accounts.size(), accountIds.size());
  }
  
  @isTest static void validateGetStringsForFakeStringFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<String> accountIds = SetUtils.getStrings(accounts, 'FakeId');
    System.assertEquals(0, accountIds.size());
  }
  
  @isTest static void validateGetStringsForNonStringFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS,
    	new Map<String, Object> { 'NumberOfEmployees' => 50 }
    );
    Set<String> accountIds = SetUtils.getStrings(accounts, 'NumberOfEmployees');
    System.assertEquals(0, accountIds.size());
  }

  @isTest static void validateGetIntegersForIntegerFieldIsSuccessful() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    for (Account a : accounts) {
    	a.NumberOfEmployees = (Integer)(Math.random() * 5000);
    }
    Set<Integer> accountIds = SetUtils.getIntegers(accounts, 'NumberOfEmployees');
    System.assertEquals(accounts.size(), accountIds.size());
  }
  
  @isTest static void validateGetIntegersForFakeIntegerFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<Integer> accountIds = SetUtils.getIntegers(accounts, 'FakeId');
    System.assertEquals(0, accountIds.size());
  }
  
  @isTest static void validateGetIntegersForNonIntegerFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<Integer> accountIds = SetUtils.getIntegers(accounts, 'Name');
    System.assertEquals(0, accountIds.size());
  }

  @isTest static void validateGetDecimalsForDecimalFieldIsSuccessful() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    for (Account a : accounts) {
    	a.AnnualRevenue = Math.random() * 100000;
    }
    Set<Decimal> accountIds = SetUtils.getDecimals(accounts, 'AnnualRevenue');
    System.assertEquals(accounts.size(), accountIds.size());
  }
  
  @isTest static void validateGetDecimalsForFakeDecimalFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<Decimal> accountIds = SetUtils.getDecimals(accounts, 'FakeId');
    System.assertEquals(0, accountIds.size());
  }
  
  @isTest static void validateGetDecimalsForNonDecimalFieldInvalid() {
    List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
    Set<Decimal> accountIds = SetUtils.getDecimals(accounts, 'Name');
    System.assertEquals(0, accountIds.size());
  }

  @isTest static void validateGetBooleansForBooleanFieldIsSuccessful() {
    List<Contact> contacts = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS);
		Set<Boolean> contactIds = SetUtils.getBooleans(contacts, 'DoNotCall');
    System.assertEquals(contacts.size(), contactIds.size());
  }
  
  @isTest static void validateGetBooleansForFakeBooleanFieldInvalid() {
    List<Contact> contacts = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS);
		Set<Boolean> contactIds = SetUtils.getBooleans(contacts, 'FakeId');
    System.assertEquals(0, contactIds.size());
  }
  
  @isTest static void validateGetBooleansForNonBooleanFieldInvalid() {
    List<Contact> contacts = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS);
		Set<Boolean> contactIds = SetUtils.getBooleans(contacts, 'FirstName');
    System.assertEquals(0, contactIds.size());
  }

  @isTest static void validateGetDatesForDateFieldIsSuccessful() {
    List<Contact> contacts = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS);
		Set<Date> contactIds = SetUtils.getDates(contacts, 'Birthdate');
    System.assertEquals(contacts.size(), contactIds.size());
  }
  
  @isTest static void validateGetDatesForFakeDateFieldInvalid() {
    List<Contact> contacts = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS);
		Set<Date> contactIds = SetUtils.getDates(contacts, 'FakeId');
    System.assertEquals(0, contactIds.size());
  }
  
  @isTest static void validateGetDatesForNonDateFieldInvalid() {
    List<Contact> contacts = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS);
		Set<Date> contactIds = SetUtils.getDates(contacts, 'FirstName');
    System.assertEquals(0, contactIds.size());
  }
}