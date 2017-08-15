/**
 * SetUtils is a common set of utility methods. Brief descriptions of the methods
 * are provided below.
 */
public class SetUtils {

	/**
	 * Take a list of records and pull out a set of ID's based on a particular field. If 
	 * there is any type of exception an empty set will be returned. 
	 */
	public static Set<Id> getIds(List<SObject> records, String idField) {
		return getIds(records, idField, false);
	}

	/**
	 * Take a list of records and pull out a set of IDs based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty set will be returned.
	 */
  public static Set<Id> getIds(List<SObject> records, String idField, Boolean addDupes) {
        Set<Id> itemList = new Set<Id>();

        if (records != null && !records.isEmpty() && idField != null) {
            try {
                for (SObject so : records) {
                    Id val = (Id)so.get(idField);
                    if (addDupes || (!addDupes && !itemList.contains(val))) {
                        itemList.add((Id)so.get(idField));
                    }
                }
            } catch (System.Exception e) {
            	itemList = new Set<Id>();
                System.debug(e);
            }
        }
        return itemList;
    }
    
	/**
	 * Take a list of records and pull out a set of Strings based on a particular field. If 
	 * there is any type of exception an empty set will be returned. 
	 */
	public static Set<String> getStrings(List<SObject> records, String stringField) {
		return getStrings(records, stringField, false);
	}

	/**
	 * Take a list of records and pull out a set of Strings based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty set will be returned.
	 */
  public static Set<String> getStrings(List<SObject> records, String stringField, Boolean addDupes) {
        Set<String> itemList = new Set<String>();

        if (records != null && !records.isEmpty() && stringField != null) {
            try {
                for (SObject so : records) {
                    String val = (String)so.get(stringField);
                    if (addDupes || (!addDupes && !itemList.contains(val))) {
                        itemList.add((String)so.get(stringField));
                    }
                }
            } catch (System.Exception e) {
            	itemList = new Set<String>();
                System.debug(e);
            }
        }
        return itemList;
    }
    
  /**
	 * Take a list of records and pull out a set of Integers based on a particular field. If 
	 * there is any type of exception an empty set will be returned. 
	 */
	public static Set<Integer> getIntegers(List<SObject> records, String intField) {
		return getIntegers(records, intField, false);
	}

	/**
	 * Take a list of records and pull out a set of Integers based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty set will be returned.
	 */
  public static Set<Integer> getIntegers(List<SObject> records, String intField, Boolean addDupes) {
        Set<Integer> itemList = new Set<Integer>();

        if (records != null && !records.isEmpty() && intField != null) {
            try {
                for (SObject so : records) {
                    Integer val = (Integer)so.get(intField);
                    if (addDupes || (!addDupes && !itemList.contains(val))) {
                        itemList.add((Integer)so.get(intField));
                    }
                }
            } catch (System.Exception e) {
            	itemList = new Set<Integer>();
                System.debug(e);
            }
        }
        return itemList;
    }

  /**
	 * Take a list of records and pull out a set of Decimals based on a particular field. If 
	 * there is any type of exception an empty set will be returned. 
	 */
	public static Set<Decimal> getDecimals(List<SObject> records, String decField) {
		return getDecimals(records, decField, false);
	}

	/**
	 * Take a list of records and pull out a set of Decimals based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty set will be returned.
	 */
  public static Set<Decimal> getDecimals(List<SObject> records, String decField, Boolean addDupes) {
        Set<Decimal> itemList = new Set<Decimal>();

        if (records != null && !records.isEmpty() && decField != null) {
            try {
                for (SObject so : records) {
                    Decimal val = (Decimal)so.get(decField);
                    if (addDupes || (!addDupes && !itemList.contains(val))) {
                        itemList.add((Decimal)so.get(decField));
                    }
                }
            } catch (System.Exception e) {
            	itemList = new Set<Decimal>();
                System.debug(e);
            }
        }
        return itemList;
    }
    
  /**
	 * Take a list of records and pull out a set of Booleans based on a particular field. If 
	 * there is any type of exception an empty set will be returned. 
	 */
	public static Set<Boolean> getBooleans(List<SObject> records, String boolField) {
		return getBooleans(records, boolField, false);
	}

	/**
	 * Take a list of records and pull out a set of Booleans based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty set will be returned.
	 */
	public static Set<Boolean> getBooleans(List<SObject> records, String boolField, Boolean addDupes) {
        Set<Boolean> itemList = new Set<Boolean>();

        if (records != null && !records.isEmpty() && boolField != null) {
            try {
                for (SObject so : records) {
                    Boolean val = (Boolean)so.get(boolField);
                    if (addDupes || (!addDupes && !itemList.contains(val))) {
                        itemList.add((Boolean)so.get(boolField));
                    }
                }
            } catch (System.Exception e) {
            	itemList = new Set<Boolean>();
                System.debug(e);
            }
        }
        return itemList;
    }

  /**
	 * Take a list of records and pull out a set of Booleans based on a particular field. If 
	 * there is any type of exception an empty set will be returned. 
	 */
	public static Set<Date> getDates(List<SObject> records, String dateField) {
		return getDates(records, dateField, false);
	}

	/**
	 * Take a list of records and pull out a set of Booleans based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty set will be returned.
	 */
  public static Set<Date> getDates(List<SObject> records, String dateField, Boolean addDupes) {
        Set<Date> itemList = new Set<Date>();
        
        if (records != null && !records.isEmpty() && dateField != null) {
            try {
                for (SObject so : records) {
                    Date val = (Date)so.get(dateField);
                    if (addDupes || (!addDupes && !itemList.contains(val))) {
                        itemList.add((Date)so.get(dateField));
                    }
                }
            } catch (System.Exception e) {
            	itemList = new Set<Date>();
                System.debug(e);
            }
        }
        return itemList;
    }
}