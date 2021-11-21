#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


// Global context
#include <MyMql\Global\Global.mqh>
#include <MyMql\DecisionMaking\DecisionIndicator.mqh>
#include <MyMql\TransactionManagement\BaseTransactionManagement.mqh>

class PolyMorphicCalcEngine : BaseObject
{
	private:
		bool isIndicatorValue;
		
	public:
		PolyMorphicCalcEngine(GlobalConfig &cfg) { this.isIndicatorValue = cfg.IsIndicator(); }
		
		void InitializeOnce(DecisionIndicator &decision, BaseTransactionManagement &transaction)
		{
			transaction.SetSimulatedOrderObjectName("SimulatedOrderBA");
			transaction.SetSimulatedStopLossObjectName("SimulatedStopLossBA");
			transaction.SetSimulatedTakeProfitObjectName("SimulatedTakeProfitBA");
			
			double spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/Pip();
			transaction.AutoAddTransactionData(spreadPips);
		}
		
		void CalculateAll(DecisionIndicator &decision, BaseTransactionManagement &transaction)
		{
			ScreenInfo screen;
			LimitGenerator generator;
			int i = Bars - 1;
			
			if(isIndicatorValue)
				i -= IndicatorCounted();
			
			double SL = 0.0, TP = 0.0, spread = MarketInfo(Symbol(),MODE_ASK) - MarketInfo(Symbol(),MODE_BID), spreadPips = spread/Pip();
			while(i >= 0)
			{
				double d = decision.GetDecision(i);
				
				if(d > 0) { // Buy
					double price = Close[i] + spread; // Ask
					GlobalContext.Limit.CalculateTP_SL(TP, SL, OP_BUY, price, false, spread, 3*spread, spread);
					generator.ValidateAndFixTPandSL(TP, SL, price, OP_BUY, spread, false);
					
					transaction.SimulateOrderSend(Symbol(), OP_BUY, 0.1, price, 0, SL ,TP, NULL, 0, 0, clrNONE, i);
				} else { // Sell
					double price = Close[i]; // Bid
					GlobalContext.Limit.CalculateTP_SL(TP, SL, OP_SELL, price, false, spread, 3*spread, spread);
					generator.ValidateAndFixTPandSL(TP, SL, price, OP_SELL, spread, false);
					
					transaction.SimulateOrderSend(Symbol(), OP_SELL, 0.1, price, 0, SL, TP, NULL, 0, 0, clrNONE, i);
				}
				
				transaction.CalculateData(i); // do the job that needs to be done
				i--;	
			}
			
			screen.ShowTextValue("CurrentValue", "Number of decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders()),clrGray, 20, 0);
			screen.ShowTextValue("CurrentValueSell", "Number of sell decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_SELL)), clrGray, 20, 20);
			screen.ShowTextValue("CurrentValueBuy", "Number of buy decisions: " + IntegerToString(transaction.GetNumberOfSimulatedOrders(OP_BUY)), clrGray, 20, 40);
			
			double profit;
			int count, countNegative, countPositive;
			
			transaction.GetBestTPandSL(TP, SL, profit, count, countNegative, countPositive);
			string summary = "Best profit: " + DoubleToString(profit,2)
				+ "\nBest Take profit: " + DoubleToString(TP,4) + " (spreadPips * " + DoubleToString(TP/spreadPips,2) + ")" 
				+ "\nBest Stop loss: " + DoubleToString(SL,4) + " (spreadPips * " + DoubleToString(SL/spreadPips,2) + ")"
				+ "\nCount orders: " + IntegerToString(count) + " (" + IntegerToString(countPositive) + " positive orders & " + IntegerToString(countNegative) + " negative orders); Procentual profit: " + DoubleToString((double)countPositive/(count>0?(double)count:1))
				+ "\n\nMaximum profit (sum): " + DoubleToString(transaction.GetTotalMaximumProfitFromOrders(),2)
				+ "\nMinimum profit (sum): " + DoubleToString(transaction.GetTotalMinimumProfitFromOrders(),2)
				+ "\nMedium profit (avg): " + DoubleToString(transaction.GetTotalMediumProfitFromOrders(),2)
				+ "\n\nSpread: " + DoubleToString(spreadPips, 4)
				+ "\nTake profit / Spread (best from average): " + DoubleToString(TP/spreadPips,4)
				+ "\nStop loss / Spread (best from average): " + DoubleToString(SL/spreadPips,4);
			GlobalContext.DatabaseLog.DataLog(decision.GetDecisionName() + " on " + _Symbol, summary);
			//Comment(summary);
		}
};

