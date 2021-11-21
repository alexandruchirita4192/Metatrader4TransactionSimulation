//+------------------------------------------------------------------+
//|                                          TestMoneyManagement.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/Global/Global.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function (used for testing)                |
//+------------------------------------------------------------------+
int OnInit()
{
	BaseMoneyManagement money;
	string accountCurrency = AccountCurrency();
	int len = SymbolsTotal(false);
	
	for(int i=0; i<len; i++)
	{
		string symbol = SymbolName(i, false),
			baseSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE),
			profitSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT),
			marginSymbolCurrency = SymbolInfoString(symbol, SYMBOL_CURRENCY_MARGIN);
		
//		if((marginSymbolCurrency == "NZD") || (marginSymbolCurrency == "AUD"))
//			DebugBreak();
		
		double minLot = MarketInfo(symbol, MODE_MINLOT);
		double freeMarginLeft =
			(AccountFreeMarginCheck(symbol, OP_BUY, minLot) + 
			AccountFreeMarginCheck(symbol, OP_SELL, minLot))/2.0;
		
		if (freeMarginLeft > 0)
   		printf(
   			"PipChangeRateForSymbol=%f; symbol=%s; baseCurrency=%s; profitCurrency=%s; marginCurrency=%s; accountCurrency=%s freeMarginLeft=%f minLot=%f accountMoney=%f",
   			money.PipChangeRateForSymbol(symbol, 0, 0, 0),
   			symbol,
   			baseSymbolCurrency,
   			profitSymbolCurrency,
   			marginSymbolCurrency,
   			accountCurrency,
   			freeMarginLeft,
   			minLot,
   			AccountBalance() + AccountCredit()
   		);
	}
	
	return(INIT_SUCCEEDED);
}
