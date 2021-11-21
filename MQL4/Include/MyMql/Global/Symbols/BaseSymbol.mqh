#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Base/BeforeObjectMQL4.mqh>
#include <MyMql/Base/BaseObject.mqh>
#include <MyMql/Global/Global.mqh>

class BaseSymbol : public BaseObject
{
	protected:
		string SymbolsList[];
		
	public:
		BaseSymbol()
		{
			bool watchList = GlobalContext.Config.GetBoolValue("OnlyWatchListSymbols");
			int len = SymbolsTotal(watchList);
			ArrayResize(SymbolsList, len);
			
			for(int i=0; i<len; i++)
				SymbolsList[i] = SymbolName(i, watchList);
				
			//AddVirtualSymbols();
		}
		
//		virtual void AddVirtualSymbols()
//		{
//			if(!SymbolExists("BTCBIT"))
//			{
//				int len = ArraySize(SymbolsList);
//				ArrayResize(SymbolsList, len+1);
//				SymbolsList[len] = "BTCBIT";
//			}
//			
//			if(!SymbolExists("EURBIT"))
//			{
//				int len = ArraySize(SymbolsList);
//				ArrayResize(SymbolsList, len+1);
//				SymbolsList[len] = "EURBIT";
//			}
//		}
//		
//		virtual bool IsVirtualSymbol(string symbolName)
//		{
//			return (symbolName == "BTCBIT");				
//		}
		
		virtual string SymbolDescription(string symbolName)
		{
			return SymbolInfoString(symbolName, SYMBOL_DESCRIPTION);
		}
		
		virtual string ExtractSymbolBaseCurrency(string symbolName)
		{
			return StringSubstr(symbolName, 0, 3);
		}
		
		virtual string ExtractSymbolProfitCurrency(string symbolName)
		{
			return StringSubstr(symbolName, 3, 3);
		}
		
		virtual string SymbolProfitCurrency(string symbolName)
		{
			return SymbolInfoString(symbolName, SYMBOL_CURRENCY_PROFIT);
		}
		
		virtual string SymbolMarginCurrency(string symbolName)
		{
			return SymbolInfoString(symbolName, SYMBOL_CURRENCY_MARGIN);
		}
		
		virtual string SymbolBaseCurrency(string symbolName) 
		{
			// trusting margin currency more than base currency (SimpleFX broker got base currency wrong)
			string marginCurrency = SymbolInfoString(symbolName, SYMBOL_CURRENCY_MARGIN);
			string baseCurrency = SymbolInfoString(symbolName, SYMBOL_CURRENCY_BASE);
			
			//SafePrintString("baseCurrency=" + baseCurrency + ";marginCurrency=" + marginCurrency);
			if(marginCurrency != baseCurrency)
			{
				string extractedBaseCurrency = ExtractSymbolBaseCurrency(symbolName);
				//SafePrintString("baseCurrency=" + baseCurrency + ";marginCurrency=" + marginCurrency + ";extractedBaseCurrency=" + extractedBaseCurrency);
				
				if(IsVerboseMode())
					Print("Base currency is wrong! Symbol name:" + symbolName + " baseCurrency:" + baseCurrency + " marginCurrency:" + marginCurrency + " extractedBaseCurrency:" + extractedBaseCurrency);
				
				if(marginCurrency == extractedBaseCurrency)
					return marginCurrency;
			}
			
			return baseCurrency;
		}
		
		
		virtual void PrintAllSymbols()
		{
			for(int i=0; i<ArraySize(SymbolsList); i++)
				SafePrintString(SymbolsList[i] + " " + SymbolDescription(SymbolsList[i]) + " Base currency: " + SymbolBaseCurrency(SymbolsList[i]) + " Profit currency: " + SymbolProfitCurrency(SymbolsList[i]));
		}
		
		virtual int GetSymbolPositionFromName(string symbolName)
		{
			// exact match
			for(int i=0;i<ArraySize(SymbolsList);i++)
				if(SymbolsList[i] == symbolName)
					return i;
			
			// symbol contains symbolName
			for(int i=0;i<ArraySize(SymbolsList);i++)
				if(StringFind(SymbolsList[i], symbolName) != -1)
					return i;
			return -1;
		}
		
		virtual string GetSymbolNameFromPosition(int pos)
		{
			if((ArraySize(SymbolsList) > pos) && (pos >= 0))
				return SymbolsList[pos];
			return NULL;
		}
		
		virtual bool SymbolExists(string symbolName)
		{
			for(int i=0;i<ArraySize(SymbolsList);i++)
				if(StringFind(SymbolsList[i], symbolName) != -1)
					return true;
			return false;
		}
		
		
		virtual string GetSymbolStartingWith(string symbolName)
		{
		   string foundSymbol = NULL;
			for(int i=0;i<ArraySize(SymbolsList);i++)
			{
				if((StringFind(SymbolsList[i], symbolName) != -1) && (StringLen(foundSymbol) < StringLen(SymbolsList[i])))
					foundSymbol = SymbolsList[i];
			}
			return foundSymbol;
		}
		
		virtual int GetShiftFromDate(string symbolName, ENUM_TIMEFRAMES timeFrame, datetime date)
		{
			//if(IsVirtualSymbol(symbolName))
			//	return 0;
			return iBarShift(symbolName, timeFrame, date);
		}
		
		virtual double SymbolCloseValueDate(string symbolName, ENUM_TIMEFRAMES timeFrame, datetime date)
		{
			int shift = GetShiftFromDate(symbolName, timeFrame, date);
			return SymbolCloseValue(symbolName, timeFrame, shift);
		}
		
		virtual double SymbolCloseValue(string symbolName, ENUM_TIMEFRAMES timeFrame, int shift)
		{
			double value = 0.0; //GetVirtualSymbolsValue(symbolName, timeFrame, shift);
			
			if((!StringIsNullOrEmpty(symbolName)) && (value == 0.0))
			{
#ifdef __MQL5__
				value = iCloseIndicator(symbolName, timeFrame, shift);
#else
				value = iClose(symbolName, timeFrame, shift);
#endif
			}
			
			return value;
		}
		
		virtual double SymbolOpenValueDate(string symbolName, ENUM_TIMEFRAMES timeFrame, datetime date)
		{
			int shift = GetShiftFromDate(symbolName, timeFrame, date);
			return SymbolOpenValue(symbolName, timeFrame, shift);
		}
		
		virtual double SymbolOpenValue(string symbolName, ENUM_TIMEFRAMES timeFrame, int shift)
		{
			double value = 0.0; //GetVirtualSymbolsValue(symbolName, timeFrame, shift);
			
			if((!StringIsNullOrEmpty(symbolName)) && (value == 0.0))
			{
#ifdef __MQL5__
				value = iOpenIndicator(symbolName, timeFrame, shift);
#else
				value = iOpen(symbolName, timeFrame, shift);
#endif
         }
         
			return value;
		}
		
		virtual double SymbolLowValueDate(string symbolName, ENUM_TIMEFRAMES timeFrame, datetime date)
		{
			int shift = GetShiftFromDate(symbolName, timeFrame, date);
			return SymbolLowValue(symbolName, timeFrame, shift);
		}
		
		virtual double SymbolLowValue(string symbolName, ENUM_TIMEFRAMES timeFrame, int shift)
		{
			double value = 0.0; //GetVirtualSymbolsValue(symbolName, timeFrame, shift);
			
			if((!StringIsNullOrEmpty(symbolName)) && (value == 0.0))
			{
#ifdef __MQL5__
				value = iLowIndicator(symbolName, timeFrame, shift);
#else
				value = iLow(symbolName, timeFrame, shift);
#endif
         }
         
			return value;
		}
		
		virtual double SymbolHighValueDate(string symbolName, ENUM_TIMEFRAMES timeFrame, datetime date)
		{
			int shift = GetShiftFromDate(symbolName, timeFrame, date);
			return SymbolHighValue(symbolName, timeFrame, shift);
		}
		
		virtual double SymbolHighValue(string symbolName, ENUM_TIMEFRAMES timeFrame, int shift)
		{
			double value = 0.0; //GetVirtualSymbolsValue(symbolName, timeFrame, shift);
			
			if((!StringIsNullOrEmpty(symbolName)) && (value == 0.0))
			{
#ifdef __MQL5__
				value = iHighIndicator(symbolName, timeFrame, shift);
#else
				value = iHigh(symbolName, timeFrame, shift);
#endif
         }
         
			return value;
		}
		
		virtual bool SymbolPartExists(string symbolName, bool isBaseSymbol = true)
		{
			int startingSymbolLength = isBaseSymbol ? 0 : 3; // base symbol starts from 0, quote symbol starts from 3
			for(int i=0;i<ArraySize(SymbolsList);i++)
				if(StringSubstr(SymbolsList[i],startingSymbolLength,3) == symbolName)
					return true;
			return false;
		}
		
		
		virtual void SymbolsListWithSymbolPart(string symbolPart, string &foundSymbolsList[], bool isBaseSymbol = true)
		{
		   int length = 0;
			for(int i=0;i<ArraySize(SymbolsList);i++)
			   if((isBaseSymbol && (SymbolBaseCurrency(SymbolsList[i]) == symbolPart)) || // base
			      ((!isBaseSymbol) && (SymbolProfitCurrency(SymbolsList[i]) == symbolPart))) // profit
			   {
					length++;
					ArrayResize(foundSymbolsList,length);
					foundSymbolsList[length-1] = SymbolsList[i];
			   }
			   
			//int startingSymbolLength = isBaseSymbol ? 0 : 3; // base symbol starts from 0, quote symbol starts from 3
			//int length = 0;
			//for(int i=0;i<ArraySize(SymbolsList);i++)
			//	if(StringSubstr(SymbolsList[i],startingSymbolLength,3) == symbolPart)
			//	{
			//		length++;
			//		ArrayResize(foundSymbolsList,length);
			//		foundSymbolsList[length-1] = SymbolsList[i];
			//	}
		}
		
		//virtual double GetVirtualSymbolsValue(string symbol, ENUM_TIMEFRAMES timeFrame, int shift)
		//{
		//	if(symbol == "BTCBIT")
		//		return 1000000.0;
		//	else if(symbol == "EURBIT")
		//		return 1000000.0 * (1 / SymbolCloseValue("BTCEUR", timeFrame, 0));
		//	return 0.0;
		//}
		
		virtual void PrintOpenMarkets()
		{
			string listOfSymbolsOpenToTrade = "";
			int len = ArraySize(SymbolsList);
			for(int i=0;i<len;i++)
#ifdef __MQL5__
				if(MQLInfoInteger(MQL_TRADE_ALLOWED) && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&
				   SymbolInfoInteger(SymbolsList[i], SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL)
#else
				if(MarketInfo(SymbolsList[i], MODE_TRADEALLOWED) == 1)
#endif
				{
					if((i == len-1) || (i%4 == 0))
					{
						listOfSymbolsOpenToTrade += SymbolsList[i];
						SafePrintString("Open market symbols: " + listOfSymbolsOpenToTrade, true);
						listOfSymbolsOpenToTrade = "";
					}
					else
						listOfSymbolsOpenToTrade += SymbolsList[i] + ", ";
				}
		}
		
		virtual string ToString()
		{
			string retString = typename(this) + " { ";
			
			// print only array length
			retString += "SymbolsList:[" + IntegerToString(ArraySize(SymbolsList)) + "] ";
			
			retString += "} ";
			return retString;
		}
		
		// we might not want this, it has so many lines. but still might be good, no idea
		virtual string ToStringArray()
		{
			string retString = typename(this) + " { ";
			
			retString += "SymbolsList { ";
			int lenSymbolsList = ArraySize(SymbolsList);
			for(int i=0;i<lenSymbolsList-1;i++)
				retString += SymbolsList[i] + ", ";
			retString += SymbolsList[lenSymbolsList-1] + " } ";
			
			retString += "} ";
			return retString;
		}
};