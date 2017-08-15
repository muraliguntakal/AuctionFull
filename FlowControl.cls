/*************************************************************************************
* Name          :    FlowControl
* Description   :    Created to Control Recursive Triggers
* Author        :    Harish Emmadi
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
08/21/2013       Harish Emmadi            Created
**************************************************************************************/
public class FlowControl {
	//---------------------------Application Automation Trigger Control--------------------------

	private static boolean runBidTriggerHandler            		  = true;
	private static boolean runcallrecordTriggerHandler            = true;

	//Return the run trigger boolean 
	public static boolean runBidTriggerHandler() { return runBidTriggerHandler; }
	public static boolean runcallrecordTriggerHandler() { return runcallrecordTriggerHandler; }

	//Set the run Trigger boolean
	public static void setRunBidTriggerHandler(boolean value){
		runBidTriggerHandler = value;
	}
    public static void setRuncallrecordTriggerHandler(boolean value){
		runcallrecordTriggerHandler = value;
	}
	
	//reset all trigger control variables.
	public static void resetAll() { 
		setRunBidTriggerHandler(true);
		setRuncallrecordTriggerHandler(true);
	}

	private static LoggingLevel  logLevel  		= LoggingLevel.INFO;

	//  Dynamically set logging Level to avoid setup noise in long logs
	public static LoggingLevel getLogLevel()             { return logLevel; }
	public static void  setLogLevel(LoggingLevel lvl)    { logLevel =  lvl; System.debug(LoggingLevel.INFO,'>>>>>>>>>>Debug level set to ' + lvl + ' <<<<<<<<<<<'); }

}