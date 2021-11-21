#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/Config/ConfigInfo.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>
		
string FirstSymbol, LastSymbol, CurrentSymbol;
int FirstPeriod, LastPeriod;


string configFullPath = "C:\\Users\\alexa\\AppData\\Roaming\\MetaQuotes\\Terminal\\2E8DC23981084565FA3E19C061F586B2\\MQL4\\Files\\Config.txt";


//Global context config data
class GlobalConfig : public ConfigInfo
{	
	public:
		GlobalConfig() : ConfigInfo(configFullPath) {}
		GlobalConfig(
			bool IsExpertAdviser,
			bool UseChartSymbol,
			bool OnlyOneSymbol,
			bool OnlyOnePeriod) : ConfigInfo(configFullPath)
		{
			Initialize(UseChartSymbol, IsExpertAdviser, OnlyOneSymbol, OnlyOnePeriod);
		}
		
		void Initialize()
		{
			UpdateSymbolAndPeriod();
			
			//SetValue("NewTime", TimeToString(Time[0]));
			SetValue("NewTime", TimeToString(TimeCurrent())); // TimeToString(Time[0]) -> TimeToString(TimeCurrent()):  Crash because Time[0] is "out of bounds"
			
			if(!GetBoolValue("OnlyOneSymbol"))
				CheckLastSymbolAndPeriodChange(false);
		}
		
		void Initialize(
		   bool IsExpertAdviser,
			bool UseChartSymbol,
			bool OnlyOneSymbol,
			bool OnlyOnePeriod,
			string ConfigFile = "")
		{
			SetBoolValue("IsExpertAdviser", IsExpertAdviser);
			SetBoolValue("UseChartSymbol", UseChartSymbol);
			SetBoolValue("OnlyOneSymbol", OnlyOneSymbol);
			SetBoolValue("OnlyOnePeriod", OnlyOnePeriod);
			
			if (!StringIsNullOrEmpty(ConfigFile)) // do not update with bullshit value (initial value might be better)
			{
			   SetValue("ConfigFile", ConfigFile);
   		   //LogInfoMessage("ConfigFile updated");
			}
			
			Initialize();
		}
		
		string GetConfigFile() { return GetValue("ConfigFile"); }
		string GetSessionName() { return GetConfigFile(); }
		
		bool IsNewBar()
		{
			if(GetTimeValue("NewTime") != iTime(_Symbol, _Period, 0))
			{
			   if (TimeToString(iTime(_Symbol, _Period, 0)) != GetValue("NewTime"))
				   SetValue("NewTime", TimeToString(iTime(_Symbol, _Period, 0))); // saves data to file!!!
				
				return true;
			}
			return false;
		}
		
		void InitCurrentSymbol(string symbol) { CurrentSymbol = symbol; }
		void UpdateSymbol(string symbol = NULL)
		{
			if(!GetBoolValue("UseChartSymbol"))
				InitCurrentSymbol(OrderGetString(ORDER_SYMBOL));
			else
			{
				if(!StringIsNullOrEmpty(symbol))
					InitCurrentSymbol(symbol);
				else
					InitCurrentSymbol(_Symbol);
			}
		}
		
		void UpdateSymbolAndPeriod()
		{
			UpdateSymbol();
			SetValue("Period", IntegerToString(PeriodSeconds()/60));
		}
		
		bool IsTradeAllowedOnEA(string symbol = NULL, bool showWarnings = true)
		{
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			
			bool isTradeAllowed = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
			datetime currentTime = iTime(symbol, PERIOD_CURRENT, 0);
			bool isTradeAllowedOnSymbol = IsTradeAllowed(symbol, currentTime);
			bool isTradeAllowedOnEASetting = GetBoolValue("IsTradeAllowedOnEA");
			bool isExpertAdviserSetting = GetBoolValue("IsExpertAdviser");
			
			if((!isTradeAllowed) && (showWarnings))
			   Print("IsTradeAllowed() returned false");
			   
			if((!isTradeAllowedOnSymbol) && (showWarnings))
			   Print("IsTradeAllowed(symbol, currentTime) returned false; cannot trade at this hour");
			
			if((!isTradeAllowedOnEASetting) && (showWarnings))
			   Print("IsTradeAllowedOnEA setting is false; configure this better");
			
			if((!isExpertAdviserSetting) && (showWarnings))
			   Print("IsExpertAdviser setting is false; configure this better");
			
			if(isTradeAllowed && // test trading in general
   			isTradeAllowedOnSymbol && // test trading now for current symbol
   			isTradeAllowedOnEASetting && // test config stuff
   			isExpertAdviserSetting
			)
				return true;
			return false;
		}
		void AllowTrades() { SetBoolValue("IsTradeAllowedOnEA", true); }
		void DenyTrades() { SetBoolValue("IsTradeAllowedOnEA", false); }		
		
		bool IsExpertAdviser() { return GetBoolValue("IsExpertAdviser"); }
		bool IsIndicator() { return !GetBoolValue("IsExpertAdviser"); }
		
		bool VirtualLimits() { return GetBoolValue("IsExpertAdviser") && GetBoolValue("VirtualLimits"); }
		void UseVirtualLimits() { SetBoolValue("VirtualLimits", true); }
		void UseTPsAndSLs() { SetBoolValue("VirtualLimits", false); }
		
		string GetSymbol() { UpdateSymbol(); return CurrentSymbol; }
		int GetPeriod() { return GetIntegerValue("Period"); }
		
		bool IsOnlyOneSymbol() { return GetBoolValue("OnlyOneSymbol"); }
		void UseOnlyOneSymbol() { SetBoolValue("OnlyOneSymbol", true); }
		void UseMultipleSymbols() { SetBoolValue("OnlyOneSymbol", false); }
		
		bool IsOnlyOnePeriod() { return GetBoolValue("OnlyOnePeriod"); }
		void UseOnlyOnePeriod() { SetBoolValue("OnlyOnePeriod", true); }
		void UseMultiplePeriod() { SetBoolValue("OnlyOnePeriod", false); }
		
		// work with order symbol vs. work with current chart symbol
		bool IsChartSymbol() { return GetBoolValue("UseChartSymbol"); }
		bool IsOrderSymbol() { return !GetBoolValue("UseChartSymbol"); }
		void UseChartSymbol() { SetBoolValue("UseChartSymbol", true); }
		void UseOrderSymbol() { SetBoolValue("UseChartSymbol", false); }
		
		void UseBulkWebServiceRequests() { SetBoolValue("UseBulkRequestsInsteadOfIndividualRequests", true); }
		void UseIndividualWebServiceRequests() { SetBoolValue("UseBulkRequestsInsteadOfIndividualRequests", false); }
		bool IsBulk() { return GetBoolValue("UseBulkRequestsInsteadOfIndividualRequests"); }
		
		bool CheckLastSymbolChange(bool verbose)
		{
			if(GetBoolValue("OnlyOneSymbol"))
				return false;
			
			bool isChanged = false;
			if (LastSymbol == NULL) // || (FirstSymbol == NULL)
			{
				LastSymbol = _Symbol;
				FirstSymbol = _Symbol;
				
				if(verbose)
					Print ("First running symbol ", LastSymbol, ".");
			}
			else
			{
				if (LastSymbol != _Symbol)
				{
					if(verbose)
						Print ("Symbol changed. Last symbol was ", LastSymbol, ", but now is ", _Symbol, ".");
					LastSymbol = _Symbol;
					isChanged = true;
				}
			}
			return isChanged;
		}
		
		bool CheckLastPeriodChange(bool verbose)
		{
			if(GetBoolValue("OnlyOnePeriod"))
				return false;
			
			bool isChanged = false;
			if (LastPeriod == 0) // || (FirstPeriod == "")
			{
				LastPeriod = _Period;
				FirstPeriod = _Period;
				if(verbose)
					Print ("First running period ", LastPeriod);
			}
			else
			{
				if (LastPeriod != _Period)
				{
					if(verbose)
						Print ("Period has changed. Last period was ", LastPeriod, ", but now is ",_Period, ".");
					LastPeriod = _Period;
					isChanged = true;
				}
			}
			return isChanged;
		}
		
		bool CheckLastSymbolAndPeriodChange(bool verbose)
		{
			if(GetBoolValue("OnlyOneSymbol"))
				return false;
			
			bool isChanged = false;
			isChanged = isChanged || CheckLastPeriodChange(verbose);
			isChanged = isChanged || CheckLastSymbolChange(verbose);	
			return isChanged;
		}
		
		void ChangePeriod()
		{
			if(GetBoolValue("OnlyOnePeriod"))
				return;
			SetValue("NewTime", TimeToString(iTime(_Symbol, _Period, 0)));
			
			bool foundCurrentPeriod = false;
			if(_Period == FirstPeriod)
				foundCurrentPeriod = true;
			
			for(int i=0;i<PeriodTotal();i++)
			{
				ENUM_TIMEFRAMES t = PeriodValue(i);
				
				if((t == _Period) && (_Period != FirstPeriod))
				{
					foundCurrentPeriod = true;
					continue;
				}
				
				if((foundCurrentPeriod) && (t != FirstPeriod))
				{
					string periodString = EnumToString(t);
					StringReplace(periodString, "PERIOD_", "");
					ChartChange(periodString);
					
					//bool isOk = ChartSetSymbolPeriod(0, _Symbol, t);
					//if(!isOk)
					//{
					//	string message = "Error changing symbol: " + ErrorDescription(GetLastError());
					//	Print(message);
					//	//GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					//	//	GlobalContext.Config.GetSessionName(),
					//	//	__FUNCTION__ + " " + message,
					//	//	TimeAsParameter());
					//}
					break;
				}
			}
		}
		
		bool ChangeSymbol(string symbol, ENUM_TIMEFRAMES newPeriod, bool useKeyBoardChangeChart = false)
		{
			if((GetBoolValue("OnlyOneSymbol")) && (!StringIsNullOrEmpty(symbol)))
			{
				Print("Closed because of config onlyOneSymbol");
				return false;
			}
			if((GetBoolValue("OnlyOnePeriod")) && (newPeriod != PERIOD_CURRENT) && (IntegerToTimeFrame(_Period) != newPeriod))
			{
				Print("Closed because of config onlyOnePeriod");
				return false;
			}
			SetValue("NewTime", TimeToString(iTime(_Symbol, _Period, 0)));
			
			if(StringIsNullOrEmpty(FirstSymbol))
			{
				FirstSymbol = _Symbol;
				FirstPeriod = _Period;
			}
			
			CurrentSymbol = symbol;
			if(useKeyBoardChangeChart)
			{
				Print(__FUNCTION__ + " ChartChange(" + symbol + "); from " + _Symbol);
				ChartChange(symbol);
			}
			else
			{
				Print(__FUNCTION__ + " ChartSetSymbolPeriod(ChartID(), " + symbol + ", PERIOD_CURRENT); from " + _Symbol);
				bool isOk = ChartSetSymbolPeriod(ChartID(), symbol, newPeriod);
				if(!isOk)
				{
					Print(__FUNCTION__ + " " + IntegerToString(__LINE__) + " Error changing symbol: ", IntegerToString(_LastError) + " details: " + ErrorDescription(_LastError));
					ResetLastError();
					return false;
				}
				return isOk;
			}
			return true;
		}
		
		string GetNextSymbol(string _symbol = NULL)
		{
			if(StringIsNullOrEmpty(_symbol))
				_symbol = _Symbol;
			
			bool foundCurrentSymbol = false;
			
			if(_symbol == FirstSymbol)
				foundCurrentSymbol = true;
			
			int total = SymbolsTotal(false);
			for(int i=0;i<total;i++)
			{
				string symbol = SymbolName(i, false);
				
				if((symbol == _symbol) && (_symbol != FirstSymbol))
				{
					foundCurrentSymbol = true;
					continue;
				}
				/*
				// if the current symbol is the last symbol, go to first symbol to include all symbols
   			else if(symbol == _symbol && (i == total-1))
				{
				   return SymbolName(0, false);
				}
				*/
				
				if((foundCurrentSymbol) && (symbol != FirstSymbol))
					return symbol;
			}
			
			return NULL;
		}
		
		bool ChangeSymbol(bool useKeyBoardChangeChart = false)
		{
			if(GetBoolValue("OnlyOneSymbol"))
				return false;
			SetValue("NewTime", TimeToString(iTime(_Symbol, _Period, 0)));
			
			CurrentSymbol = GetNextSymbol(_Symbol);
			
			if(StringIsNullOrEmpty(CurrentSymbol))
				return false;
			
			if(useKeyBoardChangeChart)
			{
				Print(__FUNCTION__ + " ChartChange(" + CurrentSymbol + "); from " + _Symbol);
				ChartChange(CurrentSymbol);
				return true;
			}
			else
			{
				Print(__FUNCTION__ + " ChartSetSymbolPeriod(ChartID(), " + CurrentSymbol + ", PERIOD_CURRENT); from " + _Symbol);
				bool isOk = ChartSetSymbolPeriod(ChartID(), CurrentSymbol, PERIOD_CURRENT);
				if(!isOk)
				{
					Print(__FUNCTION__ + " " + IntegerToString(__LINE__) + " Error changing symbol: ", IntegerToString(_LastError) + " details: " + ErrorDescription(_LastError));
					ResetLastError();
					return false;
				}
				else
					Sleep(1);
				isOk = ChartSetSymbolPeriod(ChartID(), CurrentSymbol, PERIOD_CURRENT);
				return isOk;
			}
			
			return false;
		}
};
