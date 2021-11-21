#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/DecisionIndicator.mqh>

enum ENUM_MM_TYPE
{
	MM_NONE      = 0,
	MM_MAX       = 1,
	MM_MIN       = 2
};

class DecisionMinMax : public BaseDecision
{
	private:
		double delta;
		ENUM_TIMEFRAMES runningPeriod;
		
	public:
		DecisionMinMax(ENUM_TIMEFRAMES period, double deltaArg = -1.0) : BaseDecision()
		{
			runningPeriod = period;
			
			if(deltaArg < 0)
				deltaArg = Pip();
			delta = deltaArg;
		}
		
		~DecisionMinMax() {}
		
		virtual double GetDecision(int shift, unsigned long &type) {
			double low = iLow(_Symbol, runningPeriod, shift);
			double high = iHigh(_Symbol, runningPeriod, shift);
			double close = iClose(_Symbol, runningPeriod, shift);
			
			if(low >= (close - delta))
			{
				type = MM_MIN;
				return -1.0;
			}
			
			if(high <= (close + delta))
			{
				type = MM_MAX;
				return +1.0;
			}
			
			return IncertitudeDecision;
		}
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Decision Min/Max"; }
		
		
		double GetMaxDecision()
		{
			// max(result) = +/- 1.0 (Buy = +; Sell = -)
			// min(result) = 0.0 (Incertitude = 0)
			return 1.0;
		}
};
