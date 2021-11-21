//+------------------------------------------------------------------+
//|                                                TestGenerator.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql\Global\Money\Generator\LimitGenerator.mqh>

void OnStart()
{
	//RefreshRates();
	double spread = 4.3; // Ask - Bid;
	
	LimitGenerator generator;
	LimitData data;
	generator.GetFirstTransactionData(data, _Symbol, Ask, OP_BUY, 0.5*spread, 4.0*spread, 0.5);
	
	while(generator.GetNextTransactionData(data))
		printf("TP=%f SL=%f", data.TakeProfit, data.StopLoss);
}
