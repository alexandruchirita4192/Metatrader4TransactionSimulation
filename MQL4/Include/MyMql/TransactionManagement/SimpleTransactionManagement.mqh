#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\TransactionManagement\BaseTransactionManagement.mqh>

class SimpleTransactionManagement : public BaseTransactionManagement
{
	public:
	   virtual string GetTransactionName() { return typename(this); }
		
		virtual bool ValidateTransactionBeforeRunning(ChartTransactionData &chartTransactionData, double currentDecision)
		{
			return true;
		}
		
		virtual void MakeChangesBasedOnTrend(ChartTransactionData &chartTransactionData)
		{
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
