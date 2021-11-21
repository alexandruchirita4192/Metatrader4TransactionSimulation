//+------------------------------------------------------------------+
//|                                           TestTransactionMan.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/UnOwnedTransactionManagement/CrappyTranManagement.mqh>
#include <MyMql/UnOwnedTransactionManagement/FlowWithTrendTranMan.mqh>

int OnInit()
{
	if(!IsDemo())
	{
		int result = MessageBox("Warning. This is not a test platform (so it seems)! This program will open transactions almost randomly to test some imlpemented functions! Are you sure you want to continue?", "Beware. Are you sure you want to continue?", 4);
		if(result == 7) // "No" has been pressed
			return (INIT_FAILED);
	}
	
	EventSetTimer(4);	
	CrappyTranManagement tran;
	
	// open 1 fake transaction based on RSI; we need at least one transaction to test the rest!!
	tran.SimulateOrderBasedOnRSI50(0.1);
	
	// get average price
	int nrOfOpenOrders, orderIsBuy; double averagePrice;
	tran.Get_OpenOrders_AvgPrice(nrOfOpenOrders, averagePrice, orderIsBuy);
	printf("AveragePrice = %f; NumberOfOpenOrders = %d; OrderIsBuy = %d.", averagePrice, nrOfOpenOrders, orderIsBuy);
	
	
	double SL = 0.0, TP = 0.0;
	FlowWithTrendTranMan followTrend;
	
	followTrend.FlowWithTrend_UpdateSL_TP_UsingConstants(SL, TP);
	printf("%f %f", SL, TP);
	
	
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	EventKillTimer();
}

void OnTimer() {}
