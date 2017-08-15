/**
 * MapUtils is a common set of utility methods. Brief descriptions of the methods
 * are provided below.
 */
public class MapUtils {

  /**
   * Take a list of records and group them by a particular ID field resulting in a map
   * of ID's to subset of the list of records. If the idField is not truly an Id field
   * then it will be excluded and the map will be returned empty.
   */
  public static Map<Id, List<SObject>> groupById(List<SObject> records, String idField) {
    Map<Id, List<SObject>> itemMap = new Map<Id, List<SObject>>();

    if (records != null && !records.isEmpty() && idField != null) {
      try {
        for (SObject so : records) {
          List<SObject> itemList = new List<SObject>();
          Id val = (Id)so.get(idField);

          if (itemMap.containsKey(val)) {
            itemList = itemMap.get(val);
          }
          itemList.add(so);
          itemMap.put(val, itemList);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of aggregate result records and push each value to a map. If the idField is not 
   * truly an Id field then it will be excluded and the map will be returned empty.
   */
  public static Map<Id, AggregateResult> groupById(List<AggregateResult> records, String idField) {
    Map<Id, AggregateResult> itemMap = new Map<Id, AggregateResult>();

    if (records != null && !records.isEmpty() && idField != null) {
      try {
        for (AggregateResult ar : records) {
          itemMap.put((Id)ar.get(idField), ar);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of records and group them by a particular String field resulting in a map
   * of String's to subset of the list of records. If the stringField is not truly a String field
   * then it will be excluded and the map will be returned empty.
   */
  public static Map<String, List<SObject>> groupByString(List<SObject> records, String stringField) {
    Map<String, List<SObject>> itemMap = new Map<String, List<SObject>>();

    if (records != null && !records.isEmpty() && stringField != null) {
      try {
        for (SObject so : records) {
          List<SObject> itemList = new List<SObject>();
          String val = (String)so.get(stringField);

          if (itemMap.containsKey(val)) {
            itemList = itemMap.get(val);
          }
          itemList.add(so);
          itemMap.put(val, itemList);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of aggregate result records and push each value to a map. If the idField is not 
   * truly an String field then it will be excluded and the map will be returned empty.
   */
  public static Map<String, AggregateResult> groupByString(List<AggregateResult> records, String idField) {
    Map<String, AggregateResult> itemMap = new Map<String, AggregateResult>();

    if (records != null && !records.isEmpty() && idField != null) {
      try {
        for (AggregateResult ar : records) {
          itemMap.put((String)ar.get(idField), ar);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of records and group them by a particular Integer field resulting in a map
   * of Integer's to subset of the list of records. If the intField is not truly a Integer field
   * then it will be excluded and the map will be returned empty.
   */
  public static Map<Integer, List<SObject>> groupByInteger(List<SObject> records, String intField) {
    Map<Integer, List<SObject>> itemMap = new Map<Integer, List<SObject>>();

    if (records != null && !records.isEmpty() && intField != null) {
      try {
        for (SObject so : records) {
          List<SObject> itemList = new List<SObject>();
          Integer val = (Integer)so.get(intField);

          if (itemMap.containsKey(val)) {
            itemList = itemMap.get(val);
          }
          itemList.add(so);
          itemMap.put(val, itemList);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of aggregate result records and push each value to a map. If the idField is not 
   * truly an Integer field then it will be excluded and the map will be returned empty.
   */
  public static Map<Integer, AggregateResult> groupByInteger(List<AggregateResult> records, String idField) {
    Map<Integer, AggregateResult> itemMap = new Map<Integer, AggregateResult>();

    if (records != null && !records.isEmpty() && idField != null) {
      try {
        for (AggregateResult ar : records) {
          itemMap.put((Integer)ar.get(idField), ar);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of records and group them by a particular Date field resulting in a map
   * of Date's to subset of the list of records. If the dateField is not truly a Date field
   * then it will be excluded and the map will be returned empty.
   */
  public static Map<Date, List<SObject>> groupByDate(List<SObject> records, String dateField) {
    Map<Date, List<SObject>> itemMap = new Map<Date, List<SObject>>();

    if (records != null && !records.isEmpty() && dateField != null) {
      try {
        for (SObject so : records) {
          List<SObject> itemList = new List<SObject>();
          Date val = (Date)so.get(dateField);

          if (itemMap.containsKey(val)) {
            itemList = itemMap.get(val);
          }
          itemList.add(so);
          itemMap.put(val, itemList);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Take a list of aggregate result records and push each value to a map. If the idField is not 
   * truly an Date field then it will be excluded and the map will be returned empty.
   */
  public static Map<Date, AggregateResult> groupByDate(List<AggregateResult> records, String idField) {
    Map<Date, AggregateResult> itemMap = new Map<Date, AggregateResult>();

    if (records != null && !records.isEmpty() && idField != null) {
      try {
        for (AggregateResult ar : records) {
          itemMap.put((Date)ar.get(idField), ar);
        }
      } catch (System.Exception e) {
        System.debug(e);
      }
    }
    return itemMap;
  }

  /**
   * Providing the map that needs to have an (key,value) pair added to the map, check to see if
   * the key already exists in the map and if so push that value onto the list.
   */
  public static void addToMap(Map<String, List<SObject>> soMap, String key, SObject so) {
    if (soMap != null) {
      if (!soMap.containsKey(key)) {
        soMap.put(key, new List<SObject>());
      }
      List<SObject> soList = soMap.get(key);
      soList.add(so);
    }
  }
}