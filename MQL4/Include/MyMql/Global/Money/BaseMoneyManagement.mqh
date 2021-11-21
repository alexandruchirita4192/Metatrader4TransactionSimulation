#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/Symbols/SymbolsLibrary.mqh>
#include <MyMql/Global/Global.mqh>


// Should be defined the same as decision type (because it also has sell/buy)

class BaseMoneyManagement : public BaseObject
{
	private:
		SymbolsLibrary symbol;
		
		
	public:
		BaseMoneyManagement() { }
		
		virtual double GetTotalAmount() { return AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT); }
		
		
		
		
//		// Warning. Changing CalculateCurrencyPriceForUSD might break CalculateCurrencyPrice and PipChangeRate!!
//		virtual double CalculateCurrencyPriceForUSD(bool isOrderSymbol, bool isBaseSymbol, datetime calculationDate = 0, ENUM_TIMEFRAMES timeFrame = 0, int shift = 0)
//		{
//			string symbolName = isOrderSymbol ? OrderSymbol() : Symbol();
//			string currency = isBaseSymbol ? symbol.SymbolBaseCurrency(symbolName) : symbol.SymbolProfitCurrency(symbolName);
//			if(currency == "AUD")
//				return iClose(symbol.GetSymbolStartingWith("AUDUSD"), timeFrame, shift); //MarketInfo("AUDUSD",MODE_BID);
//			else if(currency == "EUR")
//				return iClose(symbol.GetSymbolStartingWith("EURUSD"), timeFrame, shift); // MarketInfo("EURUSD",MODE_BID);
//			else if(currency == "GBP")
//				return iClose(symbol.GetSymbolStartingWith("GBPUSD"), timeFrame, shift); // MarketInfo("GBPUSD",MODE_BID);
//			else if(currency == "NZD")
//				return iClose(symbol.GetSymbolStartingWith("NZDUSD"), timeFrame, shift); // MarketInfo("NZDUSD",MODE_BID);
//			
//			double invertedPrice = 0.0;
//			if(currency == "CAD") {
//				invertedPrice = iClose(symbol.GetSymbolStartingWith("USDCAD"), timeFrame, shift); // MarketInfo("USDCAD", MODE_BID);
//				return invertedPrice != 0.0 ? 1.0/invertedPrice : 0.0;
//			} else if(currency == "CHF") {
//				invertedPrice = iClose(symbol.GetSymbolStartingWith("USDCHF"), timeFrame, shift); // MarketInfo("USDCHF", MODE_BID);
//				return invertedPrice != 0.0 ? 1.0/invertedPrice : 0.0;
//			} else if(currency == "SGD") {
//				invertedPrice = iClose(symbol.GetSymbolStartingWith("USDSGD"), timeFrame, shift); // MarketInfo("USDSGD", MODE_BID);
//				return invertedPrice != 0.0 ? 1.0/invertedPrice : 0.0;
//			} else if(currency == "USD")
//				return 1.00;
//			return 0.0;
//		}
		
		// Warning. Changing CalculateCurrencyRateForSymbol might break PipChangeRateForSymbol!!
		virtual double CalculateCurrencyRateForSymbol(string symbolName, datetime calculationDate, ENUM_TIMEFRAMES timeFrame, int shift)
		{
		   if(timeFrame == 0)
		      timeFrame = IntegerToTimeFrame(_Period);
		   
		   if(StringIsNullOrEmpty(symbolName))
		   	symbolName = _Symbol;
			
			if((shift != 0) && (calculationDate == 0))
				calculationDate = iTime(symbolName, timeFrame, shift);
			
		#ifdef __MQL4__
			string accountCurrency = AccountCurrency();
		#else
			string accountCurrency = AccountInfoString(ACCOUNT_CURRENCY);
		#endif
		   
			//if(accountCurrency == "USD")
			//{
			//	double res = CalculateCurrencyPriceForUSD(isOrderSymbol, isBaseSymbol, calculationDate, timeFrame, shift);
			//	if(res != 0.0)
			//		return res;
			//}
			
			string profitCurrency = symbol.SymbolProfitCurrency(symbolName);
			
			//SafePrintString("accountCurrency=" + accountCurrency + "; profitCurrency=" + profitCurrency);
			
			// 1. profit/quote currency = account currency => rate = 1.0 = iClose(base currency + account currency symbol)
			if(profitCurrency == accountCurrency)
				return 1.0;
			else
			{
				// 2. profit/quote currency + account currency => rate = iClose(profit/quote currency + account currency symbol)
				string testedSymbol = profitCurrency + accountCurrency;
				testedSymbol = symbol.GetSymbolStartingWith(testedSymbol); // base currency + account currency
				//SafePrintString("testedSymbol[1]=" + testedSymbol);
				if((!StringIsNullOrEmpty(testedSymbol)) && (symbol.SymbolExists(testedSymbol)))
					return symbol.SymbolCloseValueDate(testedSymbol, timeFrame, calculationDate);
				
				// 3. account currency + profit/quote currency => rate = 1/iClose(account currency + profit/quote currency symbol)
				testedSymbol = accountCurrency + profitCurrency;
				testedSymbol = symbol.GetSymbolStartingWith(testedSymbol); // account currency + base currency
				//SafePrintString("testedSymbol[2]=" + testedSymbol);
				if((!StringIsNullOrEmpty(testedSymbol)) && (symbol.SymbolExists(testedSymbol)))
				{
					double price = symbol.SymbolCloseValueDate(testedSymbol, timeFrame, calculationDate);
					
					if(price == 0.0)
					{
						string message = __FUNCTION__ + " The fuck. Price returned 0.0 for symbol '" + testedSymbol + "'. GetLastError: " + IntegerToString(GetLastError()) + " in file " + __FILE__ + " at line " + IntegerToString(__LINE__);
						if(IsVerboseMode()) Print(message);
						GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
							GlobalContext.Config.GetSessionName(),
							message,
							TimeAsParameter());
						return 0;
					}
					
					return (1.0/price); // inverted price
				}
				
				/*
				 * 4.1. indirect currency calculation 
				 * 
				 * symbol 1 = profit/quote currency + X currency 
				 * symbol 2 = X currency + account currency
				 *
				 * rate = iClose(symbol 1) * iClose(symbol 2)
				 * rate = iClose(profit/quote currency + X currency symbol) * iClose(X currency + account currency symbol)
				 */
				string symbolList[];
				symbol.SymbolsListWithSymbolPart(profitCurrency, symbolList, true /*base currency*/);
				
				if(ArraySize(symbolList) >= 1) {
					int len = ArraySize(symbolList);
					
					for(int i=0; i<len; i++)
					{
						string currentSymbolList = symbol.GetSymbolStartingWith(symbolList[i]); // base currency + X currency
						string Xcurrency = symbol.SymbolProfitCurrency(symbolList[i]); // quote/profit currency = X currency
						testedSymbol = Xcurrency + accountCurrency;
						testedSymbol = symbol.GetSymbolStartingWith(testedSymbol); // X currency + base currency
						//SafePrintString("testedSymbol[3][" + IntegerToString(i) + "]=" + testedSymbol);
						
						if((!StringIsNullOrEmpty(testedSymbol)) && (symbol.SymbolExists(testedSymbol))) {
							//if(_LastError == 4066) //ERR_HISTORY_WILL_UPDATED
							//{
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   calcShift = iBarShift(symbol.GetSymbolStartingWith(testedSymbol), timeFrame, calculationDate);
							//}
							
							double closeCurrentSymbolList = symbol.SymbolCloseValueDate(currentSymbolList, timeFrame, calculationDate);
							double closeFoundLinkSymbol = symbol.SymbolCloseValueDate(testedSymbol, timeFrame, calculationDate);
							
							if(closeCurrentSymbolList == 0.0)
							   closeCurrentSymbolList = symbol.Close(currentSymbolList);
							if(closeFoundLinkSymbol == 0.0)
							   closeFoundLinkSymbol = symbol.Close(testedSymbol);
							
							//if(closeCurrentSymbolList == 0.0) {
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   closeCurrentSymbolList = iClose(currentSymbolList, timeFrame, calcShift);
							//}
							
							if((closeCurrentSymbolList != 0.0) && (closeFoundLinkSymbol != 0.0))
								return closeCurrentSymbolList * closeFoundLinkSymbol; // iClose(s1) * iClose(s2)
							else
							{
								string message = __FUNCTION__ + " The fuck. Everything returned 0.0 for symbol '" + currentSymbolList + "'. GetLastError: " + IntegerToString(GetLastError()) + " in file " + __FILE__ + " at line " + IntegerToString(__LINE__);
								if(IsVerboseMode()) Print(message);
								GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
									GlobalContext.Config.GetSessionName(),
									message,
									TimeAsParameter());
							}
						}
					}
				}
				
				
				
				/*
				 * 4.2. indirect inverse currency calculation 
				 * 
				 * symbol 1 = X currency + profit/quote currency
				 * symbol 2 = account currency + X currency
				 *
				 * rate = 1/(iClose(symbol 1) * iClose(symbol 2))
				 * rate = 1/(iClose(account currency + X currency symbol) * iClose(X currency + profit/quote currency symbol))
				 */
				ArrayResize(symbolList,0);
				ArrayFree(symbolList);
				symbol.SymbolsListWithSymbolPart(profitCurrency, symbolList, false /* profit currency */); // 
				
				if(ArraySize(symbolList) >= 1) {
					int len = ArraySize(symbolList);
					
					for(int i=0; i<len; i++)
					{
					   string currentSymbolList = symbol.GetSymbolStartingWith(symbolList[i]); // X currency + base currency
					   string Xcurrency = symbol.SymbolBaseCurrency(symbolList[i]);
					   testedSymbol = accountCurrency + Xcurrency;
						testedSymbol = symbol.GetSymbolStartingWith(testedSymbol); // account currency + X currency
						
						if(symbol.SymbolExists(testedSymbol)) {
							//if(_LastError == 4066) //ERR_HISTORY_WILL_UPDATED
							//{
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   calcShift = iBarShift(symbol.GetSymbolStartingWith(testedSymbol), timeFrame, calculationDate);
							//}
							
							double closeCurrentSymbolList = symbol.SymbolCloseValueDate(currentSymbolList, timeFrame, calculationDate); // X currency + base currency
							double closeFoundLinkSymbol = symbol.SymbolCloseValueDate(testedSymbol, timeFrame, calculationDate); // account currency + X currency
							
							if(closeCurrentSymbolList == 0.0)
							   closeCurrentSymbolList = symbol.Close(currentSymbolList);
							if(closeFoundLinkSymbol == 0.0)
							   closeFoundLinkSymbol = symbol.Close(testedSymbol);
							
							//if(closeCurrentSymbolList == 0.0) {
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   closeCurrentSymbolList = iClose(currentSymbolList, timeFrame, calcShift);
							//}
							
							if((closeCurrentSymbolList != 0.0) && (closeFoundLinkSymbol != 0.0))
							   return 1.0/(closeCurrentSymbolList * closeFoundLinkSymbol); // 1/(iClose(s1) * iClose(s2))
							else
							{
								string message = __FUNCTION__ + " The fuck 2. Everything returned 0.0 for symbol '" + currentSymbolList + "'. Error description: " + ErrorDescription(_LastError);
								if(IsVerboseMode()) Print(message);
								GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
									GlobalContext.Config.GetSessionName(),
									message,
									TimeAsParameter());
							}
						}
					}
				}
				
				
				
				
				/*
				 * 4.3. indirect weird currency calculation 
				 * 
				 * symbol 1 = profit/quote currency + X currency
				 * symbol 2 = account currency + X currency
				 *
				 * rate = iClose(symbol 1) / iClose(symbol 2)
				 * rate = iClose(profit/quote currency + X currency symbol) / iClose(account currency + X currency symbol)
				 */
				ArrayResize(symbolList,0);
				ArrayFree(symbolList);
				symbol.SymbolsListWithSymbolPart(profitCurrency, symbolList, true /* base currency */); // 
				
				if(ArraySize(symbolList) >= 1) {
					int len = ArraySize(symbolList);
					
					for(int i=0; i<len; i++)
					{
					   string currentSymbolList = symbol.GetSymbolStartingWith(symbolList[i]); // base currency + X currency
					   string Xcurrency = symbol.SymbolProfitCurrency(symbolList[i]);
					   testedSymbol = accountCurrency + Xcurrency;
						testedSymbol = symbol.GetSymbolStartingWith(testedSymbol); // account currency + X currency
						
						if(symbol.SymbolExists(testedSymbol)) {
							//if(_LastError == 4066) //ERR_HISTORY_WILL_UPDATED
							//{
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   calcShift = iBarShift(symbol.GetSymbolStartingWith(testedSymbol), timeFrame, calculationDate);
							//}
							
							double closeCurrentSymbolList = symbol.SymbolCloseValueDate(currentSymbolList, timeFrame, calculationDate); // X currency + base currency
							double closeFoundLinkSymbol = symbol.SymbolCloseValueDate(testedSymbol, timeFrame, calculationDate); // account currency + X currency
							
							if(closeCurrentSymbolList == 0.0)
							   closeCurrentSymbolList = symbol.Close(currentSymbolList);
							if(closeFoundLinkSymbol == 0.0)
							   closeFoundLinkSymbol = symbol.Close(testedSymbol);
							
							//if(closeCurrentSymbolList == 0.0) {
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   closeCurrentSymbolList = iClose(currentSymbolList, timeFrame, calcShift);
							//}
							
							if((closeCurrentSymbolList != 0.0) && (closeFoundLinkSymbol != 0.0))
							   return closeCurrentSymbolList/closeFoundLinkSymbol; // iClose(s1) / iClose(s2)
							else
							{
								string message = __FUNCTION__ + " The fuck 2. Everything returned 0.0 for symbol '" + currentSymbolList + "'. Error description: " + ErrorDescription(_LastError);
								if(IsVerboseMode()) Print(message);
								GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
									GlobalContext.Config.GetSessionName(),
									message,
									TimeAsParameter());
							}
						}
					}
				}
				
				
				
				
				
				
				/*
				 * 4.4. indirect inverse currency calculation 
				 * 
				 * symbol 1 = X currency + profit/quote currency
				 * symbol 2 = X currency + account currency
				 *
				 * rate = iClose(symbol 2) / iClose(symbol 1)
				 * rate = iClose(X currency + account currency symbol) / iClose(X currency + profit/quote currency symbol))
				 */
				ArrayResize(symbolList,0);
				ArrayFree(symbolList);
				symbol.SymbolsListWithSymbolPart(profitCurrency, symbolList, false /* profit currency */); // 
				
				if(ArraySize(symbolList) >= 1) {
					int len = ArraySize(symbolList);
					
					for(int i=0; i<len; i++)
					{
					   string currentSymbolList = symbol.GetSymbolStartingWith(symbolList[i]); // X currency + base currency
					   string Xcurrency = symbol.SymbolBaseCurrency(symbolList[i]);
					   testedSymbol = Xcurrency + accountCurrency;
						testedSymbol = symbol.GetSymbolStartingWith(testedSymbol); // X currency + account currency
						
						if(symbol.SymbolExists(testedSymbol)) {
							//if(_LastError == 4066) //ERR_HISTORY_WILL_UPDATED
							//{
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   calcShift = iBarShift(symbol.GetSymbolStartingWith(testedSymbol), timeFrame, calculationDate);
							//}
							
							double closeCurrentSymbolList = symbol.SymbolCloseValueDate(currentSymbolList, timeFrame, calculationDate); // X currency + base currency
							double closeFoundLinkSymbol = symbol.SymbolCloseValueDate(testedSymbol, timeFrame, calculationDate); // account currency + X currency
							
							if(closeCurrentSymbolList == 0.0)
							   closeCurrentSymbolList = symbol.Close(currentSymbolList);
							if(closeFoundLinkSymbol == 0.0)
							   closeFoundLinkSymbol = symbol.Close(testedSymbol);
							
							//if(closeCurrentSymbolList == 0.0) {
							//   DownloadHistory(timeFrame, currentSymbolList);
							//   closeCurrentSymbolList = iClose(currentSymbolList, timeFrame, calcShift);
							//}
							
							if((closeCurrentSymbolList != 0.0) && (closeFoundLinkSymbol != 0.0))
							   return closeFoundLinkSymbol / closeCurrentSymbolList; // iClose(s2) / iClose(s1)
							else
							{
								string message = __FUNCTION__ + " The fuck 2. Everything returned 0.0 for symbol '" + currentSymbolList + "'. Error description: " + ErrorDescription(_LastError);
								if(IsVerboseMode()) Print(message);
								GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
									GlobalContext.Config.GetSessionName(),
									message,
									TimeAsParameter());
							}
						}
					}
				}
			}
			return 0.0;
		}
		
		//to do: fuck this - needs refactoring; uncommented to be able to compile system
		virtual double GetPriceBasedOnDecision(double decisionType, string symbolName)
		{
			double price = 0.0;
			if(StringIsNullOrEmpty(symbolName))
				symbolName = _Symbol;
			if (decisionType > 0.0)
				price = SymbolInfoDouble(symbolName, SYMBOL_ASK);
			if(decisionType < 0.0)
				price = SymbolInfoDouble(symbolName, SYMBOL_BID);
		
			return price;
		}

//		virtual double GetLotsBasedOnDecision(double decisionType, bool isOrderSymbol)
//		{
//			string symbolName = isOrderSymbol ? OrderSymbol() : Symbol();
//			return MarketInfo(symbolName, MODE_MINLOT);
//		}
		
		// Signature copied after CalculateCurrencyRateForSymbol!! Warning. Changing CalculateCurrencyRateForSymbol might break PipChangeRateForSymbol
		double PipChangeRateForSymbol(string symbolName, datetime calculationDate, ENUM_TIMEFRAMES timeFrame, int shift)
		{
			double pointChangeRate = Point() * CalculateCurrencyRateForSymbol(symbolName, calculationDate, timeFrame, shift);
			return ConvertPoint2Pip(pointChangeRate);
		}
		
		virtual string ToString()
		{
			string retString = typename(this) + " { ";
			
			retString += symbol.ToString() + " ";
			
			retString += "} ";
			return retString;
		}
};