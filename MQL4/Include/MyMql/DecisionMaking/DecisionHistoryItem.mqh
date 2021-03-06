#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


//#include <MyMql/Base/BaseObject.mqh>
//#include <MyMql/Base/DecisionHistoryItem.mqh>

struct DecisionHistoryItem //: public BaseObject
{
	public:
		double decision;
		int shift;
		
		DecisionHistoryItem(double _decision = 0.0, int _shift = 0)
		{
		   decision = _decision;
		   shift = _shift;
		}
		
		~DecisionHistoryItem() {}
		
};
