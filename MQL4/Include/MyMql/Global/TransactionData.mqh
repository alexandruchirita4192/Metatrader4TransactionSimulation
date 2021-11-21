#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


//#include <MyMql\Base\BeforeObject.mqh>
#include <MyMql\Global\LimitData.mqh>

struct TransactionData
{
	public:
		// TPs & SLs
		LimitData limits;
		
		// Order status
		bool OrderIsClosed,
			OrderClosedByStopLoss,
			OrderClosedByTakeProfit,
			
			InverseOrderIsClosed,
			InverseOrderClosedByStopLoss,
			InverseOrderClosedByTakeProfit;
		
		// Close time & price
		datetime CloseTime, InverseCloseTime;
		double ClosePrice, InverseClosePrice;
		
		double Profit, InverseProfit;
		
		
		TransactionData()
		{
		   SetEmpty();
		}
		
		TransactionData(const TransactionData &transactionData)
		{
			CopyData(transactionData);
		}
		
		void SetEmpty()
		{
		   limits.SetEmpty();
		   
		   OrderIsClosed = false;
		   OrderClosedByStopLoss = false;
		   OrderClosedByTakeProfit = false;
		   InverseOrderIsClosed = false;
		   InverseOrderClosedByStopLoss = false;
		   InverseOrderClosedByTakeProfit = false;
		   // CloseTime
		   // InverseCloseTime
		   ClosePrice = 0.0;
		   InverseClosePrice = 0.0;
		   Profit = 0.0;
		   InverseProfit = 0.0;
		}
		
		void CopyData(const TransactionData &transactionData)
		{
			limits.CopyData(transactionData.limits);
			
			Profit = transactionData.Profit;
			InverseProfit = transactionData.InverseProfit;
			
			OrderIsClosed = transactionData.OrderIsClosed;
			InverseOrderIsClosed = transactionData.InverseOrderIsClosed;
			
			OrderClosedByStopLoss = transactionData.OrderClosedByStopLoss;
			OrderClosedByTakeProfit = transactionData.OrderClosedByTakeProfit;
			InverseOrderClosedByStopLoss = transactionData.InverseOrderClosedByStopLoss;
			InverseOrderClosedByTakeProfit = transactionData.InverseOrderClosedByTakeProfit;
			
			CloseTime = transactionData.CloseTime;
			ClosePrice = transactionData.ClosePrice;
			InverseCloseTime = transactionData.InverseCloseTime;
			InverseClosePrice = transactionData.InverseClosePrice;
		}
		
		void SetLimitData(LimitData &limit)
		{
			limits.CopyData(limit);
		}
		
		string ToString(bool indent = false, int indentLevel = 0) {
			return IndentLevel(indent, indentLevel) + typename(this) + 
			   " { TakeProfit:" + DoubleToString(Normalize(limits.TakeProfit, "TakeProfit")) + 
			   " StopLoss:" + DoubleToString(Normalize(limits.StopLoss, "StopLoss")) + 
			   " ClosePrice:" + DoubleToString(Normalize(ClosePrice, "ClosePrice")) + 
			   " Profit:" + DoubleToString(Normalize(Profit, "Profit")) + 
			   " OrderIsClosed:" + BoolToString(OrderIsClosed) + " }";
		}
		
		string ToStringXml() {
			return "<" + typename(this) +
				" Profit=\"" + DoubleToString(Normalize(Profit, "Profit")) + "\"" + // sometime weird (sometimes zero; sometimes same as InverseProfit with different sign)
				" InverseProfit=\"" + DoubleToString(Normalize(InverseProfit, "InverseProfit")) + "\"" +
				
				" TakeProfit=\"" + DoubleToString(Normalize(limits.TakeProfit, "TakeProfit")) + "\"" +
				" StopLoss=\"" + DoubleToString(Normalize(limits.StopLoss, "StopLoss")) + "\"" +
				" InverseTakeProfit=\"" + DoubleToString(Normalize(limits.InverseTakeProfit, "InverseTakeProfit")) + "\"" +
				" InverseStopLoss=\"" + DoubleToString(Normalize(limits.InverseStopLoss, "InverseStopLoss")) + "\"" +
				
				" TakeProfitPips=\"" + DoubleToString(Normalize(limits.TakeProfitPips, "TakeProfitPips")) + "\"" +
				" StopLossPips=\"" + DoubleToString(Normalize(limits.StopLossPips, "StopLossPips")) + "\"" + // sometimes gets positive and negative for the same TakeProfit and StopLoss
				
				" OrderIsClosed=\"" + BoolToString(OrderIsClosed) + "\"" +
				" InverseOrderIsClosed=\"" + BoolToString(InverseOrderIsClosed) + "\"" +
				" ClosePrice=\"" + DoubleToString(Normalize(ClosePrice, "ClosePrice")) + "\"" +
				" InverseClosePrice=\"" + DoubleToString(Normalize(InverseClosePrice, "InverseClosePrice")) + "\"" +
				" OrderCloseTime=\"" + TimeToString(CloseTime) + "\"" +
				" InverseOrderCloseTime=\"" + TimeToString(InverseCloseTime) + "\"" +
				
				" OrderClosedByStopLoss=\"" + BoolToString(OrderClosedByStopLoss) + "\"" +
				" OrderClosedByTakeProfit=\"" + BoolToString(OrderClosedByTakeProfit) + "\"" +
				" InverseOrderClosedByStopLoss=\"" + BoolToString(InverseOrderClosedByStopLoss) + "\"" +
				" InverseOrderClosedByTakeProfit=\"" + BoolToString(InverseOrderClosedByTakeProfit) + "\"" +
				
				"/>";
		}
};
