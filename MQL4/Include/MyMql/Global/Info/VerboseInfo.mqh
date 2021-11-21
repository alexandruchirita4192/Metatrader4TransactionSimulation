#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict

#include <Object.mqh>

enum ENUM_VERBOSE_TYPE
{
	VERBOSE_NONE = 0,
	VERBOSE_MINIMUM = 1,
	VERBOSE_HIGH = 2,
	VERBOSE_DETAILED = 3
};

//+------------------------------------------------------------------+
//| Class VerboseInfo.                                               |
//| Purpose: Get a lot of info from the environment.                 |
//+------------------------------------------------------------------+
class VerboseInfo : CObject
{
	private:
		string delimiter;
		
	public:
		VerboseInfo(string d = "|>") {
			this.delimiter = d;
		}
		
		virtual void LineDelimiter() {
			Print(delimiter + "----------------------------------------------------------------------------------------------" + delimiter);
		}
		
		void SetDelimiter(string d) { delimiter = d; }
		string GetDelimiter() { return delimiter; }
		
		//--- method for getting client and terminal information
		virtual void ClientAndTerminalInfo()
		{
			LineDelimiter();
			printf(delimiter + " IsDemo: %s", AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ? "true" : "false"); 
#ifdef __MQL4__
			printf(delimiter + " IsTesting: %s", IsTesting()?"true":"false");
#endif
			printf(delimiter + " Symbol: %s", Symbol());
			printf(delimiter + " Period: %d", Period());
			printf(delimiter + " PeriodSeconds: %d", PeriodSeconds());
			printf(delimiter + " Digits (the accuracy of price of the current chart symbol): %d", Digits());
			printf(delimiter + " Point (the point size of the current symbol in the quote currency): %f", Point());
#ifdef __MQL4__
			printf(delimiter + " IsLibrariesAllowed: %s", IsLibrariesAllowed()?"true":"false");
#endif
#ifdef __MQL4__
			printf(delimiter + " TerminalName: %s", TerminalName());
			printf(delimiter + " TerminalCompany: %s" + TerminalCompany());
			printf(delimiter + " Working directory is: %s", TerminalPath());
#else
			printf(delimiter + " TerminalName: %s", TerminalInfoString(TERMINAL_NAME));
			printf(delimiter + " TerminalCompany: %s" + TerminalInfoString(TERMINAL_COMPANY));
			printf(delimiter + " Working directory is: %s", TerminalInfoString(TERMINAL_PATH));
#endif

			printf(delimiter + " SymbolsTotal: %d", SymbolsTotal(false));
			LineDelimiter();
		}
		
		//--- method for getting balance account information
		virtual void BalanceAccountInfo()
		{
			LineDelimiter();
			printf(delimiter + " AccountBalance: %G",AccountInfoDouble(ACCOUNT_BALANCE)); 
			printf(delimiter + " AccountCredit: %G",AccountInfoDouble(ACCOUNT_CREDIT)); 
			printf(delimiter + " AccountProfit: %G",AccountInfoDouble(ACCOUNT_PROFIT)); 
			printf(delimiter + " AccountEquity: %G",AccountInfoDouble(ACCOUNT_EQUITY)); 
			printf(delimiter + " AccountMargin: %G",AccountInfoDouble(ACCOUNT_MARGIN)); 
			printf(delimiter + " AccountMarginFree: %G",AccountInfoDouble(ACCOUNT_FREEMARGIN)); 
			printf(delimiter + " AccountMarginLevel: %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)); 
			printf(delimiter + " AccountMarginSoCall: %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)); 
			printf(delimiter + " AccountMarginSoSo: %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
			LineDelimiter();
		}
		
		//--- method for getting market information
		virtual void PrintSymbolInfoDouble()
		{
			LineDelimiter();
			printf(delimiter + " SymbolInfoDouble(SYMBOL_BID): %f", SymbolInfoDouble(_Symbol, SYMBOL_BID));
			printf(delimiter + " SymbolInfoDouble(SYMBOL_ASK): %f", SymbolInfoDouble(_Symbol, SYMBOL_ASK));
			printf(delimiter + " SymbolInfoDouble(SYMBOL_POINT): %f", SymbolInfoDouble(_Symbol, SYMBOL_POINT));
			printf(delimiter + " SymbolInfoDouble(SYMBOL_DIGITS): %d", SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
			printf(delimiter + " SymbolInfoDouble(SYMBOL_SPREAD): %d", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
			printf(delimiter + " Calculated spread(Ask-Bid): %f", (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)));
			LineDelimiter();
		}
		
		virtual string ToString()
		{
			return typename(this) + " { delimiter:" + delimiter + " } ";
		}
};
