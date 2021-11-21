//+------------------------------------------------------------------+
//|                                               YetAnotherTest.mq4 |
//|                                Copyright 2016, Chirita Alexandru |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Chirita Alexandru"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyMql/DecisionMaking/DecisionDoubleBB.mqh>

bool AssertBB (string text,
	double RealBBd2, double RealBBd1, double RealBBm, double RealBBs1, double RealBBs2,
	double BBd2, double BBd1, double BBm, double BBs1, double BBs2)
{
	bool isOk = true;
	isOk = isOk && AssertEqual(text, RealBBd2, BBd2, text + "BBd2 failed miserably", 4, false, false);
	isOk = isOk && AssertEqual(text, RealBBd1, BBd1, text + "BBd1 failed miserably", 4, false, false);
	isOk = isOk && AssertEqual(text, RealBBm,  BBm,  text + "BBm  failed miserably", 4, false, false);
	isOk = isOk && AssertEqual(text, RealBBs1, BBs1, text + "BBs1 failed miserably", 4, false, false);
	isOk = isOk && AssertEqual(text, RealBBs2, BBs2, text + "BBs2 failed miserably", 4, false, false);
	return isOk;
}


#include <MyMql\Global\Log\WebServiceLog.mqh>
#include <MyMql\Global\Config\GlobalConfig.mqh>

void OnInit()
{  
	//if(FirstSymbol == NULL)
	//   ; // to do: find wtf was i trying to do here? / only at the beginning?
	GlobalConfig config(true, true, false, false);
	
	   
	// Log with WebService
	WebServiceLog wslog(true);
	
	DecisionDoubleBB decision(1, 0);
	for(int shift=0;shift<10;shift++)
	{
		double BBs2, BBs1, BBm, BBd1, BBd2;
		double internalBandsDeviationWhole = 2.0, internalBandsDeviation = 1.0;
		
		double RealBBs2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_UPPER, shift);
		double RealBBs1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
		double RealBBm  = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, MODE_MAIN,   MODE_BASE, shift);
		double RealBBd1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
		double RealBBd2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_LOWER, shift);
		
		
		for(int nr=Period()-2;nr<=Period()+2;nr++)
		{
			decision.CalculateBands(BBs2, BBs1, BBm, BBd1, BBd2, internalBandsDeviationWhole, internalBandsDeviation, shift, nr);
			if(AssertBB(IntegerToString(nr) + ": ", RealBBd2, RealBBd1, RealBBm, RealBBs1, RealBBs2, BBd2, BBd1, BBm, BBs1, BBs2))
			{
			   wslog.ParametersSet(__FILE__, "BollingerBandsCalculation", "Bollinger bands ok on Symbol: " + _Symbol + " Period: " + IntegerToString(_Period) + " Nr: " + IntegerToString(nr) + " Shift: " + IntegerToString(shift));
   	      wslog.CallWebServiceProcedure("DataLog");
   	   }
		}
	}
	
	// Navigate next
	config.ChangeSymbol();
	//config.ChangePeriod();
	
}
