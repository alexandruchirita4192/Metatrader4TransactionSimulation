#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/DecisionIndicator.mqh>
#include <MyMql/DecisionMaking/DecisionCombinedMA.mqh>
#include <Object.mqh>

enum ENUM_3COMBINED_MA_TYPE
{
	D_3COMBINED_MA_NONE                   = 0,
	
	D_3COMBINED_MA_CLOSE_X_UP_D1          = 1,
	D_3COMBINED_MA_CLOSE_X_DOWN_D1        = 2,
	D_3COMBINED_MA_MEDIAN_X_UP_D1         = 4,
	D_3COMBINED_MA_MEDIAN_X_DOWN_D1       = 8,
	
	D_3COMBINED_MA_CLOSE_X_UP_H1          = 16,
	D_3COMBINED_MA_CLOSE_X_DOWN_H1        = 32,
	D_3COMBINED_MA_MEDIAN_X_UP_H1         = 64,
	D_3COMBINED_MA_MEDIAN_X_DOWN_H1       = 128,
	
	D_3COMBINED_MA_CLOSE_X_UP_W1          = 256,
	D_3COMBINED_MA_CLOSE_X_DOWN_W1        = 512,
	D_3COMBINED_MA_MEDIAN_X_UP_W1         = 1024,
	D_3COMBINED_MA_MEDIAN_X_DOWN_W1       = 2048,
	
	D_3COMBINED_MA_CloseResultH1_UP       = 4096,
	D_3COMBINED_MA_CloseResultH1_DOWN     = 8192,
	D_3COMBINED_MA_MedianResultH1_UP      = 16384,
	D_3COMBINED_MA_MedianResultH1_DOWN    = 32768,
	D_3COMBINED_MA_CloseResultD1_UP       = 65536,
	D_3COMBINED_MA_CloseResultD1_DOWN     = 131072,
	D_3COMBINED_MA_MedianResultD1_UP      = 262144,
	D_3COMBINED_MA_MedianResultD1_DOWN    = 524288,
	D_3COMBINED_MA_CloseResultW1_UP       = 1048576,
	D_3COMBINED_MA_CloseResultW1_DOWN     = 2097152,
	D_3COMBINED_MA_MedianResultW1_UP      = 4194304,
	D_3COMBINED_MA_MedianResultW1_DOWN    = 8388608,
	
	D_3COMBINED_MA_CloseResultH1xD1_UP    = 16777216,
	D_3COMBINED_MA_CloseResultH1xD1_DOWN  = 33554432,
	D_3COMBINED_MA_CloseResultH1xW1_UP    = 67108864,
	D_3COMBINED_MA_CloseResultH1xW1_DOWN  = 134217728,
	D_3COMBINED_MA_CloseResultD1xW1_UP    = 268435456,
	D_3COMBINED_MA_CloseResultD1xW1_DOWN  = 536870912,
	D_3COMBINED_MA_MedianResultH1xD1_UP   = 1073741824,
	D_3COMBINED_MA_MedianResultH1xD1_DOWN = 2147483648
	
	// enum does not support more than this; the rest is up to "const unsigned long"
};

const unsigned long
	D_3COMBINED_MA_MedianResultH1xW1_UP   = 4294967296,
	D_3COMBINED_MA_MedianResultH1xW1_DOWN = 8589934592,
	D_3COMBINED_MA_MedianResultD1xW1_UP   = 17179869184,
	D_3COMBINED_MA_MedianResultD1xW1_DOWN = 34359738368;
	//D_3COMBINED_MA_WhateverTheName_UP   = 68719476736,
	//D_3COMBINED_MA_WhateverTheName_DOWN = 137438953472,
	//D_3COMBINED_MA_WhateverTheName_UP   = 274877906944,
	//D_3COMBINED_MA_WhateverTheName_DOWN = 549755813888;

class Decision3CombinedMA : public DecisionIndicator
{
	private:
		DecisionCombinedMA *maDecisionH1, *maDecisionD1, *maDecisionW1;
		
	public:
		Decision3CombinedMA(int shiftValue, int internalShift) : DecisionIndicator(shiftValue, internalShift)
		{
			maDecisionH1 = new DecisionCombinedMA(PERIOD_H1, shiftValue, internalShift);
			maDecisionD1 = new DecisionCombinedMA(PERIOD_D1, shiftValue, internalShift);
			maDecisionW1 = new DecisionCombinedMA(PERIOD_W1, shiftValue, internalShift);
		}
		
		~Decision3CombinedMA()
		{
			delete maDecisionH1;
			delete maDecisionD1;
			delete maDecisionW1;
		}
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "6 Combined Moving Averages"; }
		
		virtual double GetCloseH1()  { return maDecisionH1.GetClose();  }
		virtual double GetMedianH1() { return maDecisionH1.GetMedian(); }
		virtual double GetCloseD1()  { return maDecisionD1.GetClose();  }
		virtual double GetMedianD1() { return maDecisionD1.GetMedian(); }
		virtual double GetCloseW1()  { return maDecisionW1.GetClose();  }
		virtual double GetMedianW1() { return maDecisionW1.GetMedian(); }
		
		virtual double GetCloseShiftedH1()  { return maDecisionH1.GetCloseShifted();  }
		virtual double GetMedianShiftedH1() { return maDecisionH1.GetMedianShifted(); }
		virtual double GetCloseShiftedD1()  { return maDecisionD1.GetCloseShifted();  }
		virtual double GetMedianShiftedD1() { return maDecisionD1.GetMedianShifted(); }
		virtual double GetCloseShiftedW1()  { return maDecisionW1.GetCloseShifted();  }
		virtual double GetMedianShiftedW1() { return maDecisionW1.GetMedianShifted(); }
		
		
		virtual void SetIndicatorData(
			double &Buffer_CloseShiftedH1[], double &Buffer_MedianShiftedH1[],
			double &Buffer_CloseShiftedD1[], double &Buffer_MedianShiftedD1[],
			double &Buffer_CloseShiftedW1[], double &Buffer_MedianShiftedW1[],
			int index
		);
			
		virtual void SetIndicatorShiftedData(
			double &Buffer_CloseH1[], double &Buffer_MedianH1[],
			double &Buffer_CloseD1[], double &Buffer_MedianD1[],
			double &Buffer_CloseW1[], double &Buffer_MedianW1[],
			int index
		);
		
		
		virtual double GetDecision(int internalShift, unsigned long &type);
		virtual double GetMaxDecision()
		{
			// max(maResult) = +/- 24.0 (Buy = +; Sell = -)
			// min(maResult) = 0.0 (Incertitude = 0)
			return 24.0;
		}
		
		virtual string ToString();
};


void Decision3CombinedMA::SetIndicatorShiftedData(
	double &Buffer_CloseShiftedH1[], double &Buffer_MedianShiftedH1[],
	double &Buffer_CloseShiftedD1[], double &Buffer_MedianShiftedD1[],
	double &Buffer_CloseShiftedW1[], double &Buffer_MedianShiftedW1[],
	int index
)
{
	Buffer_CloseShiftedH1[index] = maDecisionH1.GetCloseShifted(); Buffer_MedianShiftedH1[index] = maDecisionH1.GetMedianShifted();
	Buffer_CloseShiftedD1[index] = maDecisionD1.GetCloseShifted(); Buffer_MedianShiftedD1[index] = maDecisionD1.GetMedianShifted();
	Buffer_CloseShiftedW1[index] = maDecisionW1.GetCloseShifted(); Buffer_MedianShiftedW1[index] = maDecisionW1.GetMedianShifted();
}

void Decision3CombinedMA::SetIndicatorData(
	double &Buffer_CloseH1[], double &Buffer_MedianH1[],
	double &Buffer_CloseD1[], double &Buffer_MedianD1[],
	double &Buffer_CloseW1[], double &Buffer_MedianW1[],
	int index
)
{
	Buffer_CloseH1[index] = maDecisionH1.GetClose(); Buffer_MedianH1[index] = maDecisionH1.GetMedian();
	Buffer_CloseD1[index] = maDecisionD1.GetClose(); Buffer_MedianD1[index] = maDecisionD1.GetMedian();
	Buffer_CloseW1[index] = maDecisionW1.GetClose(); Buffer_MedianW1[index] = maDecisionW1.GetMedian();
}

double Decision3CombinedMA::GetDecision(int internalShift, unsigned long &type)
{
	type = D_3COMBINED_MA_NONE;
	
	// Initialize other decisions
	double maResult = maDecisionW1.GetDecision(internalShift, type);
	type = type << 4; // shift tested
	
	maResult += maDecisionH1.GetDecision(internalShift, type);
	type = type << 4; // shift tested
	
	maResult += maDecisionD1.GetDecision(internalShift, type);
	type = type << 4; // shift tested
	
	// Analysis based on Moving Average levels
	if((internalShift == 0) && (GetShiftValue() != 0))
		internalShift = GetShiftValue();
	
	// those should be the same on all periods
	double closeLevel = maDecisionD1.GetClose();
	double medianLevel = maDecisionD1.GetMedian();
	
	// H1 (fast)
	double maLevelCloseH1 = maDecisionH1.GetMAClose();
	double maLevelMedianH1 = maDecisionH1.GetMAMedian();
	double maLevelCloseShiftedH1 = maDecisionH1.GetMACloseShifted();
	double maLevelMedianShiftedH1 = maDecisionH1.GetMAMedianShifted();
	
	if((maLevelCloseH1 == 0.0) || (maLevelMedianH1 == 0.0) || (maLevelCloseShiftedH1 == 0.0) || (maLevelMedianShiftedH1 == 0.0))
		return IncertitudeDecision; // Calculate instead?
	
	// D1 (medium)
	double maLevelCloseD1 = maDecisionD1.GetMAClose();
	double maLevelMedianD1 = maDecisionD1.GetMAMedian();
	double maLevelCloseShiftedD1 = maDecisionD1.GetMACloseShifted();
	double maLevelMedianShiftedD1 = maDecisionD1.GetMAMedianShifted();
	
	if((maLevelCloseD1 == 0.0) || (maLevelMedianD1 == 0.0) || (maLevelCloseShiftedD1 == 0.0) || (maLevelMedianShiftedD1 == 0.0))
		return IncertitudeDecision; // Calculate instead
	
	// W1 (slow)
	double maLevelCloseW1 = maDecisionW1.GetMAClose();
	double maLevelMedianW1 = maDecisionW1.GetMAMedian();
	double maLevelCloseShiftedW1 = maDecisionW1.GetMACloseShifted();
	double maLevelMedianShiftedW1 = maDecisionW1.GetMAMedianShifted();
	
	//// this usually gets zered; ignore this
	//if((maLevelCloseW1 == 0.0) || (maLevelMedianW1 == 0.0) || (maLevelCloseShiftedW1 == 0.0) || (maLevelMedianShiftedW1 == 0.0))
	//	return IncertitudeDecision; // calculate instead? (calculation is a bit unreliable? too much calculation is slowing stuff?)
	
	// partial results based on each MA level
	
	
	
	// To do: What does it matter where the shift goes (maLevel < maLevelShifted or maLevel > maLevelShifted) if the data is between them? (or.. maybe that is normal up/down?) => new decision types?
	// buy:  value is not invalid && maLevel < close/median < maLevelShifted
	// sell: value is not invalid && maLevel > close/median > maLevelShifted
	double currentMaResult = IncertitudeDecision;
	
	// H1 (fast) - Close
	double maLevelCloseResultH1 = (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 < closeLevel) && (closeLevel < maLevelCloseShiftedH1)) ? BuyDecision : IncertitudeDecision);
	if(maLevelCloseResultH1 != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultH1_UP;
	currentMaResult = (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 > closeLevel) && (closeLevel > maLevelCloseShiftedH1)) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultH1_DOWN;
	maLevelCloseResultH1 += currentMaResult;
	
	// H1 (fast) - Median
	double maLevelMedianResultH1 = (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 < medianLevel) && (medianLevel < maLevelMedianShiftedH1)) ? BuyDecision : IncertitudeDecision);
	if(maLevelMedianResultH1 != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultH1_UP;
	currentMaResult = (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 > medianLevel) && (medianLevel > maLevelMedianShiftedH1)) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultH1_DOWN;
	maLevelMedianResultH1 += currentMaResult;
	
	// D1 (medium) - Close
	double maLevelCloseResultD1 = (((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 < closeLevel) && (closeLevel < maLevelCloseShiftedD1)) ? BuyDecision : IncertitudeDecision);
	if(maLevelCloseResultD1 != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultD1_UP;
	currentMaResult = (((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 > closeLevel) && (closeLevel > maLevelCloseShiftedD1)) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultD1_DOWN;
	maLevelCloseResultD1 += currentMaResult;
	
	// D1 (medium) - Median
	double maLevelMedianResultD1 = (((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 < medianLevel) && (medianLevel < maLevelMedianShiftedD1)) ? BuyDecision : IncertitudeDecision);
	if(maLevelMedianResultD1 != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultD1_UP;
	currentMaResult = (((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 > medianLevel) && (medianLevel > maLevelMedianShiftedD1)) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultD1_DOWN;
	maLevelMedianResultD1 += currentMaResult;
	
	// W1 (slow) - Close
	double maLevelCloseResultW1 =(((maLevelCloseW1 != InvalidValue) && (maLevelCloseW1 < closeLevel) && (closeLevel < maLevelCloseShiftedW1)) ? BuyDecision : IncertitudeDecision);
	if(maLevelCloseResultW1 != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultW1_UP;
	currentMaResult = (((maLevelCloseW1 != InvalidValue) && (maLevelCloseW1 > closeLevel) && (closeLevel > maLevelCloseShiftedW1)) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultW1_DOWN;
	maLevelCloseResultW1 += currentMaResult;
	
	// W1 (medium) - Median
	double maLevelMedianResultW1 = (((maLevelMedianW1 != InvalidValue) && (maLevelMedianW1 < medianLevel) && (medianLevel < maLevelMedianShiftedW1)) ? BuyDecision : IncertitudeDecision);
	if(maLevelMedianResultW1 != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultW1_UP;
	currentMaResult = (((maLevelMedianW1 != InvalidValue) && (maLevelMedianW1 > medianLevel) && (medianLevel > maLevelMedianShiftedW1)) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultW1_DOWN;
	maLevelMedianResultW1 += currentMaResult;
	
	
	
	// buy:  value is not invalid && maFasterLevel > maFasterLevelShifted && maFasterLevel > maSlowerLevel && maFasterLevel crossed maSlowerLevel (maFasterLevel between maSlowerLevel and maSlowerLevelShifted)
	// sell: value is not invalid && maFasterLevel < maFasterLevelShifted && maFasterLevel < maSlowerLevel && maFasterLevel crossed maSlowerLevel (maFasterLevel between maSlowerLevel and maSlowerLevelShifted)
	double maLevelCloseResultH1xD1 = (((maLevelCloseH1 != InvalidValue) && ((maLevelCloseH1 > maLevelCloseShiftedH1)) && (maLevelCloseH1 > maLevelCloseD1) && ((maLevelCloseD1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? BuyDecision : IncertitudeDecision);
	if(maLevelCloseResultH1xD1 != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultH1xD1_UP;
	currentMaResult = (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 < maLevelCloseShiftedH1) && (maLevelCloseH1 < maLevelCloseD1) && ((maLevelCloseD1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultH1xD1_DOWN;
	maLevelCloseResultH1xD1 += currentMaResult;
	
	double maLevelCloseResultH1xW1 = (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 > maLevelCloseShiftedH1) && (maLevelCloseH1 > maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? BuyDecision : IncertitudeDecision);
	if(maLevelCloseResultH1xW1 != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultH1xW1_UP;
	currentMaResult = (((maLevelCloseH1 != InvalidValue) && (maLevelCloseH1 < maLevelCloseShiftedH1) && (maLevelCloseH1 < maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseH1) && (maLevelCloseH1 <= maLevelCloseShiftedH1))) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultH1xW1_DOWN;
	maLevelCloseResultH1xW1 += currentMaResult;
	
	double maLevelCloseResultD1xW1 = (((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 > maLevelCloseShiftedD1) && (maLevelCloseD1 > maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseD1) && (maLevelCloseD1 <= maLevelCloseShiftedD1))) ? BuyDecision : IncertitudeDecision);
	if(maLevelCloseResultD1xW1 != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultD1xW1_UP;
	currentMaResult = (((maLevelCloseD1 != InvalidValue) && (maLevelCloseD1 < maLevelCloseShiftedD1) && (maLevelCloseD1 < maLevelCloseW1) && ((maLevelCloseW1 <= maLevelCloseD1) && (maLevelCloseD1 <= maLevelCloseShiftedD1))) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_CloseResultD1xW1_DOWN;
	maLevelCloseResultD1xW1 += currentMaResult;
	
	double maLevelMedianResultH1xD1 = (((maLevelMedianH1 != InvalidValue) && ((maLevelMedianH1 > maLevelMedianShiftedH1)) && (maLevelMedianH1 > maLevelMedianD1) && ((maLevelMedianD1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? BuyDecision : IncertitudeDecision);
	if(maLevelMedianResultH1xD1 != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultH1xD1_UP;
	currentMaResult = (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 < maLevelMedianShiftedH1) && (maLevelMedianH1 < maLevelMedianD1) && ((maLevelMedianD1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultH1xD1_DOWN;
	maLevelMedianResultH1xD1 += currentMaResult;
	
	double maLevelMedianResultH1xW1 = (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 > maLevelMedianShiftedH1) && (maLevelMedianH1 > maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? BuyDecision : IncertitudeDecision);
	if(maLevelMedianResultH1xW1 != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultH1xW1_UP;
	currentMaResult = (((maLevelMedianH1 != InvalidValue) && (maLevelMedianH1 < maLevelMedianShiftedH1) && (maLevelMedianH1 < maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianH1) && (maLevelMedianH1 <= maLevelMedianShiftedH1))) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultH1xW1_DOWN;
	maLevelMedianResultH1xW1 += currentMaResult;
	
	double maLevelMedianResultD1xW1 = (((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 > maLevelMedianShiftedD1) && (maLevelMedianD1 > maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianD1) && (maLevelMedianD1 <= maLevelMedianShiftedD1))) ? BuyDecision : IncertitudeDecision);
	if(maLevelMedianResultD1xW1 != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultD1xW1_UP;
	currentMaResult = (((maLevelMedianD1 != InvalidValue) && (maLevelMedianD1 < maLevelMedianShiftedD1) && (maLevelMedianD1 < maLevelMedianW1) && ((maLevelMedianW1 <= maLevelMedianD1) && (maLevelMedianD1 <= maLevelMedianShiftedD1))) ? SellDecision : IncertitudeDecision);
	if(currentMaResult != IncertitudeDecision)
		type += D_3COMBINED_MA_MedianResultD1xW1_DOWN;
	maLevelMedianResultD1xW1 += currentMaResult;
	
	
	// max(maResult) = +/- 24.0 (Buy = +; Sell = -)
	// min(maResult) = 0.0 (Incertitude = 0)
	maResult += 
		(maLevelCloseResultH1 + maLevelMedianResultH1 + maLevelCloseResultD1 + maLevelMedianResultD1 + maLevelCloseResultW1 + maLevelMedianResultW1) +
		2 * (maLevelCloseResultH1xD1 + maLevelCloseResultH1xW1 + maLevelCloseResultD1xW1 + maLevelMedianResultH1xD1 + maLevelMedianResultH1xW1 + maLevelMedianResultD1xW1);
	
	if(IsVerboseMode())
	{
		if((GetVerboseLevel() > 1) || (maResult != 0.0))
		{
			string text = StringFormat("MA Level Decision: [%s(%.0f)] [ ", maResult > 0.0 ? "buy" : "sell", maResult);
			text += StringFormatNumberNotZero("H1[c]: %.0f ", maLevelCloseResultH1);
			text += StringFormatNumberNotZero("H1[m]: %.0f ", maLevelMedianResultH1);
			text += StringFormatNumberNotZero("D1[c]: %.0f ", maLevelCloseResultD1);
			text += StringFormatNumberNotZero("D1[m]: %.0f ", maLevelMedianResultD1);
			text += StringFormatNumberNotZero("W1[c]: %.0f ", maLevelCloseResultW1);
			text += StringFormatNumberNotZero("W1[m]: %.0f ", maLevelMedianResultW1);
			text += StringFormat("]: [close=%f median=%f]", closeLevel, medianLevel);
			Print(text);
			
			text = "MA Level Data: ";
			text += ReturnStringOnNumberNotZero(StringFormat("H1[c,cs]: %f %f ", maLevelCloseH1, maLevelCloseShiftedH1), maLevelCloseResultH1);
			text += ReturnStringOnNumberNotZero(StringFormat("H1[m,ms]: %f %f ", maLevelMedianH1, maLevelMedianShiftedH1), maLevelMedianResultH1);
			text += ReturnStringOnNumberNotZero(StringFormat("D1[c,cs]: %f %f ", maLevelCloseD1, maLevelCloseShiftedD1), maLevelCloseResultD1);
			text += ReturnStringOnNumberNotZero(StringFormat("D1[m,ms]: %f %f ", maLevelMedianD1, maLevelMedianShiftedD1), maLevelMedianResultD1);
			text += ReturnStringOnNumberNotZero(StringFormat("W1[c,cs]: %f %f ", maLevelCloseW1, maLevelCloseShiftedW1), maLevelCloseResultW1);
			text += ReturnStringOnNumberNotZero(StringFormat("W1[m,ms]: %f %f ", maLevelMedianW1, maLevelMedianShiftedW1), maLevelMedianResultW1);
			Print(text);
			
			text = "Other info: ";
			text += ReturnStringOnCondition("simple buy decision: (value is not invalid) && (maLevel < close/median < maLevelShifted)", maResult > 0.0);
			text += ReturnStringOnCondition("simple sell decision: (value is not invalid) && (maLevel > close/median > maLevelShifted)", maResult < 0.0);
			Print(text);
			
			if(MathAbs(maResult) > 1.0)
			{
				text = "Other info: ";
				text += ReturnStringOnCondition("complex buy decision: (value is not invalid) && (maFasterLevel > maFasterLevelShifted) && (maFasterLevel > maSlowerLevel) && (maFasterLevel crossed maSlowerLevel)", maResult > 1.0);
				text += ReturnStringOnCondition("complex sell decision: (value is not invalid) && (maFasterLevel < maFasterLevelShifted) && (maFasterLevel < maSlowerLevel) && (maFasterLevel crossed maSlowerLevel)", maResult < 1.0);
				Print(text);
			}
		}
	}
	
	return maResult;
}

string Decision3CombinedMA::ToString()
{
	string retString = typename(this) + " { ";
	
	retString += "maLevelCloseH1:" + DoubleToString(maDecisionH1.GetMAClose()) + " ";
	retString += "maLevelMedianH1:" + DoubleToString(maDecisionH1.GetMAMedian()) + " ";
	retString += "maLevelCloseD1:" + DoubleToString(maDecisionD1.GetMAClose()) + " ";
	retString += "maLevelMedianD1:" + DoubleToString(maDecisionD1.GetMAMedian()) + " ";
	retString += "maLevelCloseW1:" + DoubleToString(maDecisionW1.GetMAClose()) + " ";
	retString += "maLevelMedianW1:" + DoubleToString(maDecisionW1.GetMAMedian()) + " ";
	retString += "maLevelCloseShiftedH1:" + DoubleToString(maDecisionH1.GetMACloseShifted()) + " ";
	retString += "maLevelMedianShiftedH1:" + DoubleToString(maDecisionH1.GetMAMedianShifted()) + " ";
	retString += "maLevelCloseShiftedD1:" + DoubleToString(maDecisionD1.GetMACloseShifted()) + " ";
	retString += "maLevelMedianShiftedD1:" + DoubleToString(maDecisionD1.GetMAMedianShifted()) + " ";
	retString += "maLevelCloseShiftedW1:" + DoubleToString(maDecisionW1.GetMACloseShifted()) + " ";
	retString += "maLevelMedianShiftedW1:" + DoubleToString(maDecisionW1.GetMAMedianShifted()) + " ";
	
	retString += "} ";
	return retString;
}
