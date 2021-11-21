#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <stderror.mqh>
#include <stdlib.mqh>

void PrintLog(string message) { OutputDebugStringW(message); }

#define PrintLastError if(_LastError != 0) PrintLog("file=" + __FILE__ + " function=" + __FUNCTION__ + " line=" + IntegerToString(__LINE__) + " Error=\"" + ErrorDescription(_LastError) + "\" [" + IntegerToString(_LastError) + "]");

#define _S Print(__FUNCTION__);
#define _E Print(__FUNCTION__);

#define _SW GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), __FUNCTION__, __FUNCSIG__); GlobalContext.DatabaseLog.CallWebServiceProcedure("StartProcedureLog");
#define _EW GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), __FUNCTION__); GlobalContext.DatabaseLog.CallWebServiceProcedure("EndProcedureLog");


#include <MyMql/Global/Log/WebServiceLog.mqh>

class LimitGenerator;
class BaseGlobal : public BaseObject
{
public:
	BaseGlobal() {}
	bool ChartIsChanging;

	virtual void InitRefresh()
	{
		this.ChartIsChanging = false;
		ResetLastError();
		ChartSetSymbolPeriod(0, _Symbol, _Period);
		RefreshRates();
	}
};

//static BaseGlobal DatabaseContext;
