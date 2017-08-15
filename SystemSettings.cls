public without sharing class SystemSettings{
	private static Map<String, SystemSettings__c> systemSettingsMap;
	private static System.LoggingLevel debugLevel = LoggingLevel.DEBUG;
	
	public static String getsettingValueof(String settingName){
		if(null == systemSettingsMap){
			systemSettingsMap = SystemSettings__c.getAll();
		}
		
		SystemSettings__c thissystemSetting = systemSettingsMap.get(settingName);
		
		String res = null;
		
		if(null == thissystemSetting){
			system.debug(debugLevel, 'No setting found for trigger:  '+systemSettingsMap);
			res = null;
		} else {
			res = thissystemSetting.value__c;
		}
		
		return res;
	}
}