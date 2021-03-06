#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Base/BaseObject.mqh>
#include <MyMql/DecisionMaking/DecisionHistoryItem.mqh>


const double BuyDecision = 1.0;
const double IncertitudeDecision = 0.0;
const double SellDecision = -1.0;

class BaseDecision : public BaseObject
{
	protected:
		int lenIntervals;
		DecisionHistoryItem intervals[];
		
		int lenDecisionsHistory;
		DecisionHistoryItem decisionsHistory[];

	public:
		BaseDecision() : BaseObject() {}
		~BaseDecision() {}
		
		virtual double GetSL() { return 0.0; }
		virtual double GetTP() { return 0.0; }
		
		virtual double GetMaxDecision() { return IncertitudeDecision; }
		virtual double GetDecision(int shift, unsigned long &type) { return IncertitudeDecision; type=0; }
		virtual string GetDecisionName() { return typename(this); }
		virtual string GetDecisionFullName() { return "Base Decision"; }
		
		virtual bool DecisionWithIrregularLimits() { return false; }
		
		virtual int GetOrderTypeBasedOnDecision(double decision)
		{
			if(decision > 0.0)
				return OP_BUY;
			if(decision < 0.0)
				return OP_SELL;
			
			Print("Incertitude decision in " + __FUNCTION__ + " at line " + IntegerToString(__LINE__));
			
			return -2;
		}

		virtual void CalculateDecisionHistory()
		{
			if(lenDecisionsHistory != 0)
				return;

			for(int i=0;i<iBars(_Symbol, _Period);i++)
			{
				unsigned long type = 0;
				double currentDecision = GetDecision(i, type);
				if(currentDecision != 0)
				{
					ArrayResize(decisionsHistory, lenDecisionsHistory+1);
					decisionsHistory[lenDecisionsHistory].shift = i;
					decisionsHistory[lenDecisionsHistory].decision = currentDecision;
					lenDecisionsHistory++;
				}
			}
		}

		virtual void ClearDecisionHistory()
		{
			lenDecisionsHistory = 0;
		}

		virtual void CalculateDecisionIntervals()
		{
			if(lenIntervals != 0)
				return;
			if(lenDecisionsHistory == 0)
				CalculateDecisionHistory();

			double _lastDecision = IncertitudeDecision;
			double _currentDecision = IncertitudeDecision;

			for(int i=0;i<lenIntervals;i++)
				for(int j=0;j<lenDecisionsHistory;j++)
				{
					_currentDecision = decisionsHistory[j].decision;
					if(_currentDecision != _lastDecision)
					{
						ArrayResize(intervals,lenIntervals+1);
						intervals[lenIntervals].decision = _currentDecision;
						intervals[lenIntervals].shift = decisionsHistory[j].shift;
						lenIntervals++;
					}
					_lastDecision = _currentDecision;
				}

		}

		virtual void ClearDecisionIntervals()
		{
			lenIntervals = 0;
		}

};
