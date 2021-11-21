#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\TransactionManagement\BaseTransactionManagement.mqh>

class ConfirmTransactionManagement : public BaseTransactionManagement
{
	public:
		virtual string GetTransactionName() { return typename(this); }
		
		virtual bool ValidateTransactionBeforeRunning(ChartTransactionData &chartTransactionData, double currentDecision)
		{
			if(GlobalContext.Config.GetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions"))
			{
				if((currentDecision < 0.0) && (chartTransactionData.lastDecision < 0.0))
					return false;
				if((currentDecision > 0.0) && (chartTransactionData.lastDecision > 0.0))
					return false;
			}
			
			if((currentDecision != chartTransactionData.lastDecision) || (!(GlobalContext.Config.GetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions"))))
				return false;
			return true;
		}
		
		virtual void MakeChangesBasedOnTrend(ChartTransactionData &chartTransactionData)
		{
			// this moves the last order with the trend
			if(GlobalContext.Config.GetBoolValue("UseOnlyFirstDecisionAndConfirmItWithOtherDecisions"))
				ReCalculateTPsAndSLsForLastOrder();
		}
		
		virtual bool RunTransactionFromOldDecision(int lastDecisionBarShift)
		{
			return (lastDecisionBarShift < 5);
		}
		
		virtual bool ValidateAndFixLimits()
		{
			return true;
		}
		
		virtual void ReplaceLimits(double &takeProfit, double &stopLoss) { }
};
