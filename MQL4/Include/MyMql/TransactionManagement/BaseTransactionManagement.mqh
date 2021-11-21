#property library
#property copyright "Copyright 2017, Chirita Alexandru"
#property link      ""
#property version   "1.458"
#property strict


#include <MyMql/Simulation/SimulatedOrder.mqh>
#include <MyMql/Global/Money/BaseMoneyManagement.mqh>
#include <MyMql/System/ChartTransactionData.mqh>

// initially named "LimitData"
struct ProfitLimitData
{
	public:
		double TP, SL;
		int count;
		bool irregularLimits;
		int irregularLimitsType;
		int countNegative, countPositive;
		int countInverseNegative, countInversePositive;
		double profit, inverseProfit;
	
	   void SetEmpty()
	   {
	      profit = 0;
		   inverseProfit = 0;
			count = 0;
			countNegative = 0;
			countPositive = 0;
			countInverseNegative = 0;
			countInversePositive = 0;
			irregularLimits = false;
			irregularLimitsType = 0;
	   }
};

class BaseTransactionManagement : public BaseObject {
	private:
		LimitData initializerData[];
		SimulatedOrder orders[];
		int SelectedOrder; // is updated after each SimulateOrderSend
		
	public:
		ProfitLimitData limitDataArray[];
		
		BaseTransactionManagement() {}
		
		virtual string GetTransactionName() { return typename(this); }
		
		virtual double GetOrdersProfit(bool allCharts = false)
		{
			double profitValue = 0.00;
			for(int i=OrdersTotal()-1; i>=0; --i)
			{
#ifdef __MQL4__
            if(!OrderSelect(i, SELECT_BY_POS))
               continue;
#else
			   OrderGetTicket(i);
#endif
				if (allCharts || (OrderGetString(ORDER_SYMBOL) == _Symbol))
					profitValue = profitValue + OrderGetDouble(ORDER_PRICE_CURRENT);
			}
			return profitValue;
		}
		
		virtual bool CloseAllOrders(bool allCharts = false)
		{
			bool statusOk = true;
			for(int i=OrdersTotal()-1; i>=0; --i)
			{
#ifdef __MQL4__
            if(!OrderSelect(i, SELECT_BY_POS))
               continue;
#else
			   OrderGetTicket(i);
#endif

				if (allCharts || (OrderGetString(ORDER_SYMBOL) == _Symbol))
				{
					if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY)
#ifdef __MQL4__
						statusOk = statusOk & OrderClose(OrderTicket(),OrderLots(),SymbolInfoDouble(OrderSymbol(), SYMBOL_BID),3,Yellow);
					else
						statusOk = statusOk & OrderClose(OrderTicket(),OrderLots(),SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK),3,Yellow);
#else
               {
                  Print(__FUNCSIG__ + " is incomplete for MT5 - OrderClose issue"); // to do: mt5: OrderClose();
               }
               else
               {
                  Print(__FUNCSIG__ + " is incomplete for MT5 - OrderClose issue"); // to do: mt5: OrderClose();
               }
#endif
				}
	      }
			return statusOk; // true if all orders closed, false if even one couldn't be closed
		}
		
		virtual void TestCloseProfit(bool allCharts = false) { if(GetOrdersProfit(allCharts) >= 0) CloseAllOrders(allCharts); }
		
		virtual bool ModifyOrders(double targetTP, double targetSL, bool allCharts = false)
		{
			bool statusOk = true;
			
			if ((targetTP > 0) || (targetSL > 0))
			{
				for(int i=OrdersTotal()-1; i>=0; i--)
				{
#ifdef __MQL4__
					statusOk = statusOk & OrderSelect(i, SELECT_BY_POS);
#else
			      OrderGetTicket(i);
#endif

					if (allCharts || (OrderGetString(ORDER_SYMBOL) == _Symbol))
					{
#ifdef __MQL4__
						if ((OrderStopLoss() != targetSL)  && (targetSL != 0.0))
							statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),targetSL,OrderTakeProfit(),0,Blue);
#else
      			   Print(__FUNCSIG__ + " is incomplete for MT5 -- OrderStopLoss, OrderModify issue"); // to do: order modify
#endif
                     
#ifdef __MQL4__
						if ((OrderTakeProfit() != targetTP)  && (targetTP != 0.0))
							statusOk = statusOk & OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),targetTP,0,Blue);
#else
   			      Print(__FUNCSIG__ + " is incomplete for MT5 -- OrderTakeProfit, OrderModify issue"); // to do: order modify
#endif
					}
				}
			}
			return statusOk;
		}
		
		virtual int SimulateOrderSend(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment = NULL, int magic = 0, datetime expiration = 0, color arrow_color = clrNONE, int shift = 0, int ticket = 0)
		{
			int len = ArraySize(orders);
			SelectedOrder = len;
			
			ArrayResize(orders, len + 1);
			orders[len].SetSimulatedOrderObjectName();
			orders[len].SetSimulatedTransactionWhole();
			orders[len].SetSimulatedStopLossObjectName();
			orders[len].SetSimulatedTakeProfitObjectName();
			
			if((cmd != OP_BUY) &&
			(cmd != OP_SELL) &&
			(cmd != OP_BUYLIMIT) &&
			(cmd != OP_SELLLIMIT) &&
			(cmd != OP_BUYSTOP) &&
			(cmd != OP_SELLSTOP))
			{
				string message = __FUNCTION__ + " Weird " + __FUNCTION__ + " call, with cmd=" + IntegerToString(cmd) + " in file " + __FILE__;
				if(IsVerboseMode()) Print(message);
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
					GlobalContext.Config.GetSessionName(),
					message,
					TimeAsParameter());
				
				return -1;
			}
			
			if ((takeprofit != 0.0) || (stoploss != 0.0))
			{
				LimitData limit;
				limit.SetEmpty(); // clean data just in case..
				limit.TakeProfit = takeprofit;
				limit.StopLoss = stoploss;
				
				GlobalContext.Limit.FillLimitDataStructure(limit, symbol, PERIOD_CURRENT, cmd, iTime(symbol, PERIOD_CURRENT, shift), 0, 0, 0);
				
				orders[len].AddTransactionData(limit);
			}
			
			for(int i=0;i<ArraySize(initializerData);i++)
			{
				LimitData limit;
				limit.CopyData(initializerData[i]);
				GlobalContext.Limit.FillLimitDataStructure(limit, orders[len].OrderSymbolValue, PERIOD_CURRENT, orders[len].OrderTypeValue, orders[len].OpenTime, orders[len].OpenPrice, orders[len].InverseOpenPrice, Spread(orders[len].OrderSymbolValue));
				orders[len].AddTransactionData(limit);
			}
			
			return orders[len].SimulateOrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color, shift, ticket);
		}
		
		virtual void ReCalculateTPsAndSLsForLastOrder()
		{
			int len = ArraySize(orders);
			if(len-1 < 0)
				return;
			
			int tranDataLen = orders[len-1].GetTransactionDataSize();
			for(int i=0;i<tranDataLen;i++)
			{
				LimitData data = orders[len-1].GetLimitData(i);
				 
   		   if (data.TakeProfit > 9999999)
   		      SafePrintString(__FUNCSIG__ + " The TP price is invalid [1] " + DoubleToStr(data.TakeProfit), true);
				if (data.StopLoss > 9999999)
   		      SafePrintString(__FUNCSIG__ + " The SL price is invalid [1] " + DoubleToStr(data.StopLoss), true);
				
				GlobalContext.Limit.CalculateTP_SL(data.TakeProfit, data.StopLoss, data.TakeProfitPips, data.StopLossPips, orders[len-1].OrderTypeValue, orders[len-1].OpenPrice, orders[len-1].OrderSymbolValue, 0.0);
				
				if (data.TakeProfit > 9999999)
   		      SafePrintString(__FUNCSIG__ + " The TP price is invalid [2] " + DoubleToStr(data.TakeProfit), true);
				if (data.StopLoss > 9999999)
   		      SafePrintString(__FUNCSIG__ + " The SL price is invalid [2] " + DoubleToStr(data.StopLoss), true);
				
				orders[len-1].SetLimits(data.TakeProfit, data.StopLoss, i);
			}
		}
		
		virtual bool SimulateOrderModify(int ticket, double price, double stoploss, double takeprofit, datetime expiration, color arrow_color, int shift = 0)
		{
			return orders[SelectedOrder].SimulateOrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color, shift);
		}
		
		virtual int GetNumberOfSimulatedOrders(int orderType = -1)
		{
			if(orderType == -1)
				return ArraySize(orders);
			
			int nr = 0;
			for(int i=0;i<ArraySize(orders);i++)
				if((orders[i].OrderTypeValue == orderType) || (orderType == -1))
					nr++;
			return nr;
		}
		
		virtual SimulatedOrder GetSelectedSimulatedOrder()
		{
			if(SelectedOrder < ArraySize(orders))
				return orders[SelectedOrder];
			
			string message = __FUNCTION__ + " Accessing invalid selected order in file " + __FILE__;
			if(IsVerboseMode()) Print(message);
			GlobalContext.DatabaseLog.BulkParametersSet("BulkDebugLog",
				GlobalContext.Config.GetSessionName(),
				message,
				TimeAsParameter());
			
			return orders[0]; // hoping we won't get there, but.. fuck if happens
		}
		
		virtual void CalculateDataFinal(int shift = 0)
		{
			InternalCalculateData(shift);
		}
		
		/*
		 * This is the base calculation method.
		 * All the overrides should call "InternalCalculateData" that does the stuff that needs to be done!!
		 */
		virtual bool CalculateData(int shift = 0)
		{
			return InternalCalculateData(shift);
		}
		
		virtual void LightSystemCalculation()
		{
			int len = ArraySize(orders);
			
			for(int i=0; i<len; i++)
			{
				int lastOrderType = orders[i].OrderTypeValue;
				int positionCloseUntil = 0;
				
				for(int j=i+1;j<len;j++)
				{
					int currentOrderType = orders[j].OrderTypeValue;
					
					if(((lastOrderType == OP_BUY) && (currentOrderType == OP_SELL)) ||
					((lastOrderType == OP_SELL) && (currentOrderType == OP_BUY)))
					{
						positionCloseUntil = j;
						break;
					}
				}
				
				if(positionCloseUntil == 0)
					len = positionCloseUntil;
					
				for(int j=i;j<positionCloseUntil;j++)
				{
					// calculate potential close price only once per bar, damn it
					double closePriceBid = 0.0; // ClosePrice for Buy is Bid (Close/Open/Low/High)
					double closePriceAsk = 0.0; // ClosePrice for Sell is Ask (Close/Open/Low/High + Spread)
					
					datetime closeTime = orders[positionCloseUntil].OpenTime; // TODO: Check wtf is this??
					int closeOrderTypeValue = orders[i].OrderTypeValue;
					
					int shift = iBarShift(_Symbol,PERIOD_CURRENT,closeTime);
					GetAskAndBid(closePriceAsk, closePriceBid, 0, _Symbol, shift);
					
					double closePrice = orders[i].OrderTypeValue == OP_BUY ? closePriceBid : closePriceAsk;
					double inverseClosePrice = orders[i].OrderTypeValue == OP_BUY ? closePriceAsk : closePriceBid;
					
					orders[i].SimulatedOrderCloseUpdateAll(closeTime, closeOrderTypeValue, closePrice, inverseClosePrice);
				}
				
				i = positionCloseUntil;
			}
		}
		
		virtual void GetAskAndBid(double &ask, double &bid, int type, string symbol, int shift)
		{
			switch(type)
			{
				case 0:
					bid = iOpen(symbol, 0, shift);
					break;
				case 1:
					bid = iLow(symbol, 0, shift);
					break;
				case 2:
					bid = iHigh(symbol, 0, shift);
					break;
				
				case 3:
				default:
					bid = iClose(symbol, 0, shift);
					break;
			};
			ask = bid + Spread(symbol);
		}
		
		
		/*
		 * Here comes all the important stuff (calculation)
		 */
		virtual bool InternalCalculateData(int shift = 0, bool isFinal = false)
		{
			datetime shiftedTime = iTime(_Symbol, _Period, shift);
			int len = ArraySize(orders);
			
			// calculate potential close price only once per bar, damn it
			double closePriceBid = 0.0; // ClosePrice for Buy is Bid (Close/Open/Low/High)
			double closePriceAsk = 0.0; // ClosePrice for Sell is Ask (Close/Open/Low/High + Spread)
			
			for(int type=0;type<3;type++) // skip "iClose"; iOpen->iLow->iHigh are enough
			{
				GetAskAndBid(closePriceAsk, closePriceBid, type, _Symbol, shift);
				
				if(isFinal)
				{
					for(int i=0; i<len; i++)
						orders[i].SimulatedOrderCloseUpdateAll(
							shiftedTime,
							orders[i].OrderTypeValue,
							orders[i].OrderTypeValue == OP_BUY ? closePriceBid : closePriceAsk, 
							orders[i].OrderTypeValue == OP_BUY ? closePriceAsk : closePriceBid
						);
					
					return true;
				}
				else
				{
					bool allOrdersAreCompletelyClosed = true;
					for(int i=0; i<len; i++)
						allOrdersAreCompletelyClosed = allOrdersAreCompletelyClosed && orders[i].SimulatedOrderProfitInternalUpdateAll(shiftedTime, orders[i].OrderTypeValue == OP_BUY ? closePriceBid : closePriceAsk, orders[i].OrderTypeValue == OP_BUY ? closePriceAsk : closePriceBid);
					return allOrdersAreCompletelyClosed;
				}
				
				//// if calculation is in the present, do the final data calculation
				//if(shift == 0)
				//	FinalDataCalculation();
			}
			
			return false;
		}
		
		virtual bool ValidateTransactionBeforeRunning(ChartTransactionData &chartTransactionData, double currentDecision)
		{
			return false;
		}
		
		virtual void MakeChangesBasedOnTrend(ChartTransactionData &chartTransactionData) { }
		
		virtual bool RunTransactionFromOldDecision(int lastDecisionBarShift)
		{
			return false;
		}
		
		virtual bool ValidateAndFixLimits()
		{
			return true;
		}
		
		virtual void ReplaceLimits(double &takeProfit, double &stopLoss) { }
		
		//virtual void FinalDataCalculation()
		//{
		//	int len = ArraySize(orders);
		//	for(int i=0; i<len; i++)
		//		orders[i].CalculateProfitFromTransactionData();
		//}
		
//		virtual double GetTotalMaximumProfitFromOrders()
//		{
//			double profit = 0.0;
//			int lenOrders = ArraySize(orders);
//			for(int i=0;i<lenOrders;i++)
//			{
//				orders[i].AutoCalculateProfitFromTransactionData();
//				profit += orders[i].GetMaximumProfit();
//			}
//			return profit;
//		}
//		
//		virtual double GetTotalMinimumProfitFromOrders()
//		{
//			double profit = 0.0;
//			int lenOrders = ArraySize(orders);
//			for(int i=0;i<lenOrders;i++)
//			{
//				orders[i].AutoCalculateProfitFromTransactionData();
//				profit += orders[i].GetMinimumProfit();
//			}
//			return profit;
//		}
//		
//		virtual double GetTotalMediumProfitFromOrders()
//		{
//			double profit = 0.0;
//			int lenOrders = ArraySize(orders);
//			for(int i=0;i<lenOrders;i++)
//			{
//				orders[i].AutoCalculateProfitFromTransactionData();
//				profit += orders[i].GetMediumProfit();
//			}
//			return profit;
//		}
		
//		virtual void GetWeirdBestTPandSL(double &TP, double &SL)
//		{
//			int lenOrders = ArraySize(orders), nrOrders;
//			TP = 0.0;
//			SL = 0.0;
//			nrOrders = 0;
//			
//			for(int i=0;i<lenOrders;i++)
//			{
//				double stopLossPips, takeProfitPips;
//				money.DeCalculateTP_SL(orders[i].GetBestTakeProfit(), orders[i].GetBestStopLoss(), takeProfitPips, stopLossPips, orders[i].GetOrderTypeName(), orders[i].GetOrderOpenPrice(), false, 0.0);
//				//printf("takeProfitPips=%f stopLossPips=%f bestTP=%f bestSL=%f orderType=%d openPrice=%f", takeProfitPips, stopLossPips, orders[i].GetBestTakeProfit(), orders[i].GetBestStopLoss(), orders[i].GetOrderTypeName(), orders[i].GetOrderOpenPrice());
//				
//				TP += takeProfitPips;
//				SL += stopLossPips;
//				if((stopLossPips != 0.0) && (takeProfitPips != 0.0))
//					nrOrders++;
//				
//			}
//			
//			if(nrOrders != 0)
//			{
//				TP = TP / ((double)nrOrders);
//				SL = SL / ((double)nrOrders);
//			}
//		}
		
		virtual void GetBestTPandSL(
			double &TP, double &SL,
			double &Profit, double &InverseProfit,
			int &count,
			int &countNegative, int &countPositive,
			int &countInverseNegative, int &countInversePositive,
			bool &IsInverseDecision)
		{
			count = 0;
			Profit = 0;
			InverseProfit = 0;
			int lenOrders = ArraySize(orders), lenArray = ArraySize(limitDataArray), index = 0;
			
			for(int k=0;k<lenArray;k++)
			{
				limitDataArray[k].SetEmpty();
			}
			
			if(ArraySize(limitDataArray) <= index) {
				ArrayResize(limitDataArray,index+1);
				lenArray = ArraySize(limitDataArray);
			}
			
			for(int i=0;i<lenOrders;i++)
			{
				for(int j=0;j<orders[i].GetTransactionDataSize();j++)
				{
					TransactionData data = orders[i].GetTransactionData(j); // need profit stuff too
					double takeProfit = data.limits.TakeProfitPips;
					double stopLoss = data.limits.StopLossPips;
					double profit = data.Profit;
					double inverseProfit = data.InverseProfit;
					
					if(GlobalContext.Config.GetBoolValue("GetBestTPandSLPrintZeroProfit") && ((profit == 0.0) || (inverseProfit == 0.0)))
						Print("Profit = " + DoubleToString(profit,2) + " InverseProfit = " + DoubleToString(inverseProfit,2));
					
					// parse limitDataArray of limits data
					bool found = false;
					for(int k=0;k<lenArray;k++)
					{
						// compare SLs and TPs only for constant SLs & TPs (for irregular SLs & TPs work anyway)
						if((limitDataArray[k].SL == stopLoss) && (limitDataArray[k].TP == takeProfit))
						{
							found = true;
							limitDataArray[k].count++;
							limitDataArray[k].profit += profit;
							limitDataArray[k].inverseProfit += inverseProfit;
							
							if(profit < 0.0)
   							limitDataArray[k].countNegative++;
   						else
   							limitDataArray[k].countPositive++;
   						
							if(inverseProfit < 0.0)
   							limitDataArray[k].countInverseNegative++;
   						else
   							limitDataArray[k].countInversePositive++;
						}
					}
					
					// if values not in current in limitDataArray limits data, then add
					if(!found)
					{
						index++;
						if(ArraySize(limitDataArray) <= index) {
							ArrayResize(limitDataArray,index+1);
							lenArray = ArraySize(limitDataArray);
						}
						
						limitDataArray[lenArray-1].SL = stopLoss;
						limitDataArray[lenArray-1].TP = takeProfit;
						limitDataArray[lenArray-1].profit = profit;
						limitDataArray[lenArray-1].inverseProfit = inverseProfit;
						limitDataArray[lenArray-1].count = 1;
						limitDataArray[lenArray-1].countNegative = 0;
						limitDataArray[lenArray-1].countPositive = 0;
						limitDataArray[lenArray-1].countInverseNegative = 0;
						limitDataArray[lenArray-1].countInversePositive = 0;
						
						if(profit < 0.0)
							limitDataArray[lenArray-1].countNegative++;
						else
							limitDataArray[lenArray-1].countPositive++;
						
						if(inverseProfit < 0.0)
							limitDataArray[lenArray-1].countInverseNegative++;
						else
							limitDataArray[lenArray-1].countInversePositive++;
					}
				}
			}
			
			// Get max profit & best limits (TP & SL)
			Profit = limitDataArray[0].profit;
			InverseProfit = limitDataArray[0].inverseProfit;
			TP = limitDataArray[0].TP;
			SL = limitDataArray[0].SL;
			count = limitDataArray[0].count;
			IsInverseDecision = false;
			
			for(int k=1;k<lenArray;k++)
			{
				if(limitDataArray[k].profit > Profit)
				{
					Profit = limitDataArray[k].profit;
					TP = limitDataArray[k].TP;
					SL = limitDataArray[k].SL;
					count = limitDataArray[k].count;
					countNegative = limitDataArray[k].countNegative;
					countPositive = limitDataArray[k].countPositive;
					countInverseNegative = limitDataArray[k].countInverseNegative;
					countInversePositive = limitDataArray[k].countInversePositive;
					IsInverseDecision = false;
				}
				
				if(limitDataArray[k].inverseProfit > Profit)
				{
					Profit = limitDataArray[k].inverseProfit;
					TP = limitDataArray[k].TP;
					SL = limitDataArray[k].SL;
					count = limitDataArray[k].count;
					countNegative = limitDataArray[k].countInverseNegative;
					countPositive = limitDataArray[k].countInversePositive;
					countInverseNegative = limitDataArray[k].countNegative;
					countInversePositive = limitDataArray[k].countPositive;
					IsInverseDecision = true;
				}
			}
		}
		
		virtual void AddInitializerTransactionData(LimitData &data)
		{
			int newLen = ArraySize(initializerData) + 1;
			ArrayResize(initializerData, newLen);
			
			initializerData[newLen-1].CopyData(data);
		}
		
		virtual void AddInitializerTransactionData(double TakeProfitPips, double StopLossPips)
		{
			int newLen = ArraySize(initializerData) + 1;
			ArrayResize(initializerData, newLen);
			
			initializerData[newLen-1].SetEmpty(); // at least cleanup before..
			initializerData[newLen-1].TakeProfitPips = TakeProfitPips;
			initializerData[newLen-1].StopLossPips = StopLossPips;
		}
		
		virtual void AutoAddTransactionData(LimitData &limitData[])
		{
			ArrayResize(initializerData, ArraySize(limitData));
			for(int i=0;i<ArraySize(limitData);i++)
				initializerData[i].CopyData(limitData[i]);
		}
		
		virtual void AutoAddTransactionData(double spreadPips)
		{
			// MA transaction added, at some time
			AddInitializerTransactionData(2.6*spreadPips, 2.60*spreadPips);
			AddInitializerTransactionData(2.6*spreadPips, 1.10*spreadPips);
			//AddInitializerTransactionData(2.6*spreadPips, 1.88*spreadPips);
			//AddInitializerTransactionData(3.0*spreadPips, 2.60*spreadPips);
			//AddInitializerTransactionData(2.6*spreadPips, 0.30*spreadPips);
			//AddInitializerTransactionData(2.6*spreadPips, 0.10*spreadPips); 
			//AddInitializerTransactionData(2.6*spreadPips, 1.53*spreadPips);
			//AddInitializerTransactionData(2.6*spreadPips, 1.83*spreadPips);
			//AddInitializerTransactionData(2.6*spreadPips, 2.20*spreadPips);
			// maybe best 3MA & BB? (at one time)
			AddInitializerTransactionData(2.6*spreadPips, 1.6*spreadPips);
			
			// RSI transaction added, at some time
			AddInitializerTransactionData(8.0*spreadPips, 21.0*spreadPips);
			// maybe best RSI? (at one time)
			AddInitializerTransactionData(8.0*spreadPips, 13.0*spreadPips);
			
			////// BB doesn't need shit, but it can be tested
			////AddInitializerTransactionData(0.5*spreadPips, 0.5*spreadPips, false, 0);
			////AddInitializerTransactionData(0.2*spreadPips, 0.2*spreadPips, false, 0);
		}
		
		virtual void FullSimulateOrderSend(string symbol, ENUM_TIMEFRAMES timeFrame, int timeShift, double currentDecision, double currentLots, double TP, double SL, bool validateAndFixLimits)
		{
			if(StringIsNullOrEmpty(symbol))
				symbol = _Symbol;
			if(timeFrame == PERIOD_CURRENT)
				timeFrame = IntegerToTimeFrame(_Period);
			
			// Simulate order (and send order, for EA)
			int tranInternalDataIndex = 0;
			int orderType = GetOrderTypeBasedOnDecision(currentDecision);
			double price = GetOrderOpenPrice(symbol, timeFrame, orderType, timeShift);
			
			if(validateAndFixLimits)
				GlobalContext.Limit.ValidateAndFixTPandSL(TP, SL, price, orderType, Spread(symbol), false);
			SimulateOrderSend(symbol, orderType, currentLots, price, 0, SL, TP, NULL, 0, 0, clrNONE, timeShift, 0);
		}
		
		virtual int GetOrdersCount() { return ArraySize(orders); }
		
		virtual void CleanAll(bool keepAllObjects = false) {
			ArrayResize(initializerData,0,0);
			ArrayResize(orders,0,0);
			ArrayResize(limitDataArray,0,0);
			
			if(!keepAllObjects)
				ObjectsDeleteAll(ChartID());
		}
		
		virtual string ToString()
		{
			string retString = typename(this) + " { ";
			
			retString += "initializerData:" + IntegerToString(ArraySize(initializerData)) + " ";
			retString += "orders:" + IntegerToString(ArraySize(orders)) + " ";
			retString += "SelectedOrder:" + IntegerToString(SelectedOrder) + " ";
			retString += "money:" + GlobalContext.Money.ToString() + " ";
			
			retString += "} ";
			return retString;
		}
		
		virtual void LogAllOrders()
		{
			int lenOrders = ArraySize(orders);
			
			if(lenOrders == 0)
				return;
			
			for(int i=0;i<lenOrders-1;i++)
			{
				GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), "Order[" + IntegerToString(i) + "]", orders[i].ToStringOrderMinimalNeededData());
				GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLogDetail");
			}
		}
		
		virtual void LogAllOrdersXml()
		{
			int lenOrders = ArraySize(orders);
			if(lenOrders == 0)
				return;
			
			for(int i=0;i<lenOrders-1;i++)
			{
				GlobalContext.DatabaseLog.ParametersSet(GlobalContext.Config.GetConfigFile(), "Order[" + IntegerToString(i) + "]", orders[i].ToStringOrderMinimalNeededDataXml());
				GlobalContext.DatabaseLog.CallWebServiceProcedure("DataLogDetail");
			}
		}
		
		virtual void BulkLogAllOrdersXml()
		{
			int lenOrders = ArraySize(orders);
			if(lenOrders == 0)
				return;
			
			for(int i=0;i<lenOrders-1;i++)
				GlobalContext.DatabaseLog.BulkParametersSet("BulkDataLogDetail", GlobalContext.Config.GetConfigFile(), "Order[" + IntegerToString(i) + "]", orders[i].ToStringOrderMinimalNeededDataXml());
			GlobalContext.DatabaseLog.CallBulkWebServiceProcedure("BulkDataLogDetail", true);
		}
		
		virtual string OrdersToString(bool indent = false, int indentLevel = 0)
		{
			int lenOrders = ArraySize(orders);
			
			if(lenOrders == 0)
				return "";
				
			string retString = IndentLevel(indent, indentLevel) + typename(this) + " { ";
			indentLevel++;
			
			retString += IndentLevel(indent, indentLevel) + "orders<" + typename(orders) + ">:" + IntegerToString(ArraySize(orders)) + "{ ";
			indentLevel++;
			
			for(int i=0;i<lenOrders-1;i++)
				retString += IndentLevel(indent, indentLevel) + orders[i].ToStringOrderMinimalNeededData(indent, indentLevel) + ", ";
		
			if(lenOrders - 1 > 0)
			{
				retString += IndentLevel(indent, indentLevel) + orders[lenOrders-1].ToStringOrderMinimalNeededData(indent, indentLevel);
				indentLevel--;
				retString += IndentLevel(indent, indentLevel) + " } ";
			}
			
			indentLevel--;
			retString += IndentLevel(indent, indentLevel) + "} ";
			return retString;
		}
};
