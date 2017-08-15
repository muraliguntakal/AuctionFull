@isTest
private class TestFactoryTests {
  
  private static final Pattern dynDefaultPattern = Pattern.compile(
    '^.*\\{(index|size|today|now)\\}.*$' // Goofy text highlighting'
  );

  @isTest static void validateAccountAndContactRecordsCreated() {
    List<Account> accounts = TestFactory.newInstance(Account.class, 20);

    if (TestFactory.defaults.containsKey('Account')) {
      for (Integer i = 0; i < accounts.size(); i++) {
        Map<String, Object> fieldMap = TestFactory.defaults.get('Account');

        for (String field : fieldMap.keySet()) {
          Object fieldValue = fieldMap.get(field);

          if (fieldValue instanceOf String && dynDefaultPattern.matcher(String.valueOf(fieldValue)).matches()) {
            System.assert(accounts[i].get(field) != null);
          } else {
            System.assert(fieldValue == accounts[i].get(field));
          }
        }
      }
    }
    System.assertEquals(20, accounts.size());

    List<Contact> contacts = TestFactory.newInstance(Contact.class, 20);

    if (TestFactory.defaults.containsKey('Contact')) {
      for (Integer i = 0; i < contacts.size(); i++) {
        Map<String, Object> fieldMap = TestFactory.defaults.get('Contact');

        for (String field : fieldMap.keySet()) {
          Object fieldValue = fieldMap.get(field);

          if (fieldValue instanceOf String && dynDefaultPattern.matcher(String.valueOf(fieldValue)).matches()) {
            System.assert(contacts[i].get(field) != null);
          } else {
            System.assert(fieldValue == contacts[i].get(field));
          }
        }
      }
    }
    System.assertEquals(20, contacts.size());
  }

  @isTest static void validateOpportunityRecordsCreated() {
    List<Account> accounts = TestFactory.newInstance(Account.class, 20);
    List<Opportunity> opps = TestFactory.newInstance(Opportunity.class, 20);

    if (TestFactory.defaults.containsKey('Opportunity')) {
      for (Integer i = 0; i < accounts.size(); i++) {
        Map<String, Object> fieldMap = TestFactory.defaults.get('Opportunity');

        for (String field : fieldMap.keySet()) {
          Object fieldValue = fieldMap.get(field);

          if (fieldValue instanceOf String && dynDefaultPattern.matcher(String.valueOf(fieldValue)).matches()) {
            System.assert(opps[i].get(field) != null);
          } else {
            System.assert(fieldValue == opps[i].get(field));
          }
        }
      }
    }
    System.assertEquals(20, opps.size());
  }

  @isTest static void validatePersonalizedTestDataUsed() {
    TestFactory.setDefaults('{"Account":{"Type":"Testing"}}');
    System.assert(TestFactory.defaults.get('Account').containsKey('Type') == true);

    List<Account> newAccounts = TestFactory.newInstance(Account.class, 1);
    System.assert(TestFactory.defaults.get('Account').get('Type') == newAccounts[0].get('Type'));
  }

  @isTest static void validateNoFailureOnInvalidFieldInDefaults() {
    TestFactory.setDefaults('{"Account":{"Fake":"Testing"}}');
    List<Account> newAccounts = TestFactory.newInstance(Account.class, 1);
  }

  @isTest static void validateNoFailureOnInvalidFieldInOverride() {
    List<Account> newAccounts = TestFactory.newInstance(Account.class, 1,
      new Map<String, Object> { 'Fake' => 'Testing' }
    );
  }

  @isTest static void validateInvalidJSONString() {
    TestFactory.setDefaults('{"Account":"Fake":"Testing"}}');
    System.assertEquals(null, TestFactory.defaults);
  }
}