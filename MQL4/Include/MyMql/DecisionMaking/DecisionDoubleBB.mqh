#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Global/Global.mqh>
#include <MyMql/DecisionMaking/DecisionIndicator.mqh>


enum ENUM_BB2_TYPE
{
	BB2_NONE     = 0,
	BB2_HIGH     = 1,
	BB2_LOW      = 2,
	BB2_HIGHEST  = 4,
	BB2_LOWEST   = 8
};


class DecisionDoubleBB : public DecisionIndicator
{
	private:
		double InternalSL;
		double InternalTP;
		double BBs2, BBs1, BBm, BBd1, BBd2;
		bool previousBBempty;
		
	public:
		DecisionDoubleBB(int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
			InternalSL = 0.0; InternalTP = 0.0;
		}
		
		DecisionDoubleBB(double sl, double tp, int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
			InternalSL = sl; InternalTP = tp;
		}
		
		virtual double GetSL() { return InternalSL; }
		virtual double GetTP() { return InternalTP; }
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Double Bollinger Bands"; }
		virtual bool DecisionWithIrregularLimits() { return true; }
		
		virtual double GetBBs2() { return BBs2; }
		virtual double GetBBs1() { return BBs1; }
		virtual double GetBBm()  { return BBm;  }
		virtual double GetBBd1() { return BBd1; }
		virtual double GetBBd2() { return BBd2; }
		
		virtual void SetIndicatorData(double &Buffer_BBs2[], double &Buffer_BBs1[], double &Buffer_BBm[], double &Buffer_BBd1[], double &Buffer_BBd2[], int index);
		
		virtual double GetMaxDecision()
		{
			// max(doubleBBResult) = +/- 4.0 (Buy = +; Sell = -)
			// min(doubleBBResult) = 0.0 (Incertitude = 0)
			return 4.0;
		}
		virtual double GetDecision(int shift, unsigned long &type) { return GetDecision3(type, 1.0, shift, 2.0); }
		virtual double GetDecision2(double &stopLoss, double &takeProfit, unsigned long &type, double internalBandsDeviation = 1.0, int shift = 0, double internalBandsDeviationWhole = 2.0);
		virtual double GetDecision3(unsigned long &type, double internalBandsDeviation = 1.0, int shift = 0, double internalBandsDeviationWhole = 2.0)
		{
			return GetDecision2(InternalSL, InternalTP, type, internalBandsDeviation, shift, internalBandsDeviationWhole);
		}
		
		virtual void CalculateBands(double &bbs2, double &bbs1, double &bbm, double &bbd1, double &bbd2, double internalBandsDeviationWhole, double internalBandsDeviation, int shift, int periodNr = 0);
		
		virtual string ToString();
};

void DecisionDoubleBB::SetIndicatorData(double &Buffer_BBs2[], double &Buffer_BBs1[], double &Buffer_BBm[], double &Buffer_BBd1[], double &Buffer_BBd2[], int index)
{
	Buffer_BBs2[index] = BBs2; Buffer_BBs1[index] = BBs1; Buffer_BBm[index] = BBm; Buffer_BBd1[index] = BBd1; Buffer_BBd2[index] = BBd2;
}
	
double DecisionDoubleBB::GetDecision2(double &stopLoss, double &takeProfit, unsigned long &type, double internalBandsDeviation = 1.0, int shift = 0, double internalBandsDeviationWhole = 2.0)
{
	type = BB2_NONE;
	if((shift == 0) && (GetInternalShift() != 0))
		shift = GetInternalShift();
	
#ifdef __MQL4__
	// Calculate decisions based on Bollinger Bands
	BBs2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_UPPER, shift);
	//double BBs2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
	BBs1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
	//double BBs1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_UPPER, ShiftValue);
	BBm  = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, MODE_MAIN,   MODE_BASE, shift);
	//double BBmShifted  = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, MODE_MAIN,   MODE_BASE,  ShiftValue);
	BBd1 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
	//double BBd1Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 1, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
	BBd2 = iBands(Symbol(), PERIOD_CURRENT, Period(), internalBandsDeviationWhole, 0, PRICE_CLOSE, MODE_LOWER, shift);
	//double BBd2Shifted = iBands(Symbol(), PERIOD_CURRENT, Period(), 2, 0, PRICE_CLOSE, MODE_LOWER, ShiftValue);
#else

#endif 

	// no Bollinger Bands calculation at all?
	if((BBs2 == 0.0) || (BBs1 == 0.0) || (BBm == 0.0) || (BBd1 == 0.0) || (BBd2 == 0.0))
	{
	   //if(GetVerboseLevel() > 1)
		
		if (!previousBBempty)
   		GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
   			GlobalContext.Config.GetSessionName(),
   			__FUNCTION__ + " No BB calculation at all. We got zeros: "
   				+ DoubleToString(BBs2,0) + " " + DoubleToString(BBs1,0) + " " + DoubleToString(BBm,0) + " " + DoubleToString(BBd1,0) + " " + DoubleToString(BBd2,0),
   			TimeAsParameter());
   			
   	previousBBempty = true; // log only the first time
	   
		//printf("BBs2=%f BBs1=%f BBm=%f BBd1=%f BBd2=%f", BBs2, BBs1, BBm, BBd1, BBd2);
		//CalculateBands(BBs2, BBs1, BBm, BBd1, BBd2, internalBandsDeviationWhole, internalBandsDeviation, shift);
		//printf("BBs2=%f BBs1=%f BBm=%f BBd1=%f BBd2=%f", BBs2, BBs1, BBm, BBd1, BBd2);
		
		return IncertitudeDecision;
	}
	
	// wrong Bollinger Bands calculation?
	if(!((BBs1<BBs2) && (BBm<BBs1) && (BBd1<BBm) && (BBd2<BBd1)))
	{
		GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
			GlobalContext.Config.GetSessionName(),
			__FUNCTION__ + " Wrong BB calculation: "
				+ DoubleToString(BBs2,0) + " " + DoubleToString(BBs1,0) + " " + DoubleToString(BBm,0) + " " + DoubleToString(BBd1,0) + " " + DoubleToString(BBd2,0),
			TimeAsParameter());
			
		return IncertitudeDecision;
	}
	
	// Further tests for Bollinger Bands:

#ifdef __MQL5__
	double closeLevel = iCloseMQL4(Symbol(), Period(), shift);
	double closeLevelShift = iCloseMQL4(Symbol(), Period(), shift + ShiftValue);
#else
	double closeLevel = iClose(Symbol(), Period(), shift);
	double closeLevelShift = iClose(Symbol(), Period(), shift + ShiftValue);
#endif
	
	if((closeLevel == 0) || (closeLevelShift == 0))
	{
		GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
			GlobalContext.Config.GetSessionName(),
			__FUNCTION__ + " closeLevel or closeLevelShift has zeroes! closeLevel=" + DoubleToString(closeLevel,4) + " closeLevelShift=" + DoubleToString(closeLevelShift,4),
			TimeAsParameter());

		return IncertitudeDecision;
	}
	
	// max(doubleBBResult) = +/- 4.0 (Buy = +; Sell = -)
	// min(doubleBBResult) = 0.0 (Incertitude = 0)
	double result = InvalidValue;
	
	if((closeLevel <= BBd2) // lower than the last two lines
		&& (closeLevelShift > closeLevel)) // and the close level goes down
	{
		result += 4*SellDecision;
		stopLoss = BBm;
		takeProfit = BBd2 - (BBd1 - BBd2); // approx. calculation
		type += BB2_LOWEST;
	}
	
	if((closeLevel >= BBd2) && (closeLevel <= BBd1) // between the last two lines
		&& (closeLevelShift > closeLevel)) // and the close level goes down
	{
		result += 2*SellDecision;
		stopLoss = BBm;
		takeProfit = BBd2;
		type += BB2_LOW;
	}
	
	if((closeLevel >= BBs1) && (closeLevel <= BBs2) // between the first two lines
		&& (closeLevelShift < closeLevel)) // and the close level goes up
	{
		result += 2*BuyDecision;
		stopLoss = BBm;
		takeProfit = BBs2;
		type += BB2_HIGH;
	}
	
	if((closeLevel >= BBs2) // even higher than the first line
		&& (closeLevelShift < closeLevel)) // and the close level goes up
	{
		result += 4*BuyDecision;
		stopLoss = BBm;
		takeProfit = BBs2 + (BBs2 - BBs1); // approx. calculation
		type += BB2_HIGHEST;
	}
	
	if(IsVerboseMode())
	{
		//if((GetVerboseLevel() > 1) || (result != 0))
		GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
			GlobalContext.Config.GetSessionName(),
			__FUNCTION__ + StringFormat(" Double BB Level Decision [%.2f]: [close=%f closeShifted=%f] [SL=%f TP=%f] BBs2=%f BBs1=%f BBm=%f BBd1=%f BBd2=%f\n",
				result, closeLevel, closeLevelShift,
				stopLoss, takeProfit,
				BBs2, BBs1, BBm, BBd1, BBd2
			),
			TimeAsParameter());			
	}
	
	if((result != IncertitudeDecision) && (MathAbs(stopLoss/closeLevel) > 100))
	{
		GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
			GlobalContext.Config.GetSessionName(),
			__FUNCTION__ + StringFormat(" StopLoss: %f Price: %f", stopLoss, closeLevel),
			TimeAsParameter());
		return IncertitudeDecision;
	}
	
	if((result != IncertitudeDecision) && (MathAbs(takeProfit/closeLevel) > 100))
	{
		GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
			GlobalContext.Config.GetSessionName(),
			__FUNCTION__ + StringFormat(" TakeProfit: %f Price: %f", takeProfit, closeLevel),
			TimeAsParameter());
		return IncertitudeDecision;
	}
	
	return result;
}


void DecisionDoubleBB::CalculateBands(double &bbs2, double &bbs1, double &bbm, double &bbd1, double &bbd2, double internalBandsDeviationWhole, double internalBandsDeviation, int shift, int periodNr = 0)
{
	if(periodNr == 0)
	   periodNr = PeriodSeconds()/60;
	
	if(bbm == 0.0)
	{
#ifdef __MQL5__
		bbm = iMA(Symbol(), PERIOD_CURRENT, Period(), shift, MODE_SMA, PRICE_CLOSE);
#else 
		bbm = iMA(Symbol(), PERIOD_CURRENT, Period(), 0, MODE_SMA, PRICE_CLOSE, shift);
#endif
		
		if(bbm == 0.0)
		{
			GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
				GlobalContext.Config.GetSessionName(),
				__FUNCTION__ + " The fuck. iMA not working either. Fixing",
				TimeAsParameter());
				
			//ML = SUM (CLOSE, N) / N = SMA (CLOSE, N)
			double closeSum = 0.0;
			for(int i=periodNr;i>0;i--)
			{
#ifdef __MQL5__
				closeSum += iCloseMQL4(Symbol(), PERIOD_CURRENT, shift + i);
#else
				closeSum += iClose(Symbol(), PERIOD_CURRENT, shift + i);
#endif
			}
			bbm = closeSum / ((double)periodNr);
		}
	}
	
	//StdDev = SQRT (SUM ((CLOSE — SMA (CLOSE, N))^2, N)/N)
	double closeSumMinusSMA = 0.0, currentCloseValue;
	for(int i=periodNr;i>0;i--)
	{
#ifdef __MQL5__
		currentCloseValue = iCloseMQL4(Symbol(), PERIOD_CURRENT, shift + i);
#else
		currentCloseValue = iClose(Symbol(), PERIOD_CURRENT, shift + i);
#endif
		closeSumMinusSMA += (currentCloseValue - bbm)*(currentCloseValue - bbm);
	}
	
	double StdDev = MathSqrt(closeSumMinusSMA / ((double)periodNr));
	
	//TL = ML + (D * StdDev)
	bbs2 = bbm + (internalBandsDeviationWhole * StdDev);
	bbs1 = bbm + (internalBandsDeviation * StdDev);
	
	//BL = ML - (D * StdDev)
	bbd1 = bbm - (internalBandsDeviation * StdDev);
	bbd2 = bbm - (internalBandsDeviationWhole * StdDev);
}


string DecisionDoubleBB::ToString()
{
	string retString = typename(this) + " { ";
	
	retString += "InternalSL:" + DoubleToString(InternalSL) + " ";
	retString += "InternalTP:" + DoubleToString(InternalTP) + " ";
	retString += "BBs2:" + DoubleToString(BBs2) + " ";
	retString += "BBs1:" + DoubleToString(BBs1) + " ";
	retString += "BBm:" + DoubleToString(BBm) + " ";
	retString += "BBd1:" + DoubleToString(BBd1) + " ";
	retString += "BBd2:" + DoubleToString(BBd2) + " ";
	
	retString += "} ";
	return retString;
}