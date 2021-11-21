#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\Base\BeforeObject.mqh>

struct LimitData
{
	public:
		// SLs and TPs
		double TakeProfit, StopLoss,
			InverseTakeProfit, InverseStopLoss,
			
			TakeProfitPips, StopLossPips;
		
		// implementation of "helpers"
		LimitData() {}
		
		LimitData(const LimitData &limitCopy)
		{
			CopyData(limitCopy);
		}
		
		void CopyData(const LimitData &limitCopy)
		{
			CopyData(
				limitCopy.TakeProfit,
				limitCopy.StopLoss,
				limitCopy.InverseTakeProfit,
				limitCopy.InverseStopLoss,
				limitCopy.TakeProfitPips,
				limitCopy.StopLossPips
			);
		}
		
		void CopyData(
			double takeProfit,
			double stopLoss,
			double inverseTakeProfit,
			double inverseStopLoss,
			double takeProfitPips,
			double stopLossPips)
		{
			TakeProfit = takeProfit;
			StopLoss = stopLoss;
			InverseTakeProfit = inverseTakeProfit;
			TakeProfitPips = takeProfitPips;
			StopLossPips = stopLossPips;
		}
		
		void operator = (const LimitData &limitCopy)
		{
			CopyData(limitCopy);
		}
		
		bool operator == (LimitData &right)
		{
			return ((TakeProfit == right.TakeProfit) &&
				(StopLoss == right.StopLoss) &&
				(InverseTakeProfit == right.InverseTakeProfit) &&
				(InverseStopLoss == right.InverseStopLoss) &&
				(TakeProfitPips == right.TakeProfitPips) &&
				(StopLossPips == right.StopLossPips));
		}
		
		bool operator != (LimitData &right)
		{
			return !(this == right);
		}
		
		void SetEmpty()
		{
			TakeProfit = 0.0;
			StopLoss = 0.0;
			InverseTakeProfit = 0.0;
			InverseStopLoss = 0.0;
			TakeProfitPips = 0.0;
			StopLossPips = 0.0;
		}
		
		bool IsEmpty()
		{
			return 
				((TakeProfit == 0.0) &&
				(StopLoss == 0.0) &&
				(InverseTakeProfit == 0.0) &&
				(InverseStopLoss == 0.0) &&
				(TakeProfitPips == 0.0) &&
				(StopLossPips == 0.0));
		}
};
