@isTest
private class MapUtilsTests {

  private static final Integer NUM_OF_ACCOUNTS = 2;
  private static final Integer NUM_OF_CONTACTS = 3;
  
  @isTest static void validateContactsGroupedByAccountId() {
		List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		for (Account a : accounts) {
			List<Contact> cs = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS, 
				new Map<String, Object> { 'AccountId' => a.Id }
			);
			contacts.addAll(cs);
		}
		insert contacts;
        
		Map<Id, List<Contact>> accountContactMap = MapUtils.groupById(contacts, 'AccountId');
    System.assertEquals(NUM_OF_ACCOUNTS, accountContactMap.size());
    
    for (List<Contact> cs : accountContactMap.values()) {
        System.assertEquals(NUM_OF_CONTACTS, cs.size());
    }
  }

  @isTest static void validateGroupByIdHandlesNonIdField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<Id, List<Account>> accountMap = MapUtils.groupById(accounts, 'Name');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateGroupByIdHandlesInvalidField() {
    	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<Id, List<Account>> accountMap = MapUtils.groupById(accounts, 'Fake__c');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateCountOfAccountsById() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<AggregateResult> results = [SELECT OwnerId, COUNT(Id) FROM Account GROUP BY OwnerId];

		Map<Id, AggregateResult> idMap = MapUtils.groupById(results, 'OwnerId');
		System.assertEquals(1, idMap.size());
  }

  @isTest static void validateCountOfAccountsByNonIdField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<AggregateResult> results = [SELECT Type, COUNT(Id) FROM Account GROUP BY Type];
		
		Map<Id, AggregateResult> idMap = MapUtils.groupById(results, 'Id');
		System.assertEquals(0, idMap.size());
  }

  @isTest static void validateContactsGroupedByLeadSource() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		for (Account a : accounts) {
			List<Contact> cs = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS, 
				new Map<String, Object> { 
					'AccountId' => a.Id,
					'LeadSource' => 'Testing'
				}
			);
			contacts.addAll(cs);
		}
		insert contacts;
        
		Map<String, List<Contact>> accountContactMap = MapUtils.groupByString(contacts, 'LeadSource');
    System.assertEquals(1, accountContactMap.size());
    
    for (List<Contact> cs : accountContactMap.values()) {
      System.assertEquals(NUM_OF_ACCOUNTS * NUM_OF_CONTACTS, cs.size());
    }
  }

  @isTest static void validateGroupByStringHandlesNonStringField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		for (Account a : accounts) {
			List<Contact> cs = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS, 
				new Map<String, Object> { 
					'AccountId' => a.Id ,
					'Birthdate' => Date.today()
				}
			);
			contacts.addAll(cs);
		}
		insert contacts;

		Map<String, List<Contact>> accountContactMap = MapUtils.groupByString(contacts, 'Birthdate');
		System.assertEquals(0, accountContactMap.size());
  }

  @isTest static void validateGroupByStringHandlesInvalidField() {
    	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<String, List<Account>> accountMap = MapUtils.groupByString(accounts, 'Fake__c');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateCountOfAccountsByString() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<AggregateResult> results = [SELECT Type, COUNT(Id) FROM Account GROUP BY Type];

		Map<String, AggregateResult> idMap = MapUtils.groupByString(results, 'Type');
		System.assertEquals(1, idMap.size());
  }

  @isTest static void validateCountOfAccountsByNonStringField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<AggregateResult> results = [SELECT OwnerId, COUNT(Id) FROM Account GROUP BY OwnerId];
		
		Map<String, AggregateResult> idMap = MapUtils.groupByString(results, 'Id');
		System.assertEquals(0, idMap.size());
  }

  @isTest static void validateAccountsGroupedByNumOfEmployees() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS,
  		new Map<String, Object> {
  			'NumberOfEmployees' => 12345
  		}
  	);
		insert accounts;

		Map<Integer, List<Account>> accountMap = MapUtils.groupByInteger(accounts, 'NumberOfEmployees');
    System.assertEquals(1, accountMap.size());
    
    for (List<Account> accts : accountMap.values()) {
      System.assertEquals(NUM_OF_ACCOUNTS, accts.size());
    }
  }

  @isTest static void validateGroupByIntegerHandlesNonIntegerField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<Integer, List<Account>> accountMap = MapUtils.groupByInteger(accounts, 'Name');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateGroupByIntegerHandlesInvalidField() {
    	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<Integer, List<Account>> accountMap = MapUtils.groupByInteger(accounts, 'Fake__c');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateCountOfAccountsByInteger() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<AggregateResult> results = [SELECT NumberOfEmployees, COUNT(Id) FROM Account GROUP BY NumberOfEmployees];

		Map<Integer, AggregateResult> idMap = MapUtils.groupByInteger(results, 'NumberOfEmployees');
		System.assertEquals(1, idMap.size());
  }

  @isTest static void validateCountOfAccountsByNonIntegerField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<AggregateResult> results = [SELECT OwnerId, COUNT(Id) FROM Account GROUP BY OwnerId];
		
		Map<Integer, AggregateResult> idMap = MapUtils.groupByInteger(results, 'Id');
		System.assertEquals(0, idMap.size());
  }

  @isTest static void validateContactsGroupedByBirthdate() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < accounts.size(); i++) {
			List<Contact> cs = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS, 
				new Map<String, Object> { 
					'AccountId' => accounts[i].Id,
					'Birthdate' => Date.today().addDays((Math.mod(i,2) == 0 ? 0 : 1))
				}
			);
			contacts.addAll(cs);
		}
		insert contacts;
        
		Map<Date, List<Contact>> accountContactMap = MapUtils.groupByDate(contacts, 'Birthdate');
    System.assertEquals(2, accountContactMap.size());
    
    for (List<Contact> cs : accountContactMap.values()) {
      System.assertEquals((NUM_OF_ACCOUNTS / 2) * NUM_OF_CONTACTS, cs.size());
    }
  }

  @isTest static void validateGroupByDateHandlesNonDateField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<Date, List<Account>> accountMap = MapUtils.groupByDate(accounts, 'Name');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateGroupByDateHandlesInvalidField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		Map<Date, List<Account>> accountMap = MapUtils.groupByDate(accounts, 'Fake__c');
		System.assertEquals(0, accountMap.size());
  }

  @isTest static void validateCountOfAccountsByDate() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < accounts.size(); i++) {
			List<Contact> cs = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS, 
				new Map<String, Object> { 
					'AccountId' => accounts[i].Id,
					'Birthdate' => Date.today().addDays((Math.mod(i,2) == 0 ? 0 : 1))
				}
			);
			contacts.addAll(cs);
		}
		insert contacts;

		List<AggregateResult> results = [SELECT Birthdate, COUNT(Id) FROM Contact GROUP BY Birthdate];

		Map<Date, AggregateResult> idMap = MapUtils.groupByDate(results, 'Birthdate');
		System.assertEquals(NUM_OF_ACCOUNTS, idMap.size());
  }

  @isTest static void validateCountOfAccountsByNonDateField() {
  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < accounts.size(); i++) {
			List<Contact> cs = TestFactory.newInstance(Contact.class, NUM_OF_CONTACTS, 
				new Map<String, Object> { 
					'AccountId' => accounts[i].Id,
					'Birthdate' => Date.today().addDays((Math.mod(i,2) == 0 ? 0 : 1))
				}
			);
			contacts.addAll(cs);
		}
		insert contacts;

		List<AggregateResult> results = [SELECT OwnerId, COUNT(Id) FROM Contact GROUP BY OwnerId];
		
		Map<Date, AggregateResult> idMap = MapUtils.groupByDate(results, 'Id');
		System.assertEquals(0, idMap.size());
  }

  @isTest static void validateAddToMapReturnsNullIfMapPassedInIsNull() {
  	Map<String, List<Account>> accountMap = null;

  	MapUtils.addToMap(accountMap, 'Test', TestFactory.newInstance(Account.class, 1)[0]);
  	System.assertEquals(null, accountMap);
  }

  @isTest static void validateAddToMapReturnsUniqueElements() {
  	Map<String, List<Account>> accountMap = new Map<String, List<Account>>();

  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);

  	for (Integer i = 0; i < NUM_OF_ACCOUNTS; i++) {
  		MapUtils.addToMap(accountMap, 'Test' + String.valueOf(i), accounts[i]);
  	}
  	System.assertEquals(NUM_OF_ACCOUNTS, accountMap.size(), 'The size of the map should be equal to NUM_OF_ACCOUNTS');
  }

  @isTest static void validateAddToMapReturnsGroupedElements() {
  	Map<String, List<Account>> accountMap = new Map<String, List<Account>>();

  	List<Account> accounts = TestFactory.newInstance(Account.class, NUM_OF_ACCOUNTS);

  	for (Integer i = 0; i < NUM_OF_ACCOUNTS; i++) {
  		MapUtils.addToMap(accountMap, 'Test', accounts[i]);
  	}
  	System.assertEquals(1, accountMap.size(), 'The size of the map should be equal to 1');
  	System.assertEquals(NUM_OF_ACCOUNTS, accountMap.get('Test').size(), 'The size of the Test key should equal NUM_OF_ACCOUNTS');
  }
}