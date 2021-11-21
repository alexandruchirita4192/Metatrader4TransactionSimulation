#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/TransactionData.mqh>
#include <MyMql/Global/Config/GlobalConfig.mqh>
#include <MyMql/Global/Log/FileLog.mqh>
#include <MyMql/Global/Log/Xml/XmlElement.mqh>
#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/Global/Symbols/SymbolsLibrary.mqh>
#include <MyMql/Global/Money/Generator/LimitGenerator.mqh>
#include <MyMql/Global/Info/ScreenInfo.mqh>
#include <MyMql/Global/Info/VerboseInfo.mqh>
#include <MyMql/Global/Log/FileLog.mqh>
#include <MyMql/Global/GlobalVariableCommunication.mqh>

#include <MyMql/Global/BaseGlobal.mqh>

class LimitGenerator;


class Global : public BaseGlobal
{
	public:
		// Constructor
		Global()
		{
		   Screen.DeleteAllObjects();
		   LogInfoMessage("Global constructor initialized");
		}
		
		GlobalConfig Config;
	   WebServiceLog DatabaseLog;
		//XmlElement SessionXmlData; // not used for now
		BaseMoneyManagement Money;
		SymbolsLibrary Library;
		LimitGenerator Limit;
		ScreenInfo Screen;
		VerboseInfo Verbose;
		
		void GlobalDeInit()
		{
		   Screen.DeleteAllObjects();
      	GlobalContext.DatabaseLog.WebServiceLogDeinit();
      	GlobalContext.Config.ConfigInfoDeinit();
      	
		   LogInfoMessage("GlobalDeInit executed");
		}
};

static Global GlobalContext;


string GetConfigFileValue()
{
   return GlobalContext.Config.GetValue("ConfigFile");
}
