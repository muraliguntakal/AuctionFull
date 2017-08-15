/**
 * TestFactory represents a single testing factory class for all objects within the
 * SFDC platform. The purpose of this class is to minimize the amount of effort
 * required to build Apex test classes. Additionally, if used correctly building test
 * classes with this framework will speed the process of future refactoring when new
 * requirements break historical code. 
 */
public class TestFactory {

  /**
   * A map of the defaults for all objects. This is initially set via a static 
   * resource. The format of the defaults is a JSON string.
   */
  public static Map<String, Map<String, Object>> defaults { get; private set; }

  static {
    setDefaults();
  }

  /**
   * Query the test factory static resource and deserialize the JSON string into 
   * an internal data structure. 
   */
  public static void setDefaults() {
    try {
      String jsonStr = [SELECT Body FROM StaticResource WHERE Name = 'TestFactoryData' LIMIT 1].Body.toString();
      defaults = deserializeTestData(jsonStr);
    } catch (System.Exception e) {
      System.debug(e);
    }
  }

  /**
   * Override the defaults with this method.
   */
  public static void setDefaults(String jsonStr) {
    defaults = deserializeTestData(jsonStr);
  }

  /**
   * Create a list of records of type (t) and return the records populated with the defaults.
   */
  public static List<SObject> newInstance(Type t, Integer numOfRecords) {
    return newInstance(t, numOfRecords, null);
  }

  /**
   * Create a list of records of type (t) and return the records populated with the defaults
   * and overridden with anything in the parameters argument.
   */
  public static List<SObject> newInstance(Type t, List<Map<String, Object>> parameters) {
    List<SObject> records = new List<SObject>();

    for (Integer i = 1; i <= parameters.size(); i++) {
      SObject so = (SObject)t.newInstance();

      setFieldValues(so, defaults.get(t.getName()), true, i, parameters.size());
      setFieldValues(so, parameters[i-1], false, 0, 0);

      records.add(so);
    }
    System.debug(records);
    return records;
  }

  /**
   * Create a list of records of type (t) and return the records populated with the defaults
   * and overridden with anything in the parameters argument.
   */
  public static List<SObject> newInstance(Type t, Integer numOfRecords, Map<String, Object> parameters) {
    List<SObject> records = new List<SObject>();

    for (Integer i = 1; i <= numOfRecords; i++) {
      SObject so = (SObject)t.newInstance();

      setFieldValues(so, defaults.get(t.getName()), true, i, numOfRecords);
      setFieldValues(so, parameters, false, 0, 0);

      records.add(so);
    }
    System.debug(records);
    return records;
  }

  /**
   * Use the field map to populate the record with either default values or exact values. 
   */
  private static void setFieldValues(SObject so, Map<String, Object> fieldMap, Boolean isDefault, Integer index, Integer size) {
    if (fieldMap != null) {
      for (String fm : fieldMap.keySet()) {
        try {
          so.put(fm, (isDefault ? getDefaultValue(fieldMap.get(fm), index, size) : fieldMap.get(fm)));
        } catch (System.Exception e) {
          System.debug(e);
        }
      }
    }
  }

  /**
   * Use the static defaults to either merge data into the default value or override the
   * value altogether. 
   */
  private static Object getDefaultValue(Object val, Integer index, Integer size) {
    final Map<String, List<Object>> staticDefaults = new Map<String, List<Object>> {
      '{index}' => new List<Object> {'\\{index\\}', true, String.valueOf(index)}, 
      '{size}' => new List<Object> {'\\{size\\}', true, String.valueOf(size)}, 
      '{today}' => new List<Object> {null, false, Date.today()}, 
      '{now}' => new List<Object> {null, false, DateTime.now()}
    };
    String valStr = String.valueOf(val);
    Object defaultValue = null;

    for (String sd : staticDefaults.keySet()) {
      if (valStr.contains(sd)) {
        Boolean shouldEmbedInString = (Boolean)staticDefaults.get(sd)[1];

        if (shouldEmbedInString) {
          valStr = valStr.replaceAll(String.valueOf(staticDefaults.get(sd)[0]), String.valueOf(staticDefaults.get(sd)[2]));
          defaultValue = valStr;
        } else {
          defaultValue = staticDefaults.get(sd)[2];
          break;
        }
      }
    }
    return (defaultValue != null ? defaultValue : val);
  }

  /**
   * Deserialize the JSON string into an internal data structure that can be used to 
   * populate record defaults.
   */
  private static Map<String, Map<String, Object>> deserializeTestData(String jsonStr) {
    Map<String, Map<String, Object>> objMap = null;

    try {
      Map<String, Object> testDataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
      objMap = new Map<String, Map<String, Object>>();

      for (String objName : testDataMap.keySet()) {
        objMap.put(objName, (Map<String, Object>)testDataMap.get(objName));
      }
    } catch (System.Exception e) {
      System.debug(e);
    }
    return objMap;
  }
}