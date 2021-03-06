#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/DecisionIndicator.mqh>

enum ENUM_RSI_TYPE
{
	RSI_NONE                   = 0,
	
	// 1X decisions
	RSI_CloseResultH1_UP       = 1,
	RSI_CloseResultH1_DOWN     = 2,
	RSI_MedianResultH1_UP      = 4,
	RSI_MedianResultH1_DOWN    = 8,
	
	RSI_CloseResultD1_UP       = 16,
	RSI_CloseResultD1_DOWN     = 32,
	RSI_MedianResultD1_UP      = 64,
	RSI_MedianResultD1_DOWN    = 128,
	
	RSI_CloseResultW1_UP       = 256,
	RSI_CloseResultW1_DOWN     = 512,
	RSI_MedianResultW1_UP      = 1024,
	RSI_MedianResultW1_DOWN    = 2048,
	
	// 2X decisions
	RSI_CloseResultH1_2UP       = 4096,
	RSI_CloseResultH1_2DOWN     = 8192,
	RSI_MedianResultH1_2UP      = 16384,
	RSI_MedianResultH1_2DOWN    = 32768,
	
	RSI_CloseResultD1_2UP       = 65536,
	RSI_CloseResultD1_2DOWN     = 131072,
	RSI_MedianResultD1_2UP      = 262144,
	RSI_MedianResultD1_2DOWN    = 524288,
	
	RSI_CloseResultW1_2UP       = 1048576,
	RSI_CloseResultW1_2DOWN     = 2097152,
	RSI_MedianResultW1_2UP      = 4194304,
	RSI_MedianResultW1_2DOWN    = 8388608
};

class DecisionRSI : public DecisionIndicator
{
	private:
		double rsiLevelCloseH1, rsiLevelMedianH1,
			rsiLevelCloseD1, rsiLevelMedianD1,
			rsiLevelCloseW1, rsiLevelMedianW1;

#ifdef __MQL5__
      int handleRsiCloseH1, handleRsiMedianH1, handleRsiCloseD1, handleRsiMedianD1, handleRsiCloseW1, handleRsiMedianW1;
#endif

	public:
		DecisionRSI(int shiftValue, int internalShift ) : DecisionIndicator(shiftValue, internalShift)
		{
#ifdef __MQL5__
		   handleRsiCloseH1 = handleRsiMedianH1 = handleRsiCloseD1 = handleRsiMedianD1 = handleRsiCloseW1 = handleRsiMedianW1 = INVALID_HANDLE;
#endif 
		}
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Relative Strength Index"; }
		
		virtual double GetCloseH1()  { return rsiLevelCloseH1;  }
		virtual double GetMedianH1() { return rsiLevelMedianH1; }
		virtual double GetCloseD1()  { return rsiLevelCloseD1;  }
		virtual double GetMedianD1() { return rsiLevelMedianD1; }
		virtual double GetCloseW1()  { return rsiLevelCloseW1;  }
		virtual double GetMedianW1() { return rsiLevelMedianW1; }
		
		
		virtual void SetIndicatorData(
			double &Buffer_CloseH1[], double &Buffer_MedianH1[],
			double &Buffer_CloseD1[], double &Buffer_MedianD1[],
			double &Buffer_CloseW1[], double &Buffer_MedianW1[],
			int index
		);
		
		
		double GetDecision(int shift, unsigned long &type);
		
		double GetMaxDecision()
		{
			// max(rsiResult) = +/- 12.0 (Buy = +; Sell = -)
			// min(rsiResult) = 0.0 (Incertitude = 0)
			return 12.0;
		}
		
		
		virtual string ToString();
};


void DecisionRSI::SetIndicatorData(
	double &Buffer_CloseH1[], double &Buffer_MedianH1[],
	double &Buffer_CloseD1[], double &Buffer_MedianD1[],
	double &Buffer_CloseW1[], double &Buffer_MedianW1[],
	int index
)
{
	Buffer_CloseH1[index] = rsiLevelCloseH1; Buffer_MedianH1[index] = rsiLevelMedianH1;
	Buffer_CloseD1[index] = rsiLevelCloseD1; Buffer_MedianD1[index] = rsiLevelMedianD1;
	Buffer_CloseW1[index] = rsiLevelCloseW1; Buffer_MedianW1[index] = rsiLevelMedianW1;
}


double DecisionRSI::GetDecision(int shift, unsigned long &type)
{
	if((shift == 0) && (GetShiftValue() != 0))
		shift = GetShiftValue();
	
	// Analysis based on Relative Strength levels:

#ifdef __MQL4__
	rsiLevelCloseH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, shift);
	rsiLevelMedianH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, shift);
	double rsiLevelCloseShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, shift + ShiftValue);
	double rsiLevelMedianShiftedH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, shift + ShiftValue);
	double rsiLevelCloseShifted2H1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE, shift + ShiftValue + 1);
	double rsiLevelMedianShifted2H1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN, shift + ShiftValue + 1);
	
	rsiLevelCloseD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, shift);
	rsiLevelMedianD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, shift);
	double rsiLevelCloseShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, shift + ShiftValue);
	double rsiLevelMedianShiftedD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, shift + ShiftValue);
	double rsiLevelCloseShifted2D1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE, shift + ShiftValue + 1);
	double rsiLevelMedianShifted2D1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN, shift + ShiftValue + 1);
	
	rsiLevelCloseW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, shift);
	rsiLevelMedianW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, shift);
	double rsiLevelCloseShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, shift + ShiftValue);
	double rsiLevelMedianShiftedW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, shift + ShiftValue);
	double rsiLevelCloseShifted2W1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE, shift + ShiftValue + 1);
	double rsiLevelMedianShifted2W1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN, shift + ShiftValue + 1);
#else
   if(handleRsiCloseH1 == INVALID_HANDLE)
      handleRsiCloseH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_CLOSE);
   if(handleRsiMedianH1 == INVALID_HANDLE)
      handleRsiMedianH1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_H1, PRICE_MEDIAN);
   if(handleRsiCloseD1 == INVALID_HANDLE)
      handleRsiCloseD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_CLOSE);
   if(handleRsiMedianD1 == INVALID_HANDLE)
      handleRsiMedianD1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_D1, PRICE_MEDIAN);
   if(handleRsiCloseW1 == INVALID_HANDLE)
      handleRsiCloseW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_CLOSE);
   if(handleRsiMedianW1 == INVALID_HANDLE)
      handleRsiMedianW1 = iRSI(Symbol(), PERIOD_CURRENT, PERIOD_W1, PRICE_MEDIAN);
      
   double aux1[1], aux2[1], aux3[1], aux4[1], aux5[1], aux6[1];
   
	// H1
   CopyBuffer(handleRsiCloseH1, 1, shift, 1, aux1);
   CopyBuffer(handleRsiMedianH1, 1, shift, 1, aux2);
   CopyBuffer(handleRsiCloseH1, 1, shift + ShiftValue, 1, aux3);
   CopyBuffer(handleRsiMedianH1, 1, shift + ShiftValue, 1, aux4);
   CopyBuffer(handleRsiCloseH1, 1, shift + ShiftValue + 1, 1, aux5);
   CopyBuffer(handleRsiMedianH1, 1, shift + ShiftValue + 1, 1, aux6);
   
	rsiLevelCloseH1 = aux1[0];
	rsiLevelMedianH1 = aux2[0];
	double rsiLevelCloseShiftedH1 = aux3[0];
	double rsiLevelMedianShiftedH1 = aux4[0];
	double rsiLevelCloseShifted2H1 = aux5[0];
	double rsiLevelMedianShifted2H1 = aux6[0];
	
	
	// D1
   CopyBuffer(handleRsiCloseD1, 1, shift, 1, aux1);
   CopyBuffer(handleRsiMedianD1, 1, shift, 1, aux2);
   CopyBuffer(handleRsiCloseD1, 1, shift + ShiftValue, 1, aux3);
   CopyBuffer(handleRsiMedianD1, 1, shift + ShiftValue, 1, aux4);
   CopyBuffer(handleRsiCloseD1, 1, shift + ShiftValue + 1, 1, aux5);
   CopyBuffer(handleRsiMedianD1, 1, shift + ShiftValue + 1, 1, aux6);
   
	rsiLevelCloseD1 = aux1[0];
	rsiLevelMedianD1 = aux2[0];
	double rsiLevelCloseShiftedD1 = aux3[0];
	double rsiLevelMedianShiftedD1 = aux4[0];
	double rsiLevelCloseShifted2D1 = aux5[0];
	double rsiLevelMedianShifted2D1 = aux6[0];
	
	
	// W1
   CopyBuffer(handleRsiCloseW1, 1, shift, 1, aux1);
   CopyBuffer(handleRsiMedianW1, 1, shift, 1, aux2);
   CopyBuffer(handleRsiCloseW1, 1, shift + ShiftValue, 1, aux3);
   CopyBuffer(handleRsiMedianW1, 1, shift + ShiftValue, 1, aux4);
   CopyBuffer(handleRsiCloseW1, 1, shift + ShiftValue + 1, 1, aux5);
   CopyBuffer(handleRsiMedianW1, 1, shift + ShiftValue + 1, 1, aux6);
   
	rsiLevelCloseW1 = aux1[0];
	rsiLevelMedianW1 = aux2[0];
	double rsiLevelCloseShiftedW1 = aux3[0];
	double rsiLevelMedianShiftedW1 = aux4[0];
	double rsiLevelCloseShifted2W1 = aux5[0];
	double rsiLevelMedianShifted2W1 = aux6[0];
#endif 
	// partial results based on each RSI level
	double currentResult = IncertitudeDecision;
	
	// H1 (fast) - close
	double rsiLevelCloseResultH1 = ((rsiLevelCloseH1 >= 70.0) && (rsiLevelCloseH1 != InvalidValue) ? SellDecision : IncertitudeDecision);
	if(rsiLevelCloseResultH1 != IncertitudeDecision)
		type += RSI_CloseResultH1_DOWN;
	currentResult = ((rsiLevelCloseH1 <= 30.0) && (rsiLevelCloseH1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
	if(currentResult != IncertitudeDecision)
	{
		rsiLevelCloseResultH1 += currentResult;
		type += RSI_CloseResultH1_UP;
	}
	
	// H1 (fast) - median
	double rsiLevelMedianResultH1 = ((rsiLevelMedianH1 >= 70.0) && (rsiLevelMedianH1 != InvalidValue) ? SellDecision : IncertitudeDecision);
	if(rsiLevelMedianResultH1 != IncertitudeDecision)
		type += RSI_MedianResultH1_DOWN;
	currentResult = ((rsiLevelMedianH1 <= 30.0) && (rsiLevelMedianH1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
	if(currentResult != IncertitudeDecision)
	{
		rsiLevelMedianResultH1 += currentResult;
		type += RSI_MedianResultH1_UP;
	}
	
	// D1 (medium) - close
	double rsiLevelCloseResultD1 = ((rsiLevelCloseD1 >= 70.0) && (rsiLevelCloseD1 != InvalidValue) ? SellDecision : IncertitudeDecision);
	if(rsiLevelCloseResultD1 != IncertitudeDecision)
		type += RSI_CloseResultD1_DOWN;
	currentResult = ((rsiLevelCloseD1 <= 30.0) && (rsiLevelCloseD1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
	if(currentResult != IncertitudeDecision)
	{
		rsiLevelCloseResultD1 += currentResult;
		type += RSI_CloseResultD1_UP;
	}
	
	// D1 (medium) - median
	double rsiLevelMedianResultD1 = ((rsiLevelMedianD1 >= 70.0) && (rsiLevelMedianD1 != InvalidValue) ? SellDecision : IncertitudeDecision);
	if(rsiLevelMedianResultD1 != IncertitudeDecision)
		type += RSI_MedianResultD1_DOWN;
	currentResult = ((rsiLevelMedianD1 <= 30.0) && (rsiLevelMedianD1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
	if(currentResult != IncertitudeDecision)
	{
		rsiLevelMedianResultD1 += currentResult;
		type += RSI_MedianResultD1_UP;
	}
	
	// W1 (slow) - close
	double rsiLevelCloseResultW1 = ((rsiLevelCloseW1 >= 70.0) && (rsiLevelCloseW1 != InvalidValue) ? SellDecision : IncertitudeDecision);
	if(rsiLevelCloseResultW1 != IncertitudeDecision)
		type += RSI_CloseResultW1_DOWN;
	currentResult = ((rsiLevelCloseW1 <= 30.0) && (rsiLevelCloseW1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
	if(currentResult != IncertitudeDecision)
	{
		rsiLevelCloseResultW1 += currentResult;
		type += RSI_CloseResultW1_UP;
	}
	
	// W1 (slow) - median
	double rsiLevelMedianResultW1 = ((rsiLevelMedianW1 >= 70.0) && (rsiLevelMedianW1 != InvalidValue) ? SellDecision : IncertitudeDecision);
	if(rsiLevelMedianResultW1 != IncertitudeDecision)
		type += RSI_MedianResultW1_DOWN;
	currentResult = ((rsiLevelMedianW1 <= 30.0) && (rsiLevelMedianW1 != InvalidValue) ? BuyDecision : IncertitudeDecision);
	if(currentResult != IncertitudeDecision)
	{
		rsiLevelMedianResultW1 += currentResult;
		type += RSI_MedianResultW1_UP;
	}
	
	
	
	// whole results based on each RSI level (giving more certitude => double the decision result)
	// H1 (fast) - close
	if(((rsiLevelCloseH1 < rsiLevelCloseShiftedH1) || (rsiLevelCloseH1 < rsiLevelCloseShifted2H1)) && (rsiLevelCloseResultH1 == SellDecision))
	{
		type += RSI_CloseResultH1_2DOWN;
		rsiLevelCloseResultH1 = rsiLevelCloseResultH1 * 2;
	}
	if(((rsiLevelCloseH1 > rsiLevelCloseShiftedH1) || (rsiLevelCloseH1 > rsiLevelCloseShifted2H1)) && (rsiLevelCloseResultH1 == BuyDecision))
	{
		type += RSI_CloseResultH1_2UP;
		rsiLevelCloseResultH1 = rsiLevelCloseResultH1 * 2;
	}
	
	// H1 (fast) - median
	if(((rsiLevelMedianH1 < rsiLevelMedianShiftedH1) || (rsiLevelMedianH1 < rsiLevelMedianShifted2H1)) && (rsiLevelMedianResultH1 == SellDecision))
	{
		type += RSI_MedianResultH1_2DOWN;
		rsiLevelMedianResultH1 = rsiLevelMedianResultH1 * 2;
	}
	if(((rsiLevelMedianH1 > rsiLevelMedianShiftedH1) || (rsiLevelMedianH1 > rsiLevelMedianShifted2H1)) && (rsiLevelMedianResultH1 == BuyDecision))
	{
		type += RSI_MedianResultH1_2UP;
		rsiLevelMedianResultH1 = rsiLevelMedianResultH1 * 2;
	}
	
	// D1 (medium) - close
	if(((rsiLevelCloseD1 < rsiLevelCloseShiftedD1) || (rsiLevelCloseD1 < rsiLevelCloseShifted2D1)) && (rsiLevelCloseResultD1 == SellDecision))
	{
		type += RSI_CloseResultD1_2DOWN;
		rsiLevelCloseResultD1 = rsiLevelCloseResultD1 * 2;
	}
	if(((rsiLevelCloseD1 > rsiLevelCloseShiftedD1) || (rsiLevelCloseD1 > rsiLevelCloseShifted2D1)) && (rsiLevelCloseResultD1 == BuyDecision))
	{
		type += RSI_CloseResultD1_2UP;
		rsiLevelCloseResultD1 = rsiLevelCloseResultD1 * 2;
	}
	
	// D1 (medium) - median
	if(((rsiLevelMedianD1 < rsiLevelMedianShiftedD1) || (rsiLevelMedianD1 < rsiLevelMedianShifted2D1)) && (rsiLevelMedianResultD1 == SellDecision))
	{
		type += RSI_MedianResultD1_2DOWN;
		rsiLevelMedianResultD1 = rsiLevelMedianResultD1 * 2;
	}
	if(((rsiLevelMedianD1 > rsiLevelMedianShiftedD1) || (rsiLevelMedianD1 > rsiLevelMedianShifted2D1)) && (rsiLevelMedianResultD1 == BuyDecision))
	{
		type += RSI_MedianResultD1_2UP;
		rsiLevelMedianResultD1 = rsiLevelMedianResultD1 * 2;
	}
	
	// W1 (slow) - close
	if(((rsiLevelCloseW1 < rsiLevelCloseShiftedW1) || (rsiLevelCloseW1 < rsiLevelCloseShifted2W1)) && (rsiLevelCloseResultW1 == SellDecision))
	{
		type += RSI_CloseResultW1_2DOWN;
		rsiLevelCloseResultW1 = rsiLevelCloseResultW1 * 2;
	}
	if(((rsiLevelCloseW1 > rsiLevelCloseShiftedW1) || (rsiLevelCloseW1 > rsiLevelCloseShifted2W1)) && (rsiLevelCloseResultW1 == BuyDecision))
	{
		type += RSI_CloseResultW1_2UP;
		rsiLevelCloseResultW1 = rsiLevelCloseResultW1 * 2;
	}
	
	// W1 (slow) - median
	if(((rsiLevelMedianW1 < rsiLevelMedianShiftedW1) || (rsiLevelMedianW1 < rsiLevelMedianShifted2W1)) && (rsiLevelMedianResultW1 == SellDecision))
	{
		type += RSI_MedianResultW1_2DOWN;
		rsiLevelMedianResultW1 = rsiLevelMedianResultW1 * 2;
	}
	if(((rsiLevelMedianW1 > rsiLevelMedianShiftedW1) || (rsiLevelMedianW1 > rsiLevelMedianShifted2W1)) && (rsiLevelMedianResultW1 == BuyDecision))
	{
		type += RSI_MedianResultW1_2UP;
		rsiLevelMedianResultW1 = rsiLevelMedianResultW1 * 2;
	}
	
	// max(rsiResult) = +/- 12.0
	// min(rsiResult) = 0.0
	double rsiResult =
		rsiLevelCloseResultH1 +
		rsiLevelMedianResultH1 +
		rsiLevelCloseResultD1 +
		rsiLevelMedianResultD1 +
		rsiLevelCloseResultW1 +
		rsiLevelMedianResultW1;
	
	if(IsVerboseMode())
	{
		if((GetVerboseLevel() > 1) || (rsiResult != 0))
			printf("RSI Level Decision [%f.0]: H1: %.2f %.2f D1: %.2f %.2f W1: %.2f %.2f\nRSI partial decision: H1: %.0f %.0f D1: %.0f %.0f W1: %.0f %.0f\n",
				// final RSI decision
				rsiResult,
				// close/median levels
				rsiLevelCloseH1, rsiLevelMedianH1,
				rsiLevelCloseD1, rsiLevelMedianD1,
				rsiLevelCloseW1, rsiLevelMedianW1,
				// partial RSI decisions
				rsiLevelCloseResultH1, rsiLevelMedianResultH1,
				rsiLevelCloseResultD1, rsiLevelMedianResultD1,
				rsiLevelCloseResultW1, rsiLevelMedianResultW1
			);
	}
	
	return rsiResult;
}

string DecisionRSI::ToString()
{
	string retString = typename(this) + " { ";
	
	retString += "rsiLevelCloseH1:" + DoubleToString(rsiLevelCloseH1) + " ";
	retString += "rsiLevelMedianH1:" + DoubleToString(rsiLevelMedianH1) + " ";
	retString += "rsiLevelCloseD1:" + DoubleToString(rsiLevelCloseD1) + " ";
	retString += "rsiLevelMedianD1:" + DoubleToString(rsiLevelMedianD1) + " ";
	retString += "rsiLevelCloseW1:" + DoubleToString(rsiLevelCloseW1) + " ";
	retString += "rsiLevelMedianW1:" + DoubleToString(rsiLevelMedianW1) + " ";
	
	retString += "} ";
	return retString;
}

/// DecisionRSI::CalculateRSI???(...)

//Relative Strength Index (RSI):
//RSI = 100-(100/(1+U/D))

//U — is the average number of positive price changes;
//D — is the average number of negative price changes.

