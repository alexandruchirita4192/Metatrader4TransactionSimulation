//+------------------------------------------------------------------+
//|                                      GetWebServiceDataOnline.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#include <MyMql\Global\Log\WebServiceLog.mqh> // not used because of errors - missing other needed files (caused by circular include/reference)
#include <MyMql\Global\Global.mqh>

int OnInit()
{
	GlobalContext.DatabaseLog.Initialize(false);
	GlobalContext.DatabaseLog.ParametersSet("GetWebServiceDataOnline.mq4");
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	
	GlobalContext.DatabaseLog.LogOldOfflineData(ConstOfflineFile);
	
	//GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile());
	GlobalContext.DatabaseLog.ParametersSet("GetWebServiceDataOnline.mq4");
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	
	return(INIT_SUCCEEDED);
}
