#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql\TransactionManagement\BaseTransactionManagement.mqh>

class OrderScalpingData
{
	public:
		int orderTicket, simulatedOrderPosition;
		int positiveTicks, negativeTicks;
		int lastTicksVector[];
		
		OrderScalpingData(int ticket, int simulatedOrderPos)
		{
			orderTicket = ticket;
			simulatedOrderPosition = simulatedOrderPos;
			positiveTicks = 0;
			negativeTicks = 0;
			ArrayResize(lastTicksVector,10);
		}
		
		void AddPositiveTick()
		{
			positiveTicks++;
			lastTicksVector[0] = lastTicksVector[1];
			lastTicksVector[1] = lastTicksVector[2];
			lastTicksVector[2] = lastTicksVector[3];
			lastTicksVector[3] = lastTicksVector[4];
			lastTicksVector[4] = lastTicksVector[5];
			lastTicksVector[5] = lastTicksVector[6];
			lastTicksVector[6] = lastTicksVector[7];
			lastTicksVector[7] = lastTicksVector[8];
			lastTicksVector[8] = lastTicksVector[9];
			lastTicksVector[9] = positiveTicks;
		}
		
		void AddNegativeTick()
		{
			negativeTicks++;
			lastTicksVector[0] = lastTicksVector[1];
			lastTicksVector[1] = lastTicksVector[2];
			lastTicksVector[2] = lastTicksVector[3];
			lastTicksVector[3] = lastTicksVector[4];
			lastTicksVector[4] = lastTicksVector[5];
			lastTicksVector[5] = lastTicksVector[6];
			lastTicksVector[6] = lastTicksVector[7];
			lastTicksVector[7] = lastTicksVector[8];
			lastTicksVector[8] = lastTicksVector[9];
			lastTicksVector[9] = -negativeTicks;
		}
};

class ScalpingTransactionManagement : public BaseTransactionManagement
{
	public:
	   virtual string GetTransactionName() { return typename(this); }
		
		virtual bool ValidateTransactionBeforeRunning(ChartTransactionData &chartTransactionData, double currentDecision)
		{
			return true;
		}
		
		virtual void MakeChangesBasedOnTrend(ChartTransactionData &chartTransactionData) //, bool simulation
		{
			// Scalping strategy (+ recheck TPs & SLs)
			//   - If increases towards wanted price, it's ok
			//   - If positive profit, it's ok
			//   - Negative, wait
			//   - Decreases 3 times on positive profit => get profit
			//   - If one was mostly zero or negative, close with zero (or little profit)
			//   - If negative with no chance of ever being positive / close to zero (check how it ever went) => close negative
			//   (6 ticks going lower?)
			//   - Calculate positive/negative pips too
			//   - Close on profit if profit is big
			
			////if(simulation)
			//for(int i=OrdersTotal()-1; i>=0; i--)
			//	if(!orders[i].Order Is Closed()) // somehow test
			//	if(orders[i].OrderTypeValue == OP_BUY && orders[i].OpenPrice > iClose(chartTransactionData.TranSymbol, chartTransactionData.TimeFrame, 0))
				
			//for(int i=OrdersTotal()-1; i>=0; i--)
			//{
			//	OrderSelect(i, SELECT_BY_POS);
			//	if ((OrderSymbol() == Symbol()) || allCharts)
			//	{
			//		//if ((OrderStopLoss() != targetSL)  && (targetSL != 0.0))
			//		//	statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),targetSL,OrderTakeProfit(),0,Blue);
			//		//if ((OrderTakeProfit() != targetTP)  && (targetTP != 0.0))
			//		//	statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),targetTP,0,Blue);
			//	}
			//}
		}
		
		virtual bool RunTransactionFromOldDecision(int lastDecisionBarShift)
		{
			return false; // scalping gets new orders from fresh decisions (cleaner & better)
		}
		
		virtual bool ValidateAndFixLimits()
		{
			return true;
		}
		
		virtual void ReplaceLimits(double &takeProfit, double &stopLoss)
		{
			//takeProfit = 0.0;
			//stopLoss = 0.0;
		}
};
