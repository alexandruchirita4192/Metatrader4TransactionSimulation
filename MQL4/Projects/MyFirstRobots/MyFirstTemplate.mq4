#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

#property description "First program made, used to check some MQL4 functions" 



#include <MyMql/TransactionManagement/BaseTransactionManagement.mqh>
//#include <MyMql/MoneyManagement/BaseMoneyManagement.mqh>
//#include <MyMql/Info/ScreenInfo.mqh>

//#include <MyMql/Info/VerboseInfo.mqh>
#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>
#include <MyMql/DecisionMaking/DecisionCombinedMA.mqh>
#include <MyMql/DecisionMaking/DecisionRSI.mqh>

#include <MyMql/Global/Global.mqh>

int OnInit()
{
	// Print (one time) information
	VerboseInfo vi;
	vi.ClientAndTerminalInfo();
	vi.BalanceAccountInfo();
	vi.PrintMarketInfo();
	
	//--- create timer (seconds)
	EventSetTimer(1);
	
	// Validations
	//return vi.ExpertValidationsTest();
	return INIT_SUCCEEDED;
}


void OnDeinit(const int reason)
{
	printf("OnDeinit: reason = %f", reason);
}

double CalculateDecision(double stopLoss = 0.0, double takeProfit = 0.0)
{
	DecisionDoubleBB doubleBB(1, 0);
	DecisionCombinedMA ma(1, 0);
	DecisionRSI rsi(1, 0);
	
	ulong type = 0;
	double finalResult = 
		rsi.GetDecision(0, type) +
		ma.GetDecision(0, type) +
		doubleBB.GetDecision(0, type);
	
	stopLoss = doubleBB.GetSL();
	takeProfit = doubleBB.GetTP();
	
	printf("Final decision: %f\n Stop loss: %f\n Take profit: %f",
		finalResult, stopLoss, takeProfit);
	return finalResult;
}

void OnTick()
{
	
}


void OnTimer()
{
	double SL = InvalidValue, TP = InvalidValue;
	double decision = CalculateDecision(SL, TP); // maximum possible value is +/-14.0
	
	if(MathAbs(decision) >= 7.0)
	{
		if(decision > 0.0)
		{
		}
		else
		{
		
		}
	}
}
