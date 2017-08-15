/**
 * ListUtils is a common list of utility methods. Brief descriptions of the methods
 * are provided below.
 */
public class ListUtils {

	/**
	 * Take a list of records and pull out a list of ID's based on a particular field. If 
	 * there is any type of exception an empty list will be returned. 
	 */
	public static List<Id> getIds(List<SObject> records, String idField) {
		return getIds(records, idField, false);
	}

	/**
	 * Take a list of records and pull out a list of IDs based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty list will be returned.
	 */
  public static List<Id> getIds(List<SObject> records, String idField, Boolean addDupes) {
      List<Id> itemList = new List<Id>();

      if (records != null && !records.isEmpty() && idField != null) {
          try {
              for (SObject so : records) {
                  Id val = (Id)so.get(idField);
                  if (addDupes || (!addDupes && !doesListContain(itemList, val))) {
                      itemList.add((Id)so.get(idField));
                  }
              }
          } catch (System.Exception e) {
          	itemList = new List<Id>();
              System.debug(e);
          }
      }
      return itemList;
  }
    
	/**
	 * Take a list of records and pull out a list of Strings based on a particular field. If 
	 * there is any type of exception an empty list will be returned. 
	 */
	public static List<String> getStrings(List<SObject> records, String stringField) {
		return getStrings(records, stringField, false);
	}

	/**
	 * Take a list of records and pull out a list of Strings based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty list will be returned.
	 */
  public static List<String> getStrings(List<SObject> records, String stringField, Boolean addDupes) {
      List<String> itemList = new List<String>();

      if (records != null && !records.isEmpty() && stringField != null) {
          try {
              for (SObject so : records) {
                  String val = (String)so.get(stringField);
                  if (addDupes || (!addDupes && !doesListContain(itemList, val))) {
                      itemList.add((String)so.get(stringField));
                  }
              }
          } catch (System.Exception e) {
          	itemList = new List<String>();
              System.debug(e);
          }
      }
      return itemList;
  }
    
  /**
	 * Take a list of records and pull out a list of Integers based on a particular field. If 
	 * there is any type of exception an empty list will be returned. 
	 */
	public static List<Integer> getIntegers(List<SObject> records, String intField) {
		return getIntegers(records, intField, false);
	}

	/**
	 * Take a list of records and pull out a list of Integers based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty list will be returned.
	 */
  public static List<Integer> getIntegers(List<SObject> records, String intField, Boolean addDupes) {
      List<Integer> itemList = new List<Integer>();

      if (records != null && !records.isEmpty() && intField != null) {
          try {
              for (SObject so : records) {
                  Integer val = (Integer)so.get(intField);
                  if (addDupes || (!addDupes && !doesListContain(itemList, val))) {
                      itemList.add((Integer)so.get(intField));
                  }
              }
          } catch (System.Exception e) {
          	itemList = new List<Integer>();
              System.debug(e);
          }
      }
      return itemList;
  }

  /**
	 * Take a list of records and pull out a list of Decimals based on a particular field. If 
	 * there is any type of exception an empty list will be returned. 
	 */
	public static List<Decimal> getDecimals(List<SObject> records, String decField) {
		return getDecimals(records, decField, false);
	}

	/**
	 * Take a list of records and pull out a list of Decimals based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty list will be returned.
	 */
  public static List<Decimal> getDecimals(List<SObject> records, String decField, Boolean addDupes) {
      List<Decimal> itemList = new List<Decimal>();

      if (records != null && !records.isEmpty() && decField != null) {
          try {
              for (SObject so : records) {
                  Decimal val = (Decimal)so.get(decField);
                  if (addDupes || (!addDupes && !doesListContain(itemList, val))) {
                      itemList.add((Decimal)so.get(decField));
                  }
              }
          } catch (System.Exception e) {
          	itemList = new List<Decimal>();
              System.debug(e);
          }
      }
      return itemList;
  }
    
  /**
	 * Take a list of records and pull out a list of Booleans based on a particular field. If 
	 * there is any type of exception an empty list will be returned. 
	 */
	public static List<Boolean> getBooleans(List<SObject> records, String boolField) {
		return getBooleans(records, boolField, false);
	}

	/**
	 * Take a list of records and pull out a list of Booleans based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty list will be returned.
	 */
	public static List<Boolean> getBooleans(List<SObject> records, String boolField, Boolean addDupes) {
    List<Boolean> itemList = new List<Boolean>();

    if (records != null && !records.isEmpty() && boolField != null) {
        try {
            for (SObject so : records) {
                Boolean val = (Boolean)so.get(boolField);
                if (addDupes || (!addDupes && !doesListContain(itemList, val))) {
                    itemList.add((Boolean)so.get(boolField));
                }
            }
        } catch (System.Exception e) {
        	itemList = new List<Boolean>();
            System.debug(e);
        }
    }
    return itemList;
  }

  /**
	 * Take a list of records and pull out a list of Booleans based on a particular field. If 
	 * there is any type of exception an empty list will be returned. 
	 */
	public static List<Date> getDates(List<SObject> records, String dateField) {
		return getDates(records, dateField, false);
	}

	/**
	 * Take a list of records and pull out a list of Booleans based on a particular field. If
	 * there needs to be duplicates added for some reason then TRUE can be passed to the 
	 * addDupes parameter. If there is any type of exception an empty list will be returned.
	 */
  public static List<Date> getDates(List<SObject> records, String dateField, Boolean addDupes) {
    List<Date> itemList = new List<Date>();
    
    if (records != null && !records.isEmpty() && dateField != null) {
        try {
            for (SObject so : records) {
                Date val = (Date)so.get(dateField);
                if (addDupes || (!addDupes && !doesListContain(itemList, val))) {
                    itemList.add((Date)so.get(dateField));
                }
            }
        } catch (System.Exception e) {
        	itemList = new List<Date>();
            System.debug(e);
        }
    }
    return itemList;
  }

  /**
   * Since Lists don't have a contains method, we will build one so that all wrapper methods
   * can leverage the same functionality.
   */
  private static Boolean doesListContain(List<Object> records, Object source) {
  	Boolean isFound = false;

  	if (records != null && !records.isEmpty() && source != null) {
  		for (Object record : records) {
  			if (source == record) {
  				isFound = true;
  				break;
  			}
  		}
  	}
  	return isFound;
  }
}