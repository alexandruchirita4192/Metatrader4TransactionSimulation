#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/DecisionIndicator.mqh>

enum ENUM_PS2_TYPE
{
	PS2_NONE                   = 0,
	PS2_UP                     = 1,
	PS2_DOWN                   = 2
};

class DecisionPS2 : public BaseDecision
{
	public:
		DecisionPS2() : BaseDecision() {}
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Parabolic SAR 2"; }
		
		double GetDecision(int shift, unsigned long &type);
		
		double GetMaxDecision()
		{
			// max(result) = +/- 1.0 (Buy = +; Sell = -)
			// min(result) = 0.0 (Incertitude = 0)
			return 1.0;
		}
};



double DecisionPS2::GetDecision(int shift, unsigned long &type)
{
	return IncertitudeDecision;
}
