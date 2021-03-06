#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/DecisionIndicator.mqh>
#include <MyMql/Global/Global.mqh>

enum ENUM_COMBINED_MA_TYPE
{
	COMBINED_MA_NONE          = 0,
	COMBINED_MA_CLOSE_X_UP    = 1,
	COMBINED_MA_CLOSE_X_DOWN  = 2,
	
	COMBINED_MA_MEDIAN_X_UP   = 4,
	COMBINED_MA_MEDIAN_X_DOWN = 8
};

class DecisionCombinedMA : public DecisionIndicator
{
	private:
		double closeLevel, medianLevel, closeLevelShifted, medianLevelShifted;
		double maCloseLevel, maMedianLevel, maCloseLevelShifted, maMedianLevelShifted;
		ENUM_TIMEFRAMES currentPeriod;

#ifdef __MQL5__
      int handleEmaClose, handleLwmaClose, handleSmaClose, handleSmmaClose,
         handleEmaMedian, handleLwmaMedian, handleSmaMedian, handleSmmaMedian;
#endif

	public:
		DecisionCombinedMA(GlobalConfig &config, int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
		   currentPeriod =  IntegerToTimeFrame(config.GetPeriod());
#ifdef __MQL5__
         handleEmaClose = handleLwmaClose = handleSmaClose = handleSmmaClose = handleEmaMedian = handleLwmaMedian = handleSmaMedian = handleSmmaMedian = INVALID_HANDLE;
#endif
		}
		
		DecisionCombinedMA(ENUM_TIMEFRAMES period, int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
   		currentPeriod = period;
#ifdef __MQL5__
         handleEmaClose = handleLwmaClose = handleSmaClose = handleSmmaClose = handleEmaMedian = handleLwmaMedian = handleSmaMedian = handleSmmaMedian = INVALID_HANDLE;
#endif

		}

		DecisionCombinedMA(int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
		   currentPeriod = IntegerToTimeFrame(_Period);
#ifdef __MQL5__
         handleEmaClose = handleLwmaClose = handleSmaClose = handleSmmaClose = handleEmaMedian = handleLwmaMedian = handleSmaMedian = handleSmmaMedian = INVALID_HANDLE;
#endif

		}
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Combined Moving Averages"; }
		
		virtual double GetClose()  { return closeLevel;  }
		virtual double GetCloseShifted()  { return closeLevelShifted;  }
		virtual double GetMedian() { return medianLevel; }
		virtual double GetMedianShifted() { return medianLevelShifted; }
		
		virtual double GetMAClose()  { return maCloseLevel;  }
		virtual double GetMACloseShifted()  { return maCloseLevelShifted;  }
		virtual double GetMAMedian() { return maMedianLevel; }
		virtual double GetMAMedianShifted() { return maMedianLevelShifted; }
		
		virtual void SetIndicatorData(double &Buffer_Close[], int index) {
			Buffer_Close[index] = maCloseLevel;
		}
		virtual void SetIndicatorShiftedData(double &Buffer_CloseShifted[], int index) {
			Buffer_CloseShifted[index] = maCloseLevelShifted;
		}
		
		virtual void SetIndicatorData(double &Buffer_Close[], double &Buffer_Median[], int index) {
			Buffer_Close[index] = maCloseLevel;
			Buffer_Median[index] = maMedianLevel;
		}
		virtual void SetIndicatorShiftedData(double &Buffer_CloseShifted[], double &Buffer_MedianShifted[], int index) {
			Buffer_CloseShifted[index] = maCloseLevelShifted;
			Buffer_MedianShifted[index] = maMedianLevelShifted;
		}
		
		virtual double GetDecision(int internalShift, unsigned long &type)
		{
			if((internalShift == 0) && (GetShiftValue() != 0))
				internalShift = GetShiftValue();
			
			// Analysis based on Moving Average levels:
			closeLevel = iClose(Symbol(), Period(), internalShift);
			medianLevel = (
				iOpen(Symbol(), Period(), internalShift) +
				iClose(Symbol(), Period(), internalShift)
			) / 2.0;
			closeLevelShifted = iClose(Symbol(), Period(), internalShift + ShiftValue);
			medianLevelShifted = (
				iOpen(Symbol(), Period(), internalShift + ShiftValue) +
				iClose(Symbol(), Period(), internalShift + ShiftValue)
			) / 2.0;
			
#ifdef __MQL4__
			maCloseLevel = (
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_EMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_LWMA, PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMA,  PRICE_CLOSE, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMMA, PRICE_CLOSE, internalShift)
			) / 4.0;
			maMedianLevel = (
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_EMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_LWMA, PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMA,  PRICE_MEDIAN, internalShift) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMMA, PRICE_MEDIAN, internalShift)
			) / 4.0;
			maCloseLevelShifted = (
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_EMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_LWMA, PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMA,  PRICE_CLOSE, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMMA, PRICE_CLOSE, internalShift + ShiftValue)
			) / 4.0;
			maMedianLevelShifted = (
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_EMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_LWMA, PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMA,  PRICE_MEDIAN, internalShift + ShiftValue) +
				iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMMA, PRICE_MEDIAN, internalShift + ShiftValue)
			) / 4.0;
#else
         if(handleEmaClose == INVALID_HANDLE)
            handleEmaClose = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_EMA, PRICE_CLOSE);
         if(handleLwmaClose == INVALID_HANDLE)
            handleLwmaClose = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_LWMA, PRICE_CLOSE);
         if(handleSmaClose == INVALID_HANDLE)
            handleSmaClose = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMA, PRICE_CLOSE);
         if(handleSmmaClose == INVALID_HANDLE)
            handleSmmaClose = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMMA, PRICE_CLOSE);
         
         if(handleEmaMedian == INVALID_HANDLE)
            handleEmaMedian = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_EMA, PRICE_MEDIAN);
         if(handleLwmaMedian == INVALID_HANDLE)
            handleLwmaMedian = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_LWMA, PRICE_MEDIAN);
         if(handleSmaMedian == INVALID_HANDLE)
            handleSmaMedian = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMA, PRICE_MEDIAN);
         if(handleSmmaMedian == INVALID_HANDLE)
            handleSmmaMedian = iMA(Symbol(), PERIOD_CURRENT, currentPeriod, 0, MODE_SMMA, PRICE_MEDIAN);
         
         double aux1[1], aux2[1], aux3[1], aux4[1];
         
         CopyBuffer(handleEmaClose, 1, internalShift, 1, aux1);
         CopyBuffer(handleLwmaClose, 1, internalShift, 1, aux2);
         CopyBuffer(handleSmaClose, 1, internalShift, 1, aux3);
         CopyBuffer(handleSmmaClose, 1, internalShift, 1, aux4);
         maCloseLevel = aux1[0] + aux2[0] + aux3[0] + aux4[0];
         
         CopyBuffer(handleEmaMedian, 1, internalShift, 1, aux1);
         CopyBuffer(handleLwmaMedian, 1, internalShift, 1, aux2);
         CopyBuffer(handleSmaMedian, 1, internalShift, 1, aux3);
         CopyBuffer(handleSmmaMedian, 1, internalShift, 1, aux4);
         maMedianLevel = aux1[0] + aux2[0] + aux3[0] + aux4[0];
         
         CopyBuffer(handleEmaMedian, 1, internalShift + ShiftValue, 1, aux1);
         CopyBuffer(handleLwmaMedian, 1, internalShift + ShiftValue, 1, aux2);
         CopyBuffer(handleSmaMedian, 1, internalShift + ShiftValue, 1, aux3);
         CopyBuffer(handleSmmaMedian, 1, internalShift + ShiftValue, 1, aux4);
         maCloseLevelShifted = aux1[0] + aux2[0] + aux3[0] + aux4[0];
         
         CopyBuffer(handleEmaMedian, 1, internalShift + ShiftValue, 1, aux1);
         CopyBuffer(handleLwmaMedian, 1, internalShift + ShiftValue, 1, aux2);
         CopyBuffer(handleSmaMedian, 1, internalShift + ShiftValue, 1, aux3);
         CopyBuffer(handleSmmaMedian, 1, internalShift + ShiftValue, 1, aux4);
         maMedianLevelShifted = aux1[0] + aux2[0] + aux3[0] + aux4[0];
#endif
			if((maCloseLevel == InvalidValue) || (maMedianLevel == InvalidValue) ||
			(maCloseLevelShifted == InvalidValue) || (maMedianLevelShifted == InvalidValue))
				return IncertitudeDecision; // Calculate instead?
			
			double maDecision = IncertitudeDecision;
			double currentMaDecision = IncertitudeDecision;
			
			currentMaDecision = (((closeLevel >= maCloseLevel) && (closeLevelShifted < maCloseLevelShifted)) ? BuyDecision : IncertitudeDecision);
			if(currentMaDecision != IncertitudeDecision)
			{
				type += COMBINED_MA_CLOSE_X_DOWN;
				maDecision += currentMaDecision;
			}
			
			currentMaDecision = (((closeLevel <= maCloseLevel) && (closeLevelShifted > maCloseLevelShifted)) ? SellDecision : IncertitudeDecision);
			if(currentMaDecision != IncertitudeDecision)
			{
				type += COMBINED_MA_CLOSE_X_UP;
				maDecision += currentMaDecision;
			}
			
			currentMaDecision = (((medianLevel >= maMedianLevel) && (medianLevelShifted < maMedianLevelShifted)) ? BuyDecision : IncertitudeDecision);
			if(currentMaDecision != IncertitudeDecision)
			{
				type += COMBINED_MA_MEDIAN_X_DOWN;
				maDecision += currentMaDecision;
			}
			
			currentMaDecision = (((medianLevel <= maMedianLevel) && (medianLevelShifted > maMedianLevelShifted)) ? SellDecision : IncertitudeDecision);
			if(currentMaDecision != IncertitudeDecision)
			{
				type += COMBINED_MA_MEDIAN_X_UP;
				maDecision += currentMaDecision;
			}
			
			return maDecision;
		}
		
		virtual double GetMaxDecision()
		{
			// max(maResult) = +/- 1.0 (Buy = +; Sell = -)
			// min(maResult) = 0.0 (Incertitude = 0)
			return 2.0;
		}
};

/// DecisionCombinedMA::CalculateMA???(...)

//Simple Moving Average (SMA):
//SMA = SUM(CLOSE, N)/N

//N — is the number of calculation periods.



//Exponential Moving Average (EMA):
//EMA = (CLOSE(i)*P)+(EMA(i-1)*(1-P))

//CLOSE(i) — the price of the current period closure;
//EMA(i-1) — Exponentially Moving Average of the previous period closure;
//P — the percentage of using the price value



//Smoothed Moving Average (SMMA):
//SUM1 = SUM(CLOSE, N); (Simple SMA)
//SMMA1 = SUM1/N;
//PREVSUM = SMMA(i-1) *N;
//SMMA(i) = (PREVSUM-SMMA(i-1)+CLOSE(i))/N

//SUM1 — is the total sum of closing prices for N periods;
//PREVSUM — is the smoothed sum of the previous bar;
//SMMA1 — is the smoothed moving average of the first bar;
//SMMA(i) — is the smoothed moving average of the current bar (except for the first one);
//CLOSE(i) — is the current closing price;
//N — is the smoothing period.



//Linear Weighted Moving Average (LWMA):
//LWMA = SUM(Close(i)*i, N)/SUM(i, N)

//SUM(i, N) — is the total sum of weight coefficients.
