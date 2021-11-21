#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\LotManagement\BaseLotManagement.mqh>

class BetOnDecisionLotManagement : BaseLotManagement
{
	public:
		string GetLotName() { return typename(this); }
		
		virtual double GetLotsBasedOnDecision(string symbol, double currentDecision, double maxDecision)
		{
			double maxLots = GetMaximumLotsWithAvailableFreeMargin(symbol);
			
			// this is only a way of bypassing an error that stops the simulation (later the lot is validated with ValidateLot)
			if(maxDecision == 0)
			{
				maxDecision = MarketInfo(symbol, MODE_MINLOT); // we assume minlot is enough for our margin; this might blow everything up!!!
				string message = __FUNCTION__ + " Error: divide by zero avoidance: maxDecision=0.0 and it's changed to maxDecision=MinLot!! Beware!! MinLot might be too much (we might not have enough margin)!!";
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
			}
			
			double lotsForCurrentDecision = maxLots * (currentDecision / maxDecision);
			double LotStep = GetLotsStep(symbol);
			lotsForCurrentDecision = NormalizeDouble(lotsForCurrentDecision/LotStep,0) * LotStep;
			return ValidateLot(symbol, lotsForCurrentDecision);
		}
};