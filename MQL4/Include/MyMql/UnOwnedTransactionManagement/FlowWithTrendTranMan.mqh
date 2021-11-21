#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/TransactionManagement/BaseTransactionManagement.mqh>
#include <MyMql/Global/Global.mqh>

class FlowWithTrendTranMan : public BaseTransactionManagement
{
	public:
		bool FlowWithTrend_UpdateSL_TP_UsingConstants(double targetSLpips = 50.0, double targetTPpips = 30.0, bool allCharts = false)
		{
			bool statusOk = RefreshRates();
			double targetTP, targetSL;
			
			if ((targetTPpips > 0.0) || (targetSLpips > 0.0))
			{
				for(int i=OrdersTotal()-1; i>=0; i--)
				{
					GlobalContext.Limit.CalculateTP_SL(targetTP, targetSL, targetTPpips, targetSLpips, OrderType(), OrderOpenPrice(), OrderSymbol(), Ask-Bid);
					
					statusOk = statusOk & OrderSelect(i, SELECT_BY_POS);
					if ((OrderSymbol() == Symbol()) || allCharts)
					{
						if ((OrderStopLoss() != targetSL)  && (targetSL != 0.0))
							statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),targetSL,OrderTakeProfit(),0,Blue);
						if ((OrderTakeProfit() != targetTP)  && (targetTP != 0.0))
							statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),targetTP,0,Blue);
					}
				}
			}
			return statusOk;
		}
		
		bool FlowWithTrend_UpdateSL_TP(bool allCharts = false)
		{
			bool statusOk = RefreshRates();
			
			for(int i=OrdersTotal()-1; i>=0; i--)
			{
				statusOk = statusOk & OrderSelect(i, SELECT_BY_POS);
				if((OrderSymbol() == Symbol()) || allCharts)
				{
					ENUM_MARKETINFO mInfo;
					double openPrice = OrderOpenPrice();
					double TPpips, SLpips;
					double TP = OrderTakeProfit();
					double SL = OrderStopLoss();
					double spread = Ask-Bid;
					int orderType = OrderType();
					
					if(orderType == OP_BUY)
						mInfo = MODE_ASK;
					else if(orderType == OP_SELL)
						mInfo = MODE_BID;
					else // not buy nor sell, next then
						continue;
					
					double price = MarketInfo(OrderSymbol(), mInfo);
					
					if((orderType == OP_BUY) && (price < openPrice))
						continue;
					else if((orderType == OP_SELL) && (price > openPrice))
						continue;
					
					
					GlobalContext.Limit.DeCalculateTP_SL(TP, SL, TPpips, SLpips, orderType, OrderOpenPrice(), OrderSymbol(), spread);
					GlobalContext.Limit.CalculateTP_SL(TP, SL, TPpips, SLpips, orderType, price, OrderSymbol(), spread);
					
					if((((orderType == OP_BUY) && (TP > OrderTakeProfit()) && (SL > OrderStopLoss())) ||
					((orderType == OP_SELL) && (TP < OrderTakeProfit()) && (SL < OrderStopLoss()))) &&
					((openPrice != price) && (TP != OrderTakeProfit()) && (SL != OrderStopLoss()) && (TPpips != 0.0) && (SLpips != 0.0)))
						statusOk = statusOk & OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0);
				}
			}
			return statusOk;
		}
};
