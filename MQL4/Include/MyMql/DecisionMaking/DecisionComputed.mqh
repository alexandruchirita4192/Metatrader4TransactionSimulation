#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/DecisionIndicator.mqh>

enum ENUM_COMPUTED_TYPE
{
	COMPUTED_NONE      = 0,
	COMPUTED_BUY       = 1,
	COMPUTED_SELL      = 2
};

class DecisionComputed : public DecisionIndicator
{
	public:
		DecisionComputed(BaseDecision &array[], int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
		}
		
		~DecisionComputed() {}
		
		virtual double GetDecision(int shift, unsigned long &type) { return IncertitudeDecision; type=0; }
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Decision Computed"; }
};
