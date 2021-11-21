#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/DecisionMaking/BaseDecision.mqh>
#include <MyMql/Global/Info/ScreenInfo.mqh>

enum ENUM_CANDLE_TYPE
{
	CANDLE_NONE         = 0,
	CANDLE_BULLISH      = 1,
	CANDLE_BEARISH      = 2,
	CANDLE_WHITE_HAMMER = 4,
	CANDLE_BLACK_HAMMER = 8
};

class DecisionCandle : public BaseDecision
{
	private:
		ScreenInfo info;
		int InternalShift, shift1, shift2, shift3;
		double O, O1, O2, C, C1, C2, L, L1, L2, H, H1, H2;
		

		virtual bool IsUninitialized()
		{
			return ((C == 0.0) || (O == 0.0) || (L == 0.0) || (H == 0.0) ||
				(C1 == 0.0) || (O1 == 0.0) || (L1 == 0.0) || (H1 == 0.0) ||
				(C2 == 0.0) || (O2 == 0.0) || (L2 == 0.0) || (H2 == 0.0));
		}
		
	public:
		DecisionCandle() {}
		
		DecisionCandle(int shift, unsigned long &type) {
			RefreshCandleDecision(shift);
			this.InternalShift = shift;
		}
		
		virtual double GetDecision(int shift, unsigned long &type);
		
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Candle"; }
		
		void RefreshCandleDecision(int shift);
		
		void AutoRefreshCandleDecision(int shift)
		{
			if(shift != this.InternalShift)
				RefreshCandleDecision(shift);
		}
		
		virtual bool BullishCandle(int shift) { AutoRefreshCandleDecision(shift); if(IsUninitialized()) return false; return C > O; }
		virtual bool BearishCandle(int shift) { AutoRefreshCandleDecision(shift); if(IsUninitialized()) return false; return C < O; }
		
		virtual bool WhiteHammer(int shift);
		virtual bool BlackHammer(int shift);
		
		
		virtual void CreateObjects(int shift, color objColor = LawnGreen);
		
		virtual string ToString();
};



double DecisionCandle::GetDecision(int shift, unsigned long &type)
{
	double decision = IncertitudeDecision;
	type = CANDLE_NONE;
	RefreshCandleDecision(shift);
	
	if(IsUninitialized())
		return decision;
	
	if(BullishCandle(shift))
	{
		decision += BuyDecision;
		type += CANDLE_BULLISH;
	}
	
	if(BearishCandle(shift))
	{
		decision += SellDecision;
		type += CANDLE_BEARISH;
	}
	
	if(WhiteHammer(shift))
	{
		decision += 2.0*BuyDecision;
		type += CANDLE_WHITE_HAMMER;
	}
	
	if(BlackHammer(shift))
	{
		decision += 2.0*SellDecision;
		type += CANDLE_BLACK_HAMMER;
	}
	
	return decision;
}

void DecisionCandle::RefreshCandleDecision(int shift)
{
	this.InternalShift = shift;
	shift1 = shift; shift2 = shift + 1; shift3 = shift + 2;
	int bars = iBars(_Symbol, _Period);
	
	if(shift1 >= bars)
	{
		O = H = L = C = 0;
		O1 = H1 = L1 = C1 = 0;
		O2 = H2 = L2 = C2 = 0;
		return;
	}
	O = iOpen(_Symbol, _Period, shift1); H = iHigh(_Symbol, _Period, shift1); L = iLow(_Symbol, _Period, shift1); C = iClose(_Symbol, _Period, shift1);
	
	if(shift2 >= bars)
	{
		O1 = H1 = L1 = C1 = 0;
		O2 = H2 = L2 = C2 = 0;
		return;
	}
	O1 = iOpen(_Symbol, _Period, shift2); H1 = iHigh(_Symbol, _Period, shift2); L1 = iLow(_Symbol, _Period, shift2); iClose(_Symbol, _Period, shift2);
	
	if(shift3 >= bars)
	{
		O2 = H2 = L2 = C2 = 0;
		return;
	}
	O2 = iOpen(_Symbol, _Period, shift3); H2 = iHigh(_Symbol, _Period, shift3); L2 = iLow(_Symbol, _Period, shift3); C2 = iClose(_Symbol, _Period, shift3);
}

bool DecisionCandle::WhiteHammer(int shift) {
	AutoRefreshCandleDecision(shift);
	
	if(IsUninitialized())
		return false; 
	
	if (((C > O) && ((O - L) >= 2.0 * (C - O)) && ((H - C)<=(O - L) * 0.1)))
		return true;
	return false;
}

bool DecisionCandle::BlackHammer(int shift) {
	AutoRefreshCandleDecision(shift);
	
	if(IsUninitialized())
		return false; 
	
	if (((C < O) && ((C - L) >= 2.0 * (O - C)) && ((H - O) <= (C - L) * 0.1)))
		return true;
	return false;
}


void DecisionCandle::CreateObjects(int shift, color objColor = LawnGreen) {
	AutoRefreshCandleDecision(shift);
	string objectName = "";
	
	if(WhiteHammer(shift))
	{
		objectName = info.NewObjectName("WhiteHammer");
		ObjectCreate(ChartID(), objectName, OBJ_TEXT, 0, iTime(_Symbol, _Period, shift), L - _Point);
#ifdef __MQL4__
		ObjectSetText(objectName, "WHmr", 9, "Times New Roman", objColor);
#else
   	ObjectSetString(ChartID(), objectName, OBJPROP_TEXT, "WHmr");
   	ObjectSetString(ChartID(), objectName, OBJPROP_FONT, "Times New Roman");
   	ObjectSetInteger(ChartID(), objectName, OBJPROP_COLOR, objColor);
   	ObjectSetInteger(ChartID(), objectName, OBJPROP_FONTSIZE, 9);
#endif
	}
	
	if(BlackHammer(shift))
	{
		objectName = info.NewObjectName("BlackHammer");
		ObjectCreate(ChartID(), objectName, OBJ_TEXT, 0, iTime(_Symbol, _Period, shift), L - _Point);
#ifdef __MQL4__
		ObjectSetText(objectName, "BHmr", 9, "Times New Roman", objColor);
#else
   	ObjectSetString(ChartID(), objectName, OBJPROP_TEXT, "BHmr");
   	ObjectSetString(ChartID(), objectName, OBJPROP_FONT, "Times New Roman");
   	ObjectSetInteger(ChartID(), objectName, OBJPROP_COLOR, objColor);
   	ObjectSetInteger(ChartID(), objectName, OBJPROP_FONTSIZE, 9);
#endif
	}
}

string DecisionCandle::ToString()
{
	string retString = typename(this) + " { ";
	
	retString += "info:" + info.ToString() + " ";
	retString += "InternalShift:" + IntegerToString(InternalShift) + " ";
	retString += "shift1:" + IntegerToString(shift1) + " ";
	retString += "shift2:" + IntegerToString(shift2) + " ";
	retString += "shift3:" + IntegerToString(shift3) + " ";
	retString += "O:" + DoubleToString(O) + " ";
	retString += "O1:" + DoubleToString(O1) + " ";
	retString += "O2:" + DoubleToString(O2) + " ";
	retString += "C:" + DoubleToString(C) + " ";
	retString += "C1:" + DoubleToString(C1) + " ";
	retString += "C2:" + DoubleToString(C2) + " ";
	retString += "L:" + DoubleToString(L) + " ";
	retString += "L1:" + DoubleToString(L1) + " ";
	retString += "L2:" + DoubleToString(L2) + " ";
	retString += "H:" + DoubleToString(H) + " ";
	retString += "H1:" + DoubleToString(H1) + " ";
	retString += "H2:" + DoubleToString(H2) + " ";
	
	retString += "} ";
	return retString;
}
