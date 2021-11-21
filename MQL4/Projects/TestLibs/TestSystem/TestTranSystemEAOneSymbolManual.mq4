//+------------------------------------------------------------------+
//|                                       TestSimulateTranSystem.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property strict

#include <MyMql\System\SimulateTranSystem.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>

extern bool MakeOnlyOneOrder = false;
extern bool UseOnlyFirstDecisionAndConfirmItWithOtherDecisions = false;
static SimulateTranSystem system(DECISION_TYPE_ALL, LOT_MANAGEMENT_ALL, TRANSACTION_MANAGEMENT_ALL);

int OnInit()
{
	GlobalContext.DatabaseLog.Initialize(true);
	GlobalContext.Config.Initialize(true, true, false, false, __FILE__);
	GlobalContext.Config.AllowTrades();
		
	bool isTradeAllowedOnEA = GlobalContext.Config.IsTradeAllowedOnEA(_Symbol);
	if(!isTradeAllowedOnEA)
	{
		Print(__FUNCTION__ + ": Trade is not allowed on EA for symbol " + _Symbol);
		return (INIT_FAILED);
	}
	
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("NewTradingSession");
	
	/*
	 * 1. TELIA.SE - Candle (simple & scalping)
	 * 2. FING.SE - RSI, 3MA (simple & scalping)
	 * 3. AEX25 - 2BB (simple)
	 */
	
	// Add manual config only at the beginning:
	system.CleanTranData();
	system.AddChartTransactionData(
	   _Symbol,
	   PERIOD_CURRENT,
	   typename(DecisionDoubleBB),
	   typename(BaseLotManagement),
	   typename(BaseTransactionManagement),
	   false);
	
	BaseLotManagement lots;
	if(lots.IsMarginOk(_Symbol, MarketInfo(_Symbol, MODE_MINLOT), 0.4f, true))
	{
		system.InitializeFromFirstChartTranData(true);
		system.PrintFirstChartTranData();
		system.SetupTransactionSystem();
		
		GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);
		system.RunTransactionSystemForCurrentSymbol(true);
		//if((system.chartTranData[0].LastDecisionBarShift < 3) && (system.chartTranData[0].LastDecisionBarShift != -1))
	}
	else
	{
		Print(__FUNCTION__ + " margin is not ok for symbol " + _Symbol);
		return (INIT_FAILED);
	}
	
	// Load current orders once, to all transaction types; resets and loads oldDecision
	system.LoadCurrentOrdersToAllTransactionTypes();
	
	ChartRedraw();
	return(INIT_SUCCEEDED);
}

void OnTick()
{
	// Run Expert Advisor
	GlobalContext.Config.SetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions", UseOnlyFirstDecisionAndConfirmItWithOtherDecisions);

   system.RunTransactionSystemForCurrentSymbol(true);
	
	int orders = system.OrdersCount();
	if((MakeOnlyOneOrder) && (orders > 0))
	{
	   Print("Removing expert. He made " + IntegerToString(orders) + " order(s).");
	   ExpertRemove();
	}
	
	//Print("After tick calc.");
}

void OnDeinit(const int reason)
{
	GlobalContext.DatabaseLog.ParametersSet(__FILE__);
	GlobalContext.DatabaseLog.CallWebServiceProcedure("EndTradingSession");
	GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDebugLog", true);
	
	system.PrintDeInitReason(reason);
	system.FreeArrays();
	system.RemoveUnusedDecisionsTransactionsAndLots();
}
