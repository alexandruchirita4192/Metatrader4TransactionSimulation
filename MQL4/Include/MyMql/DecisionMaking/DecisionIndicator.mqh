#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/BaseDecision.mqh>

const double InvalidValue = 0.0;

class DecisionIndicator : public BaseDecision
{
	protected:
		int ShiftValue; // difference between current data and past data (current data - ShiftValue)
		int InternalShift; // used to calculate decision in the past
		
	public:
		DecisionIndicator(int shiftValue, int internalShift) : BaseDecision()
		{
			this.ShiftValue = shiftValue;
			this.InternalShift = internalShift;
		}
		
		~DecisionIndicator() {}
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Decision Indicator"; }
		
		virtual int GetShiftValue() { return ShiftValue; }
		virtual int GetInternalShift() { return InternalShift; }
		virtual void SetShiftValue(int shiftValue = 1) { this.ShiftValue = shiftValue; }
		
		
		virtual string ToString();
};

string DecisionIndicator::ToString()
{
	string retString = typename(this) + " { ";
	
	retString += "ShiftValue:" + IntegerToString(ShiftValue) + " ";
	retString += "InternalShift:" + IntegerToString(InternalShift) + " ";
	
	retString += "} ";
	return retString;
}